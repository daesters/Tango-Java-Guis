#!/bin/bash

JAVA_VERSION_NEEDED=11

#---------------------------------------------------------
#      Checking java version 
#---------------------------------------------------------

JAVA_VERSION=`java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f-2`
if [ "$JAVA_VERSION" != "$JAVA_VERSION_NEEDED" ]; then
        echo "Using java version $JAVA_VERSION instead of $JAVA_VERSION_NEEDED. Might not work"
else
        echo "Using java version $JAVA_VERSION. Should work"
fi

#---------------------------------------------------------
#       Open TANGO settings if any
#---------------------------------------------------------

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd $SCRIPTPATH
#---------------------------------------------------------
#	Add Doc path to $PATH (depends on OS used)
#---------------------------------------------------------
#TANGO_HOME=/usr/local;		export TANGO_HOME
MY_OS=`uname`
export MY_OS

#---------------------------------------------------------
#	Set the Class Path for Tango and pogo usage
#---------------------------------------------------------
APP_DIR=libs;			export APP_DIR
PREF_DIR=libs;			export PREF_DIR

POGO_CLASS=$APP_DIR/Pogo.jar;		export POGO_CLASS

CLASSPATH=$PREF_DIR:$POGO_CLASS;    export CLASSPATH

APPLI_PACKAGE=org.tango.pogo.pogo_gui;  export APPLI_PACKAGE
APPLI_MAIN_CLASS=Pogo;		export APPLI_MAIN_CLASS

#---------------------------------------------------------
#	Start the Pogo process
#---------------------------------------------------------
echo "Starting Pogo Appli under $MY_OS.  "
#

#/usr/bin/java 	-DCPP_DOC_PATH=$CPP_DOC		\
#		-DIN_LANG=$POGO_LANG		\
#		-DEDITOR=$POGO_EDITOR 		\
#		-Dfile.encoding=ISO-8859-1 	\
#		org.tango.pogo.pogo_gui.Pogo $*

/usr/bin/java  $APPLI_PACKAGE.$APPLI_MAIN_CLASS $@
