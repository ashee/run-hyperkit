#!/bin/sh

# kill vm
# pgrep hyperkit | xargs kill -SIGHUP

# make cloud-init.iso
# hdiutil makehybrid -o cloud-init.iso -hfs -joliet -iso -default-volume-name cidata cloud-init

# copy disk image
# qemu-img convert -f qcow2 -O raw bionic-server-cloudimg-amd64.img bionic.raw

INITRD="bionic-server-cloudimg-amd64-initrd-generic"
KERNEL="bionic-server-cloudimg-amd64-vmlinuz-generic"
DISK="bionic.raw"
CMDLINE="earlyprintk=serial console=ttyS0     root=/dev/vda1"

MEM="-m 1G"
SMP="-c 2"
# NET="-s 2:0,virtio-net"
IMG_CD="-s 3,ahci-cd,cloud-init.iso"
IMG_HDD="-s 4,virtio-blk,$DISK"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
ACPI="-A"
UUID="-U $(uuidgen)"

hyperkit $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"

