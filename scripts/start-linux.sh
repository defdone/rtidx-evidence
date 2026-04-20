#!/bin/bash
# AI Agent Marketplace - Linux Launcher
# Run this script to automatically set up and run the project

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "  AI Agent Marketplace - Quick Start"
echo "========================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR] Node.js is not installed!${NC}"
    echo ""
    echo "Please install Node.js first:"
    echo ""
    echo "Option 1 - Using NodeSource (recommended):"
    echo "  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    echo ""
    echo "Option 2 - Download from website:"
    echo "  1. Visit: https://nodejs.org/"
    echo "  2. Download the LTS version"
    echo "  3. Follow installation instructions"
    echo ""
    
    # Try to open the download page
    if command -v xdg-open &> /dev/null; then
        xdg-open https://nodejs.org/ 2>/dev/null || echo "Please manually visit: https://nodejs.org/"
    else
        echo "Please manually visit: https://nodejs.org/"
    fi
    
    exit 1
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
    echo ""
    echo "Debug: Searching for npm..."
    which npm 2>/dev/null || echo "npm not found in PATH"
    exit 1
fi

# Get npm version for confirmation
NPM_VERSION=$(npm --version 2>/dev/null)
if [ -n "$NPM_VERSION" ]; then
    echo -e "${GREEN}[OK] npm ${NPM_VERSION} detected${NC}"
    echo ""
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT" || {
    echo -e "${RED}[ERROR] Failed to change to project directory!${NC}"
    echo "Current directory: $(pwd)"
    echo "Attempted directory: ${PROJECT_ROOT}"
    exit 1
}

echo -e "${BLUE}[INFO] Project directory: $(pwd)${NC}"
echo ""

# Check if package.json exists
if [ ! -f "$PROJECT_ROOT/package.json" ]; then
    echo -e "${RED}[ERROR] package.json not found!${NC}"
    echo "Please make sure you're running this from the project folder."
    exit 1
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



