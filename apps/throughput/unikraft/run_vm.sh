#!/bin/bash

if [ -z $1 ]; then
	echo "usage: $0 <vm_id> <app_options>"
	exit 1
fi

id=$1
shift

eval qemu-system-x86_64 \
	-nographic \
	-vga none \
	-net none \
	-kernel $(dirname $0)/build/unikraft_qemu-x86_64 \
	-enable-kvm \
	-cpu host \
	-netdev tap,id=tap0,script=$(dirname $0)/qemu-ifup.sh,downscript=no,vhost=on \
        -device virtio-net-pci,netdev=tap0,mac=52:54:00:12:34:5$1 \
        -append \"netdev.ipv4_addr=10.0.0.$1 netdev.ipv4_gw_addr=10.0.0.254 netdev.ipv4_subnet_mask=255.255.255.0 -- "$@"\"