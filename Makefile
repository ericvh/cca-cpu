.PHONY: default

# Check if we are running inside a Docker container
DOCKER_CONTAINER := $(shell if [ -f "/.dockerenv" ]; then echo "1"; fi)
WORK_VOLUME_NAME ?= $(shell basename `pwd`)-workspaces
ARTIFACT_VOLUME_NAME ?= $(shell basename `pwd`)-artifacts
CONTAINER_NAME ?= $(shell basename `pwd`)

qemu/.git:
	git clone --depth 1 -b cca/rfc-v1 git://jpbrucker.net/jbru/qemu.git
	mkdir qemu/build
	cd qemu/build && ../configure --target-list=aarch64-softmmu

/usr/local/bin/qemu-system-aarch64: qemu/.git
	cd qemu/build && make -j`nproc` && sudo make install

kvmtool-cca/.git:
	git clone --depth 1 -b cca/rfc-v1 https://git.gitlab.arm.com/linux-arm/kvmtool-cca.git

/usr/local/bin/lkvm: kvmtool-cca/.git
	cd kvmtool-cca && make -j`nproc` && sudo cp lkvm /usr/local/bin

/workspaces/artifacts/Image.guest:
	make -C linux-cca guest
	sudo cp linux-cca/guest/.build/arch/arm64/boot/Image /workspaces/artifacts/Image.guest

/workspaces/artifacts/Image:
	make -C linux-cca guest
	sudo cp linux-cca/host/.build/arch/arm64/boot/Image /workspaces/artifacts/Image

/workspaces/artifacts/initramfs.cpio:
	make -C u-root-initramfs
	sudo cp u-root-initramfs/initramfs.cpio /workspaces/artifacts/initramfs.cpio
	sudo cp u-root-initramfs/cpu/bin/* /usr/local/bin

clean:
	make -C linux-cca clean
	make -C u-root-initramfs clean
	rm -rf qemu/.build

nuke:
	make -C linux-cca nuke
	make -C u-root-initramfs nuke
	rm -rf qemu
	rm -rf kvmtool-cca

nuke-artifacts:
	rm -f /workspaces/artifacts/initramfs.cpio
	rm -f /workspaces/artifacts/Image
	rm -f /workspaces/artifacts/Image.guest

