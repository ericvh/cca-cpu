.PHONY: default
default: build

guest/.git:
	git clone --depth 1 --branch cca-guest/rfc-v1 https://git.gitlab.arm.com/linux-arm/linux-cca.git guest

guest/arch/arm64/cca-attestion: guest/.git
	cd guest && git checkout -b cca-guest/rfc-v1-patched
	@for patch in $(wildcard patches/*.patch); do \
		echo "Applying patch: $$patch"; \
		patch -d guest -p1 < $$patch; \
	done

guest/.build/.config: guest/arch/arm64/cca-attestation
	mkdir -p guest/.build
	cp configs/guest-linux.config guest/.build/.config
	make -C guest O=.build olddefconfig

guest/.build/arch/arm64/boot/Image: guest/.build/.config
	make -C guest -j`nproc` O=.build

host/.git: guest/.git
	cd guest && git remote set-branches origin '*' && git fetch -v --depth=1 && git worktree add ../host cca-host/rfc-v1

host/.build/.config: host/.git
	mkdir host/.build
	cp configs/host-linux.config host/.build/.config
	make -C host O=.build olddefconfig

host/.build/arch/arm64/boot/Image: host/.build/.config
	make -C host -j`nproc` O=.build

.PHONY: build
build: guest/.build/arch/arm64/boot/Image host/.build/arch/arm64/boot/Image

clean:
	rm -rf guest/.build
	rm -rf host/.build

nuke:
	rm -rf guest host
