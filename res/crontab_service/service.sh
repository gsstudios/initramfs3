#!/sbin/busybox sh

# Created By Dorimanx and Dairinin

JELLY=0;
JB_SAMMY=0;
[ -f /system/lib/ssl/engines/libkeystore.so ] && JELLY=1;
if [ -e /tmp/sammy_rom ]; then
	JB_SAMMY=1;
fi;

# allow custom user jobs
if [ ! -e /data/crontab/root ]; then
	mkdir /data/crontab/;
	cp -a /res/crontab_service/root /data/crontab/;
	chown 0:0 /data/crontab/root;
	chmod 777 /data/crontab/root;
fi;

JELLY_MIUI()
{
	if [ ! -e /system/etc/cron.d/crontabs/root ]; then
		mkdir -p /system/etc/cron.d/crontabs/;
		cp -a /data/crontab/root /system/etc/cron.d/crontabs/;
		chown 0:0 /system/etc/cron.d/crontabs/*;
		chmod 777 /system/etc/cron.d/crontabs/*;
	fi;
	echo "root:x:0:0::/system/etc/cron.d/crontabs:/sbin/sh" > /etc/passwd;
}

JB_SAMMY_CRON()
{
	if [ ! -e /var/spool/cron/crontabs/root ]; then
		mkdir -p /var/spool/cron/crontabs/;
		cp -a /data/crontab/root /var/spool/cron/crontabs/;
		chown 0:0 /var/spool/cron/crontabs/*;
		chmod 777 /var/spool/cron/crontabs/*;
	fi;
	echo "root:x:0:0::/var/spool/cron/crontabs:/sbin/sh" > /etc/passwd;
}

if [ "$JB_SAMMY" -eq "1" ]; then
	JB_SAMMY_CRON;
elif [ "$JELLY" -eq "1" ]; then
	JELLY_MIUI;
else
	JB_SAMMY_CRON;
fi;

# TZ list added by UpInTheAir@github big thanks!
# Check device local timezone & set for cron tasks
timezone=$(date +%z);
if [ "$timezone" == "+1400" ]; then
	TZ=UCT-14
elif [ "$timezone" == "+1300" ]; then
	TZ=UCT-13
elif [ "$timezone" == "+1245" ]; then
	TZ=CIST-12:45CIDT
elif [ "$timezone" == "+1200" ]; then
	TZ=NZST-12NZDT
elif [ "$timezone" == "+1100" ]; then
	TZ=UCT-11
elif [ "$timezone" == "+1030" ]; then
	TZ=LHT-10:30LHDT
elif [ "$timezone" == "+1000" ]; then
	TZ=UCT-10
elif [ "$timezone" == "+0930" ]; then
	TZ=UCT-9:30
elif [ "$timezone" == "+0900" ]; then
	TZ=UCT-9
elif [ "$timezone" == "+0830" ]; then
	TZ=KST
elif [ "$timezone" == "+0800" ]; then
	TZ=UCT-8
elif [ "$timezone" == "+0700" ]; then
	TZ=UCT-7
elif [ "$timezone" == "+0630" ]; then
	TZ=UCT-6:30
elif [ "$timezone" == "+0600" ]; then
	TZ=UCT-6
elif [ "$timezone" == "+0545" ]; then
	TZ=UCT-5:45
elif [ "$timezone" == "+0530" ]; then
	TZ=UCT-5:30
elif [ "$timezone" == "+0500" ]; then
	TZ=UCT-5
elif [ "$timezone" == "+0430" ]; then
	TZ=UCT-4:30
elif [ "$timezone" == "+0400" ]; then
	TZ=UCT-4
elif [ "$timezone" == "+0330" ]; then
	TZ=UCT-3:30
elif [ "$timezone" == "+0300" ]; then
	TZ=UCT-3
elif [ "$timezone" == "+0200" ]; then
	TZ=UCT-2
elif [ "$timezone" == "+0100" ]; then
	TZ=UCT-1
elif [ "$timezone" == "+0000" ]; then
	TZ=UCT
elif [ "$timezone" == "-0100" ]; then
	TZ=UCT1
elif [ "$timezone" == "-0200" ]; then
	TZ=UCT2
elif [ "$timezone" == "-0300" ]; then
	TZ=UCT3
elif [ "$timezone" == "-0330" ]; then
	TZ=NST3:30NDT
elif [ "$timezone" == "-0400" ]; then
	TZ=UCT4
elif [ "$timezone" == "-0430" ]; then
	TZ=UCT4:30
elif [ "$timezone" == "-0500" ]; then
	TZ=UCT5
elif [ "$timezone" == "-0600" ]; then
	TZ=UCT6
elif [ "$timezone" == "-0700" ]; then
	TZ=UCT7
elif [ "$timezone" == "-0800" ]; then
	TZ=UCT8
elif [ "$timezone" == "-0900" ]; then
	TZ=UCT9
elif [ "$timezone" == "-0930" ]; then
	TZ=UCT9:30
elif [ "$timezone" == "-1000" ]; then
	TZ=UCT10
elif [ "$timezone" == "-1100" ]; then
	TZ=UCT11
elif [ "$timezone" == "-1200" ]; then
	TZ=UCT12
else
	TZ=UCT
fi;

# set cron timezone
export TZ

#Set Permissions to scripts
chown 0:0 /data/crontab/cron-scripts/*;
chmod 777 /data/crontab/cron-scripts/*;

# use /system/etc/cron.d/crontabs/ call the crontab file "root" for JB ROMS
# use /var/spool/cron/crontabs/ call the crontab file "root" for ICS ROMS
if [ -e /system/xbin/busybox ] || [ -e /system/bin/busybox ]; then
	if [ "$JB_SAMMY" -eq "1" ]; then
		nohup /system/xbin/busybox crond -c /var/spool/cron/crontabs/
	elif [ "$JELLY" -eq "1" ]; then
		nohup /system/xbin/busybox crond -c /system/etc/cron.d/crontabs/
	else
		nohup /system/xbin/busybox crond -c /var/spool/cron/crontabs/
	fi;
fi;
