#!/bbin/elvish

/mnt/workspaces/artifacts/lkvm run --realm --irqchip=gicv3-its --console=virtio -c 1 -m 256 -k /mnt/workspaces/artifacts/Image.guest -i /mnt/workspaces/artifacts/initramfs.cpio --9p /mnt,FM --rng -p "ip=on uroot.uinitargs=/bin/bash"
