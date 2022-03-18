# This Dockerfile builds, installs, and tests Cardinal in a clean environment

FROM ubuntu:20.04

RUN useradd ligross

# install software where apt-get is sufficient
#TODO apt or apt-get? seems to be fine w apt get but internet says use apt
RUN apt-get update && \
    apt-get install -y \
        git \
        wget \
        xz-utils \
        gcc \
        make

# to prevent prompt during build of mpich
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Chicago apt-get -y install tzdata

# need mpicc and openmpi for OpenMC/HDF5
RUN apt-get install -y \
        mpich libmpich-dev \
        openmpi-bin libopenmpi-dev
#TODO can i combine all the above runs?

# create directorries needed for data, dependencies and cloning cardinal
RUN mkdir /home/multiphysics && \
    mkdir /home/software && \
    mkdir /home/software/temp && \
    mkdir /home/multiphysics/cross_sections && \
    cd /home/multiphysics && \
    git clone https://github.com/neams-th-coe/cardinal.git

# set the working directory so dependencies can be obtained via get-dependencies.sh
WORKDIR /home/multiphysics/cardinal

#get dependencies
RUN bash ./scripts/get-dependencies.sh

# obtain and unpack cross sections from ANL Box
RUN wget -q -O - https://anl.box.com/shared/static/9igk353zpy8fn9ttvtrqgzvw1vtejoz6.xz | tar -C ../cross_sections -xJ

# Set Environment Variables
ENV NEKRS_HOME /home/multiphysics/cardinal/install
ENV CC mpicc
ENV CXX mpicxx
ENV FC mipf90
ENV OPENMC_CROSS_SECTIONS /home/multiphysics/cross_sections/endfb71_hdf5/cross_sections.xml

# build hdf5 and install in /home/software/hdf5
# TODO --enable-cxx or --enable-parallel
RUN mkdir /home/software/hdf5 && \
    cd /home/software/temp && \
    wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.13/hdf5-1.13.1/src/hdf5-1.13.1.tar.gz && \
    tar -xvf hdf5-1.13.1.tar.gz && \
    cd hdf5-1.13.1 && \
    mkdir build && \
    cd build && \
    ../configure --prefix="/home/software/hdf5" --enable-optimization=high --enable-shared  --enable-hl --enable-build-mode=production --enable-parallel && \
    make -j8 && \
    make install && \
    rm -rf /home/software/temp/* 

# HDF5 env vars
# ENV HDF5_ROOT /home/software/hdf5
# ENV HDF5_INCLUDE_DIR /home/software/hdf5/include
# ENV HDF5_LIBDIR /home/software/hdf5/lib
# ENV METHOD opt

# Set OCCA backend
# ENV NEKRS_OCCA_MODE_DEFAULT CPU

# TODO delete after successul hdf5 build
# RUN h5ls --version && \
#     find . -name "hdf5.h"

# build PETSc and libMesh, okay if PETSc tests fail
# RUN bash ./contrib/moose/scripts/update_and_rebuild_petsc.sh && \
#     bash ./contrib/moose/scripts/update_and_rebuild_libmesh.sh

# # Obtain Makefile
# COPY Makefile /home/multiphysics/cardinal/
# RUN make -j8

# remove temp directory used to handle build of dependencies
# RUN rm -rf /home/simulator/temp
# TODO potentiatlly remove build directory and other compliation outputs that 
# aren't needed to run cardrinal, reduce image size, push/pull time