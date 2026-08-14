**file**: docs/requirements/requirement-least-privilege-user.md  
**Status**: Active (Version 1.3.0)  
**Area**: architecture  
**Key**: `requirement-least-privilege-user`  
**id**: RQ-LEAST-PRIVILEGE-USER  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the dedicated **least-privilege-approver** account: identity, home vs affected folders, sudoers pairing, create, and remove. That account is the **approver** in the file-based JSON approval machine owned by `requirement-domain-sudoer-approval.md`. Elev Tables A/B/C live in `requirement-three-layer-privilege-model.md`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Role

1. The product **MUST** document exactly one LPU leaf for approval: a dedicated non-root account whose extra power is **invoking the global product binary via NOPASSWD**.  
2. That account is a **least-privilege-approver**, **not** a Type 2 execution context. Day-to-day `/etc/sudoers.d` writes happen because F6 re-enters the CLI as root.  
3. Hierarchy: system-user → least-privilege-user → least-privilege-approver → this leaf (`sudoer-adm`).  
4. Every least-privilege-approver leaf **MUST** name **at least one** approval subject (the content family it may authorize). This leaf’s subject is the **sudoers grant text** (sudoer-file; queued as JSON). A leaf with no named subject is incomplete.

### 2.2 Mandatory field set (F1–F7)

Every product LPU leaf **MUST** declare:

| Field | Rule |
|-------|------|
| **F1 UID / F2 GID** | Fixed numeric pair **or** explicit distro-assigned. Collision on create **MUST** fail closed. |
| **Shell** | Default `/bin/bash` unless this file overrides. |
| **F3 System-user home** | Absolute path; selection reason `override` / `preferred-/etc` / `fallback-/home`. Bare home is **not** an affected folder. |
| **F4 Symlink map** | Table of link → target, or explicit **none**. |
| **F5 Affected folders** | Paths **excluding** bare home. Subtrees under home **MAY** appear. |
| **F6 Sudoers file** | Installed path, mode/owner, Cmnd ⊆ Table A. |
| **F7 Remove steps** | Ordered product teardown. Type 0 `uninstall` of the CLI is **not** F7. |

### 2.3 Home resolution

When creating a new LPU, resolve F3 as: override (if set) → `/etc/{{LPU_USER}}` if available → `/home/{{LPU_USER}}`. An **operator-ordered home wins**. Do not silently ignore an override.

### 2.4 Create vs remove

| Artifact | Create (Type 1 `setup`) | Remove (Type 1 `setup --uninstall` / `remove-lpu`) |
|----------|-------------------------|-----------------------------------------------------|
| Account + home | `useradd` with F1–F3 | After archive: `userdel -r` |
| Queue subtrees | mkdir + modes in F5 | archived then removed with home |
| F6 fragment | visudo + `install -m 0440` | backup then remove fragment |
| Login hook | idempotent marker in LPU rc files | strip whichever files contain the marker |
| Live `{{service}}-{{user}}` grants | not created here | **left in place** (no `--purge-grants` in v1) |

F7 v1 default **MUST** be: warn live grants stay → reverse hook → archive queues to `/var/backups/{{APP_NAME}}/{{YYYYMMDD}}-{{n}}/` → `userdel -r`. `--purge-queues` skips the archive copy; home is still removed by `userdel -r`. `--purge-grants` is **not** v1.

### 2.5 Implementation Notes (this project)

| Property | Product value | Field |
|----------|---------------|-------|
| Username / group | `sudoer-adm` | — |
| UID | `1776` | F1 |
| GID | `1776` | F2 |
| Shell | `/bin/bash` | identity |
| System-user home | `/home/sudoer-adm` | F3 |
| Home selection | **override** (operator-ordered; not `/etc/sudoer-adm`) | F3 |
| Symlinks | **none** | F4 |
| Affected | `/home/sudoer-adm/sudoer-approving` mode **3773** (sticky+setgid, owner `sudoer-adm:sudoer-adm`); `/home/sudoer-adm/sudoer-approved` **0751**; `/home/sudoer-adm/sudoer-rejected` **0751** | F5 |
| Sudoers file | `/etc/sudoers.d/sudoer-adm` mode 0440 `root:root` | F6 |
| Approval subject | sudoers grant text (sudoer-file; queued as JSON) — **at least one required** | LPA leaf |
| Login hook | `/home/sudoer-adm/.bashrc` (default); marker `# BEGIN sudoer-cli login hook`; env `SUDOER_CLI_HOOK_RAN`; command `sudo -n /usr/local/bin/sudoer-cli interactive` | F5 rc / domain SSOT |
| Remove | `sudo sudoer-cli setup --uninstall` (or `remove-lpu`) | F7 |

**Routing status:** `setup` / `remove-lpu` **are routed** and **fail closed** without euid 0. Live `useradd`/`userdel` **and hook install** are a **Gap**. Probe with `id sudoer-adm` before claiming the account exists. A TTY login as `sudoer-adm` **cannot** enter approval until F6 + hook + `sr_interactive` loop are live.

Snippet text, guards, and the review loop are owned by `requirement-domain-sudoer-approval.md`. This file owns **where** the hook is installed (this LPU’s rc only).

**Collision:** if `getent passwd 1776` or `getent group 1776` or `getent passwd sudoer-adm` exists and is **not** this identity, setup **MUST** exit non-zero.

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least-Privilege User**: sized operator, not standing root.  
- **CIAO Principle 9 – Three Types of Commands**: approver ≠ Type 2 euid.  
- **CIAO Principle 1 – Caution**: fail closed on UID collision.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: never list bare home as affected.  
- **Intentional**: override home is documented, not a silent fallback.  
- **Anti-fragile**: F7 archives queues before `userdel -r`.  
- **Over-protect**: Type 0 uninstall does not delete the LPU.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Claim F1–F7 complete while any field is hollow.  
2. List bare home inside F5.  
3. Default a new home to `/home/{{LPU_USER}}` when `/etc/{{LPU_USER}}` is free **and** no override exists.  
4. Treat Type 0 `uninstall` as F7.  
5. Document F7 as mass-revoke of live `{{service}}-{{user}}` grants in v1.  
6. Implement `nologin` as the portable default shell.  
7. Claim a TTY login as `sudoer-adm` can approve while hook install / F6 / review loop are still Gaps.  
8. Install the review hook in any account other than this LPU.  
9. Claim a least-privilege-approver leaf complete with **zero** named approval subjects.

**Violating this rule is a critical least-privilege documentation / identity regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Elev Tables A/B/C + F6 Cmnd |
| `docs/requirements/requirement-domain-sudoer-approval.md` | File-based JSON approval (roles / submit / verify) |
| `docs/requirements/requirement-shell-cli-interface.md` | Type map on the dispatcher |
| `./sudoer-cli` | Ship unit |

**Last Updated**: 2026-08-14  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
