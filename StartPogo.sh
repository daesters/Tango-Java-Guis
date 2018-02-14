#!/bin/bash

#---------------------------------------------------------
#	Add Doc path to $PATH (depends on OS used)
#---------------------------------------------------------
#TANGO_HOME=/usr/local;		export TANGO_HOME
MY_OS=`uname`
export MY_OS

CPP_DOC=NOT_INSTALLED
#---------------------------------------------------------
#	Set the template path
#---------------------------------------------------------
#TEMPLATES=/usr/local/share/pogo/templates
#export TEMPLATES

#---------------------------------------------------------
#	Set the Home Source Path
#---------------------------------------------------------
SRC_PATH=../generated
export SRC_PATH

#---------------------------------------------------------
#	Set the Class Path for Tango and pogo usage
#---------------------------------------------------------
APP_DIR=libs;			export APP_DIR
PREF_DIR=libs;			export PREF_DIR

POGO_CLASS=$APP_DIR/org.tango.pogo.jar;		export POGO_CLASS

CLASSPATH=$PREF_DIR:$POGO_CLASS;    export CLASSPATH

#---------------------------------------------------------
#	Start the Pogo process
#---------------------------------------------------------
echo "Starting Pogo Appli under $MY_OS.  "
#

/usr/bin/java 	-DCPP_DOC_PATH=$CPP_DOC		\
		-DIN_LANG=$POGO_LANG		\
		-DEDITOR=$POGO_EDITOR 		\
		-Dfile.encoding=ISO-8859-1 	\
		org.tango.pogo.pogo_gui.Pogo $*

