FROM --platform=arm64 golang:latest as builder

RUN mkdir -p /opt
RUN mkdir -p /opt

WORKDIR /opt
RUN git clone --depth 1 https://github.com/u-root/u-root.git
RUN git clone --depth 1 https://github.com/u-root/cpu.git

WORKDIR /opt/u-root
RUN go mod tidy && go build && go install
WORKDIR /opt/cpu
RUN go mod tidy && CGO_ENABLED=0 go build -o cpud ./cmds/cpud/.

# Volume mount public key from host
VOLUME ["/opt/keys/key.pub"]
# Volume mount /tmp from host for resulting initramfs.cpio
VOLUME ["/tmp"]

# Command to run
CMD ["u-root", "-o", "/dev/stdout", "-uroot-source", "/opt/u-root", "-files", "/opt/keys/key.pub:key.pub", "-initcmd=/bbin/cpud", "core", "cmds/cpud"]
