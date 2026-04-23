# PowerShell script to download Node.js LTS MSI installer
$ProgressPreference = 'SilentlyContinue'

try {
    # Get latest LTS version
    Write-Host "[INFO] Fetching latest Node.js LTS version..."
    $response = Invoke-WebRequest -Uri 'https://nodejs.org/dist/index.json' -UseBasicParsing | ConvertFrom-Json
    $lts = ($response | Where-Object { $_.lts -ne $false } | Select-Object -First 1)
    $version = $lts.version
    Write-Host "[INFO] Found Node.js LTS version: $version"
    
    # Construct MSI filename and URL using standard format
    # Note: The filename includes the 'v' prefix (e.g., node-v24.12.0-x64.msi)
    $msiFilename = "node-$version-x64.msi"
    $url = "https://nodejs.org/dist/$version/$msiFilename"
    
    Write-Host "[INFO] Downloading: $msiFilename"
    Write-Host "[INFO] From: $url"
    
    $installerPath = $env:TEMP + "\nodejs-installer.msi"
    
    # Download the MSI file
    Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing -ErrorAction Stop
    
    Write-Host "[INFO] Download completed successfully"
    Write-Host "[INFO] Installer saved to: $installerPath"
    exit 0
} catch {
    Write-Host "[ERROR] Failed to download Node.js"
    Write-Host "[ERROR] $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "[ERROR] Status Code: $($_.Exception.Response.StatusCode.value__)"
        Write-Host "[ERROR] URL attempted: $url"
    }
    exit 1
}

