#!/bin/bash
set -eu

HTTP_SERVER=112.124.9.243

# hack for me
PCNAME=`hostname`
if [ x"${PCNAME}" = x"tzs-i7pc" ]; then
       HTTP_SERVER=192.168.1.9
fi

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_h5
cd sd-fuse_h5
wget http://${HTTP_SERVER}/dvdfiles/H5/images-for-eflasher/friendlycore-xenial_4.14_arm64.tgz
tar xzf friendlycore-xenial_4.14_arm64.tgz
wget http://${HTTP_SERVER}/dvdfiles/H5/images-for-eflasher/eflasher.tgz
tar xzf eflasher.tgz

# make big file
fallocate -l 5G friendlycore-xenial_4.14_arm64/rootfs.img

# calc image size
IMG_SIZE=`du -s -B 1 friendlycore-xenial_4.14_arm64/rootfs.img | cut -f1`

# re-gen parameter.txt
./tools/generate-partmap-txt.sh ${IMG_SIZE} friendlycore-xenial_4.14_arm64 h5

sudo ./mk-sd-image.sh friendlycore-xenial_4.14_arm64
sudo ./mk-emmc-image.sh friendlycore-xenial_4.14_arm64
