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
        vim \
        xz-utils \
        gcc \
        make \
        autoconf \
        python3 \
        python3-distutils \
        python3-dev \
        python3-pip \
        flex \
        bison \
        libssl-dev \
        build-essential \
        libtool

RUN pip install python-config pyyaml packaging numpy matplotlib

# install tzdata before the next package set
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Chicago apt-get -y install tzdata

# packages that need to be installed after tzdata is properly installed
RUN apt-get install -y \
        mpich libmpich-dev \
        openmpi-bin libopenmpi-dev \
        pkg-config

RUN pip install --upgrade cmake

# RUN cmake --version

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

COPY hdf5-1_13_2.tar.gz /home/software/temp

# build hdf5 and install in /home/software/hdf5
RUN mkdir /home/software/hdf5 && \
    cd /home/software/temp && \
    tar -xvf hdf5-1_13_2.tar.gz && \
    cd hdf5-hdf5-1_13_2 && \
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
ENV PYTHONPATH /home/multiphysics/cardinal/contrib/moose/python:${PYTHONPATH}

# build PETSc and libMesh, okay if PETSc tests fail
RUN ./contrib/moose/scripts/update_and_rebuild_petsc.sh && \
    ./contrib/moose/scripts/update_and_rebuild_libmesh.sh

# Obtain Makefile and build
COPY Makefile /home/multiphysics/cardinal/
RUN make -j8

# install OpenMC python API
RUN cd contrib/openmc && \
    pip install .

# Set environment variables so tests can run
# NEEDS MOOSE_DIR to run tests
ENV MOOSE_DIR /home/multiphysics/cardinal/contrib/moose
# tests seem to run with or with out the PETSC_DIR
ENV PETSC_DIR /home/multiphysics/cardinal/contrib/moose/petsc/
# DO NOT SET LIBMESH_DIR, it causes the tests not to run
ENV OPENMC_CROSS_SECTIONS /home/multiphysics/cross_sections/endfb-vii.1-hdf5/cross_sections.xml

# Run tests best to do in interactive to see output
# RUN ./run_tests -j8