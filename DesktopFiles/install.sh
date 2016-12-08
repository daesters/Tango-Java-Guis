#!/bin/bash
#---------------------------------------------------------
#
#---------------------------------------------------------
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd $SCRIPTPATH

if [ ! -d "/usr/share/icons/custom" ]; then
  echo "Directory does not exist"
  mkdir /usr/share/icons/custom
fi

cp ./Astor.png /usr/share/icons/custom/
cp ./Astor.desktop /usr/share/applications/
chmod g-x /usr/share/applications/Astor.desktop
chmod o-x /usr/share/applications/Astor.desktop

cp ./Jive.png /usr/share/icons/custom/
cp ./Jive.desktop /usr/share/applications/
chmod g-x /usr/share/applications/Jive.desktop
chmod o-x /usr/share/applications/Jive.desktop

cp ./Trends.png /usr/share/icons/custom/
cp ./Trends.desktop /usr/share/applications/
chmod g-x /usr/share/applications/Trends.desktop
chmod o-x /usr/share/applications/Trends.desktop

echo "Installation successful"
