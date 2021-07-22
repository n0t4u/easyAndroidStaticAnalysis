#!/bin/bash

#Author: n0t4u
#Version: 0.1.0

if [ "$#" -lt 1 ]; then
	echo "No file was provided"
	exit 1
else
	echo "$1"
fi

if [ -z '$(which jadx)' ]; then
	echo "jadx is not installed. Installing now..."
	sudo apt install jadx
fi
if [ "$2" ]; then
	path="$2"
else
	path="$(pwd)"
fi

# echo "${path}"
# mkdir -p "${path}/Decompiled"
# decompile="jadx --no-debug-info -d ${path}/Decompiled $(pwd)/$1"
# $decompile

if [ $? -ne 0 ]; then
	echo "There was a problem while trying to decompile the application"
	exit 1
else
	echo "Successfully decompiled"
	manifest=$(find ${path}/Decompiled -type f -name AndroidManifest.xml)
	echo "${manifest}"

	echo -e "Package name \t $(grep -i -P "package=\"[\S]+\""  ${manifest} -o | awk '{print $2}' FS='=\"' |tr -d '"')"
	echo -e "Min SDK\t\t $(grep -i -P "minSdkVersion\=\"[\d]{1,2}" -o  ${manifest} | awk '{print $2}' FS='=\"')"
	echo -e "Target SDK\t $(grep -i -P "targetSdkVersion\=\"[\d]{1,2}" -o  ${manifest} | awk '{print $2}' FS='=\"')"
	echo -e "Max SDK\t $(grep -i -P "maxSdkVersion\=\"[\d]{1,2}" -o  ${manifest} | awk '{print $2}' FS='=\"')"
	echo -e "Is debuggable?\t $(grep -i -P "android:debuggable=\"(true|false)"  ${manifest} -o | awk '{print $2}' FS='=\"')"
	echo -e "AllowBackup?:\t $(grep -i -P "android:allowBackup=\"(true|false)"  ${manifest} -o | awk '{print $2}' FS='=\"')"
	echo -e "usesCleartextTraffic? \t $(grep -i -P "android:usesCleartextTraffic=\"(true|false)"  ${manifest} -o | awk '{print $2}' FS='=\"')"
	
	echo -e "Permissions"
	echo "$(grep -i -P '\"[\S\.]+permission[^\"]+' -o ${manifest} | tr -d '"')"
	echo -e "IP Addresses"
	echo "$(grep -r -i -P "(25[0-5]|2[0-4][1-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" -o -H -n ${path}/Decompiled/ --color='always' 2>/dev/null)"

fi