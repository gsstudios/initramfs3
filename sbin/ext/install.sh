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

# check if new SuperSU exist in kernel, and if Superuser installed, then replace with new SuperSu.
NEW_SU=1;
if [ -e /tmp/cm10.1-installed ]; then
		NEW_SU=0;
fi;

if [ -e /tmp/cm10.2-installed ] || [ -e /tmp/cm11-installed ] || [ -e /tmp/sammy_rom ]; then
	if [ -e /system/app/SuperSU.apk ] && [ -e /system/xbin/daemonsu ]; then
		if [ -e /system/chainfire/SuperSU.apk ]; then
			sumd5sum=$($BB md5sum /system/app/SuperSU.apk | $BB awk '{print $1}');
		else
			sumd5sum=1;
		fi;
		if [ -e /system/chainfire/SuperSU.apk.md5 ]; then
			sumd5sum_kernel=$(cat /system/chainfire/SuperSU.apk.md5);
		else
			sumd5sum_kernel=1;
		fi;
		if [ "$sumd5sum" == "$sumd5sum_kernel" ]; then
			NEW_SU=0;
		else
			NEW_SU=1;
		fi;
	else
		NEW_SU=1;
	fi;
fi;

if [ "$install_root" == "on" ] && [ ! -e /tmp/cm12.1-installed ]; then
	if [ "$NEW_SU" -eq "0" ]; then
		echo "SuperSU already exists";
		$BB chmod 06755 /system/xbin/su;
		if [ -e /system/xbin/daemonsu ]; then
			$BB chmod 6755 /system/xbin/daemonsu;
			if [ -e /system/etc/install-recovery.sh ]; then
				$BB rm /system/etc/install-recovery.sh;
			fi;
		fi;
	else
		echo "ROOT NOT detected, Installing SuperSU";
		#extract_payload;
		# clean su traces
		$BB rm -f /system/bin/su > /dev/null 2>&1;
		$BB rm -f /system/xbin/su > /dev/null 2>&1;
		$BB chmod 755 /system/xbin;
		if [ ! -d /system/bin/.ext ]; then
			$BB mkdir /system/bin/.ext;
			$BB chmod 777 /system/bin/.ext;
		else
			$BB rm -f /system/bin/.ext/* > /dev/null 2>&1;
		fi;

		# clean super user old apps
		$BB rm -f /system/app/*uper?ser.apk > /dev/null 2>&1;
		$BB rm -f /system/app/?uper?u.apk > /dev/null 2>&1;
		$BB rm -f /system/app/*chainfire?supersu.apk > /dev/null 2>&1;
		$BB rm -f /data/app/*uper?ser.apk > /dev/null 2>&1;
		$BB rm -f /data/app/?uper?u.apk > /dev/null 2>&1;
		$BB rm -f /data/app/*chainfire?supersu.apk > /dev/null 2>&1;
		$BB rm -f /data/dalvik-cache/*uper?ser.apk* > /dev/null 2>&1;
		$BB rm -f /data/dalvik-cache/*chainfire?supersu.apk* > /dev/null 2>&1;

		if [ -e /system/chainfire/SuperSU.apk ]; then
			$BB cp /system/chainfire/SuperSU.apk /system/app/;
			$BB cp /system/chainfire/SuperSUNoNag-v1.00.apk /system/app/;
			$BB cp /system/chainfire/xbin/access /system/xbin/su;
			$BB cp /system/chainfire/xbin/access /system/xbin/daemonsu;

			if [ ! -e /system/xbin/chattr ]; then
				$BB cp /system/chainfire/xbin/chattr /system/xbin/;
				$BB chmod 6755 /system/xbin/chattr;
			fi;
			$BB chmod 06755 /system/xbin/su;
			$BB chmod 6755 /system/xbin/daemonsu;
			$BB chmod 644 /system/app/SuperSU.apk;
			$BB chmod 644 /system/app/SuperSUNoNag-v1.00.apk;
			$BB chown 0.0 /system/app/SuperSU.apk;
			$BB chown 0.0 /system/app/SuperSUNoNag-v1.00.apk;
			$BB cp -a /system/xbin/su /system/bin/.ext/;
		elif [ -e /system_pri_rom/chainfire/SuperSU.apk ]; then
			$BB cp /system_pri_rom/chainfire/SuperSU.apk /system/app/;
			$BB cp /system_pri_rom/chainfire/SuperSUNoNag-v1.00.apk /system/app/;
			$BB cp /system_pri_rom/chainfire/xbin/access /system/xbin/su;
			$BB cp /system_pri_rom/chainfire/xbin/access /system/xbin/daemonsu;

			if [ ! -e /system/xbin/chattr ]; then
				$BB cp /system_pri_rom/chainfire/xbin/chattr /system/xbin/;
				$BB chmod 6755 /system/xbin/chattr;
			fi;
			$BB chmod 06755 /system/xbin/su;
			$BB chmod 6755 /system/xbin/daemonsu;
			$BB chmod 644 /system/app/SuperSU.apk;
			$BB chmod 644 /system/app/SuperSUNoNag-v1.00.apk;
			$BB chown 0.0 /system/app/SuperSU.apk;
			$BB chown 0.0 /system/app/SuperSUNoNag-v1.00.apk;
			$BB cp -a /system/xbin/su /system/bin/.ext/;
		else
			# extract SU binary
			$BB cp -a /res/misc/payload/su /system/bin/.ext/su;
			$BB cp -a /res/misc/payload/su /system/xbin/su;
			$BB chown 0.0 /system/xbin/su;
			$BB chmod 06755 /system/xbin/su;
			$BB chown 0.0 /system/bin/.ext/su;
			$BB chmod 06755 /system/bin/.ext/su;

			# extract super user app
			$BB cp -a /res/misc/payload/SuperSU.apk /system/app/;
			$BB chown 0.0 /system/app/SuperSU.apk;
			$BB chmod 644 /system/app/SuperSU.apk;
		fi;

		if [ ! -e /data/app/*chainfire?supersu.pr*.apk ]; then
			if [ -e /data/system/chain_pro.apk_bkp ]; then
				$BB mv /data/system/chain_pro.apk_bkp /system/app/eu.chainfire.supersu.pro-1.apk;
				$BB chmod 644 /system/app/eu.chainfire.supersu.pro-1.apk;
			else
				echo "no su pro" > /dev/null 2>&1;
			fi;
		fi;

		# restore witch if exist
		if [ -e /system/xbin/waswhich-bkp ]; then
			$BB rm -f /system/xbin/which;
			$BB cp /system/xbin/waswhich-bkp /system/xbin/which;
			$BB chmod 755 /system/xbin/which;
		fi;

		if [ -e /system/xbin/boxman ]; then
			$BB rm -f /system/xbin/busybox;
			$BB mv /system/xbin/boxman /system/xbin/busybox;
			$BB chmod 755 /system/xbin/busybox;
			$BB mv /system/bin/boxman /system/bin/busybox;
			$BB chmod 755 /system/bin/busybox;
		fi;

		# kill superuser pid
		$BB pkill -f "com.noshufou.android.su";
		$BB pkill -f "eu.chainfire.supersu";
		/system/xbin/daemonsu --auto-daemon &
	fi;
fi;

# liblights install by force to allow BLN
if [ ! -e /system/lib/hw/lights.exynos4.so.BAK ]; then
	$BB mv /system/lib/hw/lights.exynos4.so /system/lib/hw/lights.exynos4.so.BAK;
fi;
echo "Copying liblights";
$BB cp -a /res/misc/lights.exynos4.so /system/lib/hw/lights.exynos4.so;
$BB chown root:root /system/lib/hw/lights.exynos4.so;
$BB chmod 644 /system/lib/hw/lights.exynos4.so;

# add gesture_set.sh with default gustures to data to be used by user.
if [ ! -e /data/gesture_set.sh ]; then
	$BB cp -a /res/misc/gesture_set.sh /data/;
fi;

if [ -f /system/app/Extweaks.apk ] || [ -f /data/app/com.darekxan.extweaks.ap*.apk ]; then
	$BB rm -f /system/app/Extweaks.apk > /dev/null 2>&1;
	$BB rm -f /data/app/com.darekxan.extweaks.ap*.apk > /dev/null 2>&1;
	$BB rm -rf /data/data/com.darekxan.extweaks.app > /dev/null 2>&1;
	$BB rm -f /data/dalvik-cache/*com.darekxan.extweaks.app* > /dev/null 2>&1;
fi;

STWEAKS_CHECK=$($BB find /data/app/ -name com.gokhanmoral.stweaks* | wc -l);

if [ "$STWEAKS_CHECK" -eq "1" ]; then
	$BB rm -f /data/app/com.gokhanmoral.stweaks* > /dev/null 2>&1;
	$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
fi;

if [ ! -e /tmp/cm12.1-installed ]; then
	if [ -e /system/app/STweaks.apk ]; then
		stmd5sum=$($BB md5sum /system/app/STweaks.apk | $BB awk '{print $1}');
		stmd5sum_kernel=$(cat /res/stweaks_md5);
		if [ "$stmd5sum" != "$stmd5sum_kernel" ]; then
			$BB rm -f /system/app/STweaks.apk > /dev/null 2>&1;
			$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
			$BB rm -f /data/dalvik-cache/*gokhanmoral.*weak*.apk* > /dev/null 2>&1;
			$BB rm -f /cache/dalvik-cache/*gokhanmoral.*weak*.apk* > /dev/null 2>&1;
			$BB cp -a /res/misc/payload/STweaks.apk /system/app/;
			$BB chown 0.0 /system/app/STweaks.apk;
			$BB chmod 644 /system/app/STweaks.apk;
		fi;
	else
		$BB rm -f /data/app/com.gokhanmoral.*weak*.apk > /dev/null 2>&1;
		$BB rm -rf /data/data/com.gokhanmoral.*weak*/ > /dev/null 2>&1;
		$BB rm -f /data/dalvik-cache/*gokhanmoral.*weak*.apk* > /dev/null 2>&1;
		$BB rm -f /cache/dalvik-cache/*gokhanmoral.*weak*.apk* > /dev/null 2>&1;
		$BB cp -a /res/misc/payload/STweaks.apk /system/app/;
		$BB chown 0.0 /system/app/STweaks.apk;
		$BB chmod 644 /system/app/STweaks.apk;
	fi;
fi;

if [ -e /tmp/cm12.1-installed ]; then
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
