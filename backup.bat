CHCP 1251
@ECHO OFF
SETLOCAL EnableDelayedExpansion
rem SET Cat="C:\Program Files (x86)\1cv8\common"
SET MAILPASSWD=
SET STORAGEPASSWD=
REM SET Cat="F:\Program\8.3.9.2170\bin"
SET Cat="F:\Program\8.3.9.2170\bin"
SET Base=F:\1CBasesv8
SET Email_from=komvi.bkp@yandex.ru
SET Email_to=ivalkor@gmail.com
SET logfile=backup.log
SET tmplog=tmplog.log
SET key="ssh-ed25519 256 c3:80:41:87:c7:2d:be:30:98:cf:ee:e0:1e:d2:65:07"

SET storage=sftp://u36403:!STORAGEPASSWD!@storage.u36403.netangels.ru/
SET BackupPath=F:\filebackup
SET Status=Success

IF EXIST WinscpFull.log del WinscpFull.log
IF EXIST %logfile% del %logfile%

DIR %BackupPath% /B | findstr %date%
IF %ErrorLevel% == 0 goto clean


ECHO %date% %time%  >> %logfile%

ECHO Start backup KOMVI >> %logfile%
%Cat%\1cv8.exe CONFIG /F"%Base%\KOMVI" /DisableStartupMessages /DumpIB"%BackupPath%\1c83_KOMVI_%date%.dt" /NАдминистратор /OUT"%tmplog%"
IF %ERRORLEVEL% neq 0 ( TYPE %tmplog% >> %logfile% && ECHO ERROR >> %logfile%
) ELSE ( TYPE %tmplog% >> %logfile% && ECHO SUCCESS in backuping 1c KOMVI >> %logfile% )

ECHO %date% %time%  >> %logfile%

ECHO Start backup SP_KOMVI >> %logfile%
%Cat%\1cv8.exe CONFIG /F"%Base%\SP_KOMVI" /DisableStartupMessages /DumpIB"%BackupPath%\1c83_SP_KOMVI_%date%.dt" /NАдминистратор /OUT"%tmplog%"
IF %ERRORLEVEL% neq 0 ( TYPE %tmplog% >> %logfile% && ECHO ERROR >> %logfile%
) ELSE ( TYPE %tmplog% >> %logfile% && ECHO SUCCESS in backuping 1c SP_KOMVI >> %logfile% )

ECHO %date% %time%  >> %logfile%

ECHO Start send KOMVI >> %logfile%
winscp.com  /log=Winscp.log /command ^
"open %storage% -hostkey="%key%"" "put "%BackupPath%\1c83_KOMVI_%date%.dt"" "exit" >> %logfile%
IF %ERRORLEVEL% neq 0 ( ECHO ERROR in uploading KOMVI.dt to storage >> %logfile%
) ELSE ( ECHO Success in uploading KOMVI >> %logfile% ) 
TYPE Winscp.log >> WinscpFull.log

ECHO %date% %time%  >> %logfile%

ECHO ---Start send SP_KOMVI--- >> %logfile%
winscp.com  /log=Winscp.log /command ^
"open %storage% -hostkey="%key%"" "put "%BackupPath%\1c83_SP_KOMVI_%date%.dt"" "exit"
IF %ERRORLEVEL% neq 0 ( ECHO ERROR in uploading SP_KOMVI.dt to storage >> %logfile% 
) ELSE ( ECHO Success in uploading SP_KOMVI >> %logfile% )
TYPE Winscp.log >> WinscpFull.log

ECHO %date% %time%  >> %logfile%

FINDSTR /I "error" %logfile%

IF %ERRORLEVEL% == 0 SET Status=Error

sendemail.exe -f %email_from% -t %email_to% -a WinscpFull.log -u "[KOMVI Backup] %Status%" -o message-file=%logfile% -s smtp.yandex.ru:25 -xu komvi.bkp@yandex.ru -xp %MAILPASSWD%

:clean
rem cleancache
rem IF Exist %USERPROFILE%\AppData\Roaming\1C\1Cv82 ( 
rem Удаляем все файлы 
rem Del /F /Q %USERPROFILE%\AppData\Roaming\1C\1Cv82\*.* 
rem Del /F /Q %USERPROFILE%\AppData\Local\1C\1Cv82\*.* 

rem Удаляем все каталоги
rem for /d %%i in ("%USERPROFILE%\AppData\Roaming\1C\1Cv82\*") do rmdir /s /q "%%i" 
rem for /d %%i in ("%USERPROFILE%\AppData\Local\1C\1Cv82\*") do rmdir /s /q "%%i" 
rem )


DEL Winscp.log
DEL %tmplog%
ENDLOCAL

EXIT



