@echo off

Set winbuild=1
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
call :_colorprep


ECHO ======================================================================
ECHO This batch file is coded for automatic compilation of PDF files from
ECHO LaTeX .tex documents, and subsequent deletion of external/auxiliary
ECHO files.
call :_color %Magenta% "           Created by Zhiyuan Qiu [zhiyuan.qiu@outlook.com]           "
ECHO ======================================================================
call :_color %_Green% "Checking for installations and configurations..."
ECHO ======================================================================


:UserMiKTeXCheck
reg query HKEY_CURRENT_USER\Software\|find "MiKTeX">nul 2>nul
if %errorlevel%==0 (
    call :_color %_Green% "Confirmation: MiKTeX is installed"
    set TeXResult=TRUE
    ECHO ======================================================================
    goto PerlCheck
) else (
    goto LocalMiKTeXCheck
)


:LocalMiKTeXCheck
reg query HKEY_LOCAL_MACHINE\Software\|find "MiKTeX">nul 2>nul
if %errorlevel%==0 (
    call :_color %Green% "Confirmation: MiKTeX is installed"
    set TeXResult=TRUE
    ECHO ======================================================================
    goto PerlCheck
) else (
    call :_color %Red% "ERROR: You need to install MiKTeX for executing LaTeX files."
    call :_color2 %_White% "You can download the installer here: " %_Blue% "https://miktex.org/download"
    ECHO ======================================================================
    set TeXResult=FALSE
    goto PerlCheck
)


:PerlCheck
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ /s|find "Strawberry Perl">nul 2>nul
if %errorlevel%==0 (
    call :_color %_Green% "Confirmation: Perl environment is installed"
    ECHO ======================================================================
    if "%TeXResult%"=="TRUE" (
        goto Clean
    ) else (
        call :_color %Gray% "Process aborted, press any key to exit..."
        pause>nul
        exit
    )
) else (
    call :_color %Red% "ERROR: You need to install the Strawberry Perl environment for calling"
    call :_color %Red% "the latexmk package."
    call :_color2 %_White% "You can download the installer here: " %_Blue% "https://strawberryperl.com/"
    ECHO ======================================================================
    call :_color %Gray% "Process aborted, press any key to exit..."
    pause>nul
    exit
)


:Clean
DEL *.bbl *.xml *.aux *.bcf *.blg *.fdb_latexmk *.fls *.log *.out *.toc *.xdv *.acn *.acr *.alg *.glo *.ist *.lof *.lot *.slg *.slo *.sls *.gz /s
goto CompilerSel


:CompilerSel
ECHO ======================================================================
ECHO Please choose the appropriate compiler for your document:
ECHO (If you don't know what this means, just leave it alone. The program
ECHO will automatically adopt the default XeLaTeX Compiler Option after
ECHO 10 seconds)
ECHO ======================================================================
ECHO    [1]: pdfLaTeX
ECHO    [2]: XeLaTeX
ECHO    [3]: LuaLaTeX
ECHO ======================================================================
CHOICE /C 123 /N /T 10 /D 2 /M "Input number:"
set CompilerNum=%errorlevel%

goto DocNameIP


:DocNameIP
ECHO ======================================================================
call :_color2 %_White% "Please input the filename of the PDF document " %_Yellow% "without extension:"
ECHO (The default name 'Latexmk_output' will be used if you press enter 
ECHO directly)
ECHO ======================================================================
set/p DocName=Filename of the PDF:

if "%DocName%" == "" ( 
    set DocName="Latexmk_output"
)

goto TeXCheck


:TeXCheck
if exist main.tex ( 
    set TeXName="main"
    goto mk
) else ( 
    ECHO ======================================================================
    call :_color %Red% "ERROR: Source file 'main.tex' cannot be found!"
    call :_color2 %_White% "Please make sure that the main tex file and this batch file are " %_Yellow% "in the"
    call :_color %_Yellow% "same directory."
	ECHO ======================================================================
	goto Rename
)


:Rename
set/p TeXName=Enter the filename of the main tex file, or enter FF to exit the program:

if "%TeXName%" == "" ( 
    ECHO Invalid input!
    set TeXName=
    goto Rename
) else if "%TeXName%" == "FF" (
    exit
) else ( 
    if exist %TeXName%.tex ( 
	    goto mk
    ) else ( 
	    ECHO ======================================================================
		ECHO Source file '%TeXName%.tex' cannot be found!
		ECHO ======================================================================
		set TeXName=
		goto Rename
    )
)


:mk
ECHO ======================================================================
call :_color %Green% "Process start"
ECHO ======================================================================

if %CompilerNum% == 1 ( 
    latexmk -pdf -pv -jobname=%DocName% %TeXName%.tex
    latexmk -c
) else if %CompilerNum% == 2 ( 
    latexmk -pdfxe -pv -jobname=%DocName% %TeXName%.tex
    latexmk -c
) else ( 
    latexmk -pdflua -pv -jobname=%DocName% %TeXName%.tex
    latexmk -c
) 

DEL *.bbl *.xml *.aux *.bcf *.blg *.fdb_latexmk *.fls *.log *.out *.toc *.xdv *.acn *.acr *.alg *.glo *.ist *.lof *.lot *.slg *.slo *.sls *.gz /s

ECHO ======================================================================
call :_color %Green% "Process complete!"
goto AnotherOne


:AnotherOne
ECHO ======================================================================
ECHO Do you want to compile another PDF document (with different compiler
ECHO or filename settings)?
ECHO This batch program ends by default after 30 seconds.
ECHO ======================================================================
CHOICE /N /T 30 /D N /M "Yes [Y/y] / No [N/n]:"
set RepeatProc=%errorlevel%

if "%RepeatProc%" == "1" goto Restart
if "%RepeatProc%" == "2" goto exit


:Restart
set CompilerNum=
set DocName=
set RepeatProc=
cls
goto CompilerSel


::=====================================================================

Colored text thanks to Piash: https://github.com/lstprjct

:_color

if %winbuild% GEQ 10586 (
echo %esc%[%~1%~2%esc%[0m
) else (
call :batcol %~1 "%~2"
)
exit /b

:_color2

if %winbuild% GEQ 10586 (
echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
) else (
call :batcol %~1 "%~2" %~3 "%~4"
)
exit /b

::=======================================

:: Colored text with pure batch method
:: Thanks to @dbenham and @jeb
:: https://stackoverflow.com/a/10407642

:: Powershell is not used here because its slow

:batcol

pushd %_coltemp%
if not exist "'" (<nul >"'" set /p "=.")
setlocal
set "s=%~2"
set "t=%~4"
call :_batcol %1 s %3 t
del /f /q "'"
del /f /q "`.txt"
popd
exit /b

:_batcol

setlocal EnableDelayedExpansion
set "s=!%~2!"
set "t=!%~4!"
for /f delims^=^ eol^= %%i in ("!s!") do (
  if "!" equ "" setlocal DisableDelayedExpansion
    >`.txt (echo %%i\..\')
    findstr /a:%~1 /f:`.txt "."
    <nul set /p "=%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%"
)
if "%~4"=="" echo(&exit /b
setlocal EnableDelayedExpansion
for /f delims^=^ eol^= %%i in ("!t!") do (
  if "!" equ "" setlocal DisableDelayedExpansion
    >`.txt (echo %%i\..\')
    findstr /a:%~3 /f:`.txt "."
    <nul set /p "=%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%"
)
echo(
exit /b

::=======================================

:_colorprep

if %winbuild% GEQ 10586 (
for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"

set     "Red="41;97m""
set    "Gray="100;97m""
set   "Black="30m""
set   "Green="42;97m""
set    "Blue="44;97m""
set  "Yellow="43;97m""
set "Magenta="45;97m""

set    "_Red="40;91m""
set  "_Green="40;92m""
set   "_Blue="40;94m""
set  "_White="40;37m""
set "_Yellow="40;93m""

exit /b
)

if not defined _BS for /f %%A in ('"prompt $H&for %%B in (1) do rem"') do set "_BS=%%A %%A"
set "_coltemp=%SystemRoot%\Temp"

set     "Red="CF""
set    "Gray="8F""
set   "Black="00""
set   "Green="2F""
set    "Blue="1F""
set  "Yellow="6F""
set "Magenta="5F""

set    "_Red="0C""
set  "_Green="0A""
set   "_Blue="09""
set  "_White="07""
set "_Yellow="0E""

exit /b