.PHONY: default
default: /usr/local/bin/qemu-system-aarch64 /usr/local/bin/lkvm linux-cca u-root-initramfs

# Check if we are running inside a Docker container
DOCKER_CONTAINER := $(shell if [ -f "/.dockerenv" ]; then echo "1"; fi)
VOLUME_NAME := $(shell basename `pwd`)-workspaces
CONTAINER_NAME := $(shell basename `pwd`)

workspaces:
ifndef DOCKER_CONTAINER
	@echo "Checking if volume $(VOLUME_NAME) exists..."
	@if docker volume inspect $(VOLUME_NAME) >/dev/null 2>&1; then \
		echo "Volume $(VOLUME_NAME) already exists."; \
	else \
		echo "Creating volume $(VOLUME_NAME)..."; \
		docker volume create $(VOLUME_NAME); \
	fi
	docker build -t $(CONTAINER_NAME) .vscode
	docker run -v $(VOLUME_NAME):/workspaces -v $(shell pwd):/.work $(CONTAINER_NAME) sh -c "cp -r /.work/* /workspaces"
	docker run -i -t --workdir /workspaces -v $(shell pwd):/.work -v $(VOLUME_NAME):/workspaces $(CONTAINER_NAME) /bin/bash
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

.PHONY: linux-cca
linux-cca:
	make -C linux-cca

.PHONY: u-root-initramfs
u-root-initramfs:
	make -C u-root-initramfs

clean:
	make -C linux-cca clean
	make -C u-root-initramfs clean
	rm -rf qemu/.build

nuke:
	make -C linux-cca nuke
	make -C u-root-initramfs nuke
	rm -rf qemu
	rm -rf kvmtool-cca