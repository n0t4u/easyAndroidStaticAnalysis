#!/bin/bash

#Author: n0t4u
#Version: 0.2.3

#Source: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Reset
ColorOff='\033[0m'       # Text Reset


if [ "$#" -lt 1 ]; then
	echo -e "${Red}[x] No file was provided${ColorOff}"
	exit 1
else
	echo -e "${Cyan}File${ColorOff}\t$1"
fi

if [ -z '$(which jadx)' ]; then
	echo -e "${Blue}[*] jadx is not installed. Installing now...${ColorOff}"
	sudo apt install jadx
	if [ $? -eq 0 ]; then
		echo -e "${Green}[»] jadx correctly installed. Run the script again.${ColorOff}"
		exit 0
	fi
fi
if [ "$2" ]; then
	path="$2"
else
	path="$(pwd)"
fi

echo -e "${Cyan}Path${ColorOff}\t${path}"
if [[ -d "${path}/Decompiled" ]];then
    echo -e "${Yellow}[!] Decompiled folder found. Skipping APK decompilation.${ColorOff}"
else
	echo -e "${Cyan}[*] Decompiling APK with jadx...${ColorOff}"
	mkdir -p "${path}/Decompiled"
	decompile="jadx --no-debug-info -d ${path}/Decompiled $(pwd)/$1"
	$decompile
	if [ $? -ne 0 ]; then
	echo -e "${Red}[x] There was a problem while trying to decompile the application${ColorOff}"
	exit 1
	else
		echo -e "${Green}[»] Successfully decompiled${ColorOff}"
	fi
fi


#Find manifest location
manifest=$(find ${path}/Decompiled -type f -name AndroidManifest.xml)
#Get application name
echo -e "${Cyan}Application name${ColorOff}\t $(grep	-i -P "<string name=\"appName\">[\S ]+</string>" ${path}/Decompiled/resources/res/values/strings.xml | cut -d ">" -f 2 | cut -d "<" -f 1)"
#Get Package name of the application
echo -e "${Cyan}Package name${ColorOff}\t $(grep -i -P "package=\"[\S]+\""  ${manifest} -o | awk '{print $2}' FS='=\"' |tr -d '"')"
#Get Android version
echo -e "${Cyan}Application Version${ColorOff}\t $(grep -i -P "android:VersionName=\"[\S]\"" ${manifest} -o | awk '{print $2}' FS='=\"' | tr -d '"')"
#Get minimum SDK version allowed
echo -e "${Cyan}Min SDK${ColorOff}\t\t $(grep -i -P "minSdkVersion\=\"[\d]{1,2}" -o  ${manifest} | awk '{print $2}' FS='=\"')"
#Get targeted SDK version
echo -e "${Cyan}Target SDK${ColorOff}\t $(grep -i -P "targetSdkVersion\=\"[\d]{1,2}" -o  ${manifest} | awk '{print $2}' FS='=\"')"
#Get maximum SDK version allowed
echo -e "${Cyan}Max SDK${ColorOff}\t $(grep -i -P "maxSdkVersion\=\"[\d]{1,2}" -o  ${manifest} | awk '{print $2}' FS='=\"')"
#Get debuggable flag
echo -e "${Cyan}Is debuggable?${ColorOff}\t $(grep -i -P "android:debuggable=\"(true|false)"  ${manifest} -o | awk '{print $2}' FS='=\"')"
#Get backup flag
echo -e "${Cyan}AllowBackup?${ColorOff}\t $(grep -i -P "android:allowBackup=\"(true|false)"  ${manifest} -o | awk '{print $2}' FS='=\"')"
#Get HTTP flag
echo -e "${Cyan}usesCleartextTraffic?${ColorOff}\t $(grep -i -P "android:usesCleartextTraffic=\"(true|false)"  ${manifest} -o | awk '{print $2}' FS='=\"')"
#Get install location
echo -e "${Cyan}installLocation${ColorOff}\t $(grep -i -P "android:installLocation=\"[\S]+\"" ${manifest} -o | awk '{print $2}' FS='=\"' | sed 's/\"$//g')"
#Show AndroidManifest.xml location
echo -e "${Cyan}Manifest Path\t ${ColorOff}${manifest}"

#Checksums
echo -e "${Cyan}md5${ColorOff}\t$(md5sum ${path}/${1} | awk '{print $1}')"
echo -e "${Cyan}sha1${ColorOff}\t$(sha1sum ${path}/${1}| awk '{print $1}')"
echo -e "${Cyan}sha256${ColorOff}\t$(sha256sum ${path}/${1} | awk '{print $1}')"

#Get Permissions
echo -e "\n${Cyan}Permissions${ColorOff}"
echo "$(grep -i -P '<uses-permission [\S ]+\/>' -o ${manifest} | awk '{print $2}' FS='=\"' | sed 's/\" \?\/>$//g')"
#Get IP Addresses in the code
echo -e "${Cyan}IP Addresses${ColorOff}"
echo "$(grep -r -i -P '(25[0-5]|2[0-4][1-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' -o -H -n ${path}/Decompiled/ --color='always' 2>/dev/null | grep -v -e '0.0.0.0')" #-H -n
#Get web connections in the code
echo -e "${Cyan}HTTP, HTTPS and file connections${ColorOff}"
echo -e "$(grep -r -i -P '(http[s]?|file):\/\/[^\"]+' -h -o ${path}/Decompiled/ 2>/dev/null | grep -v -e 'w3.org' -e 'adobe' -e 'apache.org' -e 'xml.org' -e 'googleapis.com' | grep -v -P 'schemas.(microsoft|openxmlformats|android|xmlsoap)' | sort| uniq)"
#Get port numbers in the code
echo -e "${Cyan}Port conections${ColorOff}"
echo -e "$(grep -r -i -P '[\ \-\_]?port[_\ \-]{1}[\S\.]*\ ?= ?[\d]{1,5}[ ;]' 2>/dev/null -h ${path}/Decompiled/ --color='always' | grep -i -v -e 'support' -e 'report' )" #Remove --color
#Get hardcoded passwords
echo -e "${Cyan}Hardcoded passwords${ColorOff}"
echo -e "$(grep -r -i -P '[\S]*P(ass)?w(or)?d ?=[^;]+' -H -n -o --color='always' 2>/dev/null | grep -v -P "R[\S]*\.java")"
#Get application's activities found in the manifest
activities=$(grep -i -o -P 'activity[\S ]+android:name=\"[^\"]+' ${manifest} | awk '{print $2}' FS='name="')
echo -e "${Cyan}Activity names${ColorOff}"
for i in ${activities}; do echo ${i};	done
echo -e "${Cyan}Activity paths${ColorOff}"
for i in ${activities}; do find ${path} -name "$(echo ${i} | awk '{print $(NF)}' FS='.').java";	done
#Identify exported Activities
echo -e "${Cyan}Exported activities${ColorOff}"
for i in $(grep -i -P 'activity[\S ]+exported=\"true\"' ${manifest} | grep -P 'name=\"[^\"]+' -o | sed 's/name=\"//g'); do echo ${i};done
#Get application's services found in the manifest
echo -e "${Cyan}Services${ColorOff}"
for i in $(grep -i -o -P 'service[\S ]+android:name=\"[^\"]+' ${manifest} | awk '{print $2}' FS='name="'); do echo ${i};	done
#Identify exported Services
echo -e "${Cyan}Exported services${ColorOff}"
for i in $(grep -i -P 'service[\S ]+exported=\"true\"' ${manifest} | grep -P 'name=\"[^\"]+' -o | sed 's/name=\"//g'); do echo ${i};done
#Get application's receivers found in the manifest
echo -e "${Cyan}Receivers${ColorOff}"
for i in $(grep -i -o -P 'receiver[\S ]+android:name=\"[^\"]+' ${manifest} | awk '{print $2}' FS='name="'); do echo ${i};	done
#Identify exported Receivers
echo -e "${Cyan}Exported receivers${ColorOff}"
#Get application's providers found in the manifest
echo -e "${Cyan}Providers${ColorOff}"
for i in $(grep -i -o -P 'provider[\S ]+android:name=\"[^\"]+' ${manifest} | awk '{print $2}' FS='name="'); do echo ${i}; done
#Identify exported Providers
echo -e "${Cyan}Exported providers${ColorOff}"
for i in $(grep -i -P 'provider[\S ]+exported=\"true\"' ${manifest} | grep -P 'name=\"[^\"]+' -o | sed 's/name=\"//g'); do echo ${i}; done
#Check if any overflow vulnerable function is used"
echo -e "${Cyan}Overflow vulnerable functions${ColorOff}"
echo -e "$(grep -r -e 'strcat' -e 'strcpy' -e 'strncat' -e 'strlcat' -e 'strncpy' -e 'strlcpy' -e 'sprintf' -e 'snprintf' -e ' gets(' -e '\.gets(' -h  -H -n --color='always' ${path}/Decompiled/ 2>/dev/null)"
#Get Raw SQL queries from code"
echo -e "${Cyan}Raw SQL queries${ColorOff}"
echo -e "$(grep -r -i -o -H -n --color='always' -P '(\")[\S ]*(select [\S]+ from |update [\S]+\delete [\S]+ from |insert [\S]* into )[^\"]*' ${path}/Decompiled/ 2>/dev/null | sed 's/^"//g')" #Not tried yet
#Get keywords regarding to execution commands
echo -e "${Cyan}Executable commands${ColorOff}"
echo -e "$(grep -r -i --color='always' -H -n -P '[\S]*((^android.)runtime|exec(^utor)|(^android.)shell)[^\r\n;\{\}\(\)]+' -o -h ${path}/Decompiled/ 2>/dev/null)" #sql[^ite]{3}|