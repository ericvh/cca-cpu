.PHONY: default
default: build

ROOTDIR ?= $(abspath .)
include ../common.mk

$(SRC_DIR)/linux/guest/.git:
	git clone --depth 1 --branch cca-guest/rfc-v1 https://git.gitlab.arm.com/linux-arm/linux-cca.git $(SRC_DIR)/linux/guest
ifneq (,$(wildcard guest/arch/arm64/cca-attestion/Kconfig))
	@for patch in $(wildcard patches/*.patch); do \
		echo "Applying patch: $$patch"; \
		patch -N -d $(SRC_DIR)/linux/guest -p1 < $$patch; \
	done
endif

$(BUILDS_DIR)/linux/guest/.config: $(SRC_DIR)/linux/guest/.git configs/guest-linux.config
	mkdir -p $(BUILDS_DIR)/linux/guest
	cp configs/guest-linux.config $(BUILDS_DIR)/linux/guest/.config
	make -C $(SRC_DIR)/linux/guest O=$(BUILDS_DIR)/linux/guest olddefconfig

$(BUILDS_DIR)/linux/guest/arch/arm64/boot/Image: $(BUILDS_DIR)/linux/guest/.config
	make -C $(SRC_DIR)/linux/guest -j`nproc` O=$(BUILDS_DIR)/linux/guest
	INSTALL_MOD_PATH=$(BUILDS_DIR)/linux make -C $(SRC_DIR)/linux/host -j`nproc` O=$(BUILDS_DIR)/linux/host modules_install

$(SRC_DIR)/linux/host/.git: $(SRC_DIR)/linux/guest/.git
	cd $(SRC_DIR)/linux/guest && git remote set-branches origin '*' && git fetch -v --depth=1 && git worktree add $(SRC_DIR)/linux/host cca-host/rfc-v1

$(BUILDS_DIR)/linux/host/.config: $(SRC_DIR)/linux/host/.git configs/host-linux.config
	mkdir -p $(BUILDS_DIR)/linux/host
	cp configs/host-linux.config $(BUILDS_DIR)/linux/host/.config
	make -C $(SRC_DIR)/linux/host O=$(BUILDS_DIR)/linux/host olddefconfig

$(BUILDS_DIR)/linux/host/arch/arm64/boot/Image: $(BUILDS_DIR)/linux/host/.config
	make -C $(SRC_DIR)/linux/host -j`nproc` O=$(BUILDS_DIR)/linux/host
	INSTALL_MOD_PATH=$(BUILDS_DIR)/linux make -C $(SRC_DIR)/linux/host -j`nproc` O=$(BUILDS_DIR)/linux/host modules_install

.PHONY: build
build: $(BUILDS_DIR)/linux/guest/arch/arm64/boot/Image $(BUILDS_DIR)/linux/host/arch/arm64/boot/Image

.PHONY: host
host: $(BUILDS_DIR)/linux/host/arch/arm64/boot/Image

.PHONY: guest
guest: $(BUILDS_DIR)/linux/guest/arch/arm64/boot/Image

clean:
	rm -rf $(BUILDS_DIR)/linux

nuke: clean
	rm -rf $(SRC_DIR)/linux
