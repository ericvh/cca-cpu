.PHONY: default
default: /usr/local/bin/qemu-system-aarch64 /usr/local/bin/lkvm /workspaces/artifacts/Image.guest /workspaces/artifacts/Image /workspaces/artifacts/initramfs.cpio

# Check if we are running inside a Docker container
DOCKER_CONTAINER := $(shell if [ -f "/.dockerenv" ]; then echo "1"; fi)
WORK_VOLUME_NAME ?= $(shell basename `pwd`)-workspaces
ARTIFACT_VOLUME_NAME ?= $(shell basename `pwd`)-artifacts
CONTAINER_NAME ?= $(shell basename `pwd`)

workspaces:
ifndef DOCKER_CONTAINER
	@echo "Checking if volume $(WORK_VOLUME_NAME) exists..."
	@if docker volume inspect $(WORK_VOLUME_NAME) >/dev/null 2>&1; then \
		echo "Volume $(WORK_VOLUME_NAME) already exists."; \
	else \
		echo "Creating volume $(WORK_VOLUME_NAME)..."; \
		docker volume create $(WORK_VOLUME_NAME); \
	fi
	@if docker volume inspect $(ARTIFACT_VOLUME_NAME) >/dev/null 2>&1; then \
		echo "Volume $(ARTIFACT_VOLUME_NAME) already exists."; \
	else \
		echo "Creating volume $(ARTIFACT_VOLUME_NAME)..."; \
		docker volume create $(ARTIFACT_VOLUME_NAME); \
	fi	
	docker build -t $(CONTAINER_NAME) .devcontainer
	docker run -v $(WORK_VOLUME_NAME):/workspaces/cca-cpu -v $(shell pwd):/workspaces/.work -v $(ARTIFACT_VOLUME_NAME):/workspaces/artifacts $(CONTAINER_NAME) sh -c "cp -r /workspaces/.work/* /workspaces/cca-cpu && chown -Rf vscode.vscode /workspaces"
	docker run -i -t --workdir /workspaces/cca-cpu --user vscode -v $(ARTIFACT_VOLUME_NAME):/workspaces/artifacts -v $(shell pwd):/workspaces/.work -v $(WORK_VOLUME_NAME):/workspaces/cca-cpu -v $(HOME):/home/user $(CONTAINER_NAME) /bin/bash
else
	@echo Already in docker container
endif

start-docker: create-volume
	docker run -it --rm \
		--name $(DOCKER_CONTAINER_NAME) \
		-v $(VOLUME_NAME):/work \
		$(DOCKER_IMAGE_NAME)

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

