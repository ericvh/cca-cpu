
FROM mcr.microsoft.com/devcontainers/base:jammy AS base

ARG TARGETARCH

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y eatmydata && \
    eatmydata apt-get dist-upgrade -y && \
    eatmydata apt-get install --no-install-recommends -y \
            ccache \
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
            && \
    eatmydata apt-get autoremove -y && \
    eatmydata apt-get autoclean -y && \
    sed -Ei 's,^# (en_US\.UTF-8 .*)$,\1,' /etc/locale.gen && \
    dpkg-reconfigure locales && \
    dpkg-query --showformat '${Package}_${Version}_${Architecture}\n' --show > /packages.txt

FROM golang:latest AS cpubuild
#RUN if [ `uname -m` = "aarch64" ]; then \
#	export TARGETGOARCH="arm64"; \
#    else \
#	export TARGETGOARCH="amd64"; \
#    fi; \
#    wget https://go.dev/dl/go1.19.linux-$TARGETGOARCH.tar.gz; \
#    tar xf go*.tar.gz;rm go*.tar.gz;mv go /usr/local

RUN git clone https://github.com/u-root/cpu.git
WORKDIR /go/cpu
RUN go mod tidy
RUN CGO_ENABLED=0 go build -o cpu ./cmds/cpu/.
RUN cp cpu /go/bin

FROM base AS qemubuild
WORKDIR /usr/local/src
RUN git clone --depth 1 -b cca/rfc-v1 git://jpbrucker.net/jbru/qemu.git
WORKDIR /usr/local/src/qemu
RUN mkdir build && cd build && ../configure --target-list=aarch64-softmmu && make -j`nproc` && make install

FROM base AS lkvmbuild
WORKDIR /usr/local/src
RUN git clone --depth 1 -b cca/rfc-v1 https://git.gitlab.arm.com/linux-arm/kvmtool-cca.git
WORKDIR /usr/local/src/kvmtool-cca
RUN make -j`nproc` && cp lkvm /usr/local/bin

FROM base
COPY --from=lkvmbuild /usr/local/bin/lkvm /usr/local/bin/lkvm
COPY --from=qemubuild /usr/local/bin/* /usr/local/bin
COPY --from=cpubuild /go/bin/cpu /usr/local/bin/cpu

#ENV GOROOT /usr/local/go
#ENV PATH /usr/local/go/bin:/home/vscode/go/bin:${PATH}
#ENV LANG "en_US.UTF-8"
#ENV MAKE "/usr/bin/make"