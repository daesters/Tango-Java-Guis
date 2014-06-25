:: @echo off
:: ---------------------------------------------------------

@set TANGO_HOST=172.25.65.1:10000

:: java -mx128m -DTANGO_HOST=%TANGO_HOST% fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli panels/Ueberwachung.jdw
:: java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIB_DIR% fr.esrf.tangoatk.widget.jdraw.SimpleSynopticAppli panels/Ueberwachung.jdw
java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp TangORB.jar;ATKCore.jar;ATKWidget.jar;atkpanel.jar;LogViewer.jar;Jive.jar;log4j.jar jive3.MainPanel
