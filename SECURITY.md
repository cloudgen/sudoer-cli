# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| **1.29.0** (current) | Yes — report security issues against this release |
| 1.28.x | Yes |
| 1.25.x | Yes |
| 1.24.x | Yes |
| 1.23.x | Yes |
| 1.22.x | Yes |
| 1.21.x | Yes |
| 1.20.x | Yes |
| 1.19.x | Yes |
| 1.18.x | Yes |
| Older than 1.18.0 | Best-effort only |

## Reporting a Vulnerability

Please **do not** open a public issue for security-sensitive reports when a private channel is available.

**Maintainer contact (email):** `wongcf22@gmail.com`

- Source of contact: product **author-email** SSOT in [`LICENSE.md`](./LICENSE.md) (Copyright line).  
- Prefer email (or private GitHub security advisories when enabled) for vulnerability details, reproduction steps, and impact.  
- You should receive an acknowledgment when the report is received and actionable.  
- Do not include exploit weaponization guides in public channels.

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **[CIAO-Lite](https://github.com/cloudgen/ciao-lite)** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Unknown commands fail closed. Type 1 `approve` / `reject` / `interactive` fail closed without euid 0 (or a real root session). Submit checks JSON (A may name B). Inbound is **3773**; submit files are **0640**. Approve archives a snapshot then unlinks inbound (no `mv` of a replaceable path). |
| **I** | **Intentional** | Online install channel is `SCRIPT_URL` (product default). Automatic companion digest is the default integrity path; optional `CHECKSUM` pin is secondary (CI / out-of-band), not a `help` / `about` setting. Type 0 never writes `/etc/sudoers.d`. Type 1 `setup` is any host admin (`sudo sudoer-cli setup`; password sudo OK; not `sudo -n`). After password `sudo`, that host admin **may** approve — F6 / `sudoer-adm` is an extra path. Only **product-owned** names under `/etc/sudoers.d/` are copied, overwritten, or removed. |
| **A** | **Anti-fragile** | Isolated scratch (`APP_NAME` + `USERNAME`); atomic install place with mode **0755**. Public queues live under `/var/sudoer-cli/` with F4 views under the live LPU home. F7 removes the three public queue children. Missing companion sidecar warns and continues; mismatch aborts. |
| **O** | **Over-protect** | Protection Zones on `out_*` and install. Closed prevention catalog: no invented walls after elev. Never write `/etc/passwd` or `/etc/sudoers` (the main file). Companion verify before place/update. |

Full principles: [CIAO](https://github.com/cloudgen/ciao) · [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section is **design posture**, not a third-party certification claim.

## Install integrity and trust

This product implements **automatic companion-checksum** on online install and self-update (`requirement-shell-automatic-checksum`).

| Fact | Honest statement |
|------|------------------|
| **Default path** | Automatic `${SCRIPT_URL}.sha256` when `CHECKSUM` is unset — **no** env pin required for normal `curl \| sh` or `self-update`. |
| **Algorithm** | SHA-256 via `sha256sum`. |
| **Transparency** | Human mode shows companion **link**, expected **value**, and verification **result** (match / mismatch / missing). |
| **Mismatch** | Abort — do not install mismatched bytes. |
| **Missing sidecar** | Warn and continue (best-effort). Do **not** claim “always verified.” |
| **Optional pin** | Process-env `CHECKSUM` is **secondary** (CI / out-of-band freeze). Same-origin pin is **not** stronger than automatic mode. Not listed in `help` / `about`. |
| **Trust bound** | Same-channel SHA-256 proves **byte consistency** of script + companion. It is **not** independent authenticity (signing / separate trust root). |

Operator-facing one-liners and integrity outcomes live in [`README.md`](./README.md).

## Scope notes

- This product **does** emit and install the F6 fragment `/etc/sudoers.d/sudoer-adm` and grant files `/etc/sudoers.d/{{service}}-{{username}}` from Type 1.  
- Type 0 does **not** write `/etc/sudoers.d`.  
- This product does **not** write `/etc/passwd` or `/etc/sudoers`. LPU create/teardown uses `useradd` / `userdel` after the operator already elevated.  
- Public inbound is `/var/sudoer-cli/sudoer-request` (mode **3773**). Accepted/declined archives are **0700**.  
- Online install is `curl | sh` from `SCRIPT_URL`. Companion file is `src/sudoer-cli.sha256`. Same-channel digest is consistency, not a signed release.  
- Uninstall removes only the managed binary. `remove-lpu` tears down the LPU, hook, F6, and public queue children. Live user grants stay unless separately removed.  
- Local `~/.local/bin` install is user-rewritable; prefer global install on multi-user hosts when F6 must NOPASSWD the managed binary.  
- Related docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md).
