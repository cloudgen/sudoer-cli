**file**: docs/requirements/requirement-least-privilege-user.md  
**Status**: Active (Version 1.13.0)  
**Area**: architecture  
**Key**: `requirement-least-privilege-user`  
**id**: RQ-LEAST-PRIVILEGE-USER  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the dedicated **least-privilege-approver** account: identity, home vs affected folders, sudoers pairing, create, and remove. That account is the **approver** in the file-based JSON approval machine owned by `requirement-domain-sudoer-approval.md`. Elev Tables A/B/C live in `requirement-three-layer-privilege-model.md`. What create/teardown **blocks** vs what must stay open after elev is owned by `requirement-privilege-prevention-set.md`.

### 1.1 Human-facing

**In one sentence:** sudoer-adm is the dedicated approver account. Its home views and the waiting folder are created at setup. Ordinary logins must not create that account.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Stay a normal login; do not useradd | `sudoer-cli add-sudoer-request --file request.json` |
| The other role | Host admin already using sudo creates the account | `sudo sudoer-cli setup` |
| Not this file | Type map; dest Fence | `requirement-three-layer-privilege-model` · `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Account, home, folder views, extra fragment, teardown; rc owned by that account | Ordinary login creating the account; Type 2 dest-write as that account |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | setup / F1–F7 |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time setup | A host admin already using sudo creates sudoer-adm and the three folders. You still queue as yourself. | `sudo sudoer-cli setup` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Role

1. The product **MUST** document exactly one LPU leaf for approval: a dedicated non-root account whose extra power is **invoking the global product binary via NOPASSWD**.  
2. That account is a **least-privilege-approver**, **not** a Type 2 execution context. Day-to-day dest writes under `/etc/sudoers.d/` (product-owned names only) happen because F6 re-enters the CLI as root. **MUST NOT** write `/etc/passwd` or `/etc/sudoers`. Type 1 **MAY** copy, overwrite, and remove F6 `/etc/sudoers.d/sudoer-adm`.  
3. Hierarchy: system-user → least-privilege-user → least-privilege-approver → this leaf (`sudoer-adm`).  
4. Every least-privilege-approver leaf **MUST** name **at least one** approval subject (the content family it may authorize). This leaf’s subject is the **sudoers grant text** (sudoer-file; queued as JSON). A leaf with no named subject is incomplete.

### 2.2 Mandatory field set (F1–F7)

Every product LPU leaf **MUST** declare:

| Field | Rule |
|-------|------|
| **F1 UID / F2 GID** | Fixed numeric pair **or** explicit distro-assigned. Collision on create **MUST** fail closed. |
| **Shell** | Default `/bin/bash` unless this file overrides. |
| **F3 System-user home** | Absolute path; selection reason `override` / `preferred-/etc` / `fallback-/home`. Bare home is **not** an affected folder. |
| **F4 Symlink map** | Table of link → target. This product: LPU-home queue **views** → public `/var/{{APP_NAME}}/` real dirs. |
| **F5 Affected folders** | Paths **excluding** bare home. Public `/var/{{APP_NAME}}/` + three queue children. |
| **F6 Sudoers file** | Installed path, mode/owner, Cmnd ⊆ Table A. |
| **F7 Remove steps** | Ordered product teardown. Type 0 `uninstall` of the CLI is **not** F7. |

### 2.3 Home resolution

When creating a new LPU, resolve F3 as: override (if set) → `/etc/{{LPU_USER}}` if available → `/home/{{LPU_USER}}`. An **operator-ordered home wins**. Do not silently ignore an override.

### 2.4 Create vs remove

| Artifact | Create (Type 1 `setup`) | Remove (Type 1 `setup --uninstall` / `remove-lpu`) |
|----------|-------------------------|-----------------------------------------------------|
| Account + home | `sudo useradd` with F1–F3 (not a sudoers Cmnd) | After archive: `sudo userdel -r` |
| Public queues | mkdir `/var/{{APP_NAME}}/` + three children; modes in F5 | archived (unless `--purge-queues`) then the three children **removed** and the public root `rmdir` if empty |
| Home queue views | F4 symlinks under live LPU home | removed with `userdel -r` |
| F6 fragment | visudo + `install -m 0440` | backup then remove fragment |
| Login hook | idempotent marker in LPU `.bashrc`; **check** `.profile` and **create** it when missing (source `.bashrc`; never overwrite). After create/rewrite: **owner this LPU**, readable mode | strip whichever files contain the hook marker; then restore owner |
| Live `{{service}}-{{user}}` grants | not created here | **left in place** (no `--purge-grants` in v1) |

F7 v1 default **MUST** be: warn live grants stay → reverse hook → archive queues to `/var/backups/{{APP_NAME}}/{{YYYYMMDD}}-{{n}}/` → `userdel -r`. `--purge-queues` skips the archive copy; home is still removed by `userdel -r`. `--purge-grants` is **not** v1.

### 2.5 Implementation Notes (this project)

| Property | Product value | Field |
|----------|---------------|-------|
| Username / group | `sudoer-adm` | — |
| UID | `1776` | F1 |
| GID | `1776` | F2 |
| Shell | `/bin/bash` | identity |
| System-user home | `/etc/sudoer-adm` | F3 |
| Home selection | **preferred-/etc** (not `/home/sudoer-adm`) | F3 |
| Symlinks (F4) | Live LPU home (passwd field 6; create default `/etc/sudoer-adm`) → public real dirs: `${LPU_HOME}/sudoer-request` → `/var/{{APP_NAME}}/sudoer-request`; `${LPU_HOME}/sudoer-approved` → `/var/{{APP_NAME}}/sudoer-approved`; `${LPU_HOME}/sudoer-rejected` → `/var/{{APP_NAME}}/sudoer-rejected` | F4 |
| Affected (F5) | `/var/{{APP_NAME}}` mode **0755** owner `sudoer-adm:sudoer-adm`; `/var/{{APP_NAME}}/sudoer-request` **3773** (sticky+setgid, other `-wx` no other-r); `/var/{{APP_NAME}}/sudoer-approved` **0700**; `/var/{{APP_NAME}}/sudoer-rejected` **0700** | F5 |
| Sudoers file | `/etc/sudoers.d/sudoer-adm` mode 0440 `root:root` (Type 1 copy/overwrite/remove exception) | F6 |
| Approval subject | sudoers grant text (sudoer-file; queued as JSON) — **at least one required** | LPA leaf |
| Login hook | `${LPU_HOME}/.bashrc` (create if missing) **and** check `${LPU_HOME}/.profile` (create source-bashrc sample if missing; never overwrite). After create or rewrite: **owner `sudoer-adm:sudoer-adm`**, mode **0644**. Marker `# BEGIN sudoer-cli login hook`; env `SUDOER_CLI_HOOK_RAN`; command `sudo -n /usr/local/bin/sudoer-cli interactive` | F5 rc / domain SSOT |
| Remove | `sudo sudoer-cli setup --uninstall` (or `remove-lpu`) — any host admin, password sudo OK | F7 |

**Routing status:** `setup` / `remove-lpu` **are live** (useradd / F6 / hook / userdel) and **fail closed** without euid 0. Bootstrap is **any** host admin already root (`sudo sudoer-cli setup`); **not** `sudo -n`; **not** limited to `sudoer-adm` (that account is what setup creates). Type 0 / an LSU **MUST NOT** `useradd`. After success, setup **helps submit** (prints the `add-sudoer-request` next-step; the invoking sudoer **may** name B). Probe with `id sudoer-adm` before claiming the account exists. A TTY login as `sudoer-adm` enters approval via F6 + hook; a host admin who already used password `sudo` **may** approve without logging in as `sudoer-adm`. The hook’s `sudo -n` is **post-F6 only**.

Snippet text, guards, the `.profile` create sample, and the review loop are owned by `requirement-domain-sudoer-approval.md`. This file owns **where** the hook is installed (this LPU’s `.bashrc` and, when created or already present, this LPU’s `.profile` only).

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
3. Default a new home to `/home/{{LPU_USER}}` when `/etc/{{LPU_USER}}` is the product F3 (this product: `/etc/sudoer-adm`).  
4. Treat Type 0 `uninstall` as F7.  
5. Document F7 as mass-revoke of live `{{service}}-{{user}}` grants in v1.  
6. Implement `nologin` as the portable default shell.  
7. Claim a TTY login as `sudoer-adm` can approve while the review loop is still a Gap.  
8. Install the review hook in any account other than this LPU, or skip the LPU `~/.profile` existence check / auto-create (login then never reaches `.bashrc`).  
8a. Leave this LPU’s `.profile` or `.bashrc` owned by root (or otherwise unreadable by `sudoer-adm`) after `setup` / hook rewrite. The corresponding user **must** own those files.  
9. Claim a least-privilege-approver leaf complete with **zero** named approval subjects.  
10. Require the operator to be `sudoer-adm` (or to use `sudo -n`) in order to run first-time `setup`, **or** to finish `approve` / `reject` / `interactive` after password `sudo`. F6 is extra, not exclusive.  
11. Invent a Gap, env flag, or “not enabled” wall on live `useradd` after euid 0. Create is a §2.4 job, not a second privilege class (`requirement-privilege-prevention-set.md`).  
12. Put the inbound dropbox only under LPU home, or keep F4 as **none**. Type 0 submit is **`/var/{{APP_NAME}}/sudoer-request`**.  
13. Hardcode `/etc/sudoer-adm` as the **queue** path. Queue views use **live LPU home** (passwd field 6).  
14. Skip **chown** of a request file to `sudoer-adm:sudoer-adm` on Type 1 approve/reject (external sudo). Moved files **MUST** stay that owner.

**Violating this rule is a critical least-privilege documentation / identity regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Elev Tables A/B/C + F6 Cmnd |
| `docs/requirements/requirement-privilege-prevention-set.md` | Closed catalog of what create/teardown blocks vs must stay open |
| `docs/requirements/requirement-domain-sudoer-approval.md` | File-based JSON approval (roles / submit / verify) |
| `docs/requirements/requirement-shell-cli-interface.md` | Type map on the dispatcher |
| `./sudoer-cli` | Ship unit |

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

