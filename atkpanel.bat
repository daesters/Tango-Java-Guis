:: @echo off
:: ---------------------------------------------------------

@set TANGO_HOST=172.25.65.1:10000
:: must be absolute, so Salsa can call this script correctly
@set LIBPATH=C:\Users\user\Documents\TangoGuis\GenericGuis\libs\

:: Debug
cd
:: java -mx128m -DTANGO_HOST=%TANGO_HOST% fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli panels/Ueberwachung.jdw
:: java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIB_DIR% fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli panels/Ueberwachung.jdw
java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%TangORB.jar;%LIBPATH%ATKCore.jar;%LIBPATH%ATKWidget.jar;%LIBPATH%Atkpanel.jar;%LIBPATH%LogViewer.jar;%LIBPATH%Jive.jar;%LIBPATH%log4j.jar atkpanel.MainPanel %1 
