#!/bin/sh

# This script was created by Y. Acremann, and changed by S. Däster
# Does either call the Java binaries from the system in /usr/local/share
# from a previously compilation of the TANGO source code
# Or it calls the web updater

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

echo "### Welcome to the Tango jAva Libraries Update Script [TALUS] :-D ###"

read -p "You want to update from the web (w) or from system (s)? [W/s] " answer


case $answer in
""|[wW]* ) 
       echo "Okay, updating from web"
       ./UpdateFromWeb.py --noprompt
       ;;

[sS]* )  echo "Okay, updating from system"
         systemUpdate
         echo "Done."
        ;;

* )     echo "Dude, just enter w or s, please.";;
esac
