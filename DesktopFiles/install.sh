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

echo $SCRIPTPATH

PROGRAMPATH=$(dirname "$SCRIPTPATH")

GLOBAL_APPLICATIONSDIR=/usr/share/applications
GLOBAL_ICONDIR=/usr/share/icons/custom

USER_APPLICATIONSDIR=$HOME/.local/share/applications
USER_ICONDIR=$HOME/.local/share/icons

# Default path in .desktop files. Use '', not "". Otherwise, $HOME is replaced....
DEFAULT_SCRIPTPATH='$HOME/Desktop/TangoGuis/GenericGuis'
DEFAULT_ICONPATH='$HOME/.local/share/icons'

PROGRAMS="Astor Jive Trends Jdraw"

help() {
	cat << EOF
Usage: install.sh [OPTION...]
Installs the desktop files and corresponding icons.
Option:
  -u, --uninstall     	     uninstall icons and desktop files
  -h, --help                 this message
EOF

}

# Main uninstall function
uninstall() {
	uninstall_helper $USER_APPLICATIONSDIR $USER_ICONDIR
	uninstall_helper $GLOBAL_APPLICATIONSDIR $GLOBAL_ICONDIR
}

# Helper for uninstall
uninstall_helper() {
	# parameter 1: application dir
	 # parameter 2: Icon dir
	# Desktop files
	for program in $PROGRAMS; do
		rm $1/$program.desktop
	done

	# icons
	for program in $PROGRAMS; do
		rm $2/$program.png
	done
}

# Uses the templates and replaces the correct path
fill_templates() {
	# parameter 1: application dir
	 # parameter 2: Icon dir
	# Replace default path with the current programm path
	for program in $PROGRAMS; do
		cat $program.desktop.template | sed "s+$DEFAULT_SCRIPTPATH+$PROGRAMPATH+g" |  sed "s+$DEFAULT_ICONPATH+$2+g" > $program.desktop
	done
}


# Copies and moves the icons and desktop files
copy_and_move() {
	# parameter 1: application dir
	 # parameter 2: Icon dir
	# Move Desktop files and copy icons

	for program in $PROGRAMS; do
		cp -f ./$program.png $2
	 
		 mv -f  ./$program.desktop $1
		 chmod u+x $1/$program.desktop
		 chmod go-x $1/$program.desktop
	done
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
	check_create_dir $GLOBAL_APPLICATIONSDIR
	copy_and_move $GLOBAL_APPLICATIONSDIR $GLOBAL_ICONDIR
	echo "Installation successful"
}

## Start of the programm

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
    run_as_sudo
fi



