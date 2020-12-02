#!/bin/sh

# Settings for this gui
GUINAME=MainGui.jdw
PATH_GENERIC_GUIS=../GenericGuis
JAVA_BIN=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
JAVA_VERSIONS_ACCEPTED=6,8

#optional
TANGO_HOST=orkan.mott.loc:10000
JAVA_VERSION_NEEDED=1.8
MEMORY_ALLOCATION=32 #memory allocation in Megabytes

# -------------------
# The rest should work witouth new settings ;-)

#---------------------------------------------------------
#      Checking java version 
#---------------------------------------------------------

source check-java-version.sh

#---------------------------------------------------------
#       Open TANGO settings if any
#---------------------------------------------------------

if [ ! $TANGO_HOST ] && [ -f /etc/tangorc ]; then
   . /etc/tangorc
fi


# Java class path variables
JAVALIB=$PATH_GENERIC_GUIS/libs

TANGO=$JAVALIB/TangORB.jar

TANGOATK=$JAVALIB/ATKCore.jar:$JAVALIB/ATKWidget.jar
ATKPANEL=$JAVALIB/atkpanel.jar
LOGVIEWER=$JAVALIB/LogViewer.jar
ASTOR=$JAVALIB/Astor.jar:$JAVALIB/tools_panel.jar
LOG4J=$JAVALIB/log4j.jar

APPLI_PACKAGE=fr.esrf.tangoatk.widget.jdraw;	export APPLI_PACKAGE
APPLI_MAIN_CLASS=SimpleSynopticAppli; export APPLI_MAIN_CLASS

CLASSPATH=$TACO:$TANGO:$TANGOATK:$ATKPANEL:$LOGVIEWER:$ASTOR:$LOG4J
export CLASSPATH
LIBPATH=./libs

#---------------------------------------------------------
#       Start the synoptic appli process
#---------------------------------------------------------
#

$JAVA_BIN -mx"$MEMORY_ALLOCATION"m -Djava.library.path=$LIBPATH -DTANGO_HOST=$TANGO_HOST $APPLI_PACKAGE.$APPLI_MAIN_CLASS $GUINAME

