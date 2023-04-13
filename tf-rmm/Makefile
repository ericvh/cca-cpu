ROOTDIR ?= $(abspath .)
include ../common.mk

RMM_SRC = $(SRC_DIR)/tf-rmm
RMM_BUILD = $(BUILDS_DIR)/tf-rmm

RMM_URL = https://github.com/TF-RMM/tf-rmm.git
RMM_BRANCH = main
RMM_REVISION = tf-rmm-v0.2.0

.PHONY: default
default: build

.PHONY: build
build: $(ARTIFACTS)/rmm.img

$(RMM_SRC): $(SRC_DIR)
	if ! [ -d $(RMM_SRC) ] ; then \
		git clone --depth 1 -b $(RMM_REVISION) $(RMM_URL) $@ --recursive ; \
	fi

$(RMM_BUILD)/Makefile: $(RMM_SRC)
	$(ELF_GCC_VARS) \
        cmake -DRMM_CONFIG=fvp_defcfg -S $(RMM_SRC) -B $(RMM_BUILD)

$(RMM_BUILD)/rmm.img: $(RMM_BUILD)/Makefile
	cmake --build $(RMM_BUILD) -j $(J)

$(ARTIFACTS)/rmm.img: $(RMM_BUILD)/rmm.img $(ARTIFACTS)
	cp $< $@

.PHONY: reset
reset: clean
	(cd $(RMM_SRC) ; \
		git reset --hard ; \
		git fetch ; \
		git checkout $(RMM_REVISION))

clean:
	rm -f $(ARTIFACTS)/rmm.img
	rm -rf $(RMM_BUILD)
