#!/bin/sh

cp ../dorimanx-SG2-I9100-Kernel/READY-JB/system/bin/e2fsck /tmp/initramfs_source/sbin/
cp ../dorimanx-SG2-I9100-Kernel/READY-JB/system/bin/mount.exfat-fuse /tmp/initramfs_source/sbin/

rm -rf /tmp/initramfs_source/res/misc/Marshmallow-*;
rm -rf /tmp/initramfs_source/res/misc/Lollipop-*;
rm -rf /tmp/initramfs_source/res/vendor

du -sh /tmp/initramfs_source/
echo "if less than 14MB then all OK, if MORE remove something! Ramdisk can be max 14MB in RAM on boot."
