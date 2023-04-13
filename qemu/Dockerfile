# syntax = docker/dockerfile:1.4
FROM debian:buster

ARG USER=root
ARG UID=0

# Use bash as the default
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt \
	--mount=type=cache,target=/var/lib/apt/lists \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
	apt-get update && \
	apt-get install -yqq --no-install-recommends \
        apt-utils \
        build-essential \
        ca-certificates \
        docker.io \
        gcc \
		git \
        jq \
        less \
        libc6-dev \
		lsb-release \
        openssl \
        ninja-build \
        pkg-config \
		python3 \
        sudo \
		unzip \
        vim \
        libglib2.0-dev \
        libpixman-1-dev
