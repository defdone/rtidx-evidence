# Candidate instructions — SpinBattles Engineering Assessment

**Title:** Asset Sync & Claim API  
**Time box:** ~2–3 hours  
**Languages:** JavaScript (Node.js)  
**Stack in this starter:** Express + Postgres + `ethers` v6 + background worker (job socket; see `README.md`). Also: `helmet`, `pino`/`pino-http`, `zod` (validated request bodies/params), `p-retry` (live receipt polling).

We are not looking for a perfect production system in this window. We **are** looking for sound decisions, clear boundaries, and honest communication about tradeoffs.

## Context (what this simulates)

Users earn **off-chain credits** and can **claim digital inventory** tied to an **on-chain transaction hash**.

In real products, chain confirmation is slow and failure-prone, so verification belongs in **asynchronous workers** fed by a **queue-like handoff** from the API.

The starter already connects the API to `src/worker.js` through **`src/infra/workerTransport.js`** (push + enqueue wiring) and **`src/worker.js`** (pull consumer). Treat that as **infrastructure you build around**, not the main creative surface, unless you need a small change (document it in `NOTES.md`).

## What already works (starter)

- Postgres schema (`db/init.sql`)
- `GET /api/v1/health`
- `POST /api/v1/users` (create user by `handle`)
- `POST /api/v1/users/:userId/credits` (ledger credits + optional `idempotency_key`)
- `GET /api/v1/users/:userId/credits` (balance = sum of ledger)
- `GET /api/v1/users/:userId/inventory`
- `POST /api/v1/users/:userId/claims` (creates `claim_intents` row + enqueues worker job)
- `GET /api/v1/users/:userId/claims/:claimId` (read claim status for async UI / polling)
- Worker processes `PROCESS_CLAIM` jobs and updates rows

Default Docker setup runs with `MOCK_CHAIN=true` so you can complete flows without a real RPC.

## Your tasks (choose depth based on track)

### Everyone (Backend + Full-stack)

1. Add a short `NOTES.md` with:

- assumptions
- what you would do next with more time
- how you would test this in CI

2. Make the **claim → verify → grant** pipeline **safe under retries**:

- Like most lightweight socket queues, **duplicate deliveries are possible** under retries/restarts; design your DB effects so duplicate inventory grants cannot happen for the same `tx_hash`.

The starter is close, but you should **verify** edge cases and adjust if needed.

3. Improve **observability**:

- logs should make it easy to correlate HTTP → DB row → queue job → worker outcome

### Backend-focused

4. Add **automated tests** for the highest-risk logic (suggested: `node:test` or `jest`—your choice).

5. Harden **RPC verification** when `MOCK_CHAIN=false` and `RPC_URL` is set:

- decide what to do when receipt is not found yet (failed vs retry strategy—document the choice)
- decide how you treat reorgs (at minimum: acknowledge the risk in `NOTES.md`)

### Full-stack-focused

6. Improve the demo UI in `public/index.html` **or** add a tiny SPA build step—your choice—to reflect realistic **async** claim UX:

- show queued/processing/confirmed/failed states by polling the API (you may add endpoints if needed)

## Constraints (trust + safety)

- Do **not** request or store **seed phrases** or **private keys**.
- Do **not** introduce mainnet transfers, real funds, or custodial wallet flows.
- It is OK to use **public RPC** endpoints for testing, but avoid committing API keys.

## Submission

Follow your recruiter’s instructions (branch/PR/zip). Include:

- `NOTES.md`
- instructions to run locally (`npm start` / `npm run dev`; optional `.env` + Postgres, or zero-config embedded DB) or via optional `docker compose up --build`

## Suggested manual smoke test

1. Create a user (`POST /api/v1/users`)
2. Add credits (`POST /api/v1/users/:id/credits`)
3. Generate a plausible `tx_hash` (32-byte hex)
4. Create a claim (`POST /api/v1/users/:id/claims`)
5. Fetch inventory until the item appears (`GET /api/v1/users/:id/inventory`)

## API sketches (non-normative)

See `README.md` for ports and environment variables.
