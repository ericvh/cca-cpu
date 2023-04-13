.PHONY: default
default: build

ROOTDIR ?= $(abspath .)
include ../common.mk

QEMU_SRC = $(SRC_DIR)/qemu
QEMU_BUILD = $(BUILDS_DIR)/qemu
QEMU_URL = git://jpbrucker.net/jbru/qemu.git
QEMU_BRANCH = cca/rfc-v1
QEMU_CONFIGURE_FLAGS = --target-list=aarch64-softmmu --static --disable-docs

default: build

check:
	@if ! [ -e /.dockerenv ] ; then \
		echo "This Makefile must be run inside container" ; \
		false ; \
	fi

$(SRC_DIR): check
	mkdir -p $@

$(ARTIFACTS): check
	mkdir -p $@

$(QEMU_SRC): $(SRC_DIR)
	git clone --depth 1 -b $(QEMU_BRANCH) $(QEMU_URL) $@

check-git:
	(cd $(QEMU_SRC) ; git fetch ; git checkout $(QEMU_BRANCH))
	(cd $(QEMU_SRC) ; git submodule update --init)

build: check $(ARTIFACTS)/qemu-system-aarch64

$(QEMU_BUILD)/Makefile: $(QEMU_SRC)
	mkdir -p $(QEMU_BUILD)
	(cd $(QEMU_BUILD); $(QEMU_SRC)/configure $(QEMU_CONFIGURE_FLAGS))

$(QEMU_BUILD)/qemu-system-aarch64: $(QEMU_BUILD)/Makefile
	$(MAKE) -j`nproc` -C $(QEMU_BUILD)

$(ARTIFACTS)/qemu-system-aarch64: $(ARTIFACTS) $(QEMU_BUILD)/qemu-system-aarch64
	cp $(QEMU_BUILD)/qemu-system-aarch64 $@
	aarch64-linux-gnu-strip $@
	cp $(QEMU_BUILD)/qemu-bundle/usr/local/share/qemu/efi-virtio.rom $(ARTIFACTS)
