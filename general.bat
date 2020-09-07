:: This script should be called by the TANGO GUI scripts with variable
:: MAINCLASS and GUINAME

echo Starting %GUINAME%...

start javaw -mx128m -DTANGO_HOST=%TANGO_HOST% -cp %LIBPATH%TangORB.jar;%LIBPATH%ATKCore.jar;%LIBPATH%ATKWidget.jar;%LIBPATH%ATKPanel.jar;%LIBPATH%LogViewer.jar;%LIBPATH%Jive.jar;%LIBPATH%log4j.jar;%LIBPATH%Astor.jar;%LIBPATH%DeviceTree.jar;%LIBPATH%JTango.jar;%LIBPATH%DBBench.jar;;%LIBPATH%JSSHTerminal.jar;%LIBPATH%tool_panels.jar %MAINCLASS% %1 

echo You can close this terminal
timeout 3
exit