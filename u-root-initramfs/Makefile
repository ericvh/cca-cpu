.PHONY: default
default: build

cpu/.git:
	git clone --depth 1 https://github.com/u-root/cpu.git

cpu/bin/cpu: cpu/.git
	$(MAKE) -C cpu go

u-root/.git:
	git clone --depth 1 https://github.com/u-root/u-root.git

u-root/u-root: u-root/.git
	cd u-root && go mod tidy && go build

${HOME}/.ssh/identity:
	mkdir -p ${HOME}/.ssh
	ssh-keygen -N "" -f ${HOME}/.ssh/identity

initramfs.cpio: cpu/.git u-root/u-root ${HOME}/.ssh/identity
	cd cpu && ../u-root/u-root -o ../initramfs.cpio -files ${HOME}/.ssh/identity.pub:key.pub -files /mnt -uroot-source ../u-root -initcmd=/bbin/cpud $* core cmds/cpud

.PHONY: build
build: initramfs.cpio cpu/bin/cpu

clean:
	rm -f initramfs.cpio

nuke:
	rm -rf cpu
	rm -rf u-root
	rm -f initramfs.cpio
