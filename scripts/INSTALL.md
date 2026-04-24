# Universal One-Command Installer

Install and run the AI Agent Marketplace with a single command on any operating system!

## 🚀 Quick Install

### Linux & macOS

```bash
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | bash
```

### Windows

**CMD:**
```cmd
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install-windows.bat | cmd
```

**PowerShell:**
```powershell
irm https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.ps1 | iex
```

**Git Bash:**
```bash
# Option 1: Use the universal installer (recommended)
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | bash

# Option 2: Download and execute directly
curl -L -o install-windows.bat https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install-windows.bat
cmd.exe /c install-windows.bat
```

Or download and run directly:
```cmd
install-windows.bat
```

That's it! The installer will:
1. ✅ Detect your operating system
2. ✅ Download the project automatically
3. ✅ Install Node.js if needed
4. ✅ Set up all dependencies
5. ✅ Start the application

## 📋 What You Need

- **Internet connection** (to download the project and dependencies)
- **Terminal/PowerShell** access
- **Administrator/sudo** privileges (for Node.js installation, if needed)

## 🔧 Setup for Hosting

To use this installer, you need to host the scripts on a web server:

### 1. Required Files

Upload these files to your web server:
- `install.sh` - Universal installer (Linux/macOS)
- `install.ps1` - Universal installer (Windows PowerShell)
- `install-windows.bat` - Universal Windows installer (CMD/PowerShell/Git Bash)
- `auto-start-windows.bat` - Windows platform script
- `auto-start-mac.sh` - macOS script
- `auto-start-linux.sh` - Linux script
- `download-nodejs.ps1` - Windows helper
- `install-nodejs-helper.bat` - Windows helper

### 2. Update URLs

The `BASE_URL` is already configured in all scripts:

**install.sh:**
```bash
BASE_URL="https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"
```

**install.ps1:**
```powershell
$BASE_URL = "https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"
```

**install-windows.bat:**
```batch
set "BASE_URL=https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"
```

### 3. Hosting Options

**Bitbucket (Current):**
- Scripts are hosted on Bitbucket
- Use raw Bitbucket URLs:
  ```
  https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh
  ```

**GitHub:**
- Push to a public repository
- Use raw GitHub URLs:
  ```
  https://raw.githubusercontent.com/username/repo/branch/scripts/install.sh
  ```

**Your Own Server:**
- Upload to your web server
- Use your domain:
  ```
  https://yourserver.com/scripts/install.sh
  ```

**GitLab:**
- Similar to GitHub
- Raw file URLs available

## 🔒 Security Considerations

⚠️ **Important Security Notes:**

1. **Always use HTTPS** - Never use HTTP for downloading scripts
2. **Verify the source** - Make sure you trust the URL
3. **Review scripts** - If possible, review the script content before running
4. **Host your own** - For production use, host scripts on your own trusted server

## 📖 How It Works

```
User runs: curl -s URL | bash
    ↓
Universal installer detects OS
    ↓
Downloads platform-specific script
    ↓
Platform script:
  - Downloads project (ZIP)
  - Installs Node.js (if needed)
  - Sets up project
  - Runs application
```

## 🐛 Troubleshooting

### "curl: command not found"
**Linux:** Install curl: `sudo apt-get install curl` or `sudo yum install curl`
**macOS:** curl should be pre-installed

### "Permission denied"
Make sure scripts are executable or use `bash` instead of `sh`

### "Failed to download"
- Check internet connection
- Verify the BASE_URL is correct
- Ensure scripts are publicly accessible
- Try downloading manually first

### Windows Issues
- Use PowerShell method: `irm URL | iex`
- Or download `auto-start-windows.bat` manually
- Make sure PowerShell execution policy allows scripts

## 📝 Example Usage

### Linux
```bash
# Ubuntu/Debian
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | bash

# Or download first, then run
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

### macOS
```bash
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | bash
```

### Windows
```cmd
REM CMD
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install-windows.bat | cmd

REM Or download and run
curl -L -o install-windows.bat https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install-windows.bat
install-windows.bat
```

```powershell
# PowerShell
irm https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.ps1 | iex

# Or download first
Invoke-WebRequest -Uri https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.ps1 -OutFile install.ps1
.\install.ps1
```

```bash
# Git Bash
curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | bash
```

## 🎯 Benefits

- **One command** - No manual setup needed
- **Cross-platform** - Works on Windows, macOS, and Linux
- **Automatic** - Handles everything automatically
- **Portable** - Can be run from anywhere
- **Self-contained** - Creates its own project folder

## 📚 Additional Resources

- See `scripts/README.md` for detailed script documentation
- See `SETUP.md` for manual setup instructions
- See `scripts/README-INSTALLER.md` for installer details

