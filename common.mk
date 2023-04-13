ARTIFACTS ?= $(ROOTDIR)/artifacts
SRC_DIR ?= $(ROOTDIR)
BUILDS_DIR ?= $(ROOTDIR)/build

TFA_CLONE = $(SRC_DIR)/trusted-firmware-a
TFA_BUILD = $(BUILD_DIR)/trusted-firmware-a

TFA_URL = https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git
TFA_BRANCH = master
TFA_REVISION = v2.8-rc0

# Check if we are running inside a Docker container
DOCKER_CONTAINER := $(shell if [ -f "/.dockerenv" ]; then echo "1"; fi)
ifdef DOCKER_CONTAINER
export CONTAINER_ID := $(shell hostname)
export CONTAINER_NAME := $(shell basename `docker inspect ${CONTAINER_ID} | jq -r '.[].Name'`)
export VOLUME_NAME := $(shell docker inspect ${CONTAINER_ID} | jq -r '.[].Mounts[] | select(.Destination | startswith("/workspaces")) | .Name')
endif
