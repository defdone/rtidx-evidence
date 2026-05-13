# SpinBattles Engineering Assessment — Asset Sync & Claim API

This repository is a **2–3 hour technical exercise** starter for **Backend** and **Full-stack** candidates working on **JavaScript** services with **Postgres** (or **embedded Postgres via PGlite** when you run without `DATABASE_URL`), **EVM tooling (`ethers` v6)**, and a **background worker** connected to the API over a **local job socket**.

Production-shaped defaults are included and **actually used** in code: **`helmet`**, **`pino` / `pino-http`**, **`zod`** (request validation), and **`p-retry`** (live RPC receipt polling).

It is intentionally **small but “product-shaped”**: HTTP API → durable rows → asynchronous verification → inventory updates.

## What candidates do

Read `TASK.md`. Implement or extend the service within the time box, then walk an interviewer through tradeoffs.

## Quick start (npm — recommended for day-to-day)

**Zero-config (fastest):** with **Node 18+** only, from the repo root:

```bash
npm install
npm start
```

This runs **API + worker** together using **embedded Postgres** (no separate database install, no `.env` required). Data is stored under **`.data/pglite/`** (gitignored). Open `http://localhost:3000` and `http://localhost:3000/api/v1/health`. The demo page **polls claim status** (`GET /api/v1/users/:userId/claims/:claimId`) after you submit a claim so you can see **queued → processing → confirmed** (or **failed**) without refreshing manually.

**Your own Postgres instead:** install Postgres, create a database, run **`db/init.sql`**, copy **`.env.example` → `.env`**, set **`DATABASE_URL`**, then `npm start` again (the app will use your server and will run API + worker as **two processes** via `concurrently`).

(`npm run dev` is the same as `npm start`.)

Use **`Ctrl+C`** once to stop.

**Alternative (two terminals, external Postgres only):** `npm run api` in one, `npm run worker` in the other. (Do not use this split when **`DATABASE_URL` is unset** — embedded mode needs the single-process `npm start` path.)

When **`MOCK_CHAIN`** is not set: embedded mode defaults it to **`true`** so claims verify without an RPC URL. With **`DATABASE_URL` set**, it defaults to **`false`** unless you set **`MOCK_CHAIN=true`** in `.env` (see `.env.example`).

## Optional: full stack with Docker (reproducible)

If you prefer **one command** for **Postgres + API + worker** (still **on your PC**, via Docker Desktop), use:

```bash
docker compose up --build
```

Containers are a **packaged local environment**—not “someone else’s server” unless you deploy them there. This path is useful when you don’t want to install Postgres globally.

The compose file runs:

- `postgres` (schema in `db/init.sql`)
- `api` (`node src/server.js`) on **HTTP :3000** and job socket **:6000**
- `worker` (`node src/worker.js`) consuming from `api:6000`

## Background jobs (wiring only)

Claims enqueue asynchronous work. The starter wires **API → worker** on a fixed **push/pull port `6000`** (`push.bind(6000)` in **`src/infra/workerTransport.js`**); the worker pull side is in **`src/worker.js`**. Treat that path as **given plumbing** unless you intentionally change it (say so in `NOTES.md`).

Example job payload:

```json
{ "type": "PROCESS_CLAIM", "claimId": "<uuid>" }
```

Environment:

- **`WORKER_SOCKET_HOST`**: host the **worker** connects its pull socket to (e.g. `127.0.0.1` locally, `api` in Docker). The push side always binds **`6000`** in `src/infra/workerTransport.js` (same as your starter snippet).
- **`LOG_LEVEL`**: `pino` verbosity (`info` by default).
- **`RPC_RECEIPT_RETRIES`**: when `MOCK_CHAIN=false` and `RPC_URL` is set, how many times the worker polls for a pending receipt before giving up.

## Repo hygiene

- Do **not** commit `.env`
- Do **not** ask candidates for seed phrases or private keys

## Support

Use the contact channels your recruiting team provides. This repo should not be used to request sensitive wallet custody.
