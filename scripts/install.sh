#!/bin/bash
# Universal Installer Script for AI Agent Marketplace
# Works on Windows (PowerShell), macOS, and Linux
# Usage: curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | bash
# Or: curl -s https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts/install.sh | sh

# ========================================
# CONFIGURATION
# ========================================
BASE_URL="https://bitbucket.org/daam2251/ai-agent-marketplace/raw/main/scripts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "  AI Agent Marketplace - Universal Installer"
echo "========================================"
echo ""

# Function to detect operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)
            echo "linux"
            ;;
        Darwin*)
            echo "macos"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "windows"
            ;;
        *)
            # Try to detect Windows from environment
            if [ -n "$WINDIR" ] || [ -n "$OS" ]; then
                echo "windows"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# Function to download and execute Windows script
install_windows() {
    echo -e "${BLUE}[INFO] Detected Windows operating system${NC}"
    echo -e "${BLUE}[INFO] Downloading Windows installer...${NC}"
    echo ""
    
    # Create temp directory (Windows-compatible)
    if [ -n "$TEMP" ]; then
        TEMP_DIR="$TEMP/ai-agent-marketplace-installer"
    elif [ -n "$TMP" ]; then
        TEMP_DIR="$TMP/ai-agent-marketplace-installer"
    else
        TEMP_DIR="/tmp/ai-agent-marketplace-$$"
    fi
    mkdir -p "$TEMP_DIR" 2>/dev/null
    SCRIPT_FILE="${TEMP_DIR}/install-windows.bat"
    
    # Download the Windows universal installer
    if command -v curl &> /dev/null; then
        curl -L -o "$SCRIPT_FILE" "${BASE_URL}/install-windows.bat" 2>/dev/null
    elif command -v wget &> /dev/null; then
        wget -O "$SCRIPT_FILE" "${BASE_URL}/install-windows.bat" 2>/dev/null
    else
        echo -e "${RED}[ERROR] Neither curl nor wget is available.${NC}"
        echo -e "${YELLOW}[INFO] Please download manually from:${NC}"
        echo -e "${YELLOW}  ${BASE_URL}/install-windows.bat${NC}"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_FILE" ]; then
        echo -e "${RED}[ERROR] Failed to download Windows installer.${NC}"
        echo -e "${YELLOW}[INFO] Please download manually from:${NC}"
        echo -e "${YELLOW}  ${BASE_URL}/install-windows.bat${NC}"
        exit 1
    fi
    
    # Make it executable (for Git Bash)
    chmod +x "$SCRIPT_FILE" 2>/dev/null
    
    echo -e "${GREEN}[OK] Script downloaded successfully${NC}"
    echo -e "${BLUE}[INFO] Executing Windows installer...${NC}"
    echo ""
    
    # Execute the Windows script
    # Convert path to Windows format if needed (Git Bash)
    if command -v cygpath &> /dev/null; then
        WIN_SCRIPT_FILE=$(cygpath -w "$SCRIPT_FILE")
        cmd.exe /c "\"$WIN_SCRIPT_FILE\""
    else
        # Try direct execution
        "$SCRIPT_FILE"
    fi
}

# Function to download and execute macOS script
install_macos() {
    echo -e "${BLUE}[INFO] Detected macOS operating system${NC}"
    echo -e "${BLUE}[INFO] Downloading macOS installer...${NC}"
    echo ""
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    SCRIPT_FILE="${TEMP_DIR}/auto-start-mac.sh"
    
    # Download the macOS script
    if ! curl -L -o "$SCRIPT_FILE" "${BASE_URL}/auto-start-mac.sh"; then
        echo -e "${RED}[ERROR] Failed to download macOS script.${NC}"
        exit 1
    fi
    
    # Make it executable
    chmod +x "$SCRIPT_FILE"
    
    echo -e "${GREEN}[OK] Script downloaded successfully${NC}"
    echo -e "${BLUE}[INFO] Executing macOS installer...${NC}"
    echo ""
    
    # Execute the script
    exec "$SCRIPT_FILE"
}

# Function to download and execute Linux script
install_linux() {
    echo -e "${BLUE}[INFO] Detected Linux operating system${NC}"
    echo -e "${BLUE}[INFO] Downloading Linux installer...${NC}"
    echo ""
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    SCRIPT_FILE="${TEMP_DIR}/auto-start-linux.sh"
    
    # Download the Linux script
    if command -v curl &> /dev/null; then
        curl -L -o "$SCRIPT_FILE" "${BASE_URL}/auto-start-linux.sh"
    elif command -v wget &> /dev/null; then
        wget -O "$SCRIPT_FILE" "${BASE_URL}/auto-start-linux.sh"
    else
        echo -e "${RED}[ERROR] Neither curl nor wget is available.${NC}"
        echo -e "${YELLOW}[INFO] Please install curl or wget first.${NC}"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_FILE" ]; then
        echo -e "${RED}[ERROR] Failed to download Linux script.${NC}"
        exit 1
    fi
    
    # Make it executable
    chmod +x "$SCRIPT_FILE"
    
    echo -e "${GREEN}[OK] Script downloaded successfully${NC}"
    echo -e "${BLUE}[INFO] Executing Linux installer...${NC}"
    echo ""
    
    # Execute the script
    exec "$SCRIPT_FILE"
}

# Main execution
OS=$(detect_os)

case "$OS" in
    windows)
        install_windows
        ;;
    macos)
        install_macos
        ;;
    linux)
        install_linux
        ;;
    *)
        echo -e "${RED}[ERROR] Unsupported operating system.${NC}"
        echo -e "${YELLOW}[INFO] Detected OS: $(uname -s)${NC}"
        echo -e "${YELLOW}[INFO] Please download the appropriate script manually:${NC}"
        echo -e "${YELLOW}  Windows: ${BASE_URL}/auto-start-windows.bat${NC}"
        echo -e "${YELLOW}  macOS:   ${BASE_URL}/auto-start-mac.sh${NC}"
        echo -e "${YELLOW}  Linux:   ${BASE_URL}/auto-start-linux.sh${NC}"
        exit 1
        ;;
esac

