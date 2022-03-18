# This Dockerfile builds, installs, and tests Cardinal in a clean environment

FROM ubuntu:20.04

RUN useradd ligross

# get software where apt-get is sufficient
RUN apt-get update && \
    apt-get install -y \
        git \
        wget \
        xz-utils 

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

# build hdf5 and install in /home/software
RUN mkdir /home/software/hdf5 && \
    cd /home/software/temp && \
    wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.13/hdf5-1.13.1/src/hdf5-1.13.1.tar.gz && \
    tar -xvf hdf5-1.13.1.tar.gz && \
    cd hdf5-1.13.1 && \
    mkdir build && \
    cd build; \
    ../configure --prefix="/home/software/hdf5" --enable-optimization --enable-shared --enable-cxx --enable-hl --disable-debug; \
    # cat config.log
    # make && \
    # make install && \
    # rm -rf /home/software/temp/* 

# RUN h5ls --version && \
#     find . -name "hdf5.h"

# # Obtain Makefile
# COPY Makefile /home/multiphysics/cardinal/

# remove temp directory used to handle build of dependencies
# RUN rm -rf /home/simulator/temp