#!/bin/sh

# In the main shell script, include the following variable
# JAVA_VERSIONS_ACCEPTED=11,13,14
# JAVA_BIN=/usr/bin/java

# Terminal output
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

#---------------------------------------------------------
#      Checking java binary 
#---------------------------------------------------------
JAVA_DEFAULT=/usr/bin/java

if [ -f "$JAVA_BIN" ]; then 
	echo -e "${Cyan}Using self definied java binary!$Color_Off"
else
	# variable even defined? -> Yes: warn. No: be silent ;-)
	if [ -v JAVA_BIN ]; then
		echo -e "${Red}$JAVA_BIN does not exist. Using $JAVA_DEFAULT instead$Color_Off"
	fi
	JAVA_BIN=$JAVA_DEFAULT
fi

#---------------------------------------------------------
#      Checking java version 
#---------------------------------------------------------
JAVA_VERSION_FULL=`$JAVA_BIN -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f-2`
# Java 8 is 1.8, Java 11,13, 14, ... is 11.0, 13.0, 14.0
PART0=$(echo "$JAVA_VERSION_FULL" | cut -d'.' -f1)
PART1=$(echo "$JAVA_VERSION_FULL" | cut -d'.' -f2)
# echo "$PART0 - $PART1"
if [ $PART0 -eq 1 ]; then
	# echo "Debug: Below 11"
	JAVA_VERSION=$PART1
else
	# echo "Debug: Starting from 11"
	JAVA_VERSION=$PART0
fi
VERSION_LIST=$(echo "$JAVA_VERSIONS_ACCEPTED" | tr "," "\n")
MATCH=0
for version in $VERSION_LIST
do
	# echo "Debug: Checking version $version"
	if [ $version -eq $JAVA_VERSION ]; then
		MATCH=1
		break
	fi
done
if [ $MATCH -eq 0  ]; then
        echo -e "${Yellow}Version check: Using java version $JAVA_VERSION instead of $JAVA_VERSIONS_ACCEPTED. Might not work$Color_Off"
else
        echo -e "${Green}Version check: Using java version $JAVA_VERSION. Should work$Color_Off"
fi

