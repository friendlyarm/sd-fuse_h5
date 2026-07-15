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

git clone https://github.com/friendlyarm/u-boot --depth 1 -b sunxi-v2017.x uboot-h5

UBOOT_SRC=$PWD/uboot-h5 ./build-uboot.sh friendlycore-focal_4.14_arm64
sudo ./mk-sd-image.sh friendlycore-focal_4.14_arm64
