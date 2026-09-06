# Requirements

Authoritative specialized product law for **sudoer-cli** lives here.

**Current state (2026-09-06):** This folder is the live product law for sudoer-cli: a POSIX `/bin/sh` program you install yourself. A normal login converts and queues JSON; a host admin who already used password `sudo` runs first-time setup and review. Historical starter was **cli-template**. One domain file owns the waiting-folder machine. Registry: `index.md`. (Catalog versions: domain **2.37.1**; dest Fence **1.5.0**; well-known **1.2.0**; class **1.9.11**; CLI **3.10.2**; default interaction **1.0.1**; output **1.3.1**; coding style **1.4.1**; prompt **1.2.1**; interactive **1.5.1**; ARSA **1.0.0**; prevention **1.6.4**.)

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` | `sudoer-cli` |
| Version SSOT | `1.20.0` (ship unit hard-assign) |
| Ship unit | `src/sudoer-cli` |
| Default install | `~/.local/bin/sudoer-cli` (global `/usr/local/bin/sudoer-cli` so `sudoer-adm` can review without a password) |
| Install mode | **Local-only** |
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
