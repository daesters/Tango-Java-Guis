:: @echo off
:: ---------------------------------------------------------

@set TANGO_HOST=172.25.65.1:10000
:: must be absolute, so Salsa can call this script correctly
@set LIBPATH=%~dp0libs\
:: "%0" would be the full path of scripts, and "~dp" is a modifier 
:: to have the path without this script's filename

:: Debug
cd
:: java -mx128m -DTANGO_HOST=%TANGO_HOST% fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli panels/Ueberwachung.jdw
:: java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIB_DIR% fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli panels/Ueberwachung.jdw
java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%TangORB.jar;%LIBPATH%ATKCore.jar;%LIBPATH%ATKWidget.jar;%LIBPATH%ATKPanel.jar;%LIBPATH%LogViewer.jar;%LIBPATH%Jive.jar;%LIBPATH%log4j.jar fr.esrf.tangoatk.widget.attribute.Trend %1 
