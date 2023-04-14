#!/bin/bash
FVP_IP=`docker inspect fvp | jq -r '.[].NetworkSettings.IPAddress'`
ln -f -s /tmp/local/tmp $HOME/.lkvm
PWD=/ /workspaces/artifacts/cpu -namespace "/workspaces:/lib:/lib64:/usr:/bin:/etc:/home" $FVP_IP /workspaces/artifacts/lkvm run --realm --irqchip=gicv3-its --console=virtio \
    -c 1 -m 64 \
    -k /workspaces/artifacts/Image.guest -i /workspaces/artifacts/initramfs.cpio