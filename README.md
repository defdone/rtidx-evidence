# DeFi Real Estate

A decentralized real estate platform built with React, Vite, and Web3 technologies.

## Features

- Browse and explore real estate properties
- **Wallet Integration**: Connect with MetaMask, WalletConnect, and other popular wallets via RainbowKit
- Built with modern React and Vite
- Styled with Tailwind CSS
- Web3 integration with Wagmi and Viem
- Support for multiple chains (Ethereum, Polygon, Optimism, Arbitrum, Base, and Sepolia testnet)

## Getting Started

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   - Create a `.env` file in the root directory
   - Add your WalletConnect Project ID (get a free one from https://cloud.walletconnect.com):
     ```
     VITE_WALLETCONNECT_PROJECT_ID=your_project_id_here
     ```
   - Optionally enable testnets:
     ```
     VITE_ENABLE_TESTNETS=true
     ```
   - After deploying `contracts/AssetFactory.sol`, set the contract address for the app to use:
     ```
     VITE_ASSET_FACTORY_ADDRESS=0xYourDeployedContractAddress
     ```

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Tech Stack

- **Frontend**: React 18, Vite
- **Styling**: Tailwind CSS
- **Web3**: Wagmi, Viem, RainbowKit
- **Routing**: React Router DOM
- **Animations**: Framer Motion
- **Icons**: Lucide React

## Project Structure

```
src/
├── components/     # Reusable UI components
├── pages/         # Page components
├── context/       # React context providers
├── utils/         # Utility functions and types
└── styles/        # Global styles
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request