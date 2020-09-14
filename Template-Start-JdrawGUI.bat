:: @echo off
:: ---------------------------------------------------------
@set GUINAME=MainGui-Template.jdw

@set TANGO_HOST=172.25.65.1:10000
:: must be absolute, so Salsa can call this script correctly
@set LIBPATH=libs\

:: The rest should work without new settings ;-)

:: ---------------------------------------------------------
::       Start the synoptic appli process
::---------------------------------------------------------



:: java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%TangORB.jar;%LIBPATH%ATKCore.jar;%LIBPATH%ATKWidget.jar;%LIBPATH%atkpanel.jar;%LIBPATH%LogViewer.jar;%LIBPATH%log4j.jar;%LIBPATH%Astor.jar fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli %GUINAME%

start javaw -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%TangORB.jar;%LIBPATH%ATKCore.jar;%LIBPATH%ATKWidget.jar;%LIBPATH%atkpanel.jar fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli %GUINAME% 
exit