@echo off
:: ---------------------------------------------------------
@set GUINAME=MainGui.jdw

@set TANGO_HOST=172.25.65.1:10000
:: must be absolute, so Salsa can call this script correctly
@set LIBPATH=C:\Users\user\Documents\TangoGuis\GenericGuis\libs\

:: The rest should work without new settings ;-)

:: ---------------------------------------------------------
::       Start the synoptic appli process
::---------------------------------------------------------



start javaw -mx32m -Djava.library.path=$LIBPATH -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%TangORB.jar;%LIBPATH%ATKCore.jar;%LIBPATH%ATKWidget.jar;%LIBPATH%Atkpanel.jar;%LIBPATH%LogViewer.jar;%LIBPATH%log4j.jar;%LIBPATH%Astor.jar;%LIBPATH%tool_panels.jar fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli %GUINAME% 
exit