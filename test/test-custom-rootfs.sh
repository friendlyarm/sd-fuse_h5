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
wget http://${HTTP_SERVER}/dvdfiles/H5/images-for-eflasher/friendlycore-focal_4.14_arm64.tgz
tar xzf friendlycore-focal_4.14_arm64.tgz
wget http://${HTTP_SERVER}/dvdfiles/H5/images-for-eflasher/eflasher.tgz
tar xzf eflasher.tgz
wget http://${HTTP_SERVER}/dvdfiles/H5/rootfs/rootfs_friendlycore-focal_4.14.tgz
tar xzf rootfs_friendlycore-focal_4.14.tgz -C friendlycore-focal_4.14_arm64
echo hello > friendlycore-focal_4.14_arm64/rootfs/root/welcome.txt
(cd friendlycore-focal_4.14_arm64/rootfs/root/ && {
	wget http://${HTTP_SERVER}/dvdfiles/H5/images-for-eflasher/friendlycore-focal_4.14_arm64.tgz -O deleteme.tgz
});
./build-rootfs-img.sh friendlycore-focal_4.14_arm64/rootfs friendlycore-focal_4.14_arm64
sudo ./mk-sd-image.sh friendlycore-focal_4.14_arm64
sudo ./mk-emmc-image.sh friendlycore-focal_4.14_arm64
