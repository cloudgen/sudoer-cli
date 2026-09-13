# Requirements

Authoritative specialized product law for **sudoer-cli** lives here.

**Current state (2026-09-13):** This folder is the live product law for sudoer-cli: a POSIX `/bin/sh` program you install with `curl | sh`. A normal login converts and queues JSON; a host admin who already used password `sudo` runs first-time setup and review. Live origin **selfmanaged** (A→B). One domain file owns the waiting-folder machine. Login hook is independent `requirement-login-interactive-review-hook` (shared doorbell `login-review-hook`). This-login PATH is `requirement-shell-path-and-shell-support`. Registry: `index.md`. (Catalog versions: domain **2.41.0**; login hook **1.2.0**; path-and-shell-support **1.0.0**; dest Fence **1.5.0**; well-known **1.2.0**; class **1.11.2**; CLI **3.12.2**; default interaction **1.2.0**; Type O **1.3.0**; self-management **1.2.0**; automatic-checksum **1.1.0**; output **1.4.0**; coding style **1.4.1**; prompt **1.2.1**; interactive **1.5.1**; ARSA **1.0.0**; prevention **1.6.5**; sudoers-file **1.2.0**; three-layer **1.16.0**.)

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` | `sudoer-cli` |
| Version SSOT | `1.27.0` (ship unit hard-assign) |
| Ship unit | `src/sudoer-cli` |
| Default install | `curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli \| sh` → `~/.local/bin/sudoer-cli` (global `/usr/local/bin/sudoer-cli` so `sudoer-adm` can review without a password) |
| Install mode | **online-installable** (`curl \| sh`) |
| Domain surface | File-based JSON approval: convert/submit/list/show as yourself; `setup` / `interactive` after password `sudo` |

## Class requirement gate

| Class | Required class file |
|-------|---------------------|
| software-development | `requirement-class-software-dev.md` (**Active**) |
| genesis-template | N/A — this workspace is no longer genesis |

## Purpose

- **Plan** designs work by reading and updating these docs.  
- **Implement** delivers code that **traces** to these requirements.  
- **Review** verifies delivery against requirements and CIAO checklists.

## Layout

| Path | Role |
|------|------|
| `docs/requirements/index.md` | Registry of all requirements — keep in sync |
| `docs/requirements/requirement-*.md` | CIAO-style project requirements |

## Status values

Typical: `draft` · `Active` · `approved` · `in-progress` · `done` · `deprecated` · `superseded`

## Rules

1. Never invent paths — verify on disk.  
2. Class files only via class process; non-class via create-specific process.  
3. Never dump harness inventories into this versioned surface.  
4. Online install requirements stay **absent** unless product mode is explicitly changed.  
5. Keep exactly one Active domain SSOT. Do **not** list unrouted domain verbs in `help`.  
6. Do **not** invent a product block that is not a row in `requirement-privilege-prevention-set.md`.
