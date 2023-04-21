
FROM --platform=arm64 mcr.microsoft.com/devcontainers/base:jammy AS base

ARG TARGETARCH

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y eatmydata && \
    eatmydata apt-get dist-upgrade -y && \
    eatmydata apt-get install --no-install-recommends -y \
            ccache \
            cmake \
            device-tree-compiler \
            file \
	        gcc \
            gdb \
            libfdt-dev \
            libvirt-clients \
		    build-essential bc fakeroot linux-tools-generic dwarves \
		    libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm \
        	      ca-certificates git-core openssh-client \
        	      libpopt-dev ncurses-dev automake autoconf git pkgconf \
        	      lua5.1 liblua5.1-dev libmunge-dev libwrap0-dev libcap-dev libattr1-dev \
		    mutt \
		    pip \
            vim pinentry-tty libsasl2-modules \
            libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build libmount-dev\
            docker.io \
            && \
    sed -Ei 's,^# (en_US\.UTF-8 .*)$,\1,' /etc/locale.gen && \
    dpkg-reconfigure locales && \
    dpkg-query --showformat '${Package}_${Version}_${Architecture}\n' --show > /packages.txt
WORKDIR /tmp
RUN if [ `uname -m` = "aarch64" ]; then \
        export TARGETGOARCH="arm64"; \
    else \
        export TARGETGOARCH="amd64"; \
    fi; \
    wget https://go.dev/dl/go1.20.3.linux-$TARGETGOARCH.tar.gz; \
    tar xf go*.tar.gz;rm go*.tar.gz;mv go /usr/local
ENV GOROOT /usr/local/go
ENV PATH /usr/local/go/bin:$PATH
ENV GOPATH /home/vscode/go
RUN mkdir -p /workspaces/cca-cpu
RUN mkdir -p /workspaces/artifacts
RUN mkdir -p /workspaces/ccache
RUN mkdir -p /usr/libexec/ccache-wrappers && \
    ln -s /usr/bin/ccache /usr/libexec/ccache-wrappers/c++ && \
    ln -s /usr/bin/ccache /usr/libexec/ccache-wrappers/cc && \
    ln -s /usr/bin/ccache /usr/libexec/ccache-wrappers/clang && \
    ln -s /usr/bin/ccache /usr/libexec/ccache-wrappers/g++ && \
    ln -s /usr/bin/ccache /usr/libexec/ccache-wrappers/gcc
ENV CCACHE_DIR=/ccache
ENV CCACHE_WRAPPERSDIR "/usr/libexec/ccache-wrappers"
ENV LANG "en_US.UTF-8"
ENV MAKE "/usr/bin/make"

WORKDIR /home/vscode
