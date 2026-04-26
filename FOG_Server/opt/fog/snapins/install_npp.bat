@echo off
:: 1. Instalar Notepad++ de forma silenciosa
start /wait "" "npp_installer.exe" /S

:: 2. Crear el acceso directo en el Escritorio Público (para todos los usuarios)
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%PUBLIC%\Desktop\Notepad++.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "C:\Program Files\Notepad++\notepad++.exe" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%
