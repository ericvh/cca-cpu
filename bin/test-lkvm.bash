#!/bin/bash

cpu -d gateway.docker.internal lkvm run --realm --irqchip=gicv3-its --console=virtio \
    -c 1 -m 64 \
    -k /tmp/cpu/workspaces/artifacts/Image.guest -i /tmp/cpu/workspaces/artifacts/initramfs.cpio


ccpu realm top