#!/bin/bash

# In the main shell script, include the following variable
# JAVA_VERSIONS_ACCEPTED=11,13,14
#---------------------------------------------------------
#      Checking java version 
#---------------------------------------------------------
JAVA_VERSION_FULL=`java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f-2`
# Java 8 is 1.8, Java 11,13, 14, ... is 11.0, 13.0, 14.0
PART0=$(echo "$JAVA_VERSION_FULL" | cut -d'.' -f1)
PART1=$(echo "$JAVA_VERSION_FULL" | cut -d'.' -f2)
# echo "$PART0 - $PART1"
if [ $PART0 -eq 1 ]; then
	# echo "Below 11"
	JAVA_VERSION=$PART1
else
	# echo "Starting from 11"
	JAVA_VERSION=$PART0
fi
VERSION_LIST=$(echo "$JAVA_VERSIONS_ACCEPTED" | tr "," "\n")
MATCH=0
for version in $VERSION_LIST
do
	# echo "Checking verison $version"
	if [ $version -eq $JAVA_VERSION ]; then
		MATCH=1
		break
	fi
done
if [ $MATCH -eq 0  ]; then
        echo "Version check: Using java version $JAVA_VERSION instead of $JAVA_VERSIONS_ACCEPTED. Might not work"
else
        echo "Version check: Using java version $JAVA_VERSION. Should work"
fi

