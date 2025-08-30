FROM ubuntu:latest AS builder-x86_64

ARG GLIBC_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    GLIBC_VERSION=${GLIBC_VERSION} \
    ARCH=x86_64

RUN apt-get update && \
    apt-get install -y \
        make gcc binutils gawk bison perl python3 wget gnupg xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY build /root/build

RUN chmod +x /root/build && /root/build

FROM --platform=linux/386 i386/ubuntu:xenial AS builder-i686

ARG GLIBC_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    GLIBC_VERSION=${GLIBC_VERSION} \
    ARCH=i686

RUN apt-get update && \
    apt-get install -y \
        make gcc binutils gawk bison perl python3 wget gnupg xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY build /root/build

RUN chmod +x /root/build && /root/build
