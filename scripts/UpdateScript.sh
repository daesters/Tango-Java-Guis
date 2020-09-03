#!/bin/sh

# This script was created by Y. Acremann, and changed by S. Däster
# Does either call the Java binaries from the system in /usr/local/share
# from a previously compilation of the TANGO source code
# Or it calls the web updater

#!/bin/bash

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

# output colorized
output() {
	if [ "$2" != "" ]; then
		case $2 in
			"heading")
				color=$Cyan
				;;
			"error")
				color=$Red
				;;
			"info"|"warning")
				color=$Yellow
				;;
			"success")
				color=$Green
				;;
			*)
				color=$2
				;;
		esac
		echo "$color$1$Color_Off"
	else
		echo $1
	fi
}

systemUpdate() {

rm ./libs/*

cp -f /usr/local/share/java/Astor.jar ./libs
cp -f /usr/local/share/java/ATKCore.jar ./libs
cp -f /usr/local/share/java/ATKPanel.jar ./libs
cp -f /usr/local/share/java/ATKWidget.jar ./libs
cp -f /usr/local/share/java/DBBench.jar ./libs
cp -f /usr/local/share/java/DeviceTree.jar ./libs
cp -f /usr/local/share/java/Jive.jar ./libs
cp -f /usr/local/share/java/JSSHTerminal.jar ./libs
cp -f /usr/local/share/java/JTango.jar ./libs
cp -f /usr/local/share/java/log4j.jar ./libs
cp -f /usr/local/share/java/LogViewer.jar ./libs
cp -f /usr/local/share/java/org.tango.pogo.jar ./libs/Pogo.jar
cp -f /usr/local/share/java/TangORB.jar ./libs
cp -f /usr/local/share/java/tool_panels.jar ./libs
cp -f /usr/local/share/java/zmq.jar ./libs
cp -f /usr/local/lib/libzmq* ./libs
cp -f /usr/local/lib/libjzmq* ./libs
}


output "### Welcome to the Tango Java libraries Update Script  ###" "heading"

read -p "You want to update from the web (w) or from system (s)? [W/s] " answer


case $answer in
	""|[wW]* ) 
		output "Okay, updating from web"
	   ./WebUpdate-Symlink.py --noprompt
	   ;;

	[sS]* )  
		output "Okay, updating from system"
		systemUpdate
		output "Done." "success"
		;;

	* )     
		output "Dude, just enter w or s, please." "warning"
		;;
esac
