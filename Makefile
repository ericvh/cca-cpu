export ROOTDIR ?= $(abspath ..)
include common.mk

.PHONY: default
default: $(ARTIFACTS)/lkvm $(ARTIFACTS)/Image $(ARTIFACTS)/Image.guest $(ARTIFACTS)/initramfs.cpio $(ARTIFACTS)/cpu

$(ARTIFACTS):
	mkdir -p .$@

$(SRC_DIR)/kvmtool-cca/.git:
	git clone --depth 1 -b cca/rfc-v1 https://git.gitlab.arm.com/linux-arm/kvmtool-cca.git $(SRC_DIR)/kvmtool-cca

$(ARTIFACTS)/lkvm: $(SRC_DIR)/kvmtool-cca/.git $(ARTIFACTS)
	cd $(SRC_DIR)/kvmtool-cca && make LDFLAGS="-static" -j`nproc` && sudo cp lkvm $(ARTIFACTS)

$(ARTIFACTS)/Image.guest: $(ARTIFACTS)
	make -C linux-cca guest
	sudo cp $(BUILDS_DIR)/linux/guest/arch/arm64/boot/Image $(ARTIFACTS)/Image.guest

$(ARTIFACTS)/Image:
	make -C linux-cca host
	sudo cp $(BUILDS_DIR)/linux/host/arch/arm64/boot/Image $(ARTIFACTS)

$(ARTIFACTS)/initramfs.cpio:
	make -C u-root-initramfs initramfs.cpio

$(ARTIFACTS)/cpu:
	make -C u-root-initramfs cpu

$(ARTIFACTS)/qemu-system-aarch64:
	make -C qemu

$(ARTIFACTS)/rmm.img:
	make -C tf-rmm

$(ARTIFACTS)/bl1-linux.bin: $(ARTIFACTS)/rmm.img
	make -C tf-a $@

$(ARTIFACTS)/fip-linux.bin: $(ARTIFACTS)/rmm.img
	make -C tf-a $@

clean:
	make -C linux-cca -c clean
	make -C u-root-initramfs clean
#	rm -rf qemu/.build

nuke:
	make -C linux-cca nuke
	make -C u-root-initramfs nuke
#	rm -rf qemu
	rm -rf $(SRC_DIR)/kvmtool-cca

nuke-artifacts:
	rm -f $(ARTIFACTS)/initramfs.cpio
	rm -f $(ARTIFACTS)/Image
	rm -f $(ARTIFACTS)/Image.guest
	