# Requirements

Authoritative specialized product law for **sudoer-cli** lives here.

**Current state (2026-08-26):** Specialized **software-development** product. Historical origin **cli-template**. Domain SSOT is Active **2.34.0** (dest review is one-off yes/no; JSON-format Fence display-then-rejected; missing stamp / untrusted Cmnd warn then ask; visudo-legal args; OPEN-BEHALF). Dest Fence REQ **1.5.0**. Well-known checker **1.2.0**. Class **1.9.7**. CLI **3.8.3**. Coding style **1.3.0**. Prompt **1.1.0**. Interactive **1.4.0**. ARSA catalog Active **1.0.0**. Prevention catalog is Active **1.6.1**. Registry is populated — see `index.md`.

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` | `sudoer-cli` |
| Version SSOT | `1.17.1` (ship unit hard-assign) |
| Ship unit | `src/sudoer-cli` |
| Default install | `~/.local/bin/sudoer-cli` (global `/usr/local/bin/sudoer-cli` for production F6) |
| Install mode | **Local-only** |
| Domain surface | File-based JSON approval; Type 0 convert/submit/list/show **routed**; Type 1 `setup` / `interactive` **live** |

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
