# Recompile with: mkimage -C none -A arm -T script -d boot.cmd boot.scr
# CPU=H5
# OS=friendlycore/ubuntu-oled/ubuntu-wifiap/openwrt/debian/debian-nas...

echo "running boot.scr"
setenv load_addr 0x44000000
setenv fix_addr 0x44500000
fatload mmc 0 ${load_addr} uEnv.txt
env import -t ${load_addr} ${filesize}

fatload mmc 0 ${kernel_addr} ${kernel}
fatload mmc 0 ${ramdisk_addr} ${ramdisk}
setenv ramdisk_size ${filesize}

if test $board = nanopi-neo2-v1.1; then 
    fatload mmc 0 ${dtb_addr} sun50i-h5-nanopi-neo2.dtb
else
    fatload mmc 0 ${dtb_addr} sun50i-h5-${board}.dtb
fi
fdt addr ${dtb_addr}

# merge overlay
fdt resize 65536
overlay search
for i in ${overlays}; do
    if fatload mmc 0 ${load_addr} overlays/sun50i-h5-${i}.dtbo; then
        echo "applying overlay ${i}..."
        fdt apply ${load_addr}
    fi
done
fatload mmc 0 ${fix_addr} overlays/sun50i-h5-fixup.scr
source ${fix_addr}

# setup NEO2-V1.1 with gpio-dvfs overlay
if test $board = nanopi-neo2-v1.1; then
    fatload mmc 0 ${load_addr} overlays/sun50i-h5-gpio-dvfs-overlay.dtbo
    fdt apply ${load_addr}
fi

# setup boot_device
fdt set mmc${boot_mmc} boot_device <1>

setenv overlayfs data=/dev/mmcblk0p3
#setenv hdmi_res drm_kms_helper.edid_firmware=HDMI-A-1:edid/1280x720.bin video=HDMI-A-1:1280x720@60
setenv pmdown snd-soc-core.pmdown_time=3600000

setenv bootargs "console=${debug_port} earlyprintk
root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait fsck.repair=${fsck.repair}
panic=10 fbcon=${fbcon} ${hdmi_res} ${overlayfs} ${pmdown}"

booti ${kernel_addr} ${ramdisk_addr}:${ramdisk_size} ${dtb_addr}
