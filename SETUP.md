# Setup Guide

Simple setup instructions to get the AI Agent Marketplace running.

---

## Prerequisites

- **Node.js 18+** (check with `node --version`)
- **npm 9+** (comes with Node.js)
- **MetaMask** browser extension (optional, for wallet features)

**No database required!** The backend uses mock data by default.  
**No .env file setup needed!** The setup script automatically creates `.env` files with sensible defaults.

---

## Quick Setup (3 Steps)

### 1. Install Dependencies

Run the setup script from the project root:

```bash
npm run setup
```

This installs all dependencies for frontend, backend, and contracts, and creates `.env` files automatically.

**Or install manually:**
```bash
npm install
cd frontend && npm install && cd ..
cd backend && npm install && cd ..
cd contracts && npm install && cd ..
```

### 2. Start the Application

**Option A: Start both servers with one command (recommended)**
```bash
npm run dev
```
This starts both frontend and backend in a single terminal with colored output.

**Option B: Start servers separately**

**Terminal 1 - Backend:**
```bash
npm run dev:backend
```

**Terminal 2 - Frontend:**
```bash
npm run dev:frontend
```

### 3. Access the Application

- **Frontend:** http://localhost:5173 (or the port shown in terminal)
- **Backend API:** http://localhost:3001
- **Health Check:** http://localhost:3001/health

**That's it!** The application should be running.

---

## Understanding the Project Structure

This project uses **npm workspaces** - a feature that allows managing multiple related packages in one repository:

```
ai-agent-marketplace/
├── package.json          # Root workspace config (manages all sub-projects)
├── frontend/
│   └── package.json      # Frontend dependencies (React, Vite, etc.)
├── backend/
│   └── package.json      # Backend dependencies (Express, Prisma, etc.)
└── contracts/
    └── package.json      # Smart contract dependencies (Hardhat, etc.)
```

**Benefits:**
- Each part (frontend, backend, contracts) has its own isolated dependencies
- Can run commands from root or individual directories
- Easier to manage version conflicts
- Standard pattern for monorepo projects

**You can install all at once:**
```bash
npm install --workspaces
```

**Or install individually:**
```bash
cd frontend && npm install
cd ../backend && npm install
cd ../contracts && npm install
```

---

## Troubleshooting

### "Command not found" errors
- Make sure you're in the project root directory
- Ensure Node.js is installed: `node --version`

### Port already in use
- Backend uses port 3001, frontend uses 5173 (or next available)
- Change ports in `backend/.env` (PORT) or `frontend/vite.config.js`

### Dependencies won't install
- Delete `node_modules` folders and try again
- Clear npm cache: `npm cache clean --force`
- Make sure you have Node.js 18+

### Frontend won't start
- Check that all dependencies are installed: `cd frontend && npm install`
- Verify Node.js version: `node --version` (should be 18+)

### Backend won't start
- Check that dependencies are installed: `cd backend && npm install`
- Verify the port isn't in use
- Check console for error messages

---

## What's Next?

1. ✅ Setup complete - you should see the frontend and backend running
2. Open http://localhost:5173 in your browser
3. Check the health endpoint: http://localhost:3001/health
4. Explore the codebase!

---

## Advanced Setup

For advanced setup with database, contract deployment, and production configuration, see **[docs/SETUP.md](docs/SETUP.md)**.

---

**That's it! No database, no complex configuration needed. Just install and run!** 🚀
