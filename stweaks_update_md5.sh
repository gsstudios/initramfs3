md5sum /res/misc/payload/STweaks.apk | awk '{print $1}' > /res/stweaks_md5;
echo "Done!";
cat /res/stweaks_md5;
