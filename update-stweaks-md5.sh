#!/bin/bash
md5sum res/misc/payload/STweaks.apk | awk '{print $1}' > res/stweaks_md5;
chmod 644 res/stweaks_md5;
cat res/stweaks_md5;
