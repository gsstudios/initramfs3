#!/sbin/busybox sh

BB=/sbin/busybox

if [ ! -f /data/.siyah/efsbackup.tar.gz ]; then
	$BB mkdir /data/.siyah;
	$BB chmod 777 /data/.siyah;
	$BB tar zcvf /data/.siyah/efsbackup.tar.gz /efs;
	$BB cat /dev/block/mmcblk0p1 > /data/.siyah/efsdev-mmcblk0p1.img;
	$BB gzip /data/.siyah/efsdev-mmcblk0p1.img;
	$BB cp /data/.siyah/efs* /data/media/;
	$BB chmod 777 /data/media/efsdev-mmcblk0p3.img;
	$BB chmod 777 /data/media/efsbackup.tar.gz;
	(
		$BB sleep 120;
		$BB cp -a /data/media/efs* /sdcard/;
	)&
fi;
