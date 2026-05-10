const { Client } = require('pg');

const url = (process.env.DATABASE_URL || '').trim();
if (!url) {
  console.log('No DATABASE_URL (embedded Postgres mode). Nothing to wait for.');
  process.exit(0);
}

async function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function main() {
  const deadline = Date.now() + 60_000;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const client = new Client({ connectionString: url });
    try {
      await client.connect();
      await client.query('select 1');
      await client.end();
      process.exit(0);
    } catch (e) {
      await client.end().catch(() => {});
      if (Date.now() > deadline) {
        console.error('Postgres not reachable:', e.message);
        process.exit(1);
      }
      await sleep(750);
    }
  }
}

main();
