**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 5.3.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: this workspace is **sudoer-cli**, specialized **A → B** from **selfmanaged**. A is a live sibling product (online-install Type 0). B keeps that architecture and adds the sudoers-approval domain.

**Direction is sacred:** selfmanaged → sudoer-cli only. Never reverse-copy this ship unit onto selfmanaged.

### 1.1 Human-facing

**In one sentence:** This product grew from a shell CLI template. The live program is sudoer-cli; there is no parent binary here to copy back onto.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Use this product as sudoer-cli | `src/sudoer-cli` |
| The other role | Bootstrap origin A is the live selfmanaged CLI | sibling `selfmanaged` |
| Not this file | Domain verbs | `requirement-domain-sudoer-approval` |

| Includes | Excludes |
|----------|----------|
| A→B direction; live parent is selfmanaged | Reverse-copy onto selfmanaged |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | this product |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Keep direction | Specialize this product from the template. Do not overwrite a template with this ship unit. | (no command — architecture law) |

---

## 2. Core Rules (Mandatory)

### 2.1 Direction

1. This product is a **descendant** of **selfmanaged** (live sibling). Historical hop cli-template remains an ancestor, not the live parent.  
2. Every future edge **MUST** be **ancestor → descendant** only.  
3. Plans **MUST NOT** copy this ship unit onto selfmanaged to “share domain.”  
4. Detected reverse-copy **MUST** be treated as critical pollution (restore A from git; rebuild B).  
5. Agents **MUST** treat `selfmanaged` as this product’s live bootstrap origin for Type 0 install architecture.

### 2.2 Chain declaration (this product)

| Field | Value |
|-------|--------|
| **Historical origin** | `cli-template` — earlier hop; not the live parent |
| **Immediate origin (A)** | `selfmanaged` — live Type 0 online-install sibling |
| **This product (B / leaf)** | `sudoer-cli` |
| **Specialize mode** | Same Type 0 architecture as A (Type O `curl \| sh`) + sudoers-approval domain (Type 0 routed; Type 1 `setup` / `interactive` live) |
| **This ship unit** | `src/sudoer-cli` |
| **This channel ownership** | `SCRIPT_URL` default `https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli` |
| **This domain** | File-based JSON sudoer approval — see `requirement-domain-sudoer-approval` |

### 2.3 Architecture contracts (this origin owns)

These are **this product’s** structural contracts, inherited from selfmanaged then specialized.

| Layer | This origin |
|-------|-------------|
| Runtime | POSIX `/bin/sh`, `set -u`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_` plus domain `sr_` / `lpu_` |
| Domain prefix | `sr_` (requests) · `lpu_` (setup) |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` / `--global` |
| Integrity companion | **Present** — `${SCRIPT_URL}.sha256` (`requirement-shell-automatic-checksum`) |
| Online lifecycle | **Present** — `install` / `version-check` / `self-update` / `self-uninstall` / Type O / `SCRIPT_URL` |
| Local lifecycle | **Superseded** — do not keep a second `uninstall` / `where-is-me` class path |
| Empty argv | **Type O** install-ensure |
| Backup / restore | **Absent** |
| Sudoers-approval domain | Type 0 **routed**; Type 1 `setup` / `interactive` **live** — `requirement-domain-sudoer-approval` |

### 2.4 Surface matrix (normative for this product)

| Surface | Decision | Notes for sudoer-cli |
|---------|----------|------------------------|
| `out_*` output SSOT | **Keep** | This origin’s family |
| Modular single-file design | **Keep** | Ship unit under `src/` |
| Global flags + `app_main` | **Keep** | Same contracts; no domain flags |
| Storage resolve | **Keep** | Scratch only |
| Idempotency / interactive modes | **Keep** | Lifecycle only |
| Online channel | **Keep (from A)** | B’s `SCRIPT_URL`, not A’s |
| Type O empty argv | **Keep (from A)** | Empty argv = install-ensure |
| Domain backup + restore | **Absent** | Not this product’s domain |
| Sudoers print / setup / submit / approve / interactive | **Live** (Type 0 convert/submit; Type 1 `setup` / `interactive`; dest `/etc/sudoers.d/{{service}}-{{user}}` on authorized `approve`) | `requirement-domain-sudoer-approval` |
| Local `install` / `uninstall` / `where-is-me` | **Trim uninstall / where-is-me** | Place command is channel `install`; remove is `self-uninstall` |
| Domain / out Protection Zones | **Keep spirit** | Do not simplify `out_*` |

### 2.5 Identity (this origin)

| Concern | Value |
|---------|---------|
| `APP_NAME` | `sudoer-cli` |
| `VERSION` | `1.22.0` (product version SSOT in ship unit)
| Primary install story | `curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli \| sh` |
| README one-liner | **Yes** — B’s composed `SCRIPT_URL` |

### 2.6 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **Workspace** | `{{PROJECTS_ROOT}}/{{PROJECT_BASENAME}}` |
| **Role** | Specialized from selfmanaged. Domain stays on B. |
| **Related (not origin)** | `folder-backup`, historical `cli-template` — do not overwrite A |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: This product is the origin. Parent hops are not implied.  
- **Principle 4 / 20 – Over-protect**: Reverse-copy onto this origin is a critical pollution class.  
- **Principle 21 – Dual policies**: Identity lives in Implementation Notes and ship-unit Config.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not invent host `setup` or other OS-mutating verbs to fill the product name.  
- **Intentional:** Type 0 architecture from cli-template **plus** exactly one Active domain SSOT (`requirement-domain-sudoer-approval`).  
- **Anti-fragile:** Historical origin stays in git; do not reverse-copy this ship unit onto cli-template.  
- **Over-protect:** Channel is B’s `SCRIPT_URL`. **MUST NOT** register a second Active `requirement-domain-*`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Reverse-copy this ship unit onto selfmanaged (or a cli-template origin).  
2. Point B’s default `SCRIPT_URL` at selfmanaged’s channel.  
3. Reintroduce `backup` / `restore` folder-archive verbs without new Active requirements.  
4. Create a second Active `requirement-domain-*` or list unrouted verbs in `help`.  
5. Drop Type O / `SCRIPT_URL` / `self-uninstall` while claiming the same architecture as selfmanaged.  
6. Drop Type 0 lifecycle while claiming the same architecture as A.  
7. Name folder-backup as this product’s live origin.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Chain names **sudoer-cli** as this product; **selfmanaged** is live origin A |
| AC-2 | Ship unit is `src/sudoer-cli` |
| AC-3 | Help does not list unrouted domain verbs |
| AC-4 | Unknown domain verbs fail closed |
| AC-5 | Empty argv is Type O install-ensure |
| AC-6 | Default `SCRIPT_URL` is B’s channel, not selfmanaged’s |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class gate |
| `requirement-shell-cli-interface` | Type 0 verb catalog |
| `requirement-shell-self-management` | Online lifecycle package |
| `requirement-shell-cli-zero-arguments` | Type O empty argv |
| `requirement-shell-automatic-checksum` | Companion digest |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04,10,13** | `tests/test_cli.sh` | have | online lifecycle live; backup/restore unknown |
| **TP-CLI-07** | `tests/test_cli.sh` | have | Type O empty argv |
| **TP-CURL-02** | `tests/test_online_curl_install.sh` | have | `curl \| sh` first install |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup: selfmanaged → folder-backup (trim online) |
| 2026-08-13 | Active 2.0.0 | specialize hop; trim backup/restore/sudoers; identity **cli-template** (not host-OS setup) |
| 2026-08-13 | Active 3.0.0 | Retired live hop folder-backup; briefly named selfmanaged → cli-template |
| 2026-08-13 | Active 4.0.0 | **This product is hop 0.** No live parent. selfmanaged and folder-backup are not origins. |
| 2026-08-13 | Active 5.0.0 | Specialize A→B: this product is **sudoer-cli**; cli-template is historical origin. |
| 2026-08-14 | Active 5.1.0 | Type 1 `setup` live; dest install on authorized `approve`; `interactive` loop Gap |
| 2026-08-26 | Active 5.2.0 | Exactly one Active domain SSOT; workspace `{{PROJECTS_ROOT}}/{{PROJECT_BASENAME}}`; VERSION notes **1.17.1** |
| 2026-09-03 | Active 5.2.1 | Stay-honest Implementation Notes `VERSION` **1.18.0** |
| 2026-09-03 | Active 5.2.2 | Stay-honest Implementation Notes `VERSION` **1.19.0** |
| 2026-09-03 | Active 5.2.3 | Stay-honest Implementation Notes `VERSION` **1.20.0** |
| 2026-09-06 | Active 5.2.4 | Stay-honest Implementation Notes `VERSION` **1.21.0** |
| 2026-09-07 | Active 5.3.0 | Live origin **selfmanaged**; Type O `curl \| sh`; VERSION **1.22.0** |

---

**Last Updated**: 2026-09-08  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
