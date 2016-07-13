#/bin/bash

# Optimization script by @VUKO github

#############################################
#        howto: compress pictures
# You will need to install binary files first
# apt-get install aptitude
# aptitude install optipng pngcrush jpegoptim
#############################################

# protect recovery images from modding, or recovery will be broken.
mv res/images/icon_installing*.png /tmp/;
mv res/images/indeterminate*.png /tmp/;
mv res/images/progress_*.png /tmp/;

find . -iname '*.png' -exec optipng -o7 {} \;

for file in `find . -name "*.png"`;do
	echo $file;
	pngcrush -rem alla -reduce -brute "$file" tmp_img_file.png;
	mv -f tmp_img_file.png $file;
done;

find . -iname '*.jpg' -exec jpegoptim --force {} \;

# restore recovery images type.
mv /tmp/icon_installing*.png res/images/;
mv /tmp/indeterminate*.png res/images/;
mv /tmp/progress_*.png res/images/;

echo "done, picks optimized"
