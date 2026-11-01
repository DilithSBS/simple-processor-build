@echo off

REM This script takes in an assembly file and generates instr_mem.mem
REM Author: Converted from Bash to Windows Batch

if "%~1"=="" (
    echo Usage: %0 ^<assembly_file^>
    exit /b 1
)

set "assembly_file=%~1"
set "assembly_file=%assembly_file:/=\%"

for %%I in ("%assembly_file%") do set "filename=%%~nxI"

set "machine_dir=%~dp0..\..\tests\machine"
if not exist "%machine_dir%" mkdir "%machine_dir%"
set "machine_file=%machine_dir%\%filename%.machine"

set "output_dir=%~dp0..\..\tests\mem"
if not exist "%output_dir%" mkdir "%output_dir%"
set "output_file=%output_dir%\instr_mem.mem"
if not "%~2"=="" set "output_file=%~2"

REM Assemble the assembly program into machine code
"%~dp0..\assembler\CO2070Assembler.exe" "%assembly_file%"
if errorlevel 1 exit /b 1

REM Move the generated .machine file to tests\machine
move /y "%assembly_file%.machine" "%machine_file%" >nul
if errorlevel 1 exit /b 1

REM Remove old output file and create a new one
if exist "%output_file%" del "%output_file%"
type nul > "%output_file%"

REM Generate instruction memory content
for /f "usebackq delims=" %%L in ("%machine_file%") do (
    set "line=%%L"
    call :processLine
)

echo Machine code generated at %machine_file%!
echo Instruction memory content generated at %output_file%!
exit /b

:processLine
setlocal EnableDelayedExpansion

set "byte3=!line:~0,8!"
set "byte2=!line:~8,8!"
set "byte1=!line:~16,8!"
set "byte0=!line:~24,8!"

echo !byte0! !byte1! !byte2! !byte3!>>"%output_file%"

endlocal
exit /b