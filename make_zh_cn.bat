@echo off

Set winbuild=1
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
call :_colorprep


ECHO ======================================================================
ECHO 该批处理文件用于将LaTeX文档编译成PDF文档，并随后删除期间生成的过程文件。
ECHO 过程全自动。
call :_color %Magenta% "             由Zhiyuan Qiu制作 [zhiyuan.qiu@outlook.com]              "
ECHO ======================================================================
call :_color %_Green% "正在检查必要的安装和配置..."
ECHO ======================================================================


:UserMiKTeXCheck
reg query HKEY_CURRENT_USER\Software\|find "MiKTeX">nul 2>nul
if %errorlevel%==0 (
    call :_color %_Green% "确认： MiKTeX已安装"
    set TeXResult=TRUE
    ECHO ======================================================================
    goto PerlCheck
) else (
    goto LocalMiKTeXCheck
)


:LocalMiKTeXCheck
reg query HKEY_LOCAL_MACHINE\Software\|find "MiKTeX">nul 2>nul
if %errorlevel%==0 (
    call :_color %Green% "确认： MiKTeX已安装"
    set TeXResult=TRUE
    ECHO ======================================================================
    goto PerlCheck
) else (
    call :_color %Red% "错误：您需要安装 -MiKTeX- 编译器来执行LaTeX文件。"
    call :_color2 %_White% "您可以在MiKTeX官网下载: " %_Blue% "https://miktex.org/download"
    ECHO ======================================================================
    set TeXResult=FALSE
    goto PerlCheck
)


:PerlCheck
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ /s|find "Strawberry Perl">nul 2>nul
if %errorlevel%==0 (
    call :_color %_Green% "确认： Perl环境已安装"
    ECHO ======================================================================
    if "%TeXResult%"=="TRUE" (
        goto Clean
    ) else (
        call :_color %Gray% "程序已中止，按任意键退出..."
        pause>nul
        exit
    )
) else (
    call :_color %Red% "错误: 您需要安装 -Strawberry Perl- 环境来支持latexmk宏包的调用。"
    call :_color2 %_White% "您可以在Strawberry Perl官网下载: " %_Blue% "https://strawberryperl.com/"
    ECHO ======================================================================
    call :_color %Gray% "程序已中止，按任意键退出..."
    pause>nul
    exit
)


:Clean
DEL *.bbl *.xml *.aux *.bcf *.blg *.fdb_latexmk *.fls *.log *.out *.toc *.xdv *.acn *.acr *.alg *.glo *.ist *.lof *.lot *.slg *.slo *.sls *.gz /s
goto CompilerSel


:CompilerSel
ECHO ======================================================================
ECHO 请为您的文档选择合适的编译器：
ECHO （如果您不清楚这是什么意思，可不采取任何操作，10秒后程序将自动采取默认
ECHO XeLaTeX编译器选项）
ECHO ======================================================================
ECHO    [1]: pdfLaTeX
ECHO    [2]: XeLaTeX
ECHO    [3]: LuaLaTeX
ECHO ======================================================================
CHOICE /C 123 /N /T 10 /D 2 /M "请输入编号："
set CompilerNum=%errorlevel%

goto DocNameIP


:DocNameIP
ECHO ======================================================================
call :_color2 %_White% "请输入生成的PDF文档名称，" %_Yellow% "不包含.pdf后缀名："
ECHO （如果直接按回车键，将使用默认名称 "Latexmk_output"）
ECHO ======================================================================
set/p DocName=文档名称：

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
    call :_color %Red% "错误: 找不到编译用LaTeX源文件'main.tex'！"
    call :_color2 %_White% "请确保用于编译的主LaTeX文件存放在" %_Yellow% "和此程序同一目录下。"
	ECHO ======================================================================
	goto Rename
)


:Rename
set/p TeXName=请输入用于编译的主源文件的文件名，或输入FF退出程序：

if "%TeXName%" == "" ( 
    ECHO 无效输入！
    set TeXName=
    goto Rename
) else if "%TeXName%" == "FF" (
    exit
) else ( 
    if exist %TeXName%.tex ( 
	    goto mk
    ) else ( 
	    ECHO ======================================================================
		ECHO 找不到源文件'%TeXName%.tex'！
		ECHO ======================================================================
		set TeXName=
		goto Rename
    )
)


:mk
ECHO ======================================================================
call :_color %Green% "编译开始"
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
call :_color %Green% "编译完成！"
goto AnotherOne


:AnotherOne
ECHO ======================================================================
ECHO 您想编译多一个PDF文档（使用不同的编译器或文件名）吗？
ECHO 30秒后默认结束此批处理程序。
ECHO ======================================================================
CHOICE /N /T 30 /D N /M "是 [Y/y] / 否 [N/n]："
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