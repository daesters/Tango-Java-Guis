#!/bin/bash
#---------------------------------------------------------
#
#---------------------------------------------------------
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd $SCRIPTPATH

APPLICATIONSDIR=/usr/share/applications
# Default path in .desktop files
DEFAULTSCRIPTPATH='\/home\/geissepeter\/Desktop\/TangoGuis\/GenericGuis'

if [ ! -d "/usr/share/icons/custom" ]; then
  echo "Directory does not exist"
  mkdir /usr/share/icons/custom
fi

# Replace (next commit)
# sed -i 's/$DEFAULTSCRIPTPATH/$SCRIPTPATH/g' Astor.desktop.tpl > Astor.desktop

cp ./Astor.png /usr/share/icons/custom/
cp ./Astor.desktop $APPLICATIONSDIR


chmod g-x $APPLICATIONSDIR/Astor.desktop
chmod o-x $APPLICATIONSDIR/Astor.desktop

cp ./Jive.png /usr/share/icons/custom/
cp ./Jive.desktop $APPLICATIONSDIR/

chmod g-x $APPLICATIONSDIR/Jive.desktop
chmod o-x $APPLICATIONSDIR/Jive.desktop

cp ./Trends.png /usr/share/icons/custom/
cp ./Trends.desktop $APPLICATIONSDIR/

chmod g-x $APPLICATIONSDIR/Trends.desktop
chmod o-x $APPLICATIONSDIR/Trends.desktop

echo "Installation successful"
