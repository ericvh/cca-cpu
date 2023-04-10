FROM ubuntu:22.04

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
    wget
RUN if [ `uname -m` = "aarch64" ] ; then wget https://developer.arm.com/-/media/Files/downloads/ecosystem-models/FVP_Base_RevC-2xAEMvA_11.21_15_Linux64_armv8l.tgz ; \
                                    else wget https://developer.arm.com/-/media/Files/downloads/ecosystem-models/FVP_Base_RevC-2xAEMvA_11.21_15_Linux64.tgz ; fi \
    && tar xf F*.tgz && rm *.tgz
RUN ln -s Base_RevC_AEMvA_pkg/models/Linux64*/FVP_Base_RevC-2xAEMvA fvp
