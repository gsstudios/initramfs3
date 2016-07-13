#!/sbin/busybox sh

BB=/sbin/busybox

. /res/customconfig/customconfig-helper;
read_defaults;
read_config;

$BB mount -o remount,rw /system;
$BB mount -o remount,rw /;

cd /;

#extract_kernel_payload()
#{
#	chmod 755 /sbin/read_boot_headers;
#	eval $(/sbin/read_boot_headers /dev/block/mmcblk0p5);
#	load_offset=$boot_offset;
#	load_len=$boot_len;
#	cd /;
#	dd bs=512 if=/dev/block/mmcblk0p5 skip=$load_offset count=$load_len | xzcat | tar x;
#}
#extract_kernel_payload; #disabled


#extract_payload()
#{
#	cd /res/misc/payload/;
#	$BB xzcat SuperSU.apk.tar.xz > SuperSU.apk.tar;
#	$BB xzcat su.tar.xz > su.tar;
#	$BB tar -xvf SuperSU.apk.tar;
#	$BB tar -xvf su.tar;
#	cd /;
#}
#extract_payload; #disabled

# copy cron files
$BB cp -a /res/crontab/ /data/
$BB rm -rf /data/crontab/cron/ > /dev/null 2>&1;
if [ ! -e /data/crontab/custom_jobs ]; then
	$BB touch /data/crontab/custom_jobs;
	$BB chmod 777 /data/crontab/custom_jobs;
fi;

# liblights install by force to allow BLN
if [ ! -e /system/lib/hw/lights.exynos4.so.BAK ]; then
	$BB mv /system/lib/hw/lights.exynos4.so /system/lib/hw/lights.exynos4.so.BAK;
fi;
$BB echo "Copying liblights";
$BB cp -a /res/misc/lights.exynos4.so /system/lib/hw/lights.exynos4.so;
$BB chown root:root /system/lib/hw/lights.exynos4.so;
$BB chmod 644 /system/lib/hw/lights.exynos4.so;

# add gesture_set.sh with default gustures to data to be used by user.
if [ ! -e /data/gesture_set.sh ]; then
	$BB cp -a /res/misc/gesture_set.sh /data/;
fi;

STWEAKS_CHECK=$($BB find /data/app/ -name com.gokhanmoral.stweaks* | wc -l);

if [ "$STWEAKS_CHECK" -eq "1" ]; then
	$BB rm -f /data/app/com.gokhanmoral.stweaks* > /dev/null 2>&1;
	$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
fi;

if [ -e /tmp/cm-installed ]; then
	if [ -e /system/app/STweaks/STweaks.apk ]; then
		stmd5sum=$($BB md5sum /system/app/STweaks/STweaks.apk | $BB awk '{print $1}');
		stmd5sum_kernel=$(cat /res/stweaks_md5);
		if [ "$stmd5sum" != "$stmd5sum_kernel" ]; then
			$BB rm -f /system/app/STweaks/STweaks.apk > /dev/null 2>&1;
			$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
			$BB cp -a /res/misc/payload/STweaks.apk /system/app/STweaks/;
			$BB chown 0.0 /system/app/STweaks/STweaks.apk;
			$BB chmod 644 /system/app/STweaks/STweaks.apk;
		fi;
	else
		$BB rm -rf /data/app/com.gokhanmoral.*weak*/ > /dev/null 2>&1;
		$BB rm -rf /data/data/com.gokhanmoral.*weak*/ > /dev/null 2>&1;
		$BB mkdir /system/app/STweaks;
		$BB chown 0.0 /system/app/STweaks;
		$BB chmod 755 /system/app/STweaks;
		$BB cp -a /res/misc/payload/STweaks.apk /system/app/STweaks/;
		$BB chown 0.0 /system/app/STweaks/STweaks.apk;
		$BB chmod 644 /system/app/STweaks/STweaks.apk;
	fi;
fi;

#remove low latency xml as it is not supported by dorimanX kernel!
if [ -e /system/etc/permissions/android.hardware.audio.low_latency.xml ]; then
	$BB rm -f /system/etc/permissions/android.hardware.audio.low_latency.xml > /dev/null 2>&1;
fi;

$BB mount -o remount,rw /;
$BB mount -o remount,rw /system;
