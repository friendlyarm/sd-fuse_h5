
# sd-fuse_h5
## Introduction
This repository is a bunch of scripts to build bootable SD card images for FriendlyElec H5 boards, the main features are as follows:

* Create root ﬁlesystem image from a directory
* Build bootable SD card image
* Easy way to compile kernel、uboot and third-party driver
  
*Read this in other languages: [简体中文](README_cn.md)*  
  
## Requirements
* Supports x86_64 and arm64 platforms (Note: requires A53 or higher on arm64)
* Recommended Host OS: Ubuntu 20.04 LTS (Focal Fossa) 64-bit or Higher (Note: Build will fail on Ubuntu Bionic since package lz4 is required)
* The script will prompt for the installation of necessary packages.
* Docker container: https://github.com/friendlyarm/docker-cross-compiler-novnc

## Kernel Version Support
The sd-fuse use multiple git branches to support each version of the kernel, the current branche supported kernel version is as follows:
* 4.14.y   
  
For other kernel versions, please switch to the related git branch.
## Target board OS Supported
*Notes: The OS name is the same as the directory name, it is written in the script so it cannot be renamed.*

* friendlycore-focal_4.14_arm64
* friendlycore-xenial_4.14_arm64
* friendlywrt_4.14_arm64

  
To build an SD card image for friendlycore-focal, for example like this:
```
./mk-sd-image.sh friendlycore-focal_4.14_arm64
```
  
## Where to download files
The following files may be required to build SD card image:
* kernel source code: In the directory "07_Source codes" of [NetDrive](https://download.friendlyelec.com/h5), or download from [Github](https://github.com/friendlyarm/linux), the branch name is sunxi-4.14.y
* uboot source code: In the directory "07_Source codes" of [NetDrive](https://download.friendlyelec.com/h5), or download from [Github](https://github.com/friendlyarm/u-boot), the branch name is sunxi-v2017.x
* pre-built partition image: In the directory "03_Partition image files" of [NetDrive](https://download.friendlyelec.com/h5), or download from [HTTP server](http://112.124.9.243/dvdfiles/h5/images-for-eflasher)
* compressed root file system tar ball: In the directory "06_File systems" of [NetDrive](https://download.friendlyelec.com/h5), or download from [HTTP server](http://112.124.9.243/dvdfiles/h5/rootfs)
  
If the files are not prepared in advance, the script will automatically download the required files, but the speed may be slower due to the bandwidth of the http server.

## Script Functions
* fusing.sh: Flash the image to SD card
* mk-sd-image.sh: Build SD card image
* mk-emmc-image.sh: Build SD-to-eMMC image, used to install system to eMMC

* build-boot-img.sh:  Create boot ﬁlesystem image(boot.img) from a directory

* build-rootfs-img.sh: Create root ﬁlesystem image(rootfs.img) from a directory
* build-kernel.sh: Compile the kernel, or kernel headers
* build-uboot.sh: Compile uboot

## Usage
### Build your own SD card image
*Note: Here we use friendlycore-focal system as an example*  
Clone this repository locally, then download and uncompress the [pre-built images](http://112.124.9.243/dvdfiles/h5/images-for-eflasher), due to the bandwidth of the http server, we recommend downloading the file from the [NetDrive](https://download.friendlyelec.com/h5):
```
git clone https://github.com/friendlyarm/sd-fuse_h5 -b master --single-branch sd-fuse_h5
cd sd-fuse_h5
wget http://112.124.9.243/dvdfiles/h5/images-for-eflasher/friendlycore-focal_4.14_arm64.tgz
tar xvzf friendlycore-focal_4.14_arm64.tgz
```
After decompressing, you will get a directory named friendlycore-focal_4.14_arm64, you can change the files in the directory as needed, for example, replace rootfs.img with your own modified version, or your own compiled kernel and uboot, finally, flash the image to the SD card by entering the following command (The below steps assume your SD card is device /dev/sdX):
```
sudo ./fusing.sh /dev/sdX friendlycore-focal_4.14_arm64
```
Or, package it as an SD card image file:
```
./mk-sd-image.sh friendlycore-focal_4.14_arm64
```
The following flashable image file will be generated, it is now ready to be used to boot the device into friendlycore-focal:  
```
out/h5_sd_friendlycore-focal_4.14_arm64-YYYYMMDD.img
```

### Build your own SD-to-eMMC Image
*Note: Here we use friendlycore-focal system as an example*  
Clone this repository locally, then download and uncompress the [pre-built images](http://112.124.9.243/dvdfiles/h5/images-for-eflasher), here you need to download the friendlycore-focal and eflasher [pre-built images](http://112.124.9.243/dvdfiles/h5/images-for-eflasher):
```
git clone https://github.com/friendlyarm/sd-fuse_h5 -b master --single-branch sd-fuse_h5
cd sd-fuse_h5
wget http://112.124.9.243/dvdfiles/h5/images-for-eflasher/friendlycore-focal_4.14_arm64.tgz
tar xvzf friendlycore-focal_4.14_arm64.tgz
wget http://112.124.9.243/dvdfiles/h5/images-for-eflasher/eflasher.tgz
tar xvzf eflasher.tgz
```
Then use the following command to build the SD-to-eMMC image, the autostart=yes parameter means it will automatically enter the flash process when booting:
```
./mk-emmc-image.sh friendlycore-focal_4.14_arm64 autostart=yes
```
The following flashable image file will be generated, ready to be used to boot the device into eflasher system and then flash friendlycore-focal system to eMMC: 
```
out/h5_eflasher_friendlycore-focal_4.14_arm64-YYYYMMDD.img
```
### Backup rootfs and create custom SD image (to burn your application into other boards)
#### Backup rootfs
Run the following commands on your target board. These commands will back up the entire root partition:
```
sudo passwd root
su root
cd /
tar --warning=no-file-changed -cvpzf /rootfs.tar.gz \
    --exclude=/rootfs.tar.gz --exclude=/var/lib/docker/runtimes \
    --exclude=/etc/firstuse --exclude=/etc/friendlyelec-release \
    --exclude=/usr/local/first_boot_flag --one-file-system /
```
#### Making a bootable SD card from a root filesystem
*Note: Here we use friendlycore-focal system as an example*  
Clone this repository locally, then download and uncompress the [pre-built images](http://112.124.9.243/dvdfiles/h5/images-for-eflasher):
```
git clone https://github.com/friendlyarm/sd-fuse_h5 -b master --single-branch sd-fuse_h5
cd sd-fuse_h5
wget http://112.124.9.243/dvdfiles/h5/images-for-eflasher/friendlycore-focal_4.14_arm64.tgz
tar xvzf friendlycore-focal_4.14_arm64.tgz
```
Extract the rootfs.tar.gz exported in the previous section, the tar command requires root privileges, so you need put sudo in front of the command:
```
mkdir friendlycore-focal_4.14_arm64/rootfs
./tools/extract-rootfs-tar.sh rootfs.tar.gz friendlycore-focal_4.14_arm64/rootfs
```
or download the filesystem archive from the following URL and extract it:
```
wget http://112.124.9.243/dvdfiles/h5/rootfs/rootfs_friendlycore-focal_4.14.tgz
./tools/extract-rootfs-tar.sh rootfs_friendlycore-focal_4.14.tgz
```
Make rootfs to img:
```
sudo ./build-rootfs-img.sh friendlycore-focal_4.14_arm64/rootfs friendlycore-focal_4.14_arm64
```
Use the new rootfs.img to build SD card image:
```
./mk-sd-image.sh friendlycore-focal_4.14_arm64
```
Or build SD-to-eMMC image:
```
./mk-emmc-image.sh friendlycore-focal_4.14_arm64 autostart=yes
```
If the image path is too big to pack, you can use the RAW_SIZE_MB environment variable to set a new image size. for example, you can set it to 16GB:
```
RAW_SIZE_MB=16000 ./mk-sd-image.sh friendlycore-focal_4.14_arm64
RAW_SIZE_MB=16000 ./mk-emmc-image.sh friendlycore-focal_4.14_arm64
```

### Compiling the Kernel
*Note: Here we use friendlycore-focal system as an example*  
Clone this repository locally, then download and uncompress the [pre-built images](http://112.124.9.243/dvdfiles/h5/images-for-eflasher):
```
git clone https://github.com/friendlyarm/sd-fuse_h5 -b master --single-branch sd-fuse_h5
cd sd-fuse_h5
wget http://112.124.9.243/dvdfiles/h5/images-for-eflasher/friendlycore-focal_4.14_arm64.tgz
tar xvzf friendlycore-focal_4.14_arm64.tgz
```
Download the kernel source code from github:
```
git clone https://github.com/friendlyarm/linux -b sunxi-4.14.y --depth 1 kernel
```
Customize the kernel configuration:
```
cd kernel
touch .scmversion
make ARCH=arm64 sunxi_arm64_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- savedefconfig
cp defconfig ./arch/arm64/configs/my_defconfig                  # Save the configuration as my_defconfig
git add ./arch/arm64/configs/my_defconfig
cd -
```
To compile the kernel, use the environment variables KERNEL_SRC and KCFG to set the source code folder and the defconfig file:
```
KERNEL_SRC=kernel KCFG=my_defconfig ./build-kernel.sh friendlycore-focal_4.14_arm64
```

### Compiling the u-boot
*Note: Here we use friendlycore-focal system as an example* 
Clone this repository locally, then download and uncompress the [pre-built images](http://112.124.9.243/dvdfiles/h5/images-for-eflasher):
```
git clone https://github.com/friendlyarm/sd-fuse_h5 -b master --single-branch sd-fuse_h5
cd sd-fuse_h5
wget http://112.124.9.243/dvdfiles/h5/images-for-eflasher/friendlycore-focal_4.14_arm64.tgz
tar xvzf friendlycore-focal_4.14_arm64.tgz
```
Download the u-boot source code from github that matches the OS version, the environment variable UBOOT_SRC is used to specify the local source code directory:
```
git clone https://github.com/friendlyarm/u-boot -b sunxi-v2017.x --depth 1 uboot
UBOOT_SRC=uboot ./build-uboot.sh friendlycore-focal_4.14_arm64
```
### Common Issues and Solutions
* Unable to boot after creating rootfs (Solution: The file permissions in the file system might be corrupted. Make sure to use the tools/extract-rootfs-tar.sh script to extract rootfs, and use the -cpzf options with the tar command for packaging.)
* Process exits during creation (Solution: Ensure the machine has sufficient memory.)
