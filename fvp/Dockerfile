FROM --platform=arm64 ubuntu:22.04

RUN mkdir -p /opt/fvp
WORKDIR /opt/fvp
RUN --mount=type=cache,target=/var/cache/apt \
	--mount=type=cache,target=/var/lib/apt/lists \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
	apt-get update && \
	apt-get install -yqq --no-install-recommends \
    ca-certificates \
    libatomic1 \
    screen \
    telnet \
    wget \
    && apt-get clean
RUN wget https://developer.arm.com/-/media/Files/downloads/ecosystem-models/FVP_Base_RevC-2xAEMvA_11.21_15_Linux64_armv8l.tgz && tar xf FVP*.tgz && rm *.tgz
ENTRYPOINT ["Base_RevC_AEMvA_pkg/models/Linux64_armv8l_GCC-9.3/FVP_Base_RevC-2xAEMvA"]
CMD ["--help"]