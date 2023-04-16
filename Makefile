export ROOTDIR ?= $(abspath ..)
include common.mk

.PHONY: default ci lkvm firmware initramfs linux-host linux-guest
default: $(ARTIFACTS)/lkvm $(ARTIFACTS)/Image $(ARTIFACTS)/Image.guest $(ARTIFACTS)/initramfs.cpio $(ARTIFACTS)/cpu $(ARTIFACTS)/qemu-system-aarch64 $(ARTIFACTS)/lkvm $(ARTIFACTS)/rmm.img $(ARTIFACTS)/bl1-linux.bin $(ARTIFACTS)/fip-linux.bin fvp-docker
# ci builds neither qemu nor FVP docker images for now
lkvm: $(ARTIFACTS)/lkvm
firmware: $(ARTIFACTS)/rmm.img $(ARTIFACTS)/bl1-linux.bin $(ARTIFACTS)/fip-linux.bin
initramfs: $(ARTIFACTS)/initramfs.cpio $(ARTIFACTS)/cpu
linux-host: $(ARTIFACTS)/Image
linux-guest: $(ARTIFACTS)/Image.guest
ci: lkvm firmware initramfs cpu linux-host linux-guest

$(ARTIFACTS):
	mkdir -p $@
	chown -Rf vscode.vscode $(ARTIFACTS)

.PHONY: fvp-docker
fvp-docker:
	docker build -t cca-cpu/fvp fvp

$(SRC_DIR)/kvmtool-cca/.git:
	git clone --depth 1 -b cca/rfc-v1 https://git.gitlab.arm.com/linux-arm/kvmtool-cca.git $(SRC_DIR)/kvmtool-cca

$(ARTIFACTS)/lkvm: $(SRC_DIR)/kvmtool-cca/.git $(ARTIFACTS)
	cd $(SRC_DIR)/kvmtool-cca && make LDFLAGS="-static" -j`nproc` && cp lkvm $(ARTIFACTS)

$(ARTIFACTS)/Image.guest: $(ARTIFACTS)
	make -C linux-cca guest
	cp $(BUILDS_DIR)/linux/guest/arch/arm64/boot/Image $(ARTIFACTS)/Image.guest

$(ARTIFACTS)/Image:
	make -C linux-cca host
	cp $(BUILDS_DIR)/linux/host/arch/arm64/boot/Image $(ARTIFACTS)

$(ARTIFACTS)/initramfs.cpio:
	make -C u-root-initramfs initramfs.cpio

$(ARTIFACTS)/cpu:
	make -C u-root-initramfs cpu

$(ARTIFACTS)/qemu-system-aarch64:
	docker build -t $(CONTAINER_NAME)-qemu-builder qemu
	docker run --rm -i -t -v /var/run/docker.sock:/var/run/docker.sock -v cca-cpu-main-4766e1af21fa2d95bcb992f1e2e9bce792788547ec68e1636128b2786d141bb7:/workspaces --workdir=/workspaces/cca-cpu $(CONTAINER_NAME)-qemu-builder:latest make qemu-build
	sudo chown -Rf vscode.vscode $(ARTIFACTS)/qemu-system-aarch64
	sudo chown -Rf vscode.vscode $(ARTIFACTS)/efi-virtio.rom
	sudo chown -Rf vscode.vscode $(BUILDS_DIR)/qemu
	sudo chown -Rf vscode.vscode $(SRC_DIR)/qemu

qemu-build:
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
	rm -rf $(BUILDS_DIR)/*

nuke:
	rm -rf $(SRC_DIR)/cpu
	rm -rf $(SRC_DIR)/kvmtool-cca
	rm -rf $(SRC_DIR)/qemu
	rm -rf $(SRC_DIR)/linux
	rm -rf $(SRC_DIR)/u-root

nuke-artifacts:
	rm -rf $(ARTIFACTS)

nuke-em: nuke-artifacts nuke clean
	