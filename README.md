# sudoer-cli - Least-privilege sudoers-request approval CLI

![Version](https://img.shields.io/badge/Version-1.1.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/sudoer-cli?style=flat-square)](https://github.com/cloudgen/sudoer-cli)

POSIX `/bin/sh` CLI specialized from **cli-template**. Type 0 lifecycle (`install`, `uninstall`, `where-is-me`, `version`, `about`, `help`) is live. Type 0 domain (file-based JSON approval: convert / submit / list / show) is **routed**. Type 1 names (`setup`, `approve`, `reject`, `interactive`) are routed and **fail closed** without euid 0. Live `useradd` and dest install to `/etc` are a **Gap**.

Install **location** is still **both**:
- **local** → `~/.local/bin/sudoer-cli` (normal user)
- **global** → `/usr/local/bin/sudoer-cli` (root / `--global`) — required later for production NOPASSWD of `sudoer-adm`

The *channel* is local-only (no online `curl|sh`). Local vs global here means where the binary is placed, not an online vs offline download.

## Features

- **Self-management**: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help` (local **and** global place/remove)
- **Type N empty argv**: no arguments shows help (not install-ensure; not interactive review)
- **Managed binary mode 0755**: global install stays readable and runnable for every user
- **Fail-closed**: unknown commands exit non-zero
- **CIAO / CIAO-Lite** defensive design (Protection Zones, `out_*` output SSOT)
- **File-based JSON approval**: normal users drop self-scoped request JSON into inbound; `sudoer-adm` verifies that JSON and moves the file. Folder = state; JSON = the checkable grant.
- **Type 0 domain (routed)**: `sudoers-to-json` / `json-to-sudoers`, `add` / `update` / `remove-sudoer-request`, `list-approving` / `list-approved` / `list-rejected`, `show`
- **Type 1 (routed, fail closed without euid 0)**: `setup`, `approve`, `reject`, `interactive`. Live `useradd` / dest write to `/etc` is a **Gap**

## Quick Installation

**Local (Type 0 day-to-day):**

```sh
# From this repository checkout
sh src/sudoer-cli install
# or force refresh after updates
sh src/sudoer-cli install --force

# Ensure ~/.local/bin is on PATH, then:
sudoer-cli version
```

**Global (multi-user hosts / future production F6):**

```sh
sudo sh src/sudoer-cli install
# or: sudoer-cli install --global   # needs write access to /usr/local/bin
# Managed binary mode is always 0755 so every user can run the shell ship unit.
```

This product is **local-only** for its install channel (no default `SCRIPT_URL` online install). Global vs local here means install *location*, not an online channel.

**Source repository:** [cloudgen/sudoer-cli](https://github.com/cloudgen/sudoer-cli)  
Config identity: `REPO_USER=cloudgen`, `REPO_NAME=sudoer-cli` (override with env if needed; does not enable online install while `SCRIPT_URL` is empty).

## Usage

```sh
sudoer-cli help
sudoer-cli about
sudoer-cli --json about

sudoer-cli install
sudoer-cli where-is-me
sudoer-cli uninstall --force

# Type 0 domain (file-based JSON approval)
sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "Reload nginx"
sudoer-cli add-sudoer-request --file request.json
sudoer-cli list-approving
sudoer-cli show sudoer-20260814-folder-backup-alice-add-1.json
```

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` | Git host owner (default `cloudgen`) |
| `REPO_NAME` | Git repository name (default `sudoer-cli`) |
| `SCRIPT_URL` | Online install channel (default **empty** — local only) |
| `USER_BIN` | Per-user install destination (default `~/.local/bin`) |
| `GLOBAL_BIN` | Global install destination (default `/usr/local/bin`) |

## Examples

```sh
# Local install (user bin)
sh src/sudoer-cli install

# Global install (system bin)
sudo sh src/sudoer-cli install

# Diagnostics
sudoer-cli about
sudoer-cli --json version
```

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` (dash/bash) | Supported |
| `mktemp`, `date` | Required |
| macOS / BSD | Not primary; GNU `stat`/`sed -E` assumptions may differ |

## Related Projects

- [cli-template](https://github.com/cloudgen/cli-template) — Type 0 bootstrap origin this product was specialized from
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/sudoer-cli`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits. Do not list unrouted domain verbs in `help`.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-08-14 — version **1.1.0** (dest convention `{{service-name}}-{{username}}`; Type 0 domain routed).
