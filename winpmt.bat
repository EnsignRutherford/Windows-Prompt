@ECHO OFF & SETLOCAL
REM ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
REM
REM Name:        WINPMT.BAT
REM
REM Description: Custom Command Processor prompt for Windows 10+.  
REM              Windows before version 10 has no native support for ANSI colors on the console, hence the original work in the article
REM              below has not worked since support for the MS-DOS subsystem was dropped, dropping ANSI.SYS support.
REM              An update to an article originally published in PC Magazine, originally dated March 28th, 1995 page 252.
REM              https://books.google.com/books?id=eMKimy4DFaEC&printsec=frontcover&source=gbs_ge_summary_r&cad=0#v=onepage&q&f=false
REM
REM              This script takes advantage of escape sequences originally supported by ANSI.SYS that were added back into Windows 10+:
REM              https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
REM
REM              NOTE: This now ONLY works on Windows 10+ as it takes advantages of specific codes and functions only available in
REM                    Windows 10+.
REM                    This file must be encoded as ANSI in order for the copyright symbol to work properly.
REM
REM Author:      Russ Le Blang
REM
REM Date:        May 11th, 2023
REM
REM ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

REM Setup defaults
SET COMMAND_PROCESSOR_ANSI_ENABLE_KEY=HKCU\Console
SET COMMAND_PROCESSOR_REGISTRY_ANSI_ENABLE_VALUE=VirtualTerminalLevel
SET COMMAND_PROCESSOR_REGISTRY_KEY=HKCU\Software\Microsoft\Command Processor
SET COMMAND_PROCESSOR_REGISTRY_KEY2=HKCU\Console\%%SystemRoot%%_system32_cmd.exe
SET COMMAND_PROCESSOR_REGISTRY_AUTORUN_VALUE=AutoRun
SET COMMAND_PROCESSOR_REGISTRY_DEFAULTCOLOR_VALUE=DefaultColor
SET COMMAND_PROCESSOR_REGISTRY_SCREENCOLORS_VALUE=ScreenColors

SET COMMAND_PROCESSOR_VERSION=Microsoft Windows 11 Command Processor 
REM SET COMMAND_PROCESSOR_COPYRIGHT=(C) Microsoft Corporation. All rights reserved.
CHCP 1252 > NUL
SET COMMAND_PROCESSOR_COPYRIGHT=© Microsoft Corporation. All rights reserved.
CHCP 850 > NUL

REM Time prompt and time, removing milliseconds with backspaces
SET TIME_PROMPT=Time:$S$T$H$H$H
REM
REM Current directory in brackets, newline and greather-than character
REM
REM SET CONSOLE_PROMPT=[$P]$_$G

REM
REM Simulate an HP-UX style prompt with the current directory in brackets, newline, user name, computer name and greather-than character
REM
SET CONSOLE_PROMPT=$B$S[$P]$_%USERNAME%@%COMPUTERNAME%:$G

SET TITLE=WINDOWS 11
SET INSTRUCTION1=CTRL+ESC $Q Start Menu
SET INSTRUCTION2=Type HELP $Q Help
SET FOREGROUND_HEADER_TEXT=37
SET BACKGROUND_HEADER_TEXT=44
SET FOREGROUND_NORMAL_TEXT=37
SET BACKGROUND_NORMAL_TEXT=40
SET NORMAL_TEXT_COLOR=07
SET INDEX=0
SET "TAB=     "

REM Enable global support ANSI escape sequences support in the registry
REM
REM Details can be found here: https://superuser.com/questions/413073/windows-console-with-ansi-colors-handling
REM
REG ADD "%COMMAND_PROCESSOR_ANSI_ENABLE_KEY%" /v %COMMAND_PROCESSOR_REGISTRY_ANSI_ENABLE_VALUE% /t REG_DWORD /d 0x01 /f >NUL  2>NUL
IF %ERRORLEVEL% NEQ 1 GOTO NO_ANSI_ENABLE
ECHO Error occurred trying to enable global ANSI support in the command processor. 
ECHO Current user may not have proper access to update the registry key %COMMAND_PROCESSOR_ANSI_ENABLE_KEY%\%COMMAND_PROCESSOR_REGISTRY_ANSI_ENABLE_VALUE%.
EXIT /B 1
:NO_ANSI_ENABLE

REM This file can be placed in C:\Windows or C:\Users\[User] folder.
REM  winpmt /i, /I, /install, /INSTALL will register this file such that it is executed the first time a CMD instance is started.
REM
REM Update registry key and point to this file to handle CMD startup
REM
REM If /D was NOT specified on the command line, then when CMD.EXE starts, it
REM looks for the following REG_SZ/REG_EXPAND_SZ registry variables, and if
REM either or both are present, they are executed first.
REM
REM HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor\AutoRun
REM
REM     and/or
REM
REM HKEY_CURRENT_USER\Software\Microsoft\Command Processor\AutoRun
REM
REM If the right parameter was specified update the registry with the location of this file
IF "%1" == "/?" GOTO HELP
IF /I "%1" == "/I" GOTO INSTALL
IF "%1" == "" GOTO NO_INSTALL
ECHO Parameter format not correct - "%1".
EXIT /B 1
GOTO NO_INSTALL
:HELP
ECHO WINPMT [/I]
ECHO Customizes the Command Processor Prompt.  Supports Windows 10+.
ECHO.
ECHO   /I          Installs this script to be executed when CONHOST.EXE or CMD.EXE
ECHO               is first started.
EXIT /B 0
:INSTALL
REM SET AutoRun to the fully qualified path of this file's location
REG ADD "%COMMAND_PROCESSOR_REGISTRY_KEY%" /f /v %COMMAND_PROCESSOR_REGISTRY_AUTORUN_VALUE% /t REG_SZ /d %~f0 >NUL 2>NUL
IF %ERRORLEVEL% NEQ 1 GOTO NO_INSTALL
ECHO Error occurred trying to install the script to Auto-Run from %~f0. 
ECHO Current user may not have proper access to update the registry key %COMMAND_PROCESSOR_REGISTRY_KEY%\%COMMAND_PROCESSOR_REGISTRY_AUTORUN_VALUE%.
EXIT /B 1
:NO_INSTALL

REM Print Time prompt and console prompt
SET WINPMT=%TIME_PROMPT%$S%CONSOLE_PROMPT%

REM Save cursor position
REM Previously was $E[s in ANSI.SYS
SET WINPMT=%WINPMT%$E7

REM Move cursor to upper left
SET WINPMT=%WINPMT%$E[H

REM SET bold foreground text color and background color
SET WINPMT=%WINPMT%$E[1;%FOREGROUND_HEADER_TEXT%;%BACKGROUND_HEADER_TEXT%m

REM Clear to end of line
SET WINPMT=%WINPMT%$E[K

REM Print "Windows 11" or Whatever custom title string to appear, e.g. Company Name, User name
SET WINPMT=%WINPMT%$S$S%TITLE%

REM Print tab, first user instruction, eight tabs for spacing and second user instruction
SET WINPMT=%WINPMT%%TAB%%INSTRUCTION1%%TAB%%TAB%%TAB%%TAB%%TAB%%TAB%%TAB%%TAB%%INSTRUCTION2%

REM Restore saved cursor position
REM Previously was $E[u in ANSI.SYS
SET WINPMT=%WINPMT%$E8

REM SET white foreground, black background
SET WINPMT=%WINPMT%$E[0;%FOREGROUND_NORMAL_TEXT%;%BACKGROUND_NORMAL_TEXT%m

REM Color attributes are specified by TWO hex digits -- the first
REM corresponds to the background; the second the foreground.  Each digit
REM can be any of the following values:
REM 
REM     0 = Black       8 = Gray
REM     1 = Blue        9 = Light Blue
REM     2 = Green       A = Light Green
REM     3 = Aqua        B = Light Aqua
REM     4 = Red         C = Light Red
REM     5 = Purple      D = Light Purple
REM     6 = Yellow      E = Light Yellow
REM     7 = White       F = Bright White
REM
COLOR %NORMAL_TEXT_COLOR%

REM SET current user DefaultColor in the registry as well
REG ADD "%COMMAND_PROCESSOR_REGISTRY_KEY%" /v %COMMAND_PROCESSOR_REGISTRY_DEFAULTCOLOR_VALUE% /t REG_DWORD /d 0x%NORMAL_TEXT_COLOR% /f >NUL 2>NUL
IF %ERRORLEVEL% NEQ 1 GOTO NO_DEFAULT_COLOR
ECHO Error occurred trying to set the default color of the command processor. 
ECHO Current user may not have proper access to update the registry key %COMMAND_PROCESSOR_REGISTRY_KEY%\%COMMAND_PROCESSOR_REGISTRY_DEFAULTCOLOR_VALUE%.
EXIT /B 1
:NO_DEFAULT_COLOR

REM SET current user ScreenColors in the registry as well
REG ADD "%COMMAND_PROCESSOR_REGISTRY_KEY2%" /v %COMMAND_PROCESSOR_REGISTRY_SCREENCOLORS_VALUE% /t REG_DWORD /d 0x%NORMAL_TEXT_COLOR% /f >NUL 2>NUL
IF %ERRORLEVEL% NEQ 1 GOTO NO_SCREEN_COLORS
ECHO Error occurred trying to set the screen color of the command processor. 
ECHO Current user may not have proper access to update the registry key %COMMAND_PROCESSOR_REGISTRY_KEY2%\%COMMAND_PROCESSOR_REGISTRY_SCREENCOLORS_VALUE%.
EXIT /B 1
:NO_SCREEN_COLORS


REM Clear screen for final display using colors previously set
CLS

REM
REM Print Microsoft Windows 11 Command Processor Version, number and copyright
REM Calculate Windows version and put into a variable.  Cannot use traditional for loop executing the 'ver' command
REM because with autorun it shells this file again and creates an infinite loop.
REM
REM Code belows assumes ver returns a string with this format:
REM
REM Microsoft Windows [Version WW.X.YYYYY.ZZZZ]
REM

REM Create temporary filename to prevent issues with multiple prompts opening at the same time
SETLOCAL ENABLEDELAYEDEXPANSION
:TEMPFILELOCATION_LOOP
SET /A INDEX+=1
SET "TEMPFILELOCATION=%TEMP%\WINPMT_%INDEX%.TMP"
IF EXIST %TEMPFILELOCATION% GOTO TEMPFILELOCATION_LOOP
VER > %TEMPFILELOCATION%
FOR /F "DELIMS=" %%i IN (%TEMPFILELOCATION%) DO (
	SET result=%%i
	FOR /F "USEBACK TOKENS=1* DELIMS=[" %%j IN ('!result!') DO (
		SET "param2=%%k"
		SET VERSION=!param2:~0,-1!
	)
)
DEL %TEMPFILELOCATION%
ECHO. & ECHO %COMMAND_PROCESSOR_VERSION%%VERSION% & ECHO %COMMAND_PROCESSOR_COPYRIGHT% & ECHO.
ENDLOCAL
REM Set the final prompt variable value and clears all the variables created by this batch script
ENDLOCAL & (SET "PROMPT=%WINPMT%")
IF %ERRORLEVEL% NEQ 1 GOTO NO_PROMPT
ECHO Error occurred trying to set the PROMPT of the command processor. 
EXIT /B 1
:NO_PROMPT
