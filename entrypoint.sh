#!/bin/bash -e
#set -x

WORK_PATH=/home
#make and config OS img
cd ${WORK_PATH}
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
virt-customize -a /home/jammy-server-cloudimg-amd64.img --install fio
virt-customize -a /home/jammy-server-cloudimg-amd64.img --mkdir /home/fiotest --upload /home/generate_fio_config.sh:/home/fiotest/generate_fio_config.sh


cat >ubuntu-data <<EOF
#cloud-config
password: ubuntu
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
    -./home/fiotest/generate_fio_config.sh
EOF
cloud-localds ubuntu-data.img ubuntu-data

./spdk_vhost_setup.sh
