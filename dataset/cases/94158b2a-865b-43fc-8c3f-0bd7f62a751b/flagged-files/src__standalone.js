/**
 * API + worker in one process (required when using embedded PGlite: one DB file cannot be opened by two Node processes).
 * Started from `src/run-dev.js` when DATABASE_URL is unset.
 */
process.env.SPIN_EMBEDDED_SINGLE_PROCESS = '1';
require('dotenv').config();
const { closeWorkerQueue } = require('./infra/workerTransport');
const { pool } = require('./infra/db');

async function main() {
  const { runApiServer } = require('./server');
  const { runWorker } = require('./worker');

  const { server } = await runApiServer({ attachSignals: false });
  const { pull } = await runWorker({ attachSignals: false, skipSleep: true });

  const shutdown = async () => {
    try {
      pull.close();
    } catch (_) {}
    try {
      await closeWorkerQueue();
    } catch (_) {}
    try {
      server.close();
    } catch (_) {}
    try {
      await pool.end();
    } catch (_) {}
    process.exit(0);
  };

  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error(e);
  process.exit(1);
});
