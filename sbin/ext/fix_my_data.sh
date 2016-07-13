#!/sbin/busybox sh

read -t 5 -p "Start fixing DATA partition? 5sec time out then NO (y/n)"
if [ "$REPLY" == "y" ]; then
	if [ ! -e /data/dalvik_cache/ ]; then
		echo "starting to fix DATA"
		FS_DATA=$(cat /tmp/data_fs_check);
		if [ "$FS_DATA" == "ext4" ]; then
			/sbin/e2fsck -fyc /dev/block/mmcblk0p10;
			/sbin/e2fsck -fyc /dev/block/mmcblk0p10;
			/sbin/e2fsck -p /dev/block/mmcblk0p10;
		elif [ "$FS_DATA" == "f2fs" ]; then
			/sbin/fsck.f2fs -p -f /dev/block/mmcblk0p10;
		else
			echo "UNKOWN OR UNSUPPORTED PARTITION TYPE \"$FS_DATA\"";
		fi;
		mount -t $FS_DATA /dev/block/mmcblk0p10 /data;
		rm -f /data/dalvik-cache/*;
		sync;
		umount /data;
		echo "All done!"
	else
		echo "DATA Partition is MOUNTED! you can't run this script, reboot to recovery, them run via ADB"
	fi;
fi;
