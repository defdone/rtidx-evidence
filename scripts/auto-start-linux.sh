#!/bin/bash
# AI Agent Marketplace - Linux Auto-Install & Launcher
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
    
    # Check if curl or wget is available
    if command -v curl &> /dev/null; then
        DOWNLOAD_CMD="curl -L -o"
    elif command -v wget &> /dev/null; then
        DOWNLOAD_CMD="wget -O"
    else
        echo -e "${RED}[ERROR] Neither curl nor wget is available.${NC}"
        echo -e "${YELLOW}[INFO] Please install curl or wget to download the project.${NC}"
        exit 1
    fi
    
    # Download ZIP file
    ZIP_FILE="${PROJECT_ROOT}/${REPO_NAME}.zip"
    EXTRACT_DIR="${PROJECT_ROOT}/extracted-temp"
    
    echo -e "${BLUE}[INFO] Downloading repository as ZIP...${NC}"
    if ! $DOWNLOAD_CMD "$ZIP_FILE" "$ZIP_URL"; then
        echo -e "${RED}[ERROR] Failed to download repository.${NC}"
        echo -e "${YELLOW}[INFO] Please check your internet connection and ZIP URL.${NC}"
        echo -e "${YELLOW}[INFO] ZIP URL: ${ZIP_URL}${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}[INFO] Download completed. Extracting files...${NC}"
    
    # Check if unzip is available
    if ! command -v unzip &> /dev/null; then
        echo -e "${YELLOW}[WARN] unzip not found. Installing unzip...${NC}"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y unzip
        elif command -v yum &> /dev/null; then
            sudo yum install -y unzip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y unzip
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy --noconfirm unzip
        else
            echo -e "${RED}[ERROR] Cannot install unzip automatically.${NC}"
            echo -e "${YELLOW}[INFO] Please install unzip manually and try again.${NC}"
            exit 1
        fi
    fi
    
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
# Step 1: Check if Node.js is installed
# ========================================
# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]'
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# Function to install Node.js on Debian/Ubuntu
install_nodejs_debian() {
    echo -e "${BLUE}[INFO] Installing Node.js using NodeSource repository...${NC}"
    echo ""
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}[WARN] curl not found. Installing curl first...${NC}"
        sudo apt-get update -qq
        sudo apt-get install -y curl
    fi
    
    # Install Node.js LTS from NodeSource
    echo -e "${BLUE}[INFO] Adding NodeSource repository...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Failed to add NodeSource repository${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[INFO] Installing Node.js...${NC}"
    sudo apt-get install -y nodejs > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Failed to install Node.js${NC}"
        return 1
    fi
    
    return 0
}

# Function to install Node.js on RHEL/CentOS/Fedora
install_nodejs_rhel() {
    echo -e "${BLUE}[INFO] Installing Node.js using NodeSource repository...${NC}"
    echo ""
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}[WARN] curl not found. Installing curl first...${NC}"
        if command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        else
            sudo yum install -y curl
        fi
    fi
    
    # Install Node.js LTS from NodeSource
    echo -e "${BLUE}[INFO] Adding NodeSource repository...${NC}"
    curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash - > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Failed to add NodeSource repository${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[INFO] Installing Node.js...${NC}"
    if command -v dnf &> /dev/null; then
        sudo dnf install -y nodejs > /dev/null 2>&1
    else
        sudo yum install -y nodejs > /dev/null 2>&1
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Failed to install Node.js${NC}"
        return 1
    fi
    
    return 0
}

# Function to install Node.js on Arch Linux
install_nodejs_arch() {
    echo -e "${BLUE}[INFO] Installing Node.js using pacman...${NC}"
    echo ""
    
    sudo pacman -Sy --noconfirm nodejs npm > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Failed to install Node.js${NC}"
        return 1
    fi
    
    return 0
}

# Function to install Node.js automatically
install_nodejs() {
    DISTRO=$(detect_distro)
    
    echo -e "${YELLOW}[WARN] Node.js is not installed.${NC}"
    echo -e "${BLUE}[INFO] Attempting to install Node.js automatically...${NC}"
    echo ""
    
    # Check if we have sudo access
    if ! sudo -n true 2>/dev/null; then
        echo -e "${YELLOW}[INFO] This script requires sudo privileges to install Node.js.${NC}"
        echo -e "${YELLOW}[INFO] You will be prompted for your password.${NC}"
        echo ""
    fi
    
    case "$DISTRO" in
        ubuntu|debian)
            install_nodejs_debian
            ;;
        rhel|centos|fedora)
            install_nodejs_rhel
            ;;
        arch|manjaro)
            install_nodejs_arch
            ;;
        *)
            echo -e "${RED}[ERROR] Unsupported Linux distribution: $DISTRO${NC}"
            echo -e "${YELLOW}[INFO] Please install Node.js manually from https://nodejs.org/${NC}"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK] Node.js installed successfully!${NC}"
        echo ""
        
        # Refresh PATH in case node was just installed
        export PATH="/usr/bin:/usr/local/bin:$PATH"
        
        # Verify installation
        if command -v node &> /dev/null; then
            NODE_VERSION=$(node --version 2>/dev/null)
            echo -e "${GREEN}[OK] Node.js ${NODE_VERSION} is now available${NC}"
            echo ""
            return 0
        else
            echo -e "${YELLOW}[WARN] Node.js installed but not found in PATH.${NC}"
            echo -e "${YELLOW}[INFO] Please restart your terminal and run this script again.${NC}"
            return 1
        fi
    else
        return 1
    fi
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    if ! install_nodejs; then
        echo -e "${RED}[ERROR] Failed to install Node.js automatically.${NC}"
        echo -e "${YELLOW}[INFO] Please install Node.js manually and try again.${NC}"
        exit 1
    fi
fi

# Get Node.js version
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
    echo "Please reinstall Node.js (npm comes with Node.js)"
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
    echo -e "${RED}[ERROR] Setup failed! Please check the error messages above.${NC}"
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
