# RTIdx Evidence Vault

> **WARNING**: Branches in this repository contain snapshots of repositories reported as potentially malicious. **DO NOT EXECUTE any code from `case/*` branches.**

## What is this?

This repository is the **evidence vault** for [RTIdx](https://github.com/defdone/rtidx) — a scam detection platform that analyzes suspicious job recruitment interactions and the repositories they link to.

When a user reports a suspicious recruitment attempt with a repository URL, the RTIdx worker:

1. Scans the repository for malicious patterns (obfuscation, data exfiltration, crypto wallet harvesting, etc.)
2. Generates a risk verdict with confidence score
3. **Mirrors the repository here** as an orphan branch for evidence preservation and research

## Branch structure

- `master` — this README and security docs
- `case/{uuid}` — each branch is an isolated, full-history mirror of a reported repository

Each `case/*` branch preserves the complete git history of the source repository at the time it was reported, including all commits, authors, and timestamps.

## Research use

This data is used for:

- **LLM training** — teaching models to detect malicious code patterns in recruitment scam repos
- **Pattern analysis** — identifying reusable templates and infrastructure across scam campaigns
- **Feature engineering** — extracting signals for the RTIdx scoring engine

### Known campaign patterns captured here

| Campaign | Malware family | Technique |
|----------|---------------|-----------|
| Contagious Interview | BeaverTail / InvisibleFerret | npm postinstall → wallet drain |
| Fake Assessment | Various | eval() + base64 obfuscation |
| Crypto Wallet Drain | Custom | Web3 credential harvesting |
| Credential Harvester | Custom | Hardcoded Supabase/Firebase creds |

## Data sources

Analysis methodology is informed by:

- [Anatomy of a Developer Recruitment Scam](https://www.alexpruteanu.cloud/blog/anatomy-of-a-developer-recruitment-scam) (Pruteanu)
- [Inside the Scam: North Korea IT Worker Threat](https://www.recordedfuture.com/research/inside-the-scam-north-koreas-it-worker-threat) (Recorded Future)
- [Anansi: Scalable Characterization of Message-Based Job Scams](https://arxiv.org/abs/2602.24223) (arXiv)
- [Job Scam Social Media Study](https://heimdalsecurity.com/blog/job-scam-social-media-study/) (Heimdal Security)

## License

The snapshots in `case/*` branches are preserved for security research purposes under fair use. Original code ownership belongs to the respective authors. This repository does not claim ownership of mirrored content.

---

**Maintained by**: [defdone](https://github.com/defdone)
**Part of**: [RTIdx Project](https://github.com/defdone/rtidx)
