ROOTDIR ?= $(abspath .)
include ../common.mk

TFA_SRC = $(SRC_DIR)/trusted-firmware-a
TFA_BUILD = $(BUILDS_DIR)/trusted-firmware-a

TFA_URL = https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git
TFA_BRANCH = master
TFA_REVISION = v2.8-rc0

.PHONY: default
default: build

.PHONY: build
build: $(ARTIFACTS)/bl1-linux.bin $(ARTIFACTS)/fip-linux.bin

$(TFA_SRC): $(SRC_DIR)
	if ! [ -d $(TFA_SRC) ] ; then \
		git clone --depth 1 -b $(TFA_REVISION) $(TFA_URL) $@ --recursive ; \
	fi

LINUX_BASE_ADDR = 0x84000000

$(ARTIFACTS)/rmm.img:
	$(MAKE) -C $(ROOTDIR)/tf-rmm

$(TFA_BUILD)/fvp/debug/bl1.bin \
$(TFA_BUILD)/fvp/debug/fip.bin: $(TFA_SRC) $(ARTIFACTS)/rmm.img
	grep -q virtio_p9 $(TFA_SRC)/fdts/fvp-base-psci-common.dtsi || \
		(patch -N -p 1 -d $(TFA_SRC) -i $(ROOTDIR)/cca-cpu/tf-a/patches/0001-Disable-cpuidle.patch && \
		 patch -N -p 1 -d $(TFA_SRC) -i $(ROOTDIR)/cca-cpu/tf-a/patches/0002-Add-9p-support-to-DTS-file-and-bootargs.patch)
	$(ELF_GCC_VARS) \
		$(MAKE) -C $(TFA_SRC) -j$(J) \
			BUILD_BASE=$(TFA_BUILD) \
			PLAT=fvp \
			DEBUG=1 \
			ENABLE_RME=1 \
			ARM_DISABLE_TRUSTED_WDOG=1 \
			PRELOADED_BL33_BASE=$(LINUX_BASE_ADDR) \
			ARM_PRELOADED_DTB_BASE=0x82000000 \
			RMM=$(ARTIFACTS)/rmm.img \
			ARM_LINUX_KERNEL_AS_BL33=1 \
			all fip

$(ARTIFACTS)/bl1-linux.bin: $(TFA_BUILD)/fvp/debug/bl1.bin $(ARTIFACTS)
	cp $< $@
	
$(ARTIFACTS)/fip-linux.bin: $(TFA_BUILD)/fvp/debug/fip.bin $(ARTIFACTS)
	cp $< $@

.PHONY: reset
reset: clean
	(cd $(TFA_SRC) ; \
		git reset --hard ; \
		git fetch ; \
		git checkout $(TFA_REVISION))

.PHONY: clean
clean:
	rm -rf $(TFA_BUILD)
	rm -f $(ARTIFACTS)/bl1-linux.bin $(ARTIFACTS)/fip-linux.bin
