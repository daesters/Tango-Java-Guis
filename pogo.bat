:: @echo off
:: ---------------------------------------------------------
:: Needs Javaversion 11 or beyond..

@set TANGO_HOST=172.25.65.1:10000
:: must be absolute, so Salsa can call this script correctly
@set SCRIPTPATH=%~dp0
@set LIBPATH=%SCRIPTPATH%libs\

echo Starting pogo....
start javaw -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%Pogo.jar org.tango.pogo.pogo_gui.Pogo %1 

echo You can close this terminal
timeout 30
::exit