@echo off
setlocal

REM ============================
REM VARIABLES
REM ============================
set "ARCHIVE=%USERPROFILE%\Desktop\license.rar"  REM change to .zip if needed
set "TEMP_EXTRACT=%TEMP%\license_extracted"
set "DEST=C:\Program Files\Enscape\RendererHost"

REM ============================
REM ADMIN CHECK
REM ============================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo ❌ Run this script as Administrator!
    pause
    exit /b
)

REM ============================
REM CREATE TEMP & DEST
REM ============================
if exist "%TEMP_EXTRACT%" rd /s /q "%TEMP_EXTRACT%"
mkdir "%TEMP_EXTRACT%"
if not exist "%DEST%" mkdir "%DEST%"

REM ============================
REM DETECT ARCHIVE TYPE
REM ============================
set "ARCHIVE_EXT=%ARCHIVE:~-3%"

if /I "%ARCHIVE_EXT%"=="zip" (
    REM Use Windows built-in Compressed Folder Tools via PowerShell
    powershell -Command "Expand-Archive -Force -Path '%ARCHIVE%' -DestinationPath '%TEMP_EXTRACT%'"
) else (
    REM Use WinRAR or 7-Zip
    if exist "C:\Program Files\WinRAR\WinRAR.exe" (
        "C:\Program Files\WinRAR\WinRAR.exe" x "%ARCHIVE%" "%TEMP_EXTRACT%\" -y
    ) else if exist "C:\Program Files (x86)\WinRAR\WinRAR.exe" (
        "C:\Program Files (x86)\WinRAR\WinRAR.exe" x "%ARCHIVE%" "%TEMP_EXTRACT%\" -y
    ) else if exist "C:\Program Files\7-Zip\7z.exe" (
        "C:\Program Files\7-Zip\7z.exe" x "%ARCHIVE%" -o"%TEMP_EXTRACT%" -y
    ) else (
        echo ❌ No supported extraction tool found! Install WinRAR or 7-Zip.
        pause
        exit /b
    )
)

REM ============================
REM COPY TO DEST
REM ============================
robocopy "%TEMP_EXTRACT%" "%DEST%" /E /COPYALL /R:3 /W:2

REM ============================
REM CLEANUP TEMP
REM ============================
rd /s /q "%TEMP_EXTRACT%"

echo ✅ Extraction and copy complete!
pause
