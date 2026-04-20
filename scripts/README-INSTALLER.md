# Universal Installer

This directory contains universal installer scripts that work across all operating systems.

## Quick Start

### For Linux and macOS

Simply run this command in your terminal:

```bash
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | bash
```

Or if you prefer `sh`:

```bash
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | sh
```

### For Windows (PowerShell)

Run this command in PowerShell:

```powershell
irm https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.ps1 | iex
```

Or the longer version:

```powershell
Invoke-WebRequest -Uri https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.ps1 | Invoke-Expression
```

## How It Works

1. **Universal Script** detects your operating system
2. **Downloads** the appropriate platform-specific script
3. **Executes** the downloaded script automatically
4. The platform script then:
   - Downloads the project (if needed)
   - Installs Node.js (if needed)
   - Sets up the project
   - Runs the application

## Setup Instructions

### 1. Host the Scripts

You need to host the following files on a web server:

- `install.sh` - Universal installer for Linux/macOS
- `install.ps1` - Universal installer for Windows (PowerShell)
- `auto-start-windows.bat` - Windows-specific installer
- `auto-start-mac.sh` - macOS-specific installer
- `auto-start-linux.sh` - Linux-specific installer
- `download-nodejs.ps1` - Windows Node.js download helper
- `install-nodejs-helper.bat` - Windows Node.js install helper

### 2. BASE_URL Configuration

The `BASE_URL` is already configured in all scripts:

```bash
# In install.sh
BASE_URL="https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"
```

```powershell
# In install.ps1
$BASE_URL = "https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"
```

```batch
# In install-windows.bat
set "BASE_URL=https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"
```

### 3. Hosting Options

**Option A: Bitbucket (Current)**
- Scripts are hosted on Bitbucket
- Use raw Bitbucket URLs:
  - `https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh`

**Option B: GitHub**
- Push scripts to a GitHub repository
- Use raw GitHub URLs:
  - `https://raw.githubusercontent.com/username/repo/branch/scripts/install.sh`

**Option C: Your Own Server**
- Upload scripts to your web server
- Use your domain:
  - `https://yourserver.com/scripts/install.sh`

**Option D: GitLab**
- Use their raw file URLs
- Similar format to GitHub/Bitbucket

## Security Note

⚠️ **Important**: Running scripts directly from the internet can be a security risk. Always:
- Verify the source URL
- Review the script content if possible
- Use HTTPS URLs only
- Consider hosting on your own trusted server

## Alternative: Direct Download

If you prefer not to use `curl | bash`, you can:

1. Download the installer script manually
2. Review it
3. Make it executable: `chmod +x install.sh`
4. Run it: `./install.sh`

## Troubleshooting

### "Command not found: curl"
- **Linux**: Install curl: `sudo apt-get install curl` (Debian/Ubuntu) or `sudo yum install curl` (RHEL/CentOS)
- **macOS**: curl should be pre-installed
- **Windows**: Use PowerShell method instead

### "Permission denied"
- Make sure the script is executable: `chmod +x install.sh`

### "Failed to download script"
- Check your internet connection
- Verify the BASE_URL is correct
- Make sure the scripts are publicly accessible

## Platform-Specific Scripts

The universal installer downloads and runs these platform-specific scripts:

- **Windows**: `auto-start-windows.bat`
- **macOS**: `auto-start-mac.sh`
- **Linux**: `auto-start-linux.sh`

Each platform script handles:
- Project download (ZIP)
- Node.js installation
- Project setup
- Application startup

