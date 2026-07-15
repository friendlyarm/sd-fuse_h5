#!/bin/bash
set -eu

if [ -f "$(dirname "$(readlink -f "$0")")/../.use-local-r2" ]; then
    CDN_URL=http://cdn.local/friendlyelec-cdn/os-images/h5/images
else
    CDN_URL=https://downloads.friendlyelec.com/os-images/h5/images
fi
# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_h5
cd sd-fuse_h5
wget ${CDN_URL}/friendlycore-focal_4.14_arm64.tgz
tar xzf friendlycore-focal_4.14_arm64.tgz
wget ${CDN_URL}/eflasher.tgz
tar xzf eflasher.tgz

# make big file
fallocate -l 5G friendlycore-focal_4.14_arm64/rootfs.img

# calc image size
IMG_SIZE=`du -s -B 1 friendlycore-focal_4.14_arm64/rootfs.img | cut -f1`

# re-gen parameter.txt
./tools/generate-partmap-txt.sh ${IMG_SIZE} friendlycore-focal_4.14_arm64 h5

sudo ./mk-sd-image.sh friendlycore-focal_4.14_arm64
sudo ./mk-emmc-image.sh friendlycore-focal_4.14_arm64
