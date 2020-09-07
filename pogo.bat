:: @echo off
:: ---------------------------------------------------------
:: Needs Javaversion 11 or beyond..

@set TANGO_HOST=172.25.65.1:10000
:: must be absolute, so Salsa can call this script correctly
@set LIBPATH=%~dp0libs\

java -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%Pogo.jar org.tango.pogo.pogo_gui.Pogo %1 