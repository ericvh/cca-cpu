/workspaces/artifacts/qemu-system-aarch64 -M virt -cpu host -enable-kvm -M gic-version=3 -smp 1 -m 256M \
    -nographic -M confidential-guest-support=rme0 -object rme-guest,id=rme0,measurement-algo=sha512 \
    -kernel /workspaces/artifacts/Image.guest -initrd /workspaces/artifacts/initramfs.cpio -append 'ip=on earlycon=hvc0 console=hvc0' \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0 \
    -device virtio-serial-pci,id=virtio-serial0 -chardev stdio,id=charconsole0 \
    -device virtio-net-pci,netdev=n1 \
    -netdev user,id=n1,hostfwd=tcp:127.0.0.1:17010-:17010,net=192.168.1.0/24,host=192.168.1.1 \
    -fsdev local,security_model=passthrough,id=fsdev0,path=/mnt \
    -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=FM \
    -device virtconsole,chardev=charconsole0,id=console0 -overcommit mem-lock=on -nodefaults


