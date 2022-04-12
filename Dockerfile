# This Dockerfile builds, installs, and tests Cardinal in a clean environment
FROM ubuntu:20.04

# Add non root user to system
RUN useradd -s /bin/bash multiphysics

## Commands that need to be run from root
# install software where apt-get is sufficient as root user
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        git \
        wget \
        xz-utils \
        gcc \
        make \
        python3 \
        python3-distutils \
        python3-dev \
        python3-pip \
        flex \
        bison

RUN pip install python-config

# install tzdata before the next package set
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Chicago apt-get -y install tzdata

# packages that need to be installed after tzdata is properly installed
RUN apt-get install -y \
        mpich libmpich-dev \
        openmpi-bin libopenmpi-dev \
        cmake \
        pkg-config

# set alternative so that python runs python 3 code without installing python 2 
# the arguments are as follows:
# RUN update-alternatives --install </path/to/alternative> <name> </path/to/source> <priority>
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3 99

# create directorries needed for data, dependencies, and cloning cardinal
RUN mkdir /home/software && \
    mkdir /home/software/temp && \
    mkdir /home/multiphysics && \
    mkdir /home/multiphysics/cross_sections

# Make multiphysics the owner of /home/multiphysics and /home/softawre to avoid permisisons issues
RUN chown -R multiphysics /home/multiphysics
RUN chown -R multiphysics /home/software

## Change user so that non-root user is running MPI
USER multiphysics

RUN cd /home/multiphysics && \
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
ENV FC mpif90
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
ENV HDF5_ROOT /home/software/hdf5
ENV HDF5_INCLUDE_DIR /home/software/hdf5/include
ENV HDF5_LIBDIR /home/software/hdf5/lib
ENV METHOD opt

# Set OCCA backend
ENV NEKRS_OCCA_MODE_DEFAULT CPU

# Add python path
ENV PYTHONPATH /home/multiphysics/cardinal/contrib/moose/python:{$PYTHONPATH}

# build PETSc and libMesh, okay if PETSc tests fail
RUN ./contrib/moose/scripts/update_and_rebuild_petsc.sh && \
    ./contrib/moose/scripts/update_and_rebuild_libmesh.sh

# See environemnt before make
RUN env | sort >> before_make.txt

# Obtain Makefile and build
COPY Makefile /home/multiphysics/cardinal/
RUN make -j8

# Remove files not needed to run cardrinal. reduces image size, push/pull time
RUN rm -rf /home/simulator/temp
# TODO potentiatlly remove build directory and other compliation outputs 

# Set environment variables so tests can run
# NEEDS MOOSE_DIR to run tests
ENV MOOSE_DIR /home/multiphysics/cardinal/contrib/moose
# tests seem to run with or with out the PETSC_DIR
# ENV PETSC_DIR /home/multiphysics/cardinal/contrib/moose/petsc/
# when either of the two are commented in, the tests dont run. when they are commented out. the tests run
# ENV LIBMESH_DIR /home/multiphysics/cardinal/contrib/moose/libmesh/
# ENV LIBMESH_DIR /home/multiphysics/cardinal/contrib/moose/libmesh/installed/bin

# See environemnt before running tests
RUN env | sort >> before_tests.txt

# # Run tests
# RUN touch test_output
# RUN ./run_tests 1>> one_thread_output.txt 2>> one_thread_error.txt
RUN ./run_tests 1>> one_thread_output.txt 2>> one_thread_error.txt