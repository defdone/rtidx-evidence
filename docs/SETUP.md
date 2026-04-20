# Advanced Setup Guide

This guide covers advanced setup including database configuration, contract deployment, and production settings.

**For simple setup without database, see [../SETUP.md](../SETUP.md)**

---

## Prerequisites

- **Node.js** 18.0.0 or higher
- **npm** 9.0.0 or higher
- **PostgreSQL** 14 or higher (for database setup)
- **Git**
- **MetaMask** browser extension (for frontend testing)

**Optional:**
- Docker (for running PostgreSQL)
- VS Code or your preferred IDE

---

## Step 1: Clone Repository

```bash
git clone [repository-url]
cd ai-agent-marketplace
```

---

## Step 2: Frontend Setup

```bash
cd frontend
npm install
```

**Configure environment:**
```bash
cp .env.example .env
# Edit .env with your configuration
```

**Start development server:**
```bash
npm run dev
```

Frontend should be available at `http://localhost:5173`

---

## Step 3: Backend Setup

```bash
cd backend
npm install
```

**Configure environment:**
```bash
cp .env.example .env
# Edit .env with your database and configuration
```

**Set up database:**
```bash
# Create PostgreSQL database
createdb ai_agent_marketplace

# Run migrations
npx prisma migrate dev

# Generate Prisma Client
npx prisma generate
```

**Start development server:**
```bash
npm run dev
```

Backend should be available at `http://localhost:3001`

---

## Step 4: Smart Contracts Setup

```bash
cd contracts
npm install
```

**Configure environment:**
```bash
cp .env.example .env
# Edit .env with your testnet RPC URL and private key
```

**Compile contracts:**
```bash
npx hardhat compile
```

**Run tests:**
```bash
npx hardhat test
```

**Deploy to testnet (optional):**
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

---

## Step 5: Configuration

### Frontend Configuration

Edit `frontend/.env`:
```
VITE_API_URL=http://localhost:3001/api
VITE_CHAIN_ID=11155111
VITE_CONTRACT_ADDRESSES={"AgentNFT":"","AgentMarketplace":"","RevenueSharing":""}
```

### Backend Configuration

Edit `backend/.env`:
```
PORT=3001
DATABASE_URL=postgresql://user:password@localhost:5432/ai_agent_marketplace
JWT_SECRET=your-secret-key-here
BLOCKCHAIN_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
PRIVATE_KEY=your-private-key-for-contract-interaction
```

### Contracts Configuration

Edit `contracts/.env`:
```
PRIVATE_KEY=your-deployer-private-key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
ETHERSCAN_API_KEY=your-etherscan-api-key
```

---

## Step 6: Verify Setup

1. **Frontend:** Open `http://localhost:5173` - should see React app
2. **Backend:** Check `http://localhost:3001/api/health` - should return status
3. **Contracts:** Run `npx hardhat compile` - should compile without errors

---

## Troubleshooting

### Frontend Issues

**Problem:** Vite dev server won't start
- **Solution:** Check Node.js version (need 18+)
- **Solution:** Delete `node_modules` and reinstall

**Problem:** Tailwind CSS not working
- **Solution:** Check `tailwind.config.js` content paths
- **Solution:** Verify PostCSS configuration

### Backend Issues

**Problem:** Database connection fails
- **Solution:** Check PostgreSQL is running
- **Solution:** Verify DATABASE_URL in .env
- **Solution:** Check database exists

**Problem:** Prisma migration fails
- **Solution:** Check database connection
- **Solution:** Verify schema.prisma syntax

### Contract Issues

**Problem:** Contracts won't compile
- **Solution:** Check Solidity version in hardhat.config.js
- **Solution:** Verify OpenZeppelin contracts installed

**Problem:** Can't deploy to testnet
- **Solution:** Check RPC URL is correct
- **Solution:** Verify private key has testnet ETH
- **Solution:** Check network configuration

---

## Next Steps

Once setup is complete:
1. Review [CONTEXT.md](CONTEXT.md) to understand what's implemented
2. Review [LIMITATIONS.md](LIMITATIONS.md) to see what's not done
3. Start exploring the codebase
4. Provide feedback on architecture and code quality

---

*If you encounter issues not covered here, check the main README or project documentation.*
