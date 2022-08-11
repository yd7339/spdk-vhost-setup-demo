#!/bin/bash -e
#set -x
BASE_PATH=/home
SPDK_PATH=/home/spdk
VHOST_PATH=/var/tmp
CPUMASK=0x3

#Init the SPDK-vhost device
cd ${SPDK_PATH}

#check hugemem
HUGEMEM=4096 scripts/setup.sh
build/bin/vhost -S ${VHOST_PATH} -s 1024 -m ${CPUMASK} &

BDEV_NAME=`scripts/rpc.py bdev_nvme_attach_controller -b Nvme0 -t pcie -a 0000:68:00.0`
scripts/rpc.py vhost_create_blk_controller --cpumask 0x1 vhost.1 ${BDEV_NAME}

qemu-system-x86_64 \
--enable-kvm -cpu host -smp 2 -m 1G \
-object memory-backend-file,id=mem0,size=1G,mem-path=/dev/hugepages,share=on \
-numa node,memdev=mem0 \
-drive file=/home/jammy-server-cloudimg-amd64.img,if=none,id=disk \
-drive file=/home/ubuntu-data.img,format=raw \
-device ide-hd,drive=disk,bootindex=0 \
-chardev socket,id=spdk_vhost_blk0,path=/var/tmp/vhost.1 \
-device vhost-user-blk-pci,chardev=spdk_vhost_blk0,num-queues=2 \
-nographic

