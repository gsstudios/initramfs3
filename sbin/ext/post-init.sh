#!/sbin/busybox sh

BB=/sbin/busybox

# first mod the partitions then boot
$BB sh /sbin/ext/system_tune_on_init.sh;

ROOT_RW()
{
	$BB mount -o remount,rw /;
}
ROOT_RW;

# fix owners on critical folders
$BB chown -R root:root /tmp;
$BB chown -R root:root /res;
$BB chown -R root:root /sbin;
$BB chown -R root:root /lib;

# oom and mem perm fix
$BB chmod 666 /sys/module/lowmemorykiller/parameters/cost;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/adj;

# protect init from oom
$BB echo "-1000" > /proc/1/oom_score_adj;

# set sysrq to 2 = enable control of console logging level as with CM-KERNEL
$BB echo "2" > /proc/sys/kernel/sysrq;

# bypass for reboot command till fixed.
$BB rm -f /sbin/reboot;

# fix storage folder owner
$BB chown system:sdcard_rw /storage;

PIDOFINIT=$(pgrep -f "/sbin/ext/post-init.sh");
for i in $PIDOFINIT; do
	$BB echo "-600" > /proc/"$i"/oom_score_adj;
done;

if [ "$($BB cat /tmp/sec_rom_boot)" -eq "1" ]; then
	$BB mount -o remount,rw,noauto_da_alloc,journal_async_commit /data;
	$BB mount -o remount,rw,noauto_da_alloc,journal_async_commit /efs;
	$BB mount -o remount,rw /
	$BB umount -l /preload;
	if [ ! -e /data_pri_rom ]; then
		$BB mkdir /data_pri_rom;
		FS_DATA=$($BB cat /tmp/data_fs_check);
		$BB mount -t $FS_DATA /dev/block/mmcblk0p10 /data_pri_rom;
		$BB chmod 700 /data_pri_rom;
	fi;
	if [ ! -e /system_pri_rom ]; then
		$BB mkdir /system_pri_rom;
		$BB mount -t ext4 /dev/block/mmcblk0p9 /system_pri_rom;
		$BB chmod 700 /system_pri_rom;
	fi;
else
	$BB mount -o remount,rw,noauto_da_alloc,journal_async_commit /preload;
fi;

# allow user and admin to use all free mem.
$BB echo 0 > /proc/sys/vm/user_reserve_kbytes;
$BB echo 8192 > /proc/sys/vm/admin_reserve_kbytes;


# Tune entropy parameters.
$BB echo "512" > /proc/sys/kernel/random/read_wakeup_threshold;
$BB echo "256" > /proc/sys/kernel/random/write_wakeup_threshold;

if [ ! -d /data/.siyah ]; then
	$BB mkdir -p /data/.siyah;
fi;

# reset config-backup-restore
if [ -f /data/.siyah/restore_running ]; then
	$BB rm -f /data/.siyah/restore_running;
fi;

# reset profiles auto trigger to be used by kernel ADMIN, in case of need, if new value added in default profiles
# just set number $RESET_MAGIC + 1 and profiles will be reset one time on next boot with new kernel.
RESET_MAGIC=5;
if [ ! -e /data/.siyah/reset_profiles ]; then
	$BB echo "0" > /data/.siyah/reset_profiles;
fi;
if [ "$($BB cat /data/.siyah/reset_profiles)" -eq "$RESET_MAGIC" ]; then
	$BB echo "no need to reset profiles";
else
	$BB rm -f /data/.siyah/*.profile;
	$BB echo "$RESET_MAGIC" > /data/.siyah/reset_profiles;
fi;

[ ! -f /data/.siyah/default.profile ] && $BB cp -a /res/customconfig/default.profile /data/.siyah/default.profile;
[ ! -f /data/.siyah/battery.profile ] && $BB cp -a /res/customconfig/battery.profile /data/.siyah/battery.profile;
[ ! -f /data/.siyah/performance.profile ] && $BB cp -a /res/customconfig/performance.profile /data/.siyah/performance.profile;
[ ! -f /data/.siyah/extreme_performance.profile ] && $BB cp -a /res/customconfig/extreme_performance.profile /data/.siyah/extreme_performance.profile;
[ ! -f /data/.siyah/extreme_battery.profile ] && $BB cp -a /res/customconfig/extreme_battery.profile /data/.siyah/extreme_battery.profile;

$BB chmod -R 0777 /data/.siyah/;

. /res/customconfig/customconfig-helper;
read_defaults;
read_config;

# custom boot booster stage 1
$BB echo "$boot_boost" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;

# mdnie sharpness tweak
if [ "$mdniemod" == "on" ]; then
	$BB sh /sbin/ext/mdnie-sharpness-tweak.sh;
fi;

# Apps and ROOT Install
$BB sh /sbin/ext/install.sh;

# Clean /res/ from no longer needed files to free modules kernel allocated mem
$BB rm -rf /res/misc/sql /res/images /res/misc/vendor;

(
	# check cpu voltage group and report to tmp file, and set defaults for STweaks
	sleep 5;
	ROOT_RW;
	dmesg | grep VDD_INT | cut -c 19-50 > /tmp/cpu-voltage_group;
	$BB chmod 777 /tmp/cpu-voltage_group;

	VDD_INT=$($BB cat /tmp/cpu-voltage_group | $BB cut -c 24);

	if [ "$cpu_voltage_switch" == "off" ] && [ "$VDD_INT" != "3" ]; then
		if [ "$VDD_INT" -eq "1" ]; then
			$BB sh /res/uci.sh cpu-voltage 1 1450;
			$BB sh /res/uci.sh cpu-voltage 2 1400;
			$BB sh /res/uci.sh cpu-voltage 3 1325;
			$BB sh /res/uci.sh cpu-voltage 4 1300;
			$BB sh /res/uci.sh cpu-voltage 5 1275;
			$BB sh /res/uci.sh cpu-voltage 6 1225;
			$BB sh /res/uci.sh cpu-voltage 7 1175;
			$BB sh /res/uci.sh cpu-voltage 8 1125;
			$BB sh /res/uci.sh cpu-voltage 9 1075;
			$BB sh /res/uci.sh cpu-voltage 10 1050;
			$BB sh /res/uci.sh cpu-voltage 11 1025;
			$BB sh /res/uci.sh cpu-voltage 12 1000;
			$BB sh /res/uci.sh cpu-voltage 13 975;
			$BB sh /res/uci.sh cpu-voltage 14 975;
			$BB sh /res/uci.sh cpu-voltage 15 950;
			$BB sh /res/uci.sh cpu-voltage 16 950;
		elif [ "$VDD_INT" -eq "2" ]; then
			$BB sh /res/uci.sh cpu-voltage 1 1450;
			$BB sh /res/uci.sh cpu-voltage 2 1400;
			$BB sh /res/uci.sh cpu-voltage 3 1350;
			$BB sh /res/uci.sh cpu-voltage 4 1325;
			$BB sh /res/uci.sh cpu-voltage 5 1300;
			$BB sh /res/uci.sh cpu-voltage 6 1250;
			$BB sh /res/uci.sh cpu-voltage 7 1200;
			$BB sh /res/uci.sh cpu-voltage 8 1150;
			$BB sh /res/uci.sh cpu-voltage 9 1100;
			$BB sh /res/uci.sh cpu-voltage 10 1050;
			$BB sh /res/uci.sh cpu-voltage 11 1025;
			$BB sh /res/uci.sh cpu-voltage 12 1000;
			$BB sh /res/uci.sh cpu-voltage 13 1000;
			$BB sh /res/uci.sh cpu-voltage 14 1000;
			$BB sh /res/uci.sh cpu-voltage 15 975;
			$BB sh /res/uci.sh cpu-voltage 16 975;
		elif [ "$VDD_INT" -eq "4" ]; then
			$BB sh /res/uci.sh cpu-voltage 1 1400;
			$BB sh /res/uci.sh cpu-voltage 2 1350;
			$BB sh /res/uci.sh cpu-voltage 3 1300;
			$BB sh /res/uci.sh cpu-voltage 4 1275;
			$BB sh /res/uci.sh cpu-voltage 5 1250;
			$BB sh /res/uci.sh cpu-voltage 6 1200;
			$BB sh /res/uci.sh cpu-voltage 7 1150;
			$BB sh /res/uci.sh cpu-voltage 8 1100;
			$BB sh /res/uci.sh cpu-voltage 9 1050;
			$BB sh /res/uci.sh cpu-voltage 10 1000;
			$BB sh /res/uci.sh cpu-voltage 11 1000;
			$BB sh /res/uci.sh cpu-voltage 12 975;
			$BB sh /res/uci.sh cpu-voltage 13 975;
			$BB sh /res/uci.sh cpu-voltage 14 975;
			$BB sh /res/uci.sh cpu-voltage 15 950;
			$BB sh /res/uci.sh cpu-voltage 16 950;
		elif [ "$VDD_INT" -eq "5" ]; then
			$BB sh /res/uci.sh cpu-voltage 1 1375;
			$BB sh /res/uci.sh cpu-voltage 2 1325;
			$BB sh /res/uci.sh cpu-voltage 3 1275;
			$BB sh /res/uci.sh cpu-voltage 4 1250;
			$BB sh /res/uci.sh cpu-voltage 5 1225;
			$BB sh /res/uci.sh cpu-voltage 6 1175;
			$BB sh /res/uci.sh cpu-voltage 7 1125;
			$BB sh /res/uci.sh cpu-voltage 8 1075;
			$BB sh /res/uci.sh cpu-voltage 9 1025;
			$BB sh /res/uci.sh cpu-voltage 10 975;
			$BB sh /res/uci.sh cpu-voltage 11 975;
			$BB sh /res/uci.sh cpu-voltage 12 950;
			$BB sh /res/uci.sh cpu-voltage 13 950;
			$BB sh /res/uci.sh cpu-voltage 14 950;
			$BB sh /res/uci.sh cpu-voltage 15 925;
			$BB sh /res/uci.sh cpu-voltage 16 925;
		fi;
	fi;
)&

# busybox addons
if [ -e /system/xbin/busybox ] && [ ! -e /sbin/ifconfig ]; then
	$BB ln -s /system/xbin/busybox /sbin/ifconfig;
fi;

######################################
# Loading Modules
######################################
(
	sleep 40;
	# order of modules load is important
#	$BB insmod /system/lib/modules/j4fs.ko;
#	$BB mount -t j4fs /dev/block/mmcblk0p4 /mnt/.lfs

	if [ "$usbserial_module" == "on" ]; then
		if [ -e /system/lib/modules/usbserial.ko ]; then
			$BB insmod /system/lib/modules/usbserial.ko;
			$BB insmod /system/lib/modules/ftdi_sio.ko;
			$BB insmod /system/lib/modules/pl2303.ko;
		else
			$BB insmod /lib/modules/usbserial.ko;
			$BB insmod /lib/modules/ftdi_sio.ko;
			$BB insmod /lib/modules/pl2303.ko;
		fi;
	fi;
	if [ "$cifs_module" == "on" ]; then
		if [ -e /system/lib/modules/cifs.ko ]; then
			$BB insmod /system/lib/modules/cifs.ko;
		else
			$BB insmod /lib/modules/cifs.ko;
		fi;
	fi;
	if [ "$eds_module" == "on" ]; then
		if [ -e /system/lib/modules/eds.ko ]; then
			$BB insmod /system/lib/modules/eds.ko;
		else
			$BB insmod /lib/modules/eds.ko;
		fi;
	fi;
)&

# some nice thing for dev
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq /cpufreq;
	$BB ln -s /sys/devices/system/cpu/cpufreq/ /cpugov;
fi;

# enable kmem interface for everyone by GM
$BB echo "0" > /proc/sys/kernel/kptr_restrict;

# Cortex parent should be ROOT/INIT and not STweaks
nohup /sbin/ext/cortexbrain-tune.sh;
CORTEX=$($BB pgrep -f "/sbin/ext/cortexbrain-tune.sh");
$BB echo "-900" > /proc/"$CORTEX"/oom_score_adj;

# create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	$BB mkdir -p /system/etc/init.d/
	$BB chmod 755 /system/etc/init.d/;
fi;

(
	if [ "$init_d" == "on" ]; then
		$BB sh /sbin/ext/run-init-scripts.sh;
	fi;
)&

# disable debugging on some modules
if [ "$logger" == "off" ]; then
	$BB echo "0" > /sys/module/ump/parameters/ump_debug_level;
	$BB echo "0" > /sys/module/mali/parameters/mali_debug_level;
	$BB echo "0" > /sys/module/kernel/parameters/initcall_debug;
	$BB echo "0" > /sys/module/lowmemorykiller/parameters/debug_level;
	$BB echo "0" > /sys/module/cpuidle_exynos4/parameters/log_en;
	$BB echo "0" > /sys/module/earlysuspend/parameters/debug_mask;
	$BB echo "0" > /sys/module/alarm/parameters/debug_mask;
	$BB echo "0" > /sys/module/alarm_dev/parameters/debug_mask;
	$BB echo "0" > /sys/module/binder/parameters/debug_mask;
	$BB echo "0" > /sys/module/xt_qtaguid/parameters/debug_mask;
fi;

ROOT_RW;

(
	# mount apps2sd partition point for CyanogenMod
	if [ "$($BB cat /tmp/sec_rom_boot)" -eq "1" ]; then
		$BB mount --bind /mnt/.secondrom/.android_secure /mnt/secure/asec;
	fi;

	SD_COUNTER=0;
	while [ "$($BB mount | ($BB grep '179_11' || $BB grep '179:11') | $BB wc -l)" == "0" ]; do
		if [ "$SD_COUNTER" -ge "60" ]; then
			break;
		fi;
		$BB echo "Waiting For Internal SDcard to be mounted";
		$BB sleep 5;
		SD_COUNTER=$((SD_COUNTER+1));
		# max 5min
	done;

	if [ -e /sys/block/mmcblk1/queue/scheduler ]; then
		$BB echo "deadline" > /sys/block/mmcblk1/queue/scheduler;
	fi;
)&

(
	COUNTER=0;
	$BB echo "0" > /tmp/uci_done;
	$BB chmod 666 /tmp/uci_done;

	while [ "$($BB cat /tmp/uci_done)" != "1" ]; do
		if [ "$COUNTER" -ge "40" ]; then
			break;
		fi;
		$BB echo "500000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
		$BB echo "$boot_boost" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
		$BB pkill -f "com.gokhanmoral.stweaks.app";
		$BB echo "Waiting For UCI to finish";
		$BB sleep 3;
		COUNTER=$((COUNTER+1));
		# max 2min
	done;

	# restore normal freq
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
	if [ "$scaling_max_freq" -eq "1000000" ] && [ "$scaling_max_freq_oc" -gt "1000000" ]; then
		$BB echo "$scaling_max_freq_oc" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
	else
		$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
	fi;

	# tweaks all the dm partitions that hold moved to sdcard apps
	$BB sleep 30;
	DM_COUNT=$($BB find /sys/block/dm* | $BB wc -l);
	if [ "$DM_COUNT" -gt "0" ]; then
		for d in $($BB mount | $BB grep dm | $BB cut -d " " -f1 | $BB grep -v vold); do
			$BB mount -o remount,noauto_da_alloc "$d";
		done;

		DM=$(find /sys/block/dm*);
		for i in ${DM}; do
			$BB echo "0" > "$i"/queue/rotational;
			$BB echo "0" > "$i"/queue/iostats;
		done;
	fi;

	# script finish here, so let me know when
	$BB echo "Done Booting" > /data/dm-boot-check;
	$BB date >> /data/dm-boot-check;
)&

(
	# stop uci.sh from running all the PUSH Buttons in stweaks on boot
	$BB mount -o remount,rw rootfs;
	$BB chown -R root:system /res/customconfig/actions/;
	$BB chmod -R 6755 /res/customconfig/actions/;
	$BB mv /res/customconfig/actions/push-actions/* /res/no-push-on-boot/;
	$BB chmod 6755 /res/no-push-on-boot/*;

	# apply STweaks settings
	$BB echo "booting" > /data/.siyah/booting;
	$BB chmod 777 /data/.siyah/booting;
	$BB pkill -f "com.gokhanmoral.stweaks.app";
	nohup $BB sh /res/uci.sh restore;
	UCI_PID=$(pgrep -f "/res/uci.sh");
	$BB echo "-800" > /proc/"$UCI_PID"/oom_score_adj;
	ROOT_RW;
	$BB echo "1" > /tmp/uci_done;

	# restore all the PUSH Button Actions back to there location
	$BB mv /res/no-push-on-boot/* /res/customconfig/actions/push-actions/;
	$BB pkill -f "com.gokhanmoral.stweaks.app";

	# change USB mode MTP or Mass Storage
	$BB sh /res/uci.sh usb-mode "$usb_mode";

	# update cpu tunig after profiles load
	$BB sh /sbin/ext/cortexbrain-tune.sh apply_cpu update > /dev/null;
	$BB rm -f /data/.siyah/booting;

	# ###############################################################
	# I/O related tweaks
	# ###############################################################

	$BB mount -o remount,rw /system;

	# correct touch keys light, if rom mess user configuration
	$BB sh /res/uci.sh generic /sys/class/misc/notification/led_timeout_ms "$led_timeout_ms";

	# Update UKSM in case ROM changed to other setting.
	if [ "$run" == "on" ]; then
		$BB echo "1" > /sys/kernel/mm/uksm/run;
	else
		$BB echo "0" > /sys/kernel/mm/uksm/run;
	fi;
	$BB echo "$sleep_millisecs" > /sys/kernel/mm/uksm/sleep_millisecs;
	$BB echo "10" > /sys/kernel/mm/uksm/max_cpu_percentage;
)&

(
	# kill radio logcat to sdcard
	$BB pkill -f "logcat -b radio -v time";

	# EFS Backup
	$BB sh /sbin/ext/efs-backup.sh;
)&
