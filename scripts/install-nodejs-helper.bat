@echo off
REM Helper script to install Node.js via winget
REM This separate file avoids batch parsing issues with -- characters

winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
exit /b %errorlevel%

