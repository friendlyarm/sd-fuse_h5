#!/bin/bash
set -eu

HTTP_SERVER=112.124.9.243

# hack for me
PCNAME=`hostname`
if [ x"${PCNAME}" = x"tzs-i7pc" ]; then
       HTTP_SERVER=127.0.0.1
fi

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_h5
cd sd-fuse_h5
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/H5/images-for-eflasher/friendlycore-xenial_4.14_arm64.tgz
tar xzf friendlycore-xenial_4.14_arm64.tgz

git clone https://github.com/friendlyarm/u-boot --depth 1 -b sunxi-v2017.x uboot-h5

UBOOT_SRC=$PWD/uboot-h5 ./build-uboot.sh friendlycore-xenial_4.14_arm64
sudo ./mk-sd-image.sh friendlycore-xenial_4.14_arm64
