const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
const config = require('../config');

function normalizePgResult(r) {
  if (!r) return r;
  let rowCount = r.rowCount;
  if (rowCount == null) {
    const n = r.rows ? r.rows.length : 0;
    rowCount = n > 0 ? n : (r.affectedRows ?? 0);
  }
  return { ...r, rowCount };
}

let pgliteInstance = null;

async function getPglite() {
  if (pgliteInstance) return pgliteInstance;
  const { PGlite } = require('@electric-sql/pglite');
  const dataDir = path.join(__dirname, '../../.data/pglite');
  fs.mkdirSync(dataDir, { recursive: true });
  const db = new PGlite(dataDir);
  await db.waitReady;

  const exists = await db.query(
    `select 1 from information_schema.tables where table_schema = 'public' and table_name = 'users' limit 1`
  );
  if (!exists.rows.length) {
    const initPath = path.join(__dirname, '../../db/init.sql');
    const sql = fs.readFileSync(initPath, 'utf8');
    await db.exec(sql);
  }

  pgliteInstance = db;
  return db;
}

function buildPgPool() {
  return new Pool({
    connectionString: config.databaseUrl,
    max: 10,
  });
}

let pool;

if (config.useEmbeddedPostgres) {
  pool = {
    query: async (text, params) => {
      const db = await getPglite();
      return normalizePgResult(await db.query(text, params));
    },
    end: async () => {
      if (pgliteInstance) {
        await pgliteInstance.close();
        pgliteInstance = null;
      }
    },
  };
} else {
  pool = buildPgPool();
}

async function withTransaction(fn) {
  if (config.useEmbeddedPostgres) {
    const db = await getPglite();
    return db.transaction(async (tx) => {
      const client = {
        query: async (text, params) => normalizePgResult(await tx.query(text, params)),
      };
      return fn(client);
    });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

module.exports = { pool, withTransaction };
