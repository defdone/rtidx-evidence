@echo off
REM Universal Windows Installer - Works in CMD, PowerShell, and Git Bash
REM Usage: 
REM   CMD: curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install-windows.bat | cmd
REM   PowerShell: irm https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install-windows.bat | cmd
REM   Git Bash: curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install-windows.bat | bash
REM Or download and run: install-windows.bat

REM ========================================
REM CONFIGURATION
REM ========================================
set "BASE_URL=https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"

echo.
echo ========================================
echo  AI Agent Marketplace - Windows Installer
echo ========================================
echo.

echo [INFO] Downloading installer script...
echo.

REM Use a stable installer folder under the user's profile to avoid 8.3 short names
REM (ADMINI~1 etc.) which can confuse Node/Vite path resolution.
REM We deliberately base this on %USERPROFILE% instead of %TEMP%.
set "TEMP_DIR=%USERPROFILE%\AppData\Local\Temp\ai-agent-marketplace-installer"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
set "SCRIPT_FILE=%TEMP_DIR%\auto-start-windows.bat"

REM Try PowerShell download first (works in both CMD and PowerShell)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%BASE_URL%/auto-start-windows.bat' -OutFile '%SCRIPT_FILE%' -UseBasicParsing -ErrorAction Stop; Write-Host '[OK] Script downloaded successfully'; exit 0 } catch { Write-Host '[ERROR] Failed to download script'; Write-Host $_.Exception.Message; exit 1 }" 2>nul

if errorlevel 1 (
    REM PowerShell download failed, try alternative methods
    echo [WARN] PowerShell download failed, trying alternative...
    
    REM Check if curl is available (Windows 10+)
    where.exe curl >nul 2>nul
    if not errorlevel 1 (
        echo [INFO] Using curl to download...
        curl -L -o "%SCRIPT_FILE%" "%BASE_URL%/auto-start-windows.bat"
        if errorlevel 1 (
            echo [ERROR] Failed to download script using curl
            goto :error_exit
        )
    ) else (
        REM Check if bitsadmin is available (Windows built-in)
        bitsadmin /transfer "DownloadScript" "%BASE_URL%/auto-start-windows.bat" "%SCRIPT_FILE%" >nul 2>nul
        if errorlevel 1 (
            echo [ERROR] Failed to download script
            echo [INFO] Please check your internet connection
            echo [INFO] Or download manually from: %BASE_URL%/auto-start-windows.bat
            goto :error_exit
        )
    )
)

if not exist "%SCRIPT_FILE%" (
    echo [ERROR] Script file not found after download
    goto :error_exit
)

echo [OK] Script downloaded successfully
echo [INFO] Executing installer...
echo.

REM Execute the downloaded script
call "%SCRIPT_FILE%"
set EXIT_CODE=%errorlevel%

REM Clean up temp file (optional - comment out if you want to keep it for debugging)
REM del "%SCRIPT_FILE%" >nul 2>nul

if %EXIT_CODE% neq 0 exit /b %EXIT_CODE%
exit /b 0

:error_exit
echo.
echo [INFO] Manual download instructions:
echo   1. Visit: %BASE_URL%/auto-start-windows.bat
echo   2. Save the file as auto-start-windows.bat
echo   3. Double-click to run it
echo.
pause
exit /b 1

