#!/bin/bash
set -eu

if [ -f "$(dirname "$(readlink -f "$0")")/../.use-local-r2" ]; then
    CDN_URL=http://cdn.local/friendlyelec-cdn/os-images/h5/images
    ROOTFS_URL=http://cdn.local/friendlyelec-cdn/rootfs/h5
else
    CDN_URL=https://downloads.friendlyelec.com/os-images/h5/images
    ROOTFS_URL=https://downloads.friendlyelec.com/rootfs/h5
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
wget ${ROOTFS_URL}/rootfs_friendlycore-focal_4.14.tgz
wget ${ROOTFS_URL}/rootfs_friendlycore-focal_4.14.tgz.sha256
sha256sum -c rootfs_friendlycore-focal_4.14.tgz.sha256
tar xzf rootfs_friendlycore-focal_4.14.tgz -C friendlycore-focal_4.14_arm64
echo hello > friendlycore-focal_4.14_arm64/rootfs/root/welcome.txt
(cd friendlycore-focal_4.14_arm64/rootfs/root/ && {
	wget ${CDN_URL}/friendlycore-focal_4.14_arm64.tgz -O deleteme.tgz
});
./build-rootfs-img.sh friendlycore-focal_4.14_arm64/rootfs friendlycore-focal_4.14_arm64
sudo ./mk-sd-image.sh friendlycore-focal_4.14_arm64
sudo ./mk-emmc-image.sh friendlycore-focal_4.14_arm64
