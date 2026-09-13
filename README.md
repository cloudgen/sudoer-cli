# sudoer-cli - Least-privilege sudoers-request approval CLI

![Version](https://img.shields.io/badge/Version-1.28.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/sudoer-cli?style=flat-square)](https://github.com/cloudgen/sudoer-cli)

This program lets a normal login **ask for a sudo grant for themselves** by putting a JSON file in a folder. A dedicated account (`sudoer-adm`) reads that file and **moves** it. **Folders are the state. The JSON file is the request.** There is no ticket database.

| Who | What they do | What they must not do |
|-----|--------------|------------------------|
| **You** (ordinary login) | Turn a sudoers fragment into JSON, or submit JSON you already have. This program **names** the file and puts it in the waiting folder. No root login is required. | Write `/etc`. Approve or reject the file. |
| **Approver** (the host admin who already typed password `sudo`, `sudoer-adm`, or a real root login) | Open that same JSON again. If it is valid, **move** it to accepted or declined. On accept, install `/etc/sudoers.d/<service>-<username>`. The password `sudo` **is** that decision. File owner and parsed name do **not** block the move. | Write `/etc/passwd` or the main `/etc/sudoers` file. |
| **Host admin** | Run `sudo sudoer-cli setup`. A password is OK. That creates `sudoer-adm`, the waiting/accepted/declined folders, and the sudoers fragment that lets `sudoer-adm` review without a password. Setup then prints how you submit a request as yourself. The same password `sudo` can then approve. | Treat setup as “approve this request.” Let an ordinary login create the `sudoer-adm` account. Treat a bare `sudoer-cli` (no arguments) as a review — that installs or confirms install. |

Where the program is **installed** is still **both**:
- **your user bin** → `~/.local/bin/sudoer-cli` (ordinary login)
- **the system bin** → `/usr/local/bin/sudoer-cli` (needs root / `--global`) — later required so `sudoer-adm` can run the program without a password. Global setup also creates `/usr/local/bin/sudoer-review-hook` (a symlink) and plants that name in the approver’s `.bashrc`. If login review does not start, the skip line says to run `sudo sudoer-cli interactive` from a host admin.

Install is **online**: `curl | sh` places the program. “Local” vs “global” here still means **which directory the binary lives in**.

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
| Test PATH ensure | Prove user-bin PATH / `.profile` writes against a throw-away folder. Does not rewrite this login’s real `~/.bashrc`. | `sudoer-cli rc-test --root "$tmpdir" --file bashrc --case create` |
| Submit | Hand that JSON to this program. It **chooses the filename** and writes it into `/var/sudoer-cli/sudoer-request/`. You still do not need to be root. | `sudoer-cli add-sudoer-request --file request.json` |
| Wait | The file sits in the waiting folder. Anyone can drop a file in; they cannot list or steal someone else’s file. | `sudoer-cli list-approving` |
| Decide | A host admin who already used password `sudo` (or `sudoer-adm`, or a real root login) re-reads the waiting file and **shows it as YAML**, indented two spaces under the Request id. If the JSON is broken, dest says so, does **not** ask, and moves the file to rejected. If a command lives under someone’s home (or the queue stamp is missing), dest **warns** and still asks yes/no. Moving a valid file *is* the decision. First-time setup must already have been run. | `sudo sudoer-cli interactive` |
| Live grant | Only after accept: a fragment at `/etc/sudoers.d/<service>-<subject>` (for example `folder-backup-bob` when the JSON `username` is bob). This program never writes `/etc/passwd` or the main `/etc/sudoers` file. | (the approve path) |

Pretty-printed and compact JSON are the same grant. If the request looks incomplete (it lists more commands than could be read), **do not approve it** — fix the file and convert or submit again.

Login as `sudoer-adm` (TTY hook) or `sudo sudoer-cli interactive` prints each remaining grant as a group. Older copies of the same dest (`username` + `service`) are collapsed first. The Request id, superseded notes, and the yes/no prompt stay flush-left; `queued by` and the YAML body are indented two spaces.

One waiting grant (older duplicate already superseded):

```text
$ sudo su - sudoer-adm
[INFO] superseded sudoer-20260908-grok-cli-adm01-add-1.json (kept sudoer-20260908-grok-cli-adm01-add-2.json)
[INFO] Request sudoer-20260908-grok-cli-adm01-add-2.json
  queued by sudoer-cli 1.23.0
  schema_version: 1
  purpose: "Allow adm01 to run grok-cli backup as root."
  username: adm01
  service: grok-cli
  action: add
  submit_app: sudoer-cli
  submit_version: 1.23.0
  submit_by: adm01
  commands:
    - runas: root
      tags:
        - NOPASSWD
      path: /usr/local/bin/grok-cli
      args:
        - backup
Approve this request (y/N)?
```

Two remaining grants (different dests), so each body sits under its own Request line:

```text
[INFO] Request sudoer-20260908-grok-cli-adm01-add-2.json
  queued by sudoer-cli 1.23.0
  schema_version: 1
  purpose: "Allow adm01 to run grok-cli backup as root."
  username: adm01
  service: grok-cli
  action: add
  submit_app: sudoer-cli
  submit_version: 1.23.0
  submit_by: adm01
  commands:
    - runas: root
      tags:
        - NOPASSWD
      path: /usr/local/bin/grok-cli
      args:
        - backup
Approve this request (y/N)?
[INFO] Request sudoer-20260908-dns-cli-alice-add-1.json
  queued by dns-cli 1.12.0
  schema_version: 1
  purpose: "Allow alice to reload dns."
  username: alice
  service: dns-cli
  action: add
  submit_app: dns-cli
  submit_version: 1.12.0
  submit_by: alice
  commands:
    - runas: root
      tags:
        - NOPASSWD
      path: /usr/local/bin/dns-cli
      args:
        - reload
Approve this request (y/N)?
```

## Features

- **Install and keep yourself** — `install`, `version-check`, `self-update`, `self-uninstall`, `version`, `about`, `help` work in your user bin and in `/usr/local/bin`
- **No arguments installs** — empty argv is install-ensure (`curl | sh`); it does not start a review
- **Numbered start list** — `sudoer-cli menu` (or `main`) on a real terminal; a pipe still prints help
- **Everyone can run the installed program** — mode `0755`
- **Unknown commands fail** (non-zero exit)
- **CIAO / CIAO-Lite** defensive design
- **Folder + JSON approval** — waiting folder, one JSON request, approver moves the file
- **Unit-test dest fences without sudo** — `fence-test --file PATH` is a **test-purpose** verb (local test folder; does not queue; does not need a sudoers file). Sample: `tests/fixtures/fence-test/pass/login-hook-elev-dns-adm.json`
- **Convert, submit, list, and show without being root** — **operational** `sudoers-to-json`, `json-to-sudoers`, `add` / `update` / `remove-sudoer-request`, `list-approving` / `list-approved` / `list-rejected`, `show`. **Test-purpose** `test-json-format` / `test-well-known-binary` / `fence-test` are listed apart in help.
- **First-time setup** (`sudo sudoer-cli setup`) creates `sudoer-adm` and the folders, then tells you how to queue a request as yourself. Approve and `interactive` work after that same password `sudo` — you do not have to log in as `sudoer-adm`. Never writes `/etc/passwd` or the main `/etc/sudoers`

## Quick Installation

**Per-user (non-root):**

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli | sh
```

**System-wide (root / elevated):**

```sh
sudo curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli | sudo sh
```

Then verify:

```sh
sudoer-cli about
```

### Integrity (automatic checksum)

**Primary path:** the program downloads the companion digest **itself**. You do **not** set `CHECKSUM` for normal online install or self-update.

Online install / self-update does **not** only trust the download blindly:

| Mode | When | Algorithm | What happens |
|------|------|-----------|--------------|
| **Automatic (default)** | `CHECKSUM` **unset** (default one-liner) | **SHA-256** via `sha256sum` | After download, fetch companion **`${SCRIPT_URL}.sha256`**. Human mode shows the companion **link**, expected **value**, and **result**. **Match** → install continues. **Mismatch** → install **aborts**. **Sidecar missing** → **warning**, install continues (best-effort). |
| **Strict pin (optional)** | `CHECKSUM` set to an out-of-band hex digest | **SHA-256** | Download must match the pin exactly; **mismatch aborts**. Secondary—CI / freeze installs only. |

Default channel companion path (`${SCRIPT_URL}.sha256`):

```text
https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli.sha256
```

In this repository the companion file is **`src/sudoer-cli.sha256`** (bare 64-char hex of `src/sudoer-cli`). Same-channel SHA-256 proves **consistency** of the two files on that channel; it is not a substitute for signed releases.

**From this repository checkout** (same channel, or override `SCRIPT_URL` in tests):

```sh
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

This product is **online-installable**. Global vs local here means install *location* (user bin vs `/usr/local/bin`).

**Numbered start list** (after install; running with no arguments installs or confirms install):

```text
$ sudoer-cli menu
[INFO] **sudoer-cli**(*1.28.0*) — numbered list of live commands
1. sudoers-to-json: Convert sudoers fragment to request JSON
2. json-to-sudoers: Convert request JSON to sudoers fragment
3. print-sudoers: Print the sudoers fragment that lets sudoer-adm review without a password
4. print-sudoers-install-script: Emit admin install script
5. add-sudoer-request: Queue an add request (JSON or sudoers)
6. update-sudoer-request: Queue an update request
7. remove-sudoer-request: Queue a purpose-only remove (--service)
8. list-approving: List waiting requests
9. list-approved: List accepted requests
10. list-rejected: List declined requests
11. show: Show a known request
12. remove-lpu: Remove the dedicated approver account (sudoer-adm)
13. approve: Copy/overwrite dest in /etc/sudoers.d (product names only)
14. reject: Decline a waiting request
15. interactive: Review waiting requests one file at a time (not empty argv)
99. Exit
```

A number or name that is not on this list prints an error, reprints **this** list, and waits. Type `99` (or `exit` / `quit`) to leave.

**Source repository:** [cloudgen/sudoer-cli](https://github.com/cloudgen/sudoer-cli)  
Config identity: `REPO_USER=cloudgen`, `REPO_NAME=sudoer-cli`. Default channel: `https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli`.

## Usage

```sh
sudoer-cli help
sudoer-cli menu
sudoer-cli about
sudoer-cli --json about

sudoer-cli install
sudoer-cli version-check
sudoer-cli self-update
sudoer-cli self-uninstall --force

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
| `SCRIPT_URL` | Online install channel (default `https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli`) |
| `USER_BIN` | Per-user install destination (default `~/.local/bin`) |
| `GLOBAL_BIN` | Global install destination (default `/usr/local/bin`) |

## Examples

```sh
# Online install (user bin)
curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli | sh

# Online install (system bin)
sudo curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli | sudo sh

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

2026-09-13 — version **1.28.0** (doorbell `/usr/local/bin/sudoer-review-hook`; setup heals old `login-review-hook` rc and F6).
2026-09-13 — version **1.27.0** (shared doorbell `/usr/local/bin/login-review-hook`; login skip line says Next:; sudoers for login-hook grants that name).
2026-09-13 — version **1.26.0** (numbered list: a wrong pick reprints this list and waits; does not quit).
2026-09-09 — version **1.25.0** (this-login PATH / `.profile` ensure after user-bin install; Type 0 `rc-test --root`; sibling unify).
2026-09-08 — version **1.24.0** (Type 1 `interactive` reviews `sudoer-adm` rc and replaces an old product-binary hook with `sudoer-cli-hook`).
2026-09-08 — version **1.23.0** (login-hook / `interactive` YAML review body indented two spaces per request; README shows the display samples).
2026-09-08 — version **1.22.0** (online-installable: `curl | sh`, Type O empty argv, `version-check` / `self-update` / `self-uninstall`; specialized from selfmanaged).
2026-09-03 — version **1.20.0** (dest `interactive` keeps the latest duplicate inbound grant per dest; help and numbered list use people/folder words).
2026-09-03 — version **1.19.0** (numbered start list on `sudoer-cli menu` / `main`; empty argv still prints help).
2026-09-03 — version **1.18.0** (login-hook-symlink `/usr/local/bin/sudoer-cli-hook`; setup heals old `.bashrc` hook path; default-cli-main-menu-style printers).
2026-08-26 — version **1.17.1** (`json-to-sudoers` visudo-legal args; visudo fail names visudo, not “host validation”).
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
