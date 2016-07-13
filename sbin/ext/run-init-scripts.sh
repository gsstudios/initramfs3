#!/sbin/busybox sh

BB=/sbin/busybox

if [ -d /system/etc/init.d ]; then
	$BB chmod 755 /system/etc/init.d/*;
	$BB run-parts /system/etc/init.d/;
fi;

if [ -f /system/bin/customboot.sh ]; then
	$BB chmod 755 /system/bin/customboot.sh;
	$BB sh /system/bin/customboot.sh;
fi;

if [ -f /system/xbin/customboot.sh ]; then
	$BB chmod 755 /system/xbin/customboot.sh;
	$BB sh /system/xbin/customboot.sh;
fi;

if [ -f /data/local/customboot.sh ]; then
	$BB chmod 755 /data/local/customboot.sh;
	$BB sh /data/local/customboot.sh;
fi;
