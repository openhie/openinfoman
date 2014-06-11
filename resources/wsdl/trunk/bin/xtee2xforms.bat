@echo off
rem Usage: xtee2xforms.bat wsdlpath xformspath "param1=value" "param2=value"
 
rem Find the application home.
rem %~dp0 is location of current script under NT
set _REALPATH=%~dp0
java -jar %_REALPATH%\..\lib\saxon9.jar -s:%1 -o:%2 -xsl:%_REALPATH%\..\src\xtee2xforms.xsl %3 %4 %5 %6 %7 %8 %9
