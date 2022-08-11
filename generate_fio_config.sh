#!/bin/bash -e
#set -x

cd /home
cat > "test.fio" <<EOF
[global]
description="rand read test with block size of 4k"
iodepth=1
runtime=120
ramp_time=30
direct=1
thread
rw=randread
ioengine=libaio
bs=4k
size=2G
numjobs=3
group_reporting
[job0]
filename=/dev/sda
EOF
fio /home/test.fio
