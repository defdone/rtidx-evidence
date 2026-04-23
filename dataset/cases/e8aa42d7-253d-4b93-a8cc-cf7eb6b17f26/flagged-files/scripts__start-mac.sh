#!/bin/bash
# AI Agent Marketplace - macOS/Linux Launcher
# Double-click this file (or run: bash start-mac.sh) to automatically set up and run the project

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

# Minimum Node.js major version required (e.g. 20 for Node 20.x)
NODE_MIN_MAJOR=20

# Get Node.js major version number (e.g. 10 or 24). Empty if node not available.
get_node_major_version() {
    node --version 2>/dev/null | sed -n 's/^v\([0-9]*\).*/\1/p'
}

# Load nvm into current shell if installed (so we may pick up Node 20+ from nvm)
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR] Node.js is not installed!${NC}"
    echo ""
    echo "This project requires Node.js version ${NODE_MIN_MAJOR} or higher."
    echo ""
    echo "Recommended - install via nvm (no admin required):"
    echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
    echo "  Then restart terminal, or run: . \"\$HOME/.nvm/nvm.sh\""
    echo "  nvm install 24"
    echo "  nvm use 24"
    echo ""
    echo "Or install from: https://nodejs.org/ (LTS version 20+)"
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open https://nodejs.org/ 2>/dev/null || true
    fi
    exit 1
fi

# Check Node.js version (must be >= NODE_MIN_MAJOR)
NODE_MAJOR=$(get_node_major_version)
if [ -z "$NODE_MAJOR" ] || [ "$NODE_MAJOR" -lt "$NODE_MIN_MAJOR" ] 2>/dev/null; then
    echo -e "${RED}[ERROR] Node.js version is too old (detected: $(node --version 2>/dev/null), need >= ${NODE_MIN_MAJOR}).${NC}"
    echo ""
    echo "macOS sometimes ships an old Node. Install a newer version:"
    echo ""
    echo "Option 1 - nvm (recommended):"
    echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
    echo "  . \"\$HOME/.nvm/nvm.sh\""
    echo "  nvm install 24"
    echo "  nvm use 24"
    echo ""
    echo "Option 2 - Download Node 20+ from: https://nodejs.org/"
    echo ""
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


