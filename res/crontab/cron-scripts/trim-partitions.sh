#!/sbin/busybox sh
# Clear Cache script

(
	PROFILE=`cat /data/.siyah/.active.profile`;
	. /data/.siyah/${PROFILE}.profile;

	if [ "$cron_trim_partitions" == "on" ]; then

		while [ ! `cat /proc/loadavg | cut -c1-4` \< "3.50" ]; do
			echo "Waiting For CPU to cool down";
			sleep 30;
		done;

		date +%H:%M-%D-%Z > /data/crontab/cron_trim_partitions;
		echo "Trim CACHE Partition" >> /data/crontab/cron_trim_partitions;
                /sbin/fstrim -v /cache  >> /data/crontab/cron_trim_partitions;	
                
                echo "Trim System Partition" >> /data/crontab/cron_trim_partitions;
                /sbin/fstrim -v /system  >> /data/crontab/cron_trim_partitions;
                
                echo "Trim DATA Partition" >> /data/crontab/cron_trim_partitions;
                /sbin/fstrim -v /data  >> /data/crontab/cron_trim_partitions;
                
                echo "Trim Preload Partition" >> /data/crontab/cron_trim_partitions;
                /sbin/fstrim -v /preload  >> /data/crontab/cron_trim_partitions;
                
                echo "All-Done" >> /data/crontab/cron_trim_partitions;
                
		date +%H:%M-%D-%Z >> /data/crontab/cron_trim_partitions;
		echo "Done! Trimming Partitions" >> /data/crontab/cron_trim_partitions;
		sync;
	fi;
)&

