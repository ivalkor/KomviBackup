chcp 1251
@echo off
Setlocal
rem Set Cat="C:\Program Files (x86)\1cv8\common"
Set Cat="F:\Program\8.3.9.2170\bin"
Set Base=F:\1CBasesv8
Set Email_from=komvi.bkp@yandex.ru
Set Email_to=ivalkor@gmail.com
Set logfile=backup.log
Set tmplog=tmplog.log
Set key="ssh-ed25519 256 c3:80:41:87:c7:2d:be:30:98:cf:ee:e0:1e:d2:65:07"
Set storage=
Set BackupPath=F:\filebackup
Set Status=Success

IF EXIST WinscpFull.log del WinscpFull.log
IF EXIST %logfile% del %logfile%

dir %BackupPath% /B | findstr %date%
If %ErrorLevel% == 0 goto clean


echo -------%date%------------ >> %logfile%
echo %time% >> %logfile%

echo ---Start backup KOMVI--- >> %logfile%
%Cat%\1cv8.exe CONFIG /F"%Base%\KOMVI" /DisableStartupMessages /DumpIB"%BackupPath%\1c83_KOMVI_%date%.dt" /NАдминистратор /OUT"%tmplog%"
if %ERRORLEVEL% neq 0 ( type %tmplog% >> %logfile% && echo ERROR >> %logfile%
) else ( type %tmplog% >> %logfile% && echo SUCCESS in backuping 1c KOMVI >> %logfile% )
echo ---End backup KOMVI--- >> %logfile%

echo ---Start backup SP_KOMVI--- >> %logfile%
%Cat%\1cv8.exe CONFIG /F"%Base%\SP_KOMVI" /DisableStartupMessages /DumpIB"%BackupPath%\1c83_SP_KOMVI_%date%.dt" /NАдминистратор /OUT"%tmplog%"
if %ERRORLEVEL% neq 0 ( type %tmplog% >> %logfile% && echo ERROR >> %logfile%
) else ( type %tmplog% >> %logfile% && echo SUCCESS in backuping 1c SP_KOMVI >> %logfile% )
echo ---End backup SP_KOMVI--- >> %logfile%


echo ---Start send KOMVI--- >> %logfile%
winscp.com  /log=Winscp.log /command ^
"open %storage% -hostkey="%key%"" "put "%BackupPath%\1c83_KOMVI_%date%.dt"" "exit" >> %logfile%
if %ERRORLEVEL% neq 0 ( echo ERROR in uploading KOMVI.dt to storage >> %logfile%
) else ( echo Success in uploading KOMVI >> %logfile% ) 
type Winscp.log >> WinscpFull.log
echo ---End send KOMVI--- >> %logfile%


echo ---Start send SP_KOMVI--- >> %logfile%
winscp.com  /log=Winscp.log /command ^
"open %storage% -hostkey="%key%"" "put "%BackupPath%\1c83_SP_KOMVI_%date%.dt"" "exit"
if %ERRORLEVEL% neq 0 ( echo ERROR in uploading SP_KOMVI.dt to storage >> %logfile% 
) else ( echo Success in uploading SP_KOMVI >> %logfile% )
type Winscp.log >> WinscpFull.log
echo ---End send SP_KOMVI--- >> %logfile%


findstr /I "error" %logfile%

if %ERRORLEVEL% == 0 set Status=Error

sendemail.exe -f %email_from% -t %email_to% -a WinscpFull.log -u "[KOMVI Backup] %Status%" -o message-file=%logfile% -s smtp.yandex.ru:25 -xu komvi.bkp@yandex.ru 

:clean
rem cleancache
rem If Exist %USERPROFILE%\AppData\Roaming\1C\1Cv82 ( 
rem Удаляем все файлы 
rem Del /F /Q %USERPROFILE%\AppData\Roaming\1C\1Cv82\*.* 
rem Del /F /Q %USERPROFILE%\AppData\Local\1C\1Cv82\*.* 

rem Удаляем все каталоги
rem for /d %%i in ("%USERPROFILE%\AppData\Roaming\1C\1Cv82\*") do rmdir /s /q "%%i" 
rem for /d %%i in ("%USERPROFILE%\AppData\Local\1C\1Cv82\*") do rmdir /s /q "%%i" 
rem )


del Winscp.log
del %tmplog%
endlocal

exit



