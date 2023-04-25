#!/bbin/elvish
#FVP_IP=`docker inspect fvp | jq -r '.[].NetworkSettings.IPAddress'`
#ln -f -s /tmp/local/tmp $HOME/.lkvm
#PWD=/ /workspaces/artifacts/cpu -namespace "/workspaces:/lib:/lib64:/usr:/bin:/etc:/home" $FVP_IP /workspaces/artifacts/lkvm run --realm --irqchip=gicv3-its --console=virtio \
#    -c 1 -m 256 \
#    -k /workspaces/artifacts/Image.guest -i /workspaces/artifacts/initramfs.cpio
/mnt/workspaces/artifacts/lkvm run --realm --irqchip=gicv3-its --console=virtio -c 1 -m 256 -k /mnt/workspaces/artifacts/Image.guest -i /mnt/workspaces/artifacts/initramfs.cpio --9p /tmp/cpu,FM --rng -p "ip=on"
