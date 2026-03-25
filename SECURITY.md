# Security Policy

## Malicious Code Warning

**This repository intentionally contains snapshots of potentially malicious code.**

Branches named `case/*` are mirrors of repositories that were reported to [RTIdx](https://github.com/defdone/rtidx) as part of suspected scam or fraud investigations. These repositories may contain:

- Cryptocurrency wallet stealers
- Credential harvesters (browser data, SSH keys, AWS credentials)
- Obfuscated payloads (base64, hex encoding, eval())
- Data exfiltration code (Discord webhooks, Telegram bots)
- Malicious npm lifecycle hooks (postinstall, preinstall)
- Reverse shells and remote code execution
- Keyloggers and clipboard monitors
- Cryptominers
- Anti-sandbox / anti-debugging techniques

## DO NOT

- **Do not run `npm install`** on any `case/*` branch — postinstall hooks may execute malicious code
- **Do not execute any scripts** (`.sh`, `.ps1`, `.bat`, `.js`, `.ts`) from these branches
- **Do not open these projects in an IDE** that auto-executes tasks (e.g., VS Code with auto-run npm)
- **Do not use your real credentials** if examining code that references APIs or databases

## Safe analysis

If you need to examine the code:

1. Use a **sandboxed VM** or container with no network access
2. Read files via `git show` or GitHub web UI — do not checkout
3. Disable all IDE auto-execution features
4. Never run the code on a machine with real credentials, wallets, or sensitive data

## Reporting

### Found a false positive?
If a `case/*` branch contains code that is NOT malicious and was incorrectly flagged, please open an issue on the [main RTIdx repo](https://github.com/defdone/rtidx/issues).

### Found a vulnerability in RTIdx itself?
Please report security vulnerabilities in the RTIdx platform privately via [GitHub Security Advisories](https://github.com/defdone/rtidx/security/advisories).

### Want your repository removed?
If your repository was mirrored here and you want it removed, open an issue on [RTIdx](https://github.com/defdone/rtidx/issues) with the branch name and proof of ownership. We will review and remove within 72 hours.

## Responsible disclosure

This evidence vault exists for **security research and scam detection training**. We publish this data to:

- Help the developer community recognize malicious patterns
- Provide training data for AI models that protect against recruitment scams
- Support law enforcement and security researchers investigating scam campaigns

We take removal requests seriously and will honor them promptly.
