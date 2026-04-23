#!/usr/bin/env node

/**
 * Simple setup script for AI Agent Marketplace
 * Installs all dependencies for frontend, backend, and contracts
 */

import { execSync } from 'child_process';
import { existsSync, copyFileSync, writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[36m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function runCommand(command, cwd = process.cwd()) {
  try {
    execSync(command, { 
      cwd, 
      stdio: 'inherit',
      shell: true 
    });
    return true;
  } catch (error) {
    return false;
  }
}

function checkNodeVersion() {
  try {
    const version = execSync('node --version', { encoding: 'utf-8' }).trim();
    const majorVersion = parseInt(version.replace('v', '').split('.')[0]);
    if (majorVersion < 18) {
      log(`⚠️  Warning: Node.js ${version} detected. Node.js 18+ is recommended.`, 'yellow');
      return false;
    }
    log(`✓ Node.js ${version} detected`, 'green');
    return true;
  } catch (error) {
    log('✗ Node.js not found. Please install Node.js 18+ first.', 'red');
    return false;
  }
}


/**
 * Create .env file locally: copy from .env.example if present, otherwise write default content.
 */
function createEnvFile(dir, envExamplePath, envPath, defaultContent) {
  const fullEnvPath = join(dir, envPath);
  const fullExamplePath = join(dir, envExamplePath);

  if (existsSync(fullExamplePath)) {
    try {
      copyFileSync(fullExamplePath, fullEnvPath);
      return;
    } catch (error) {
    }
  }

  try {
    writeFileSync(fullEnvPath, defaultContent, 'utf-8');
  } catch (error) {
  }
}

async function main() {
  log('\n🚀 Setting up AI Agent Marketplace...\n', 'blue');

  // Check Node.js version
  if (!checkNodeVersion()) {
    process.exit(1);
  }

  const rootDir = __dirname;
  const frontendDir = join(rootDir, 'frontend');
  const backendDir = join(rootDir, 'backend');
  const contractsDir = join(rootDir, 'contracts');

  // Check if directories exist
  if (!existsSync(frontendDir) || !existsSync(backendDir) || !existsSync(contractsDir)) {
    log('✗ Project structure is incomplete. Please ensure all directories exist.', 'red');
    process.exit(1);
  }

  // Create .env files locally (from .env.example or default content)
  log('\n📝 Creating environment files...', 'blue');

  const frontendEnvContent = ``;
  createEnvFile(frontendDir, '.env.example', '.env', frontendEnvContent);

  const backendEnvContent = ``;
  createEnvFile(backendDir, '.env.example', '.env', backendEnvContent);

  const contractsEnvContent = ``;
  createEnvFile(contractsDir, '.env.example', '.env', contractsEnvContent);

  // Install root dependencies (if any)
  log('\n📦 Installing root dependencies...', 'blue');
  if (existsSync(join(rootDir, 'package.json'))) {
    runCommand('npm install', rootDir);
  }

  // Install frontend dependencies
  log('\n📦 Installing frontend dependencies...', 'blue');
  if (!runCommand('npm install', frontendDir)) {
    log('✗ Failed to install frontend dependencies', 'red');
    process.exit(1);
  }
  log('✓ Frontend dependencies installed', 'green');

  // Install backend dependencies
  log('\n📦 Installing backend dependencies...', 'blue');
  if (!runCommand('npm install', backendDir)) {
    log('✗ Failed to install backend dependencies', 'red');
    process.exit(1);
  }
  log('✓ Backend dependencies installed', 'green');

  // Install contracts dependencies
  log('\n📦 Installing contracts dependencies...', 'blue');
  if (!runCommand('npm install', contractsDir)) {
    log('✗ Failed to install contracts dependencies', 'red');
    process.exit(1);
  }
  log('✓ Contracts dependencies installed', 'green');


  // Compile contracts
  // TEMPORARILY COMMENTED OUT FOR TESTING
  // log('\n🔨 Compiling smart contracts...', 'blue');
  // if (runCommand('npm run compile', contractsDir)) {
  //   log('✓ Contracts compiled successfully', 'green');
  // } else {
  //   log('⚠️  Contract compilation had issues (this is okay for now)', 'yellow');
  // }

  log('\n✅ Setup complete!\n', 'green');
  log('Next steps:', 'blue');
  log('1. Start both servers: npm run dev', 'blue');
  log('2. Or start separately:', 'blue');
  log('   - Backend:  npm run dev:backend', 'blue');
  log('   - Frontend: npm run dev:frontend\n', 'blue');
}

main().catch((error) => {
  log(`\n✗ Setup failed: ${error.message}`, 'red');
  process.exit(1);
});

