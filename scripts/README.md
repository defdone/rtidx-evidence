# Launcher Scripts

These scripts make it easy to set up and run the AI Agent Marketplace without using the command line.

## Available Scripts

### Standard Scripts (Manual Node.js Installation)

These scripts check for Node.js and guide you to install it if needed:

- **`start-windows.bat`** (Windows) - Checks for Node.js and guides installation
- **`start-mac.sh`** (macOS) - Checks for Node.js and guides installation
- **`start-linux.sh`** (Linux) - Checks for Node.js and guides installation

### Auto-Install Scripts (Recommended) ⭐

These scripts **automatically install Node.js** if it's not present, then run the project:

- **`auto-start-windows.bat`** (Windows) - Automatically installs Node.js using winget or Chocolatey
- **`auto-start-mac.sh`** (macOS) - Automatically installs Node.js using nvm (Node Version Manager)
- **`auto-start-linux.sh`** (Linux) - Automatically installs Node.js using your package manager

**Features:**
- ✅ Automatically installs Node.js if missing
- ✅ No browser popups or manual installation needed
- ✅ Runs the project immediately after setup
- ✅ Supports multiple install methods (nvm on macOS; apt, yum, dnf, pacman on Linux; winget, choco on Windows)

## How to Use

### Recommended: Auto-Install Scripts

**Windows:**
1. Navigate to the `scripts` folder
2. Double-click `auto-start-windows.bat`
3. The script will automatically install Node.js (if needed) and run the project

**macOS:**
1. Open a terminal
2. Navigate to the project folder
3. Make the script executable (first time only):
   ```bash
   chmod +x scripts/auto-start-mac.sh
   ```
4. Run the script:
   ```bash
   ./scripts/auto-start-mac.sh
   ```
   Or: `bash scripts/auto-start-mac.sh`

**Linux:**
1. Open a terminal
2. Navigate to the project folder
3. Make the script executable (first time only):
   ```bash
   chmod +x scripts/auto-start-linux.sh
   ```
4. Run the script:
   ```bash
   ./scripts/auto-start-linux.sh
   ```
   Or: `bash scripts/auto-start-linux.sh`

**Note:** The auto-install scripts require:
- **Windows:** winget (Windows 10/11) or Chocolatey
- **macOS:** Nothing extra—Node.js is installed via nvm (installed by the script if needed). Requires Node.js 20+ (old system Node is upgraded automatically).
- **Linux:** sudo access and a supported package manager (apt, yum, dnf, or pacman)

### Standard Scripts (Manual Installation)

If you prefer to install Node.js manually:

**Windows:**
1. Navigate to the `scripts` folder
2. Double-click `start-windows.bat`
3. Follow the on-screen instructions

**macOS:**
1. Navigate to the `scripts` folder
2. Make the script executable (first time only):
   ```bash
   chmod +x scripts/start-mac.sh
   ```
3. Double-click `start-mac.sh` (or right-click → Open → Open)
4. If you see a security warning, right-click the file → Open → Open
5. Follow the on-screen instructions

**Linux:**
1. Open a terminal
2. Navigate to the project folder
3. Make the script executable (first time only):
   ```bash
   chmod +x scripts/start-linux.sh
   ```
4. Run the script:
   ```bash
   ./scripts/start-linux.sh
   ```
   Or: `bash scripts/start-linux.sh`

## Troubleshooting

### "Node.js is not installed"
**For auto-start scripts:**
- The script will attempt to install Node.js automatically
- Make sure you have the required package manager installed (see above)
- On Linux, you may need to enter your sudo password

**For standard scripts:**
- The script will open the Node.js download page
- Download and install the LTS (Long Term Support) version
- **No restart needed!** Just:
  - **Windows:** Close the current window and double-click the script again
  - **Mac/Linux:** Close the terminal and open a new one, then run the script again

### Auto-install failed (macOS)
- The script installs Node.js via **nvm** (no Homebrew required). If it fails, install manually:
  - Run: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash`
  - Restart terminal, then: `nvm install 24` and `nvm use 24`
- If you see "Node.js version is too old", macOS may have an old system Node; the script will try to install Node 24 via nvm automatically.

### Auto-install failed (Linux)
- Make sure you have sudo access
- Check that your distribution is supported (Ubuntu, Debian, RHEL, CentOS, Fedora, Arch, Manjaro)
- Try installing Node.js manually using the standard script

### Auto-install failed (Windows)
- Make sure you have winget (Windows 10/11) or Chocolatey installed
- For winget: Update Windows or install from Microsoft Store
- For Chocolatey: Install from https://chocolatey.org/

### "Permission denied" (Mac/Linux)
- Right-click the script → Properties → Make executable
- Or run: `chmod +x scripts/start-mac.sh` (or `start-linux.sh`)

### Script closes immediately
- The script needs to be run from the project folder
- Make sure you're in the correct directory
- On Windows, you can drag the script file into a Command Prompt window

### Setup takes a long time
- This is normal! Installing dependencies can take 5-10 minutes
- Make sure you have a stable internet connection
- Don't close the window while setup is running

### "npm is not available" (Windows)
- The script automatically detects `npm.cmd` on Windows
- If you see this error, try closing and reopening the command prompt
- Make sure Node.js was installed correctly (npm comes with Node.js)

### Script works but stops after detecting Node.js
- **Windows:** Make sure you're running from Command Prompt, not PowerShell
- Or double-click the `.bat` file instead of running from terminal
- The script should continue automatically after detecting Node.js and npm


