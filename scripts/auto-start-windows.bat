@echo off
REM AI Agent Marketplace - Windows Auto-Install & Launcher
REM Fully portable script that downloads the project and sets everything up automatically

REM ========================================
REM CONFIGURATION - Update this with your ZIP download URL
REM ========================================
REM IMPORTANT: Replace the URL below with your actual ZIP download URL
REM Examples:
REM   Bitbucket: https://bitbucket.org/username/repo/get/master.zip
REM   GitHub: https://github.com/username/repo/archive/refs/heads/main.zip
REM   GitLab: https://gitlab.com/username/repo/-/archive/main/repo-main.zip
REM   Or any direct ZIP download URL
REM ========================================
set "ZIP_URL=https://bitbucket.org/daam2251/ai-agent-marketplace/get/main.zip"
set "REPO_NAME=ai-agent-marketplace"
REM Note: The script always downloads as ZIP (no Git required)

echo.
echo ========================================
echo  AI Agent Marketplace - Auto Start
echo ========================================
echo.

REM ========================================
REM Step 0: Create project folder and check/download project if needed
REM ========================================
echo [INFO] Setting up project folder...
REM Get the directory where script is located (same directory as script)
set "SCRIPT_DIR=%~dp0"
REM Remove trailing backslash to get clean directory path
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Resolve to long path (avoids 8.3 short names like ADMINI~1 that break Vite/Node)
for /f "delims=" %%I in ('powershell -NoProfile -Command "(New-Object -ComObject Scripting.FileSystemObject).GetFolder('%SCRIPT_DIR%').Path" 2^>nul') do set "SCRIPT_DIR=%%I"

REM Create project folder with repo name in the same directory as the script
set "PROJECT_ROOT=%SCRIPT_DIR%\%REPO_NAME%"
echo [INFO] Script directory: %SCRIPT_DIR%
echo [INFO] Project will be created at: %PROJECT_ROOT%

REM Create project folder if it doesn't exist
if not exist "%PROJECT_ROOT%" (
    echo [INFO] Creating project folder: %PROJECT_ROOT%
    mkdir "%PROJECT_ROOT%"
)

REM Change to project root
cd /d "%PROJECT_ROOT%"
if errorlevel 1 (
    echo [ERROR] Failed to create or access project directory!
    echo Attempted directory: %PROJECT_ROOT%
    pause
    exit /b 1
)

REM Check if package.json exists (project is already downloaded)
if exist "package.json" (
    echo [OK] Project found in: %CD%
    echo.
    goto :check_nodejs
)

REM Project not found, need to download it
echo [INFO] Project not found. Downloading from ZIP URL...
echo [INFO] ZIP URL: %ZIP_URL%
echo [INFO] This may take a few minutes. Please wait...
echo.

REM Use PowerShell to download and extract ZIP (always use ZIP, no Git required)
REM Download ZIP to project folder
REM Ensure PROJECT_ROOT has trailing backslash for proper path construction
if not "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT%\"
set "ZIP_FILE=%PROJECT_ROOT%%REPO_NAME%.zip"

REM Download and extract using the direct ZIP URL
REM Extract to project folder, then move files to project root
set "EXTRACT_DIR=%PROJECT_ROOT%extracted-temp"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { $projectRoot = '%PROJECT_ROOT%'; $zipFile = [System.IO.Path]::Combine($projectRoot, '%REPO_NAME%.zip'); $extractDir = [System.IO.Path]::Combine($projectRoot, 'extracted-temp'); Write-Host '[INFO] Downloading repository as ZIP...'; Write-Host '[INFO] URL: %ZIP_URL%'; Write-Host '[INFO] Saving to: ' $zipFile; Write-Host '[INFO] Extract directory: ' $extractDir; Write-Host '[INFO] Project directory: ' $projectRoot; Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile $zipFile -UseBasicParsing -ErrorAction Stop; Write-Host '[INFO] Download completed. Extracting files...'; if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }; Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force; $extractedFolder = Get-ChildItem $extractDir -Directory | Where-Object { $_.Name -like '*%REPO_NAME%*' -or $_.Name -like '*main*' -or $_.Name -like '*master*' -or $_.Name -like '*main*' } | Select-Object -First 1; if ($extractedFolder) { Write-Host '[INFO] Copying files to project directory...'; Write-Host '[INFO] Found folder: ' $extractedFolder.Name; Copy-Item -Path \"$($extractedFolder.FullName)\*\" -Destination $projectRoot -Recurse -Force; Remove-Item -Path $extractedFolder.FullName -Recurse -Force; Write-Host '[OK] Files copied successfully' } else { Write-Host '[WARN] Could not find extracted folder, trying alternative...'; $allDirs = Get-ChildItem $extractDir -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if ($allDirs) { Write-Host '[INFO] Using folder: ' $allDirs.Name; Copy-Item -Path \"$($allDirs.FullName)\*\" -Destination $projectRoot -Recurse -Force; Remove-Item -Path $allDirs.FullName -Recurse -Force } }; Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue; Write-Host '[OK] Project downloaded and extracted successfully!'; Write-Host '[INFO] ZIP file saved at: ' $zipFile; Write-Host '[INFO] You can delete it manually if you want to re-download next time.'; exit 0 } catch { Write-Host '[ERROR] Failed to download repository'; Write-Host '[ERROR]' $_.Exception.Message; if ($_.Exception.Response) { Write-Host '[ERROR] Status Code:' $_.Exception.Response.StatusCode.value__ }; exit 1 }"

if errorlevel 1 (
    echo [ERROR] Failed to download repository.
    echo [INFO] Please check your internet connection and ZIP URL.
    echo [INFO] ZIP URL: %ZIP_URL%
    echo [INFO] Make sure the ZIP URL is correct and accessible.
    pause
    exit /b 1
)

echo [OK] Project downloaded successfully!
echo.

REM Verify project was downloaded (we're already in PROJECT_ROOT)
if not exist "package.json" (
    echo [ERROR] Project download completed but package.json not found!
    echo [INFO] Please check the ZIP URL and try again.
    echo [INFO] Current directory: %CD%
    pause
    exit /b 1
)

echo [OK] Project is ready!
echo [INFO] Project directory: %CD%
echo.

:check_nodejs
REM ========================================
REM Step 1: Check if Node.js is installed
REM ========================================
node --version >nul 2>nul
if errorlevel 1 (
    REM Node.js is not installed, try to install it
    goto :install_nodejs
) else (
    REM Node.js is already installed
    goto :node_found
)

:install_nodejs
echo [INFO] Node.js is not installed.
echo [INFO] Attempting to install Node.js automatically...
echo.

REM Check if winget is available (Windows 10/11)
where.exe winget >nul 2>nul
if not errorlevel 1 (
    REM winget is available, use it
    goto :use_winget
)
REM winget not available, try chocolatey
where.exe choco >nul 2>nul
if not errorlevel 1 (
    REM Use Chocolatey
    goto :use_chocolatey
)
REM Neither winget nor chocolatey available
goto :no_installer

:use_winget
echo [INFO] Installing Node.js using Windows Package Manager...
echo [INFO] This may take a few minutes. Please wait...

REM Use PowerShell to execute winget to avoid batch parsing issues with -- characters
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $ProgressPreference = 'SilentlyContinue'; $result = winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements; exit $LASTEXITCODE }"
set WINGET_RESULT=%errorlevel%

if %WINGET_RESULT% neq 0 (
    echo [ERROR] Failed to install Node.js using winget
    echo [INFO] Please install Node.js manually from https://nodejs.org/
    pause
    exit /b 1
)
set INSTALLER_TYPE=winget
goto :after_install

:use_chocolatey
echo [INFO] Installing Node.js using Chocolatey...
echo [INFO] This may take a few minutes. Please wait...
choco install nodejs-lts -y
if errorlevel 1 (
    echo [ERROR] Failed to install Node.js using Chocolatey
    echo [INFO] Please install Node.js manually from https://nodejs.org/
    pause
    exit /b 1
)
REM Refresh PATH using Chocolatey's refreshenv
call refreshenv >nul 2>nul
set INSTALLER_TYPE=choco
goto :after_install

:no_installer
REM No package manager available, download and install Node.js directly
echo [INFO] No package manager found. Downloading Node.js directly...
echo [INFO] This may take a few minutes. Please wait...
echo.

REM Use PowerShell to download Node.js MSI installer (inline to avoid dependency on external file)
set "NODE_INSTALLER=%TEMP%\nodejs-installer.msi"

REM Download Node.js LTS MSI using PowerShell (inline script)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { Write-Host '[INFO] Fetching latest Node.js LTS version...'; $response = Invoke-WebRequest -Uri 'https://nodejs.org/dist/index.json' -UseBasicParsing | ConvertFrom-Json; $lts = ($response | Where-Object { $_.lts -ne $false } | Select-Object -First 1); $version = $lts.version; Write-Host '[INFO] Found Node.js LTS version: ' $version; $msiFilename = \"node-$version-x64.msi\"; $url = \"https://nodejs.org/dist/$version/$msiFilename\"; Write-Host '[INFO] Downloading: ' $msiFilename; Invoke-WebRequest -Uri $url -OutFile '%NODE_INSTALLER%' -UseBasicParsing -ErrorAction Stop; Write-Host '[INFO] Download completed successfully'; exit 0 } catch { Write-Host '[ERROR] Failed to download Node.js'; Write-Host '[ERROR]' $_.Exception.Message; exit 1 }"

if errorlevel 1 (
    echo [ERROR] Failed to download Node.js installer.
    echo [INFO] Please check your internet connection and try again.
    echo [INFO] Or download manually from: https://nodejs.org/
    pause
    exit /b 1
)

echo [INFO] Installing Node.js (this may take a few minutes)...
echo [INFO] Please wait, installation is in progress...
echo.

REM Install Node.js silently using msiexec
REM /qn = quiet no UI, /norestart = don't restart, ADDLOCAL=all = install all features
msiexec /i "%NODE_INSTALLER%" /qn /norestart ADDLOCAL=ALL

REM Wait for installation to complete
timeout /t 10 /nobreak >nul 2>nul

REM Clean up installer
if exist "%NODE_INSTALLER%" del "%NODE_INSTALLER%" >nul 2>nul

REM Refresh PATH - add Node.js to current session PATH
if exist "%ProgramFiles%\nodejs\node.exe" (
    set "PATH=%ProgramFiles%\nodejs;%PATH%"
)
if exist "%ProgramFiles(x86)%\nodejs\node.exe" (
    set "PATH=%ProgramFiles(x86)%\nodejs;%PATH%"
)

REM Verify installation
node --version >nul 2>nul
if errorlevel 1 (
    echo [WARN] Node.js installation completed but not found in PATH.
    echo [INFO] Please close this window, open a new one, and run this script again.
    echo [INFO] The installation may require a new terminal session to take effect.
    pause
    exit /b 1
)

echo [OK] Node.js installed successfully!
set INSTALLER_TYPE=direct
goto :after_install

:after_install

REM Wait a moment for installation to complete
timeout /t 5 /nobreak >nul 2>nul

REM Try to refresh PATH for winget installations
if "%INSTALLER_TYPE%"=="winget" (
    REM Try to find Node.js in common installation locations and add to PATH
    if exist "%ProgramFiles%\nodejs\node.exe" (
        set "PATH=%ProgramFiles%\nodejs;%PATH%"
    )
    if exist "%ProgramFiles(x86)%\nodejs\node.exe" (
        set "PATH=%ProgramFiles(x86)%\nodejs;%PATH%"
    )
    if exist "%LocalAppData%\Microsoft\WindowsApps\node.exe" (
        set "PATH=%LocalAppData%\Microsoft\WindowsApps;%PATH%"
    )
)

REM Verify installation
node --version >nul 2>nul
if errorlevel 1 (
    echo [WARN] Node.js was installed but not found in PATH.
    echo [INFO] Please close this window, open a new one, and run this script again.
    echo [INFO] Or restart your computer if the issue persists.
    pause
    exit /b 1
)

echo [OK] Node.js installed successfully!
echo.

:node_found
REM Get Node.js version
for /f "tokens=*" %%i in ('node --version 2^>nul') do set NODE_VERSION=%%i
if "%NODE_VERSION%"=="" set NODE_VERSION=detected
echo [OK] Node.js %NODE_VERSION% detected
echo.

REM Continue with npm check
echo [INFO] Checking for npm...
call npm.cmd --version >nul 2>nul
if errorlevel 1 (
    call npm --version >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] npm is not available!
        echo Please reinstall Node.js (npm comes with Node.js)
        pause
        exit /b 1
    )
    set NPM_CMD=npm
) else (
    set NPM_CMD=npm.cmd
)

REM Get npm version for confirmation
for /f "tokens=*" %%i in ('%NPM_CMD% --version 2^>nul') do set NPM_VERSION=%%i
echo [OK] npm %NPM_VERSION% detected
echo.

REM Ensure we're in the project root (resolve path properly)
cd /d "%PROJECT_ROOT%"
if errorlevel 1 (
    echo [ERROR] Failed to change to project directory!
    echo Current directory: %CD%
    echo Attempted directory: %PROJECT_ROOT%
    pause
    exit /b 1
)
REM Update PROJECT_ROOT with resolved path
set "PROJECT_ROOT=%CD%"

echo ========================================
echo  Step 1: Setting up the project...
echo ========================================
echo.
echo This may take a few minutes. Please wait...
echo.

REM Run setup
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

REM Run dev
call %NPM_CMD% run dev

pause

