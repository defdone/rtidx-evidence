require('dotenv').config();

/**
 * Push/pull job socket port is fixed at **6000** for this starter (matches `push.bind(6000)` in `src/infra/workerTransport.js`).
 * Only the worker **host** is configurable (Docker service name vs localhost).
 */
const WORKER_JOB_SOCKET_PORT = 6000;

const workerSocketHost =
  process.env.WORKER_SOCKET_HOST || process.env.AXJET_PUSH_HOST || '127.0.0.1';

const databaseUrl = (process.env.DATABASE_URL || '').trim();
const useEmbeddedPostgres = !databaseUrl;

let mockChain;
if (process.env.MOCK_CHAIN !== undefined && String(process.env.MOCK_CHAIN).trim() !== '') {
  mockChain = String(process.env.MOCK_CHAIN).toLowerCase() === 'true';
} else if (useEmbeddedPostgres) {
  mockChain = true;
} else {
  mockChain = false;
}

module.exports = {
  port: Number(process.env.PORT || 3000),
  databaseUrl: databaseUrl || null,
  useEmbeddedPostgres,
  workerSocketPort: WORKER_JOB_SOCKET_PORT,
  workerSocketHost,
  rpcUrl: process.env.RPC_URL || '',
  mockChain,
  logLevel: process.env.LOG_LEVEL || 'info',
  rpcReceiptRetries: Math.max(0, Number(process.env.RPC_RECEIPT_RETRIES || 5)),
};
