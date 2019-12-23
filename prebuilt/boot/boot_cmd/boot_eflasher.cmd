# Recompile with: mkimage -C none -A arm -T script -d boot.cmd boot.scr
# CPU=H5
# OS=eflasher

echo "running eflasher boot.scr"
setenv fsck.repair yes
setenv ramdisk rootfs.cpio.gz
setenv kernel Image

setenv env_addr 0x45000000
setenv kernel_addr 0x46000000
setenv ramdisk_addr 0x47000000
setenv dtb_addr 0x48000000
setenv fdtovaddr 0x49000000

fatload mmc ${boot_part} ${kernel_addr} ${kernel}
fatload mmc ${boot_part} ${ramdisk_addr} ${ramdisk}
setenv ramdisk_size ${filesize}
if test $board = nanopi-neo2-v1.1; then 
    fatload mmc ${boot_part} ${dtb_addr} sun50i-h5-nanopi-neo2.dtb
else
    fatload mmc ${boot_part} ${dtb_addr} sun50i-h5-${board}.dtb
fi
fdt addr ${dtb_addr}

# setup NEO2-V1.1 with gpio-dvfs overlay
if test $board = nanopi-neo2-v1.1; then
    fatload mmc ${boot_part} ${fdtovaddr} overlays/sun50i-h5-gpio-dvfs-overlay.dtb
    fdt resize 8192
    fdt apply ${fdtovaddr}
fi

# setup boot_device
fdt set mmc${boot_mmc} boot_device <1>

setenv fbcon map:0
#setenv hdmi_res drm_kms_helper.edid_firmware=HDMI-A-1:edid/1280x720.bin video=HDMI-A-1:1280x720@60
setenv pmdown snd-soc-core.pmdown_time=3600000

setenv bootargs "console=ttyS0,115200 earlyprintk
root=${rootfs_part} rootfstype=ext4 rw rootwait fsck.repair=${fsck.repair}
panic=10 fbcon=${fbcon} ${hdmi_res} ${overlayfs} ${pmdown}"

booti ${kernel_addr} ${ramdisk_addr}:${ramdisk_size} ${dtb_addr}
