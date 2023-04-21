# CPU for CCA Demo

## Goal

Build an environment which runs without buildroots to allow for easy development and test of CCA environments by leveraging u-root,
cpu, and virtio 9p backmounts.  For more information on any of these environments see the links session at the end of this document.

## Components

- _.devcontainer_ : devcontainer setup including primary Dockerfile 
- _bin_ : scripts for executing the demo
- _u-root-initramfs_ : u-root initramfs to avoid buildroots
- _fvp_ : Container formula for FVP
- _linux-cca_: kernels for guest and host
- _tf-a_ : CCA enabled TF-A firmware
- _tf-rmm_ : Realm Management Monitor for managing CCA realms
- _qemu_ : CCA enabled qemu build environment.

## Build

The repository is setup as a vscode devcontainer, if you clone the repository into a vscode dev-container volume many things will be setup for you.
The system is setup to build components using Docker volumes.  .devcontainer contains a Dockerfile for the primary development environment which will
support building golang components, the linux kernel, TF-A, kvmtool, and qemu.

In the devcontainer, this repo ends up in a /worksapces/cca-cpu directory - instead of cloning components into its tree, it clones them as peer directories
and uses a peer build directory for intermediate files and binaries.  Final binaries are put in the /workspaces/artifacts directory.  If you aren't in a 
devcontainer, please ensure you are okay with peer directories to the cloned directory being created or place everything in its own hierarchy.

### Dev Container

If you are already running in an arm64 dev container, you should be able to run:
```
make
```
and it will take care of building everything.  My native environment for development/test is an Arm laptop running OSX with docker desktop installed.
It should be possible to run in linux/arm64 or even WSL/arm64 enviornments, but I have not directly tested.  It should also be possible to use binfmt
and qemu-user-static to run cross-arch docker container environments (although build will be significantly slower).

### Standalone and using pre-built artifacts

There is a github CI action which builds many of the binaries, but not the FVP docker image -- so you'll need to build that yourself:
```
docker build -t cca-cpu/fvp:latest fvp
```
Then you can grab the latest artifacts and unpack them to artifacts.  _NOTE_: if you can't create /workspaces in your environment, then you need to modify the paths in all the scripts.
```
make downloadlatest
sudo mkdir -p /workspaces
sudo mv ../artifacts /workspaces/artifacts
```

### Standalone and building components

This is not currently well tested and probably has bugs.

```
docker run -i -t -v `pwd`:/workspaces/cca-cpu -w /workspaces/cca-cpu ghcr.io/ericvh/cca-cpu /bin/bash
make
``` 

## Use

Once everything is built, you should be able to run the demo:

```
vscode ➜ /workspaces/cca-cpu (fvp-cpu) $ bin/start-fvp.bash 
Starting FVP...hit ^a-d to exit
...
[    3.723671] Freeing unused kernel memory: 7936K
[    3.724486] Run /init as init process
2023/04/21 18:40:47 Welcome to u-root!
                              _
   _   _      _ __ ___   ___ | |_
  | | | |____| '__/ _ \ / _ \| __|
  | |_| |____| | | (_) | (_) | |_
   \__,_|    |_|  \___/ \___/ \__|

[    3.837078] cgroup: Unknown subsys name 'net_cls'
root@172:/# /workspaces/cca-cpu/bin/test-lkvm.bash
  # lkvm run -k /mnt/workspaces/artifacts/Image.guest -m 256 -c 1 --name guest-150
[    1.345860] cacheinfo: Unable to detect cache hierarchy for CPU 0
[    1.453459] loop: module loaded
[    1.457073] tun: Universal TUN/TAP device driver, 1.6
[    1.497107] net eth0: Fail to set guest offload.
[    1.498512] virtio_net virtio2 eth0: set_features() failed (-22); wanted 0x0000000000134829, left 0x0080000000134829
[    1.523209] VFIO - User Level meta-driver version: 0.3
[    1.531093] SMCCC: SOC_ID: ARCH_SOC_ID not implemented, skipping ....
[    1.537293] NET: Registered PF_PACKET protocol family
[    1.538770] 9pnet: Installing 9P2000 support
[    1.558259] NET: Registered PF_VSOCK protocol family
[    1.616972] registered taskstats version 1
[    1.730594] Freeing unused kernel memory: 1088K
[    1.733815] Run /init as init process
1970/01/01 00:00:01 Welcome to u-root!
                              _
   _   _      _ __ ___   ___ | |_
  | | | |____| '__/ _ \ / _ \| __|
  | |_| |____| | | (_) | (_) | |_
   \__,_|    |_|  \___/ \___/ \__|

[    2.612950] cgroup: Unknown subsys name 'net_cls'
root@(none):/# 
```

The second invocation (test-lkvm) takes a couple minutes due to dialated simulation time.
Both the FVP linux host (root@172 prompt) and the CCA realm (root@unknown) have the namespace
from the originating vscode dev container mounted (this includes /workspaces, /home, as well
as /usr, /bin, and /lib) -- so you can run all executables just like you would in your
devcontainer.

This should allow you to develop your own code in whatever language you like and run it inside
the enclave.

Everything in the scripts is run from inside screen, so use screen key combos for scrollback, etc.
There are other screens inside the FVP container which have the RMM console, debug console, and FVP console itself.

## Future

- We aren't doing anything to attest the realm or applications within it yet.
- Provide a vscode feature template which allows you to include appropraite artifacts and start scripts without operating in cca-cpu so that you can incorporate it into any (arm64) development environment
- Enable networking and use cpu to provide multi-session access to realm.

## Links

- https://github.com/u-root/u-root
- https://github.com/u-root/cpu
- https://www.arm.com/architecture/security-features/arm-confidential-compute-architecture