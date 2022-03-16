# This Dockerfile builds, installs, and tests Cardinal in a clean environment

FROM ubuntu:20.04

RUN useradd ligross

RUN apt-get update && \
    apt-get install -y \
        git

RUN mkdir /home/multiphysics && \
    cd /home/multiphysics && \
    git clone https://github.com/neams-th-coe/cardinal.git && \
    ls /home/multiphysics/cardinal

# potentially useful WORKDIR /home/multiphysics/cardinal