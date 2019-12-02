#!/bin/bash
#---------------------------------------------------------
# Installation script for desktop files in linux for most used TANGO GUIs
# 
# Created by Rafael Gort
# Adapted by Simon Däster
#
# ETH Zürich, Gruppe Vaterlaus
# 2016-2020
#---------------------------------------------------------
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd $SCRIPTPATH

GLOBAL_APPLICATIONSDIR=/usr/share/applications
GLOBAL_ICONDIR=/usr/share/icons/custom

USER_APPLICATIONSDIR=$HOME/.local/share/applications
USER_ICONDIR=$HOME/.local/share/icons

# Default path in .desktop files. Use '', not "". Otherwise, $HOME is replaced....
DEFAULT_SCRIPTPATH='$HOME/Desktop/TangoGuis/GenericGuis/'
DEFAULT_ICONPATH='$HOME/.local/share/icons'

help() {
	cat << EOF
Usage: install.sh [OPTION...]
Installs the desktop files and corresponding icons.
Option:
  -u, --uninstall     	     uninstall icons and desktop files
  -h, --help                 this message
EOF

}

# Helper for uninstall
uninstall_helper() {
	# Desktop files
	rm $1/Astor.desktop	
	rm $1/Jive.desktop	
	rm $1/Trends.desktop	
	rm $1/Jdraw.desktop

	# icons
	rm $2/Astor.png 
	rm $2/Trends.png
	rm $2/Jive.png
	rm $2/Jdraw.png
}

# Main uninstall function
uninstall() {
	uninstall_helper $USER_APPLICATIONSDIR $USER_ICONDIR
	uninstall_helper $GLOBAL_APPLICATIONSDIR $GLOBAL_ICONDIR
}

# Uses the templates and replaces the correct path
fill_templates() {
	cat Jive.desktop.template | sed "s+$DEFAULT_SCRIPTPATH+$1+g" |  sed "s+$DEFAULT_ICONPATH+$2+g" > Jive.desktop
       cat Astor.desktop.template | sed "s+$DEFAULT_SCRIPTPATH+$1+g" |  sed "s+$DEFAULT_ICONPATH+$2+g" > Astor.desktop
       cat Trends.desktop.template | sed "s+$DEFAULT_SCRIPTPATH+$1+g" |  sed "s+$DEFAULT_ICONPATH+$2+g" > Trends.desktop
       cat Jdraw.desktop.template | sed "s+$DEFAULT_SCRIPTPATH+$1+g" |  sed "s+$DEFAULT_ICONPATH+$2+g" > Jdraw.desktop
}


# Copies and moves the icons and desktop files
copy_and_move() {

	cp -f ./Astor.png $2
	cp -f ./Trends.png $2
	cp -f ./Jive.png $2
	cp -f ./Jdraw.png $2

	mv -f ./Astor.desktop $1
	chmod u+x $1/Astor.desktop
	chmod go-x $1/Astor.desktop
	
	mv -f ./Jive.desktop $1
	chmod u+x $1/Jive.desktop
	chmod go-x $1/Jive.desktop

	mv -f ./Trends.desktop $1/
	chmod u+x $1/Trends.desktop
	chmod go-x $1/Trends.desktop

	mv -f ./Jdraw.desktop $1/
	chmod u+x $1/Jdraw.desktop
	chmod go-x $1/Jdraw.desktop
}

# Checks for the directory for icons and creates it, if necessary
check_create_dir() {
	if [ ! -d "$1" ]; then
	  echo "Icon directory does not exist"
	  mkdir $1
	fi
}



# Main programm, local user installation
run_user() {

	fill_templates $USER_APPLICATIONSDIR $USER_ICONDIR

	check_create_dir $USER_ICONDIR

	copy_and_move $USER_APPLICATIONSDIR $USER_ICONDIR

	echo "Installation successful"
}


# Main programm, global root installation
run_as_sudo() {

	fill_templates $GLOBAL_APPLICATIONSDIR $GLOBAL_ICONDIR
	
	# check_create_dir $GLOBAL_APPLICATIONSDIR

	# copy_and_move $GLOBAL_APPLICATIONSDIR $GLOBAL_ICONDIR
	
	echo "Installation successful"
}


# Help or uninstall
if [ ! -z "$1" ] && ([ $1 = "--help" ] || [ $1 = "-h" ]) ; then
	help
	exit
fi

if [ ! -z "$1" ] && ([ $1 = "--uninstall" ] || [ $1 = "-u" ]) ; then
	echo uninstall
	uninstall
	exit
fi


# Normal operation from here on

if [ `whoami` != root ]; then
    	echo "Running as non-sudo, installing in $USER_APPLICATIONSDIR"
    	run_user
else
   	echo You are running as sudo, installing in $GLOBAL_APPLICATIONSDIR
    	#run_as_sudo
fi



