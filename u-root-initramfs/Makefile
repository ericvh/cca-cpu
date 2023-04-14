.PHONY: default
default: build

ROOTDIR ?= $(abspath .)
include ../common.mk 

$(SRC_DIR)/cpu/.git:
	git clone --depth 1 https://github.com/u-root/cpu.git $(SRC_DIR)/cpu
	patch -N -p 1 -d $(SRC_DIR)/cpu -i $(ROOTDIR)/cca-cpu/u-root-initramfs/remove-init-tasks.patch

$(ARTIFACTS)/cpu: $(SRC_DIR)/cpu/.git
	cd $(SRC_DIR)/cpu && go build -o $(ARTIFACTS)/cpu $(SRC_DIR)/cpu/cmds/cpu/.

$(SRC_DIR)/u-root/.git:
	git clone --depth 1 https://github.com/u-root/u-root.git $(SRC_DIR)/u-root

$(BUILDS_DIR)/u-root/u-root: $(SRC_DIR)/u-root/.git
	mkdir -p $(BUILDS_DIR)/u-root
	cd $(SRC_DIR)/u-root && go mod tidy && go build -o $(BUILDS_DIR)/u-root

${HOME}/.ssh/identity:
	mkdir -p ${HOME}/.ssh
	ssh-keygen -N "" -f ${HOME}/.ssh/identity

$(ARTIFACTS)/initramfs.cpio: $(SRC_DIR)/cpu/.git $(BUILDS_DIR)/u-root/u-root ${HOME}/.ssh/identity
	cd $(SRC_DIR)/cpu && $(BUILDS_DIR)/u-root/u-root -o $(ARTIFACTS)/initramfs.cpio -files ${HOME}/.ssh/identity.pub:key.pub -files /mnt -uroot-source $(SRC_DIR)/u-root -initcmd=/bbin/cpud $* core cmds/cpud

.PHONY: build
build: $(ARTIFACTS)/initramfs.cpio $(ARTIFACTS)/cpu

.PHONY: cpu
cpu: $(ARTIFACTS)/cpu

.PHONY: initramfs.cpio
initramfs.cpio: $(ARTIFACTS)/initramfs.cpio

clean:
	rm -f $(BUILDS_DIR)/u-root-initramfs

nuke: clean
	rm -rf $(SRC_DIR)/cpu
	rm -rf $(SRC_DIR)/u-root
