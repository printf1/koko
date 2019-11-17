@echo off

setlocal enabledelayedexpansion

set BATCH_PATH=%~dp0
cd %BATCH_PATH%

set log=%BATCH_PATH%%~n0.log
call :tee account_login is start 

REM get whoami
set whoami=
for /f "delims=" %%i in ('whoami') do (
	set whoami=%%i
)
call :tee whoami=%whoami%

REM check the file is exist
if not exist  %BATCH_PATH%321_honban_info.txt goto file_not_exist

set zb=
set username=
set comment=
set fullname=
set account_zb=
set hokairai=
set gp=

set uy=運用
set uy_v=Administrators

set bs=保守
set bs_v=Users

set sys=システム
set sys_v= 

set cmd1=
set bean=false

 FOR /f "delims= " %%I IN ('date /t') DO SET F_DATE=%%I
  SET D_DATE=%F_DATE:/=%
  echo !D_DATE!
  SET SYSDATE=%D_DATE:~-4%
  echo !SYSDATE!
 
for /f "eol=' tokens=1-7 delims=," %%a in (%BATCH_PATH%321_honban_info.txt) do (
  REM check parameter
  if %%a == "" goto err_param
  if %%b == "" goto err_param
  if %%e == "" goto err_param
  if %%g == "" goto err_param
  
  
  
  
  rem echo !uy!-!uy_v!
  rem echo !bs!-!bs_v!
  REM check match
  
   
  
  if %%e ==!uy! if not %%g ==!uy_v! goto err_param
  if %%e ==!bs! if not %%g ==!bs_v! goto err_param
  
  set zb=%%a
  set username=%%b
  set comment=%%c
  set fullname=%%d
  set account_zb=%%e
  set hokairai=%%f
  set gp=%%g
     
  set D_USER=%%b
  set str=!D_USER!
  set U_PASSWORD=
  goto LOOPSTR
  
  
  :LOOPSTR
  if not "%str%"=="" (
     (set str=%str:~0,-1%)
     (set U_PASSWORD=%U_PASSWORD%%str:~-1%)
     (goto :LOOPSTR)
  )
  
  SET passwd=Nx%U_PASSWORD%#%SYSDATE% > %log% 
 
  
  echo !gp! 2>>%log% 
  net localgroup !gp! 2>nul >>%log% 
  if !ERRORLEVEL! neq 0 (
  goto err_none
  )  

  net user !username! 2>>%log% 
  if !ERRORLEVEL! equ 0 (
  goto err_exist 
  )   
  
  set cmd1=net user !username! !username! /add
  if not !comment! == "" ( set cmd1=!cmd1! /comment:"!comment!")
  if not !fullname! == "" ( set cmd1=!cmd1! /fullname:"!fullname!")
  echo cmd1 : !cmd1! 2>>%log%
  
  
  
 
  rem echo user:!username! hasn't logged in yet. >> %log%  
  !cmd1! 2>>%log%
  
  
   
  
  net user !username! !passwd!
  wmic useraccount where Name="!username!" set PasswordExpires=FALSE
  if not "!account_zb!" == "!uy!" (
  wmic useraccount where Name="!username!" set PasswordChangeable=FALSE
  )
  if not "!gp!" == "!bs_v!" (
  net localgroup "!gp!" "!username!" /add
  )  
  if not "!gp!" == "!bs_v!" (
  net localgroup Users !username! /delete
  )
  echo Confirm after login 
  set bean=true  
  REM runas /user:!username! cmd 
)
 
if "!bean!" == "false" goto err_empty


call :tee account_login is end
exit /b 0




:err_exist
call :tee !username! is exist. 
echo user is exist.
mshta vbscript:msgbox("User is exist",0,"confirm the configuration file")(window.close)
exit /b 1

:err_param
call :tee Parameter is illegal.
echo Parameter is illegal.
mshta vbscript:msgbox("Parameter is illegal",0,"confirm the configuration file")(window.close)
exit /b 1

:file_not_exist
call :tee 321_honban_info.txt is not exist.
echo 321_honban_info.txt is not exist.
mshta vbscript:msgbox("%BATCH_PATH%321_honban_info.txt is not exist",0,"confirm the configuration file")(window.close)
exit /b 1

:err_none
call :tee group doesn't exist
echo group doesn't exist
mshta vbscript:msgbox("group doesn't exist",0,"confirm the configuration file")(window.close)
exit /b 1

:err_empty
call :tee 321_honban_info.txt is empty.
echo 321_honban_info.txt is empty.
mshta vbscript:msgbox("321_honban_info.txt is empty",0,"confirm the configuration file")(window.close)
exit /b 1

:tee 
echo %DATE% %TIME% %* >> %log% 
exit /b 0