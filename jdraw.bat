:: @echo off
:: ---------------------------------------------------------

@echo off
:: ---------------------------------------------------------

@set TANGO_HOST=172.25.65.1:10000
:: must be absolute, so Salsa can call this script correctly
@set SCRIPTPATH=%~dp0
@set LIBPATH=%SCRIPTPATH%libs\
:: "%0" would be the full path of scripts, and "~dp" is a modifier 
:: to have the path without this script's filename
@set MAINCLASS=fr.esrf.tangoatk.widget.util.jdraw.JDrawEditorFrame
@set GUINAME=JDraw

call %SCRIPTPATH%general.bat
