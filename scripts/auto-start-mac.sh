#!/bin/bash
# AI Agent Marketplace - macOS Auto-Install & Launcher
# Fully portable script that downloads the project and sets everything up automatically

# ========================================
# CONFIGURATION - Update this with your ZIP download URL
# ========================================
# IMPORTANT: Replace the URL below with your actual ZIP download URL
# Examples:
#   Bitbucket: https://bitbucket.org/username/repo/get/master.zip
#   GitHub: https://github.com/username/repo/archive/refs/heads/main.zip
#   GitLab: https://gitlab.com/username/repo/-/archive/main/repo-main.zip
#   Or any direct ZIP download URL
# ========================================
ZIP_URL="https://bitbucket.org/daam2251/ai-agent-marketplace/get/main.zip"
REPO_NAME="ai-agent-marketplace"
# Note: The script always downloads as ZIP (no Git required)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "  AI Agent Marketplace - Auto Start"
echo "========================================"
echo ""

# ========================================
# Step 0: Create project folder and check/download project if needed
# ========================================
echo -e "${BLUE}[INFO] Setting up project folder...${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create project folder with repo name in the same directory as the script
PROJECT_ROOT="${SCRIPT_DIR}/${REPO_NAME}"

echo -e "${BLUE}[INFO] Script directory: ${SCRIPT_DIR}${NC}"
echo -e "${BLUE}[INFO] Project will be created at: ${PROJECT_ROOT}${NC}"

# Create project folder if it doesn't exist
if [ ! -d "$PROJECT_ROOT" ]; then
    echo -e "${BLUE}[INFO] Creating project folder: ${PROJECT_ROOT}${NC}"
    mkdir -p "$PROJECT_ROOT"
fi

# Change to project root
cd "$PROJECT_ROOT" || {
    echo -e "${RED}[ERROR] Failed to create or access project directory!${NC}"
    echo "Attempted directory: ${PROJECT_ROOT}"
    exit 1
}

# Check if package.json exists (project is already downloaded)
if [ -f "package.json" ]; then
    echo -e "${GREEN}[OK] Project found in: $(pwd)${NC}"
    echo ""
    # Continue to Node.js check
else
    # Project not found, need to download it
    echo -e "${BLUE}[INFO] Project not found. Downloading from ZIP URL...${NC}"
    echo -e "${BLUE}[INFO] ZIP URL: ${ZIP_URL}${NC}"
    echo -e "${BLUE}[INFO] This may take a few minutes. Please wait...${NC}"
    echo ""
    
    # Download ZIP file
    ZIP_FILE="${PROJECT_ROOT}/${REPO_NAME}.zip"
    EXTRACT_DIR="${PROJECT_ROOT}/extracted-temp"
    
    echo -e "${BLUE}[INFO] Downloading repository as ZIP...${NC}"
    if ! curl -L -o "$ZIP_FILE" "$ZIP_URL"; then
        echo -e "${RED}[ERROR] Failed to download repository.${NC}"
        echo -e "${YELLOW}[INFO] Please check your internet connection and ZIP URL.${NC}"
        echo -e "${YELLOW}[INFO] ZIP URL: ${ZIP_URL}${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}[INFO] Download completed. Extracting files...${NC}"
    
    # Extract ZIP file
    if [ -d "$EXTRACT_DIR" ]; then
        rm -rf "$EXTRACT_DIR"
    fi
    mkdir -p "$EXTRACT_DIR"
    
    if ! unzip -q "$ZIP_FILE" -d "$EXTRACT_DIR"; then
        echo -e "${RED}[ERROR] Failed to extract ZIP file.${NC}"
        rm -f "$ZIP_FILE"
        exit 1
    fi
    
    # Find extracted folder
    EXTRACTED_FOLDER=$(find "$EXTRACT_DIR" -maxdepth 1 -type d \( -name "*${REPO_NAME}*" -o -name "*main*" -o -name "*master*" -o -name "*main*" \) | head -n 1)
    
    if [ -z "$EXTRACTED_FOLDER" ]; then
        # Try to find any directory
        EXTRACTED_FOLDER=$(find "$EXTRACT_DIR" -maxdepth 1 -type d ! -path "$EXTRACT_DIR" | head -n 1)
    fi
    
    if [ -n "$EXTRACTED_FOLDER" ]; then
        echo -e "${BLUE}[INFO] Copying files to project directory...${NC}"
        echo -e "${BLUE}[INFO] Found folder: $(basename "$EXTRACTED_FOLDER")${NC}"
        cp -r "${EXTRACTED_FOLDER}"/* "$PROJECT_ROOT"/
        rm -rf "$EXTRACTED_FOLDER"
    else
        echo -e "${RED}[ERROR] Could not find extracted folder.${NC}"
        rm -rf "$EXTRACT_DIR"
        rm -f "$ZIP_FILE"
        exit 1
    fi
    
    # Clean up
    rm -rf "$EXTRACT_DIR"
    echo -e "${GREEN}[OK] Project downloaded and extracted successfully!${NC}"
    echo -e "${BLUE}[INFO] ZIP file saved at: ${ZIP_FILE}${NC}"
    echo -e "${BLUE}[INFO] You can delete it manually if you want to re-download next time.${NC}"
    echo ""
fi

# Verify project was downloaded
if [ ! -f "package.json" ]; then
    echo -e "${RED}[ERROR] Project download completed but package.json not found!${NC}"
    echo -e "${YELLOW}[INFO] Please check the ZIP URL and try again.${NC}"
    echo -e "${YELLOW}[INFO] Current directory: $(pwd)${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Project is ready!${NC}"
echo -e "${BLUE}[INFO] Project directory: $(pwd)${NC}"
echo ""

# ========================================
# Step 1: Check if Node.js is installed (version >= 20)
# ========================================
NODE_MIN_MAJOR=20
NODE_TARGET_VERSION="v24.14.0"
NODE_INSTALL_BASE="${HOME}/.local/share/ai-agent-marketplace/node"

# Get Node.js major version number (e.g. 10 or 24). Empty if node not available.
get_node_major_version() {
    local ver
    ver=$(node --version 2>/dev/null | sed -n 's/^v\([0-9]*\).*/\1/p')
    echo "$ver"
}

detect_macos_node_arch() {
    case "$(uname -m)" in
        arm64)
            echo "arm64"
            ;;
        x86_64)
            echo "x64"
            ;;
        *)
            echo ""
            ;;
    esac
}

use_portable_node_if_present() {
    local arch
    local node_dir
    arch=$(detect_macos_node_arch)
    if [ -z "$arch" ]; then
        return 1
    fi

    node_dir="${NODE_INSTALL_BASE}/${NODE_TARGET_VERSION}-darwin-${arch}"
    if [ -x "${node_dir}/bin/node" ]; then
        export PATH="${node_dir}/bin:${PATH}"
        return 0
    fi
    return 1
}

install_portable_node() {
    local arch
    local node_dir
    local archive_name
    local download_url
    local temp_dir
    local archive_path
    local extracted_dir

    arch=$(detect_macos_node_arch)
    if [ -z "$arch" ]; then
        echo -e "${RED}[ERROR] Unsupported macOS CPU architecture: $(uname -m)${NC}"
        return 1
    fi

    node_dir="${NODE_INSTALL_BASE}/${NODE_TARGET_VERSION}-darwin-${arch}"
    archive_name="node-${NODE_TARGET_VERSION}-darwin-${arch}.tar.gz"
    download_url="https://nodejs.org/dist/${NODE_TARGET_VERSION}/${archive_name}"

    echo -e "${BLUE}[INFO] Installing portable Node.js ${NODE_TARGET_VERSION} for macOS ${arch}...${NC}"
    echo -e "${BLUE}[INFO] This does not use nvm, Homebrew, sudo, or Xcode.${NC}"
    echo ""

    mkdir -p "$NODE_INSTALL_BASE" || return 1
    temp_dir=$(mktemp -d) || return 1
    archive_path="${temp_dir}/${archive_name}"

    if ! curl -fsSL -o "$archive_path" "$download_url"; then
        echo -e "${RED}[ERROR] Failed to download Node.js from:${NC}"
        echo -e "${RED}  ${download_url}${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    if ! tar -xzf "$archive_path" -C "$temp_dir"; then
        echo -e "${RED}[ERROR] Failed to extract Node.js archive.${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    extracted_dir="${temp_dir}/node-${NODE_TARGET_VERSION}-darwin-${arch}"
    if [ ! -d "$extracted_dir" ]; then
        echo -e "${RED}[ERROR] Extracted Node.js directory not found.${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    rm -rf "$node_dir"
    if ! mv "$extracted_dir" "$node_dir"; then
        echo -e "${RED}[ERROR] Failed to move Node.js into install directory.${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    rm -rf "$temp_dir"
    export PATH="${node_dir}/bin:${PATH}"

    echo -e "${GREEN}[OK] Portable Node.js $(node --version 2>/dev/null) installed and active${NC}"
    return 0
}

# Load project-managed Node.js first if we already installed it earlier
use_portable_node_if_present

# Check if we have Node.js and it is at least version 20
NODE_MAJOR=$(get_node_major_version)
NEED_INSTALL=false
if [ -z "$NODE_MAJOR" ]; then
    NEED_INSTALL=true
elif [ "$NODE_MAJOR" -lt "$NODE_MIN_MAJOR" ] 2>/dev/null; then
    echo -e "${YELLOW}[WARN] Node.js version is too old (detected: $(node --version 2>/dev/null), need >= ${NODE_MIN_MAJOR}).${NC}"
    echo -e "${BLUE}[INFO] Will install portable Node.js ${NODE_TARGET_VERSION}.${NC}"
    echo ""
    NEED_INSTALL=true
fi

if [ "$NEED_INSTALL" = true ]; then
    if ! install_portable_node; then
        echo -e "${RED}[ERROR] Failed to install Node.js automatically.${NC}"
        echo -e "${YELLOW}[INFO] Please install Node.js ${NODE_MIN_MAJOR}+ manually from https://nodejs.org/ and re-run this script.${NC}"
        exit 1
    fi
fi

# Final verification: node must be available and version >= 20
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR] Node.js is not available in PATH.${NC}"
    echo -e "${YELLOW}[INFO] Please install Node.js ${NODE_MIN_MAJOR}+ from https://nodejs.org/ and re-run this script.${NC}"
    exit 1
fi

NODE_MAJOR=$(get_node_major_version)
if [ -n "$NODE_MAJOR" ] && [ "$NODE_MAJOR" -lt "$NODE_MIN_MAJOR" ] 2>/dev/null; then
    echo -e "${RED}[ERROR] Node.js version must be >= ${NODE_MIN_MAJOR} (detected: $(node --version)).${NC}"
    echo -e "${YELLOW}[INFO] Please install Node.js ${NODE_MIN_MAJOR}+ from https://nodejs.org/ and re-run this script.${NC}"
    exit 1
fi

# Get Node.js version for display
NODE_VERSION=$(node --version 2>/dev/null)
if [ -z "$NODE_VERSION" ]; then
    NODE_VERSION="detected"
fi
echo -e "${GREEN}[OK] Node.js ${NODE_VERSION} detected${NC}"
echo ""

# Check if npm is available
echo -e "${BLUE}[INFO] Checking for npm...${NC}"
if ! command -v npm &> /dev/null; then
    echo -e "${RED}[ERROR] npm is not available!${NC}"
    echo -e "${YELLOW}[INFO] Node.js was found, but npm was not available in PATH.${NC}"
    echo -e "${YELLOW}[INFO] Please reinstall Node.js ${NODE_MIN_MAJOR}+ from https://nodejs.org/ and re-run this script.${NC}"
    exit 1
fi

# Get npm version for confirmation
NPM_VERSION=$(npm --version 2>/dev/null)
if [ -n "$NPM_VERSION" ]; then
    echo -e "${GREEN}[OK] npm ${NPM_VERSION} detected${NC}"
    echo ""
fi

echo "========================================"
echo "  Step 1: Setting up the project..."
echo "========================================"
echo ""
echo "This may take a few minutes. Please wait..."
echo ""

# Run setup
if ! npm run setup; then
    echo ""
    echo -e "${RED}[ERROR] Project setup failed during 'npm run setup'.${NC}"
    echo -e "${YELLOW}[INFO] Node.js installation completed, so this is likely a dependency install or project setup issue.${NC}"
    echo -e "${YELLOW}[INFO] If the logs mention 'xcode', 'clang', 'make', or 'node-gyp', then an npm package is trying to build native code on this Mac.${NC}"
    echo -e "${YELLOW}[INFO] In that case, Apple Command Line Tools may still be required even though full Xcode is not.${NC}"
    echo -e "${YELLOW}[INFO] If the logs do not mention build tools, review the npm error above for the specific package that failed.${NC}"
    exit 1
fi

echo ""
echo "========================================"
echo "  Step 2: Starting the application..."
echo "========================================"
echo ""
echo "The application will start in a moment..."
echo "Once started, you can access it at:"
echo "  - Frontend: http://localhost:5173"
echo "  - Backend:  http://localhost:3001"
echo ""
echo "To stop the application, press Ctrl+C"
echo ""

# Run dev
npm run dev
