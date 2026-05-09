# Universal Installer Script for AI Agent Marketplace (PowerShell)
# Works on Windows PowerShell
# Usage: irm https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.ps1 | iex
# Or: Invoke-WebRequest -Uri https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.ps1 | Invoke-Expression

# ========================================
# CONFIGURATION
# ========================================
$BASE_URL = "https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"

Write-Host ""
Write-Host "========================================"
Write-Host "  AI Agent Marketplace - Universal Installer"
Write-Host "========================================"
Write-Host ""

Write-Host "[INFO] Detected Windows operating system" -ForegroundColor Blue
Write-Host "[INFO] Downloading Windows installer..." -ForegroundColor Blue
Write-Host ""

# Create temp directory
$TEMP_DIR = Join-Path $env:TEMP "ai-agent-marketplace-installer"
if (-not (Test-Path $TEMP_DIR)) {
    New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null
}

$SCRIPT_FILE = Join-Path $TEMP_DIR "install-windows.bat"

try {
    Write-Host "[INFO] Downloading universal Windows installer..." -ForegroundColor Blue
    Write-Host "[INFO] URL: $BASE_URL/install-windows.bat" -ForegroundColor Blue
    Invoke-WebRequest -Uri "$BASE_URL/install-windows.bat" -OutFile $SCRIPT_FILE -UseBasicParsing -ErrorAction Stop
    
    Write-Host "[OK] Script downloaded successfully" -ForegroundColor Green
    Write-Host "[INFO] Executing Windows installer..." -ForegroundColor Blue
    Write-Host ""
    
    # Execute the Windows script
    & cmd.exe /c "`"$SCRIPT_FILE`""
} catch {
    Write-Host "[ERROR] Failed to download or execute installer" -ForegroundColor Red
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "[INFO] Please download the script manually from:" -ForegroundColor Yellow
    Write-Host "  $BASE_URL/install-windows.bat" -ForegroundColor Yellow
    exit 1
}

