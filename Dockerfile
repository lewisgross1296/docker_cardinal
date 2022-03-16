# This Dockerfile builds, installs, and tests Cardinal in a clean environment

FROM ubuntu:20.04

RUN useradd ligross

RUN apt-get update && \
    apt-get install -y \
        git \
        wget

RUN mkdir /home/multiphysics && \
    cd /home/multiphysics && \
    git clone https://github.com/neams-th-coe/cardinal.git && \
    ls /home/multiphysics/cardinal

WORKDIR /home/multiphysics/cardinal

RUN ./scripts/get-dependencies.sh

# get this to work
RUN ./scripts/download-openmc-cross-sections.sh

RUN ls /home/multiphysics