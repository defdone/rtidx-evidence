@echo off
REM AI Agent Marketplace - Windows Launcher
REM Double-click this file to automatically set up and run the project

echo.
echo ========================================
echo  AI Agent Marketplace - Quick Start
echo ========================================
echo.

REM Check if Node.js is installed
REM Try running node directly - this is the most reliable test
node --version >nul 2>nul
if errorlevel 1 (
    REM If direct execution failed, try where.exe to see if it's in PATH
    where.exe node >nul 2>nul
    if errorlevel 1 (
        REM Node.js is definitely not installed or not in PATH
        goto :node_not_found
    ) else (
        REM Found in PATH but can't execute - might be a PATH refresh issue
        REM Try one more time after a brief moment
        timeout /t 1 /nobreak >nul 2>nul
        node --version >nul 2>nul
        if errorlevel 1 goto :node_not_found
    )
)
goto :node_found

:node_not_found
echo [ERROR] Node.js is not installed or not accessible!
echo.
echo Please install Node.js first:
echo 1. Visit: https://nodejs.org/
echo 2. Download the LTS version (recommended)
echo 3. Run the installer
echo 4. Close this window and double-click this file again
echo    (No restart needed - just close and reopen!)
echo.
echo Opening Node.js download page...
start https://nodejs.org/
pause
exit /b 1

:node_found
REM Get Node.js version (we know it works from the check above)
for /f "tokens=*" %%i in ('node --version 2^>nul') do set NODE_VERSION=%%i
if "%NODE_VERSION%"=="" set NODE_VERSION=detected
echo [OK] Node.js %NODE_VERSION% detected
echo.

REM Continue with npm check
REM Check if npm is available by trying to run it
REM On Windows, npm is typically npm.cmd, so we need to call it explicitly
echo [INFO] Checking for npm...
REM Try npm.cmd first (Windows standard)
call npm.cmd --version >nul 2>nul
if errorlevel 1 (
    REM Try without .cmd extension as fallback
    call npm --version >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] npm is not available!
        echo Please reinstall Node.js (npm comes with Node.js)
        echo.
        echo Debug: Searching for npm in PATH...
        where.exe npm 2>nul
        if errorlevel 1 echo npm not found in PATH
        echo.
        echo Note: If running from PowerShell, try double-clicking the .bat file instead.
        pause
        exit /b 1
    )
    REM If npm worked without .cmd, use that
    set NPM_CMD=npm
) else (
    REM npm.cmd worked, use that
    set NPM_CMD=npm.cmd
)

REM Get npm version for confirmation
for /f "tokens=*" %%i in ('%NPM_CMD% --version 2^>nul') do set NPM_VERSION=%%i
echo [OK] npm %NPM_VERSION% detected
echo.

REM Get the directory where this script is located and go up one level to project root
set "PROJECT_ROOT=%~dp0.."
REM Resolve to absolute then to long path (avoids 8.3 short names that break Vite/Node)
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"
for /f "delims=" %%I in ('powershell -NoProfile -Command "(New-Object -ComObject Scripting.FileSystemObject).GetFolder('%PROJECT_ROOT%').Path" 2^>nul') do set "PROJECT_ROOT=%%I"

REM Change to project root
cd /d "%PROJECT_ROOT%"
if errorlevel 1 (
    echo [ERROR] Failed to change to project directory!
    echo Current directory: %CD%
    echo Attempted directory: %PROJECT_ROOT%
    pause
    exit /b 1
)

echo [INFO] Project directory: %CD%
echo.

REM Check if package.json exists
if not exist "%PROJECT_ROOT%\package.json" (
    echo [ERROR] package.json not found!
    echo Please make sure you're running this from the project folder.
    pause
    exit /b 1
)

echo ========================================
echo  Step 1: Setting up the project...
echo ========================================
echo.
echo This may take a few minutes. Please wait...
echo.

REM Run setup (use the detected npm command)
call %NPM_CMD% run setup
if errorlevel 1 (
    echo.
    echo [ERROR] Setup failed! Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Step 2: Starting the application...
echo ========================================
echo.
echo The application will start in a moment...
echo Once started, you can access it at:
echo   - Frontend: http://localhost:5173
echo   - Backend:  http://localhost:3001
echo.
echo To stop the application, close this window or press Ctrl+C
echo.

REM Run dev (use the detected npm command)
call %NPM_CMD% run dev

pause

