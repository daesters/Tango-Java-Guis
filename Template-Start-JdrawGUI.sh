#!/bin/sh

# Settings for this gui
GUINAME=MainGui.jdw
PATH_GENERIC_GUIS=../GenericGuis

#optional
TANGO_HOST=orkan.mott.loc:10000

JAVA_VERSION_NEEDED=1.8
# -------------------
# The rest should work witouth new settings ;-)

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

# Checking Java version
JAVA_VERSION=`java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f-2`
if [ "$JAVA_VERSION" != "$JAVA_VERSION_NEEDED" ]; then
	echo "Using java version $JAVA_VERSION instead of $JAVA_VERSION_NEEDED. Might not work"
else
	echo "Using java version $JAVA_VERSION. Should work"
fi

java -mx128m -Djava.library.path=$LIBPATH -DTANGO_HOST=$TANGO_HOST $APPLI_PACKAGE.$APPLI_MAIN_CLASS $GUINAME

