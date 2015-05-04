#!/sbin/busybox sh

# stop ROM VM from booting!
stop;

# check if gps or battery failed to init on reboot
GPS_ERR_CHECK=$(dmesg | grep -w "k3g_probe : Device indentification failed" | wc -l);
BATTERY_CHECK=$(dmesg | grep -w "max8997_muic_charger_cb: fail to get battery ps" | wc -l);
if [ "$GPS_ERR_CHECK" -eq "1" ] || [ "$BATTERY_CHECK" -eq "1" ]; then
	sync;
	reboot;
fi;

# set busybox location
BB=/sbin/busybox

$BB mount -o remount,rw,nosuid,nodev /cache;
$BB mount -o remount,rw,nosuid,nodev /data;
$BB mount -o remount,rw /;
$BB mount -o remount,rw /lib/modules;

# cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;
$BB rm -rf /data/anr/* 2> /dev/null;

# critical Permissions fix
$BB chown -R root:system /sys/devices/system/cpu/;
$BB chown -R system:system /data/anr;
$BB chown -R root:radio /data/property/;
$BB chmod -R 777 /tmp/;
$BB chmod -R 6755 /sbin/ext/;
$BB chmod -R 0777 /dev/cpuctl/;
$BB chmod -R 0777 /data/system/inputmethod/;
$BB chmod -R 0777 /sys/devices/system/cpu/;
$BB chmod -R 0777 /data/anr/;
$BB chmod 0744 /proc/cmdline;
$BB chmod -R 0770 /data/property/;
$BB chmod -R 0400 /data/tombstones;

LOG_SDCARDS=/log-sdcards
FIX_BINARY=/sbin/fsck_msdos

SDCARD_FIX()
{
	# fixing sdcards
	$BB date > $LOG_SDCARDS;
	$BB echo "FIXING STORAGE" >> $LOG_SDCARDS;

	if [ -e /dev/block/mmcblk1p1 ]; then
		$BB echo "EXTERNAL SDCARD CHECK" >> $LOG_SDCARDS;
		$BB cp /sbin/libexfat_utils.so /system/lib/;
		$BB mount -t exfat /dev/block/mmcblk1p1 /mnt/tmp;
		EXFAT_CHECK=$(cat /proc/self/mounts | grep "/dev/block/mmcblk1p1" | wc -l);
		if [ "$EXFAT_CHECK" -eq "1" ]; then
			$BB sh -c "/sbin/fsck.exfat -R /dev/block/mmcblk1p1" >> $LOG_SDCARDS;
			$BB umount /mnt/tmp;
		else
			$BB sh -c "$FIX_BINARY -p -f /dev/block/mmcblk1p1" >> $LOG_SDCARDS;
		fi;
	else
		$BB echo "EXTERNAL SDCARD NOT EXIST" >> $LOG_SDCARDS;
	fi;

	$BB echo "INTERNAL SDCARD CHECK" >> $LOG_SDCARDS;
	$BB sh -c "$FIX_BINARY -p -f /dev/block/mmcblk0p11" >> $LOG_SDCARDS;
	$BB echo "DONE" >> $LOG_SDCARDS;
}

BOOT_ROM()
{

	# perm fixes
	$BB chown -R root:root /data/property;
	$BB chmod -R 0700 /data/property;

	# Start ROM VM boot!
	start;
}

if [ -e /tmp/wrong_kernel ]; then
	if [ -e /system/bin/wrong_kernel.png ]; then
		$BB cp /system/bin/wrong_kernel.png /res/images/icon_clockwork.png;
		/sbin/choose_rom 0;
	fi;
	sleep 15;
	sync;
	reboot;
else
	if [ -e /system/bin/fsck_msdos ]; then
		FIX_BINARY=/system/bin/fsck_msdos
		BOOT_ROM;
		SDCARD_FIX;
	else
		BOOT_ROM;
		SDCARD_FIX;
	fi;
fi;
