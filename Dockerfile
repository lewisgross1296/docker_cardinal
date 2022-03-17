# This Dockerfile builds, installs, and tests Cardinal in a clean environment

FROM ubuntu:20.04

RUN useradd ligross

# get git and wget
RUN apt-get update && \
    apt-get install -y \
        git \
        wget \
        xz-utils

# create directorries needed and clone cardinal
RUN mkdir /home/multiphysics && \
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

# Obtain Makefile
COPY Makefile /home/multiphysics/cardinal/