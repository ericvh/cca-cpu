export ROOTDIR ?= $(abspath ..)

include common.mk


.PHONY: default ci lkvm firmware initramfs linux downloadlatest
default: lkvm firmware initramfs linux fvp-docker qemu
# ci builds neither qemu nor FVP docker images for now
ci: lkvm firmware initramfs linux
# standalone pulls artifacts from server and just builds qemu and fvp
standalone: fvp-docker qemu downloadlatest

lkvm: $(ARTIFACTS)/lkvm
firmware: $(ARTIFACTS)/rmm.img $(ARTIFACTS)/bl1-linux.bin $(ARTIFACTS)/fip-linux.bin
initramfs: $(ARTIFACTS)/initramfs.cpio $(ARTIFACTS)/cpu $(ARTIFACTS)/cpud
linux: $(ARTIFACTS)/Image $(ARTIFACTS)/Image.guest
qemu: $(ARTIFACTS)/qemu-system-aarch64

$(ARTIFACTS):
	mkdir -p $@
	chown -Rf $(USER).$(USER) $(ARTIFACTS)

downloadlatest: $(ARTIFACTS)
	wget -O $(ARTIFACTS)/Image https://github.com/ericvh/cca-cpu/releases/latest/download/Image > /dev/null 2>&1
	wget -O $(ARTIFACTS)/Image.guest https://github.com/ericvh/cca-cpu/releases/latest/download/Image.guest > /dev/null 2>&1
	wget -O $(ARTIFACTS)/initramfs.cpio https://github.com/ericvh/cca-cpu/releases/latest/download/initramfs.cpio > /dev/null 2>&1
	wget -O $(ARTIFACTS)/rmm.img https://github.com/ericvh/cca-cpu/releases/latest/download/rmm.img > /dev/null 2>&1
	wget -O $(ARTIFACTS)/bl1-linux.bin https://github.com/ericvh/cca-cpu/releases/latest/download/bl1-linux.bin > /dev/null 2>&1
	wget -O $(ARTIFACTS)/fip-linux.bin https://github.com/ericvh/cca-cpu/releases/latest/download/fip-linux.bin > /dev/null 2>&1
	wget -O $(ARTIFACTS)/cpu https://github.com/ericvh/cca-cpu/releases/latest/download/cpu > /dev/null 2>&1
	wget -O $(ARTIFACTS)/lkvm https://github.com/ericvh/cca-cpu/releases/latest/download/lkvm > /dev/null 2>&1

.PHONY: fvp-docker
fvp-docker: $(ARTIFACTS)/cpud
	cp $(ARTIFACTS)/cpud fvp
	cp $(ARTIFACTS)/identity.pub fvp
	docker build -t cca-cpu/fvp fvp
	rm -f fvp/cpud
	rm -f fvp/identity.pub

$(SRC_DIR)/kvmtool-cca/.git:
	git clone --depth 1 -b cca/rfc-v1 https://git.gitlab.arm.com/linux-arm/kvmtool-cca.git $(SRC_DIR)/kvmtool-cca

$(ARTIFACTS)/lkvm: $(SRC_DIR)/kvmtool-cca/.git $(ARTIFACTS)
	cd $(SRC_DIR)/kvmtool-cca && make LDFLAGS="-static" -j`nproc` && cp lkvm $(ARTIFACTS)
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/Image.guest: $(ARTIFACTS)
	make -C linux-cca guest
	cp $(BUILDS_DIR)/linux/guest/arch/arm64/boot/Image $(ARTIFACTS)/Image.guest
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/Image: $(ARTIFACTS)
	make -C linux-cca host
	cp -rf $(BUILDS_DIR)/linux/lib $(ARTIFACTS)
	cp $(BUILDS_DIR)/linux/host/arch/arm64/boot/Image $(ARTIFACTS)
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/initramfs.cpio:
	make -C u-root-initramfs initramfs.cpio
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/cpu:
	make -C u-root-initramfs cpu
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/cpud:
	make -C u-root-initramfs cpud
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/qemu-system-aarch64:
	make -C qemu
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/rmm.img: $(ARTIFACTS)
	make -C tf-rmm
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/bl1-linux.bin: $(ARTIFACTS)/rmm.img
	make -C tf-a $@
	chmod -Rf ugo+rw $(ARTIFACTS)

$(ARTIFACTS)/fip-linux.bin: $(ARTIFACTS)/rmm.img
	make -C tf-a $@
	chmod -Rf ugo+rw $(ARTIFACTS)

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
	