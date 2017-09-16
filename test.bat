rem chcp 1251
rem @echo off
Setlocal
rem Set Cat="C:\Program Files (x86)\1cv8\common"
Set Cat="F:\Program\8.3.9.2170\bin"
Set Base=F:\1CBasesv8
Set Email_from=komvi.bkp@yandex.ru
Set Email_to=ivalkor@gmail.com
Set logfile=backup.log
Set tmplog=tmplog.log
Set key="ssh-ed25519 256 c3:80:41:87:c7:2d:be:30:98:cf:ee:e0:1e:d2:65:07"
Set storage=sftp://u36403:9keehiykz7@storage.u36403.netangels.ru/
Set BackupPath=F:\filebackup
Set Status=Success

dir %BackupPath% /B | findstr %date%
If %ErrorLevel% == 0 goto clean


echo -------%date%------------ >> %logfile%
echo %time% >> %logfile%

echo ---Start backup KOMVI--- >> %logfile%

%Cat%\1cv8.exe CONFIG /F"%Base%\KOMVI" /DisableStartupMessages /DumpIB"%BackupPath%\1c83_KOMVI_%date%.dt" /NАдминистратор /OUT"%tmplog%"
if %ERRORLEVEL% neq 0 ( type %tmplog% >> %logfile% && echo ERROR >> %logfile%
) else ( type %tmplog% >> %logfile% && echo SUCCESS in backuping 1c KOMVI >> %logfile% )
echo ---End backup KOMVI--- >> %logfile%


echo ---Start send KOMVI--- >> %logfile%
winscp.com  /log=Winscp.log /command ^
"open %storage% -hostkey="%key%"" "put "%BackupPath%\1c83_KOMVI_%date%.dt"" "exit" >> %logfile%
if %ERRORLEVEL% neq 0 ( echo ERROR in uploading KOMVI.dt to storage >> %logfile%
) else ( echo Success in uploading KOMVI >> %logfile% ) 
echo ---End send KOMVI--- >> %logfile%
type Winscp.log >> WinscpFull.log
findstr /I "error" %logfile%
if %ErrorLevel% == 0 Set Status=Error
echo %Status%
pause
sendemail.exe -f %email_from% -t %email_to% -a WinscpFull.log -u "[KOMVI Backup] %Status%" -o message-file=%logfile% -s smtp.yandex.ru:25 -xu komvi.bkp@yandex.ru -xp jLOS5CR7

del %tmplog%
endlocal
exit