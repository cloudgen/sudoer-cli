# sudoer-cli - Least-privilege sudoers-request approval CLI

![Version](https://img.shields.io/badge/Version-1.17.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/sudoer-cli?style=flat-square)](https://github.com/cloudgen/sudoer-cli)

This program lets a normal login **ask for a sudo grant for themselves** by putting a JSON file in a folder. A dedicated account (`sudoer-adm`) reads that file and **moves** it. **Folders are the state. The JSON file is the request.** There is no ticket database.

| Who | What they do | What they must not do |
|-----|--------------|------------------------|
| **You** (ordinary login) | Turn a sudoers fragment into JSON, or submit JSON you already have. This program **names** the file and puts it in the waiting folder. No root login is required. | Write `/etc`. Approve or reject the file. |
| **Approver** (the host admin who already typed password `sudo`, `sudoer-adm`, or a real root login) | Open that same JSON again. If it is valid, **move** it to accepted or declined. On accept, install `/etc/sudoers.d/<service>-<username>`. The password `sudo` **is** that decision. File owner and parsed name do **not** block the move. | Write `/etc/passwd` or the main `/etc/sudoers` file. |
| **Host admin** | Run `sudo sudoer-cli setup`. A password is OK. That creates `sudoer-adm`, the waiting/accepted/declined folders, and the sudoers fragment that lets `sudoer-adm` review without a password. Setup then prints how you submit a request as yourself. The same password `sudo` can then approve. | Treat setup as “approve this request.” Let an ordinary login create the `sudoer-adm` account. Treat a bare `sudoer-cli` (no arguments) as a review — that still only prints help. |

Where the program is **installed** is still **both**:
- **your user bin** → `~/.local/bin/sudoer-cli` (ordinary login)
- **the system bin** → `/usr/local/bin/sudoer-cli` (needs root / `--global`) — later required so `sudoer-adm` can run the program without a password

There is **no** online install (`curl|sh`). “Local” vs “global” here means **which directory the binary lives in**, not online vs offline.

## How file-based JSON approval works

There is **no ticket database**. **Folders are the state. A JSON file is the request.**

```text
you convert / submit
        ↓
/var/sudoer-cli/sudoer-request/     waiting
        ↓  sudoer-adm moves the file
   ┌────┴────┐
   ↓         ↓
approved   rejected
   ↓
/etc/sudoers.d/<service>-<subject>     live grant (on accept only)
```

| This machine includes | This machine is not |
|-----------------------|---------------------|
| Three folders: waiting, accepted, declined | A ticket table, a mail queue, or a CI job |
| One JSON file per request | The `--json` flag on `help` / `about` (that is only output shape) |
| You may file a grant for **yourself or another login**; the waiting filename uses **that subject** | Forcing the name to be the submitter |
| Pretty-printed or compact JSON — same grant | Approving a file that looks incomplete (missing commands) |

| Step | What this means | What you type |
|------|-----------------|---------------|
| Convert | Turn a sudoers fragment into JSON. This does **not** put anything in the waiting folder. Use it to look at the grant before you queue it. | `sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "..."` |
| Test JSON | Check a grant JSON against the dest format fence without becoming root and without putting it in the waiting folder. | `sudoer-cli test-json-format --file request.json` |
| Test command path | Check that each command is a well-known system binary (not a file under someone’s home). | `sudoer-cli test-well-known-binary --file request.json` |
| Test dest fences | **Unit test** of a local test folder. Point at a JSON file. **No sudo** except wrap chmod/chown of that folder. Does not queue. | `sh src/sudoer-cli fence-test --file tests/fixtures/fence-test/pass/login-hook-elev-dns-adm.json` |
| Submit | Hand that JSON to this program. It **chooses the filename** and writes it into `/var/sudoer-cli/sudoer-request/`. You still do not need to be root. | `sudoer-cli add-sudoer-request --file request.json` |
| Wait | The file sits in the waiting folder. Anyone can drop a file in; they cannot list or steal someone else’s file. | `sudoer-cli list-approving` |
| Decide | A host admin who already used password `sudo` (or `sudoer-adm`, or a real root login) re-reads the JSON and **moves** the file. Moving it *is* the decision. First-time setup must already have been run. | `sudo sudoer-cli interactive` |
| Live grant | Only after accept: a fragment at `/etc/sudoers.d/<service>-<subject>` (for example `folder-backup-bob` when the JSON `username` is bob). This program never writes `/etc/passwd` or the main `/etc/sudoers` file. | (the approve path) |

Pretty-printed and compact JSON are the same grant. If the request looks incomplete (it lists more commands than could be read), **do not approve it** — fix the file and convert or submit again.

## Features

- **Install and remove yourself** — `install`, `uninstall`, `where-is-me`, `version`, `about`, `help` work in your user bin and in `/usr/local/bin`
- **No arguments shows help** — it does not install, and it does not start a review
- **Everyone can run the installed program** — mode `0755`
- **Unknown commands fail** (non-zero exit)
- **CIAO / CIAO-Lite** defensive design
- **Folder + JSON approval** — waiting folder, one JSON request, approver moves the file
- **Unit-test dest fences without sudo** — `fence-test --file PATH` is a **test-purpose** verb (local test folder; does not queue; does not need a sudoers file). Sample: `tests/fixtures/fence-test/pass/login-hook-elev-dns-adm.json`
- **Convert, submit, list, and show without being root** — **operational** `sudoers-to-json`, `json-to-sudoers`, `add` / `update` / `remove-sudoer-request`, `list-approving` / `list-approved` / `list-rejected`, `show`. **Test-purpose** `test-json-format` / `test-well-known-binary` / `fence-test` are listed apart in help.
- **First-time setup** (`sudo sudoer-cli setup`) creates `sudoer-adm` and the folders, then tells you how to queue a request as yourself. Approve and `interactive` work after that same password `sudo` — you do not have to log in as `sudoer-adm`. Never writes `/etc/passwd` or the main `/etc/sudoers`

## Quick Installation

**Local (your user bin):**

```sh
# From this repository checkout
sh src/sudoer-cli install
# or force refresh after updates
sh src/sudoer-cli install --force

# Ensure ~/.local/bin is on PATH, then:
sudoer-cli version
```

**Global (system bin / multi-user hosts):**

```sh
sudo sh src/sudoer-cli install
# or: sudoer-cli install --global   # needs write access to /usr/local/bin
# Mode 0755 so every user can run the installed program.

# First-time: create sudoer-adm, the three folders, and the sudoers
# fragment that lets the approver review without a password.
# A host admin may use a password here. Also works from the checkout:
# sudo src/sudoer-cli setup
# (setup installs the system binary if it is missing).
sudo sudoer-cli setup
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

# File-based JSON approval
sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "Reload nginx"
sudoer-cli test-json-format --file request.json
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

# Convert a sudoers fragment to request JSON (does not queue)
sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "Allow backup and restore"

# Test grant JSON against the dest format fence (does not queue)
sudoer-cli test-json-format --file request.json

# Queue the request for yourself
sudoer-cli add-sudoer-request --file request.json

# Approver (after setup): list inbound, then review on a TTY
sudoer-cli list-approving
sudo sudoer-cli interactive

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

- [cli-template](https://github.com/cloudgen/cli-template) — bootstrap origin this product was specialized from (install/help/version CLI, no approval machine)
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/sudoer-cli`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits. Do not list unrouted domain verbs in `help`.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-08-21 — version **1.17.0** (dest `interactive` warns then asks on missing stamp / untrusted Cmnd; no `set -u` crash after Fence pass).
2026-08-21 — version **1.16.0** (Type 0 stamps `submit_app` / `submit_version`; dest shows `queued by {app} {version}` before yes/no).
2026-08-21 — version **1.15.3** (`fence-test` Next: uses checkout `src/sudoer-cli`, not a global install).
2026-08-21 — version **1.15.2** (test-purpose vs operational verbs; help lists unit testers of a local test folder apart from convert/submit).
2026-08-20 — version **1.13.0** (dest `interactive` shows a broken waiting file, does not ask yes/no, and moves it to the rejected folder).
2026-08-20 — version **1.12.0** (dest `interactive` asks one yes/no per waiting file: yes accepts, no or Enter rejects; no skip or quit).
2026-08-20 — version **1.11.0** (in-tool sudo goes through `util_sudo`; chmod checks owner first via `util_chmod` and does not `sudo chmod` when you already own the file).
2026-08-20 — version **1.10.0** (dest-written `submit_by` converts queue Unix owner into JSON; Type 0 must not plant it).
2026-08-18 — version **1.7.1** (`setup` checks and creates a missing LPU `~/.profile` so the login hook can fire).
2026-08-18 — version **1.7.0** (password `sudo` is the approval; setup prints how to submit as yourself; ordinary logins never create `sudoer-adm`).
2026-08-17 — version **1.6.2** (pretty `commands[]` fidelity; operator-readable convert/submit errors; README Description follows **write-human-intro**: people and folders, not privilege-type codes).
2026-08-15 — version **1.6.1** (`interactive` keeps stdin for prompts; 1.6.0 loop live; about lists queue paths; TP-SR-INT / TP-SR-Q in DTV).
2026-08-15 — version **1.5.1** (inbound 3773 + submit 0640; approve archives snapshot; F7 removes `/var/sudoer-cli` children).
2026-08-15 — version **1.5.0** (public queues `/var/sudoer-cli/sudoer-request`; approver home views of those folders).
2026-08-14 — version **1.4.1** (`setup` runs `useradd` as root without a second `sudo`; home `/etc/sudoer-adm`).
