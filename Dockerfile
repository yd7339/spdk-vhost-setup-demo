# ubuntu-spdk-vhost

ARG OS_VER="22.04"
ARG OS_IMAGE="ubuntu"
ARG WORK_PATH=/home
FROM ${OS_IMAGE}:${OS_VER}
#export http_proxy=http://child-prc.intel.com:913
#export https_proxy=http://child-prc.intel.com:913
RUN apt-get update && \
    apt-get install -y make gcc git libaio-dev qemu-system-x86 kmod pkg-config wget cloud-image-utils libguestfs-tools

WORKDIR ${WORK_PATH}

ARG SPDK_REPO=https://github.com/spdk/spdk
RUN cd ${WORK_PATH} && git clone ${SPDK_REPO} spdk && \
    cd spdk && git submodule update --init && \
    ./scripts/pkgdep.sh && \
    ./configure && \
    make
COPY /scripts/* ${WORK_PATH}/
#RUN chmod +x /home/*.sh
RUN mkfifo /export-logs
CMD (${WORK_PATH}/entrypoint.sh; echo $? > status) 2>$1 | tee output.log && \
    tar cf /export-logs status output.log && \
    sleep infinity

