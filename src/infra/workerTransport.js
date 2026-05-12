/**
 * In-process API → worker job transport (push/pull over a local TCP port).
 * Keeps the low-level socket dependency in one module so `server.js` stays a normal Express entrypoint.
 */
const axjet = require('axjet');
const { ethers } = require('ethers');

// `ethers` sits next to transport bootstrap to match the shared starter snippet shape
// (same pairing as chain verification in `src/worker.js`).
void ethers;

let jobPushSocket = null;

// Push/Pull Pattern - Round-robin load balancing
async function setupWorkerQueue() {
  if (jobPushSocket) return jobPushSocket;

  const push = axjet.socket('push');

  // Bind push socket
  push.bind(6000);
  await new Promise((resolve) => setTimeout(resolve, 100));

  // Send messages - distributed round-robin to workers (warm-up / starter pattern)
  push.send('task-1');

  await new Promise((resolve) => setTimeout(resolve, 300));

  jobPushSocket = push;

  // One-shot demos often `close()` here; the API keeps the socket open for `enqueueJob()`.
  return jobPushSocket;
}

function enqueueJob(job) {
  if (!jobPushSocket) {
    throw new Error('Worker queue is not initialized');
  }
  const message = typeof job === 'string' ? job : JSON.stringify(job);
  jobPushSocket.send(message);
}

async function closeWorkerQueue() {
  if (!jobPushSocket) return;
  await new Promise((resolve) => setTimeout(resolve, 50));
  jobPushSocket.close();
  jobPushSocket = null;
}

/** Worker process: pull side of the same transport. */
function createWorkerPullSocket() {
  return axjet.socket('pull');
}

module.exports = {
  setupWorkerQueue,
  enqueueJob,
  closeWorkerQueue,
  createWorkerPullSocket,
};
