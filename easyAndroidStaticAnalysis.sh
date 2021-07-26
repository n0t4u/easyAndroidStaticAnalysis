#!/bin/bash

#Author: n0t4u
#Version: 0.1.1

if [ "$#" -lt 1 ]; then
	echo "No file was provided"
	exit 1
else
	echo "$1"
fi

if [ -z '$(which jadx)' ]; then
	echo "jadx is not installed. Installing now..."
	sudo apt install jadx
	if [ $? -eq 0 ]; then
		echo "jadx correctly installed. Run the script again."
		exit 0
	fi
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
	#echo "$(grep -r -i -P '(25[0-5]|2[0-4][1-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' -o -H -n ${path}/Decompiled/ --color='always' 2>/dev/null)"
	echo -e "HTTP, HTTPS and file connections"
	echo -e "$(grep -r -i -P '(http[s]?|file):\/\/[^\"]+' -h -o ${path}/Decompiled/ 2>/dev/null | grep -v -e 'w3.org' -e 'adobe' | sort| uniq)"
	echo -e "Port conections"
	echo -e "$(grep -r -i -P 'port[_\ \-]{1}[\S\.]*\ ?= ?[\d]{1,5}[ ;]' 2>/dev/null -h ${path}/Decompiled/ --color='always' | grep -i -v -e 'support' -e 'report' )" #Remove --color
	echo -e "Hardcoded passwords"
	echo -e "$(grep -r -i -P '[\S]*P(ass)?w(or)?d ?=[^;]+' -H -n -o --color='always' 2>/dev/null)"
	echo -e "Activities"
	echo -e "$(grep -i -o -P 'activity[\S ]+android:name=\"[^\"]+' ${manifest} | awk '{print $2}' FS='name=\"')"
	echo -e "Exported Activities"
	echo -e "$(grep -i -P 'activity[\S ]+exported=\"true\"' ${manifest} | grep -P 'name=\"[^\"]+' -o | sed 's/name=\"//g')"
	echo -e "Overflow vulnerable functions"
	echo -e "$(grep -r -e 'strcat' -e 'strcpy' -e 'strncat' -e 'strlcat' -e 'strncpy' -e 'strlcpy' -e 'sprintf' -e 'snprintf' -e ' gets(' -e '\.gets(' -h  -H -n --color='always' ${path}/Decompiled/ 2>/dev/null)"
	echo -e "Raw SQL queries"
	echo -e "$(grep -r -i -P '(select [\S]+ from|update [\S]+\delete [\S]+ from|insert [\S]* into)' ${path}/Decompiled/ 2>/dev/null)" #Not tried yet

fi