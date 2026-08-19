**file**: docs/requirements/requirement-privilege-prevention-set.md  
**Status**: Active (Version 1.6.0)  
**Area**: architecture  
**Key**: `requirement-privilege-prevention-set`  
**id**: RQ-PRIVILEGE-PREVENTION-SET  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **what this product blocks, stops, or prevents**, and for **what it must not block** after the operator has already elevated.

The Type 0 / Type 1 / Type 2 map and elev Tables A / B / C stay on `requirement-three-layer-privilege-model.md`. Least-privilege-approver identity (F1–F7) stays on `requirement-least-privilege-user.md`. File-based JSON approval verbs, schema, queues, hook, and dest transform stay on `requirement-domain-sudoer-approval.md`. This file **does not** replace those tables. It owns the **closed prevention catalog** and the **must-remain-open catalog**.

A wall that is not a §2.2 row is **not** product law.

### 1.1 Human-facing

**In one sentence:** After you already used password sudo, this program must not invent a second lock. The catalog lists what is blocked and what must stay open.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Approve after sudo as the same person who elevated | `sudo sudoer-cli interactive` |
| The other role | Dedicated account is an extra path | `sudoer-adm` |
| Not this file | Dest Fence (broken JSON) | `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Closed block list; OPEN-SUDOER-APPR / OPEN-DECIDE / OPEN-BEHALF | Invented walls; `SUDO_USER` must equal sudoer-adm; forcing A=B |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | authz after elev |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Approve as the elevating admin | Password sudo already decided. File checks still run. Person checks must not steal that decision. | `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Closed-list rule

1. A product **block** exists **only** when it has a row in §2.2.  
2. If an action is **not** listed in §2.2, the product **MUST NOT** stop it — unless this requirement is revised in the **same change** as the new block.  
3. Maintainers **MUST NOT** invent a wall that is not a §2.2 row. Invented walls include: an unpublished live-command whitelist; an unpublished live-command denylist; a Gap stub or “not enabled” die on a listed Type 1 verb after euid 0; an env flag that turns off `useradd` / F6 / hook; a ban on in-tool password `sudo`; treating CI, test isolation, or a missing host account as a security gate; a second privilege check after password `sudo` or a root login — **including** `SUDO_USER` must equal the LPU on `approve` / `reject` / `interactive`. That last form is **blockage of approval**, not helpful checking. Helpful checks review the **file** (schema, visudo, hostile inode). Forcing A=B or dying because owner A ≠ subject B is blockage (**PP-A-18**), not a helpful check.  
4. §2.3 is the **must-remain-open** catalog. Closing a §2.3 row **MUST** revise this file first.  
5. Table A is **only** the F6 sudoers line. Table B is **only** what must not appear **in** the F6 fragment. Table C is **script jobs** (examples of what the already-elevated ship unit runs). Those tables **MUST NOT** be reread as a live-command whitelist or denylist.  
6. **No published denylist ⇒ no extra restrict** on live tools a Type 1 job needs.

### 2.2 What this product blocks (closed catalog)

Each row is a **real** product stop. How the stop is implemented (fail closed, refuse to emit, refuse to install) lives on the **Owner** requirement. This catalog answers **what** is prevented.

#### 2.2.1 Privilege actor

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-PASSWD** | Write `/etc/passwd`, `/etc/group`, `/etc/shadow`, or `/etc/gshadow` | any type | Fail closed. Create/teardown the LPU with `sudo useradd` / `sudo userdel` only | LPU · three-layer |
| **PREV-SUDOERS-D** | Write `/etc/sudoers` (the main file); Type 0 write `/etc/sudoers.d`; Type 1 write a **foreign** name under `/etc/sudoers.d` | Type 0 / foreign | Fail closed. This product **does** copy / overwrite / remove **product-owned** names (OPEN-SUDOERS-D-EX) | three-layer · domain |
| **PREV-T0-USER** | Create or delete the LPU (`useradd` / `userdel`) | Type 0 / ordinary login (LSU). An LSU **never** creates an account itself | Fail closed; no account mutate. Only Type 1 `setup` (sudoer sudo) creates the LPU | LPU · domain |
| **PREV-T0-QUEUE** | `mkdir` the production inbound / accepted / declined trio | Type 0 | Fail closed if the dir is missing | domain |
| **PREV-T1-EUID** | Any Type 1 verb without euid 0 | any login | Fail closed; no partial host write | three-layer · domain |
| **PREV-BOOT-EUID** | `setup` / `remove-lpu` without euid 0 | any login | Fail closed; tell the operator to run `sudo {{APP}} setup` (password `sudo`; **not** `sudo -n`) | three-layer · domain |
| **PREV-APPR-LPU** | `approve` / `reject` / `interactive` as the LPU **euid** (no F6 re-entry) | LPU login without `sudo` | Fail closed `authz` (not euid 0) | domain · three-layer |
| **PREV-FORCE-AUTHZ** | `--force` skipping Type 1 authz, or `--force` auto-approving in `interactive` | Type 1 | Still fail `authz`; still prompt | domain |

#### 2.2.2 F6 fragment and dest writes

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-F6-ALL** | `ALL=(ALL) ALL` or `NOPASSWD: ALL` in F6 / `print-sudoers` | emit / install | Must not emit | three-layer Table B |
| **PREV-F6-SHELL** | `/bin/sh`, `/bin/bash`, or an unrestricted shell as an F6 Cmnd | emit / install | Must not emit | three-layer Table B |
| **PREV-F6-CMND** | `useradd`, `visudo`, `rm`, or a package manager as an **F6 sudoers Cmnd** | emit / install | Must not emit. Account create is `sudo useradd` **inside** the ship unit (Table C), not a grant in F6 | three-layer Table B |
| **PREV-F6-LOCAL** | Elevate `{{USER_BIN}}/{{APP_NAME}}` or an ad-hoc `/tmp` binary as production F6 | emit / install | Must not emit | three-layer |
| **PREV-F6-SCOPE** | Writes outside product-owned `/etc/sudoers.d` names (F6 `{{LPU_USER}}`, grant `{{service}}-{{username}}`), LPU home `/etc/{{LPU_USER}}/` (queues, hooks, `.bak`), `/etc/sudoers.bak/`, `/var/backups/{{APP_NAME}}/` | Type 1 jobs | Bound dest only | three-layer · domain |
| **PREV-DEST-REMOVE** | Install a live dest named `{{service}}-{{username}}-remove` | approve remove | Delete `/etc/sudoers.d/{{service}}-{{username}}` only | domain |
| **PREV-FOREIGN** | Touch a foreign file under `/etc/sudoers.d` (not F6, not `{{service}}-{{username}}`) | Type 1 | Leave it | domain |

#### 2.2.3 Identity, teardown, elev path

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-COLLIDE** | `setup` when UID, GID, or LPU name exists and is **not** this identity | Type 1 bootstrap | Exit non-zero; no partial create | LPU |
| **PREV-UNINST-F7** | Type 0 `uninstall` treated as LPU teardown | Type 0 | `uninstall` removes the **managed binary only** | LPU · local-self-management |
| **PREV-PURGE-GRANTS** | `--purge-grants` mass-revoke of live `{{service}}-{{user}}` dests | F7 v1 | **Absent** in v1; live grants stay | LPU |
| **PREV-SUDO-N-BOOT** | Bootstrap / first-time `setup` documented or implemented as `sudo -n` | Type 1 bootstrap | Must not be the path. Password `sudo` or a root login. The only specified `-n` is the F6 login hook **after** F6 exists | three-layer · domain |
| **PREV-T2** | A Type 2 execution euid for dest writes (`su` / `runuser` to the LPU) | design / code | Type 2 remains **Not used** | three-layer |

#### 2.2.4 Request body and convert

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-SCHEMA** | Unknown JSON keys; remove JSON with `commands`; mixed or unknown service families | submit and approve | Fail closed (`invalid_json` / `remove_extra_fields` / `unknown_service`) | domain |
| **PREV-INCLUDE** | User `ALL`, Cmnd `ALL`, `#include`, `Defaults`, or aliases in a request | convert / submit / approve | Reject | domain |
| **PREV-JSON-VISUDO** | Feeding request JSON to `visudo` | convert / submit / approve | Materialize sudoers text on a private copy first | domain |

#### 2.2.5 UX, hang, and test gates

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-EMPTY-INT** | Empty argv becoming `interactive` | any uid | Empty argv is Type N help | CLI · zero-arguments · domain |
| **PREV-HELP** | Listing a verb in `help` that has no dispatcher arm | help | Must not list | CLI · domain |
| **PREV-HANG** | Prompt or hang when `TTY` is not `1`; login hook hanging `scp` / CI; hook `exit` on `sudo -n` fail | `interactive` / hook | Fail closed `confirm_required`; hook skips / warns and login continues | interactive · domain |
| **PREV-TEST-ROOTS** | Pointing production dest / queues at a fake root without `{{TEST_ROOTS_FLAG}}=1` **or** a Type 1 `setup`-created path | Type 0 / tests | Fail closed | domain · three-layer |

### 2.3 What this product does **not** block (must remain open)

These rows are **product law**. They are not “nice to have.” Closing one is the same class of defect as adding an unlisted block.

| ID | Must stay open | After / when | Why |
|----|----------------|--------------|-----|
| **OPEN-ELEV** | Run the Type 1 job the operator invoked — **including** `approve` / `reject` / `interactive` | After password `sudo` **or** a root login (`SUDO_USER` may be **any** host admin) | That elev **is** the approval. **MUST NOT** invent a second lock |
| **OPEN-SUDOER-APPR** | Any already euid-0 host admin **MAY** `approve` / `reject` / `interactive` | Same as OPEN-ELEV | F6 / `sudoer-adm` is **not** the only approver. Requiring `SUDO_USER==sudoer-adm` is an invented wall |
| **OPEN-DECIDE** | Type 1 `approve` / `reject` **MUST** move a regular inbound JSON after euid 0 | After elev | **MUST NOT** fail `owner_mismatch` or `self_scope`. File owner and parsed subject are not a second lock. Dest identity is JSON `username` / `service` when present |
| **OPEN-BEHALF** | Type 0 **MAY** submit a grant for another login B; allocated filename uses **B** | Type 0 submit | Forcing A=B or dying because owner A ≠ subject B is **PP-A-18**. Allocator takes JSON / User spec as B |
| **OPEN-SUDO** | The ship unit **MAY** invoke password `sudo` (outer **or** in-tool) | Mix model | “Avoid `sudo -n`” is **not** “avoid `sudo`” |
| **OPEN-USERADD** | Type 1 `setup` / `remove-lpu` **MUST** call `sudo useradd` / `sudo userdel` (password `sudo`) | After euid 0 | Account create is a script job, not an F6 Cmnd |
| **OPEN-TOOLS** | Type 1 **MAY** run the OS tools the job needs (`mkdir`, `chmod`, `visudo -cf`, `install`, product-scoped `rm`, …) | After euid 0 | Table A is not a live-command catalog |
| **OPEN-UNLISTED** | A live tool that is **not** listed in Table A, Table B, or Table C is **not** forbidden | After euid 0 | No denylist ⇒ no extra restrict |
| **OPEN-BOOT-ANY** | **Any** host admin already euid 0 **MAY** run `setup` / `remove-lpu` | Bootstrap | F6 / LPU do not exist yet. **MUST NOT** require `SUDO_USER` to be the LPU |
| **OPEN-ROOT-APPR** | A real root login **MAY** run `approve` / `reject` / `interactive` | After euid 0, `SUDO_USER` empty | Same Type 1 verbs as the F6 approver |
| **OPEN-CONFIRM** | The **only** extra gate after elev is TTY confirm or `--force` on **sensitive** undo-hard steps | After euid 0 | Confirm is not a new privilege class |
| **OPEN-NO-FLAG** | No env flag, Gap stub, or “not enabled in this environment” die on live `useradd` / F6 / hook after euid 0 | Type 1 `setup` | Nobody published that gate |
| **OPEN-NO-CI** | Continuous integration is **not** a product gate on `useradd` | Host vs suite | A suite that cannot enter a sudo password **MUST NOT** be rewritten as “create is forbidden” |
| **OPEN-NO-ISOL** | Test isolation (fake dest roots, temp homes) is **not** a security wall on live `setup` | Host vs suite | Isolation is a test helper, not Type 1 law |
| **OPEN-TABLE-A** | Table A stays **one** F6 line (global binary). It **MUST NOT** grow into “every binary the script may exec” | emit | Fragment ≠ live allowlist |
| **OPEN-TABLE-C** | Table C rows **MUST NOT** be copied into F6 / `print-sudoers`. Unlisted tools stay allowed | emit vs script | Wrong surface |
| **OPEN-ETC-USER** | Type 1 **MUST** put LPU home / queues / hooks under `/etc/{{LPU_USER}}/` | After euid 0 | Prefer `/etc/{{username}}/` for the account tree. There is **no** blanket “do not write `/etc`” |
| **OPEN-SUDOERS-D-EX** | Type 1 **MAY** **copy**, **overwrite**, and **remove** product-owned files under `/etc/sudoers.d/` (F6 `{{LPU_USER}}`; grant `{{service}}-{{username}}`) | After euid 0 | This product **is** the sudoers manager. Exception to the portable “do not write sudoers.d” default. Still **PREV-PASSWD**, **PREV-FOREIGN**, no `/etc/sudoers` main-file write |

### 2.4 Sensitive is not blocked

These steps are **hard to undo**. They stay **allowed** after elev. The extra gate is confirm or `--force` only — not a new privilege class and not a live-command whitelist.

| Step | Extra gate | Still allowed after elev? |
|------|------------|---------------------------|
| Type 0 `uninstall` (managed binary only) | TTY confirm; non-interactive requires `--force` | yes |
| Type 1 `remove-lpu` / `userdel -r` | TTY confirm unless `--force` | yes |
| `--purge-queues` (skip archive copy) | same F7 confirm / `--force` | yes |

`--force` **MUST NOT** skip §2.2 authz rows (**PREV-FORCE-AUTHZ**).

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **Ship unit** | `src/sudoer-cli` |
| **LPU** | `sudoer-adm` (UID/GID `1776`, create home `/etc/sudoer-adm`; public queues `/var/{{APP_NAME}}/`) |
| **F6 file** | `/etc/sudoers.d/sudoer-adm` = `sudoer-adm ALL=(root) NOPASSWD: /usr/local/bin/sudoer-cli` (Type 1 copy/overwrite/remove exception) |
| **Grant dest** | `/etc/sudoers.d/{{service}}-{{username}}` (worked: `/etc/sudoers.d/folder-backup-leolio`) |
| **Usual bootstrap** | `sudo src/sudoer-cli setup` or `sudo sudoer-cli setup` (password `sudo` OK) |
| **Test-roots flag** | `SUDOER_CLI_ALLOW_TEST_ROOTS=1` |
| **Absent flags** | There is **no** `LIVE_LPU` flag, **no** `SUDOER_CLI_LIVE_LPU_TEST`, **no** Gap on create |
| **Routing** | Type 1 `setup` / `remove-lpu` / `approve` / `reject` / `interactive` live |
| **Sensitive confirms** | `uninstall`; `remove-lpu` / `setup --uninstall` |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: The block list is written down. Agents do not invent a second security story.  
- **CIAO Principle 9 – Three Types of Commands**: Type 0 stays Type 0; Type 1 after elev is not re-gated.  
- **CIAO Principle 10 – Least privilege**: Size the job **before** elev (Type 0 vs Type 1, F6 contents). After elev, least privilege is **not** “invent a command allowlist.”  
- **CIAO Principle 1 – Caution**: Fail closed on the published rows; fail loud; do not silently skip `useradd`.  
- **CIAO Principle 4 / 20 – Over-protect**: Over-protect the **closed list** and the **must-remain-open** list — not an unpublished extra wall.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Only published rows stop an action. Unknown tools are not silently denied.  
- **Intentional**: Block vs open is a pair. One catalog without the other is incomplete.  
- **Anti-fragile**: Password `sudo` / root login works on a real host; CI not being able to type a password does not rewrite the product.  
- **Over-protect**: Adding a new block without revising this file is a privilege regression (the agent took the power to lock the operator out).

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Add a product block that is not a §2.2 row without revising this file in the same change.  
2. Close a §2.3 row (treat Table A as a live-command whitelist; ban in-tool password `sudo`; require `sudo -n` for `setup`; require the operator to already be the LPU **for setup or for approve**; die “not enabled”; add `LIVE_LPU` / isolation / CI as a create gate; re-add a **PREV-APPR-ACTOR** row that fails an already euid-0 host admin whose `SUDO_USER` is not `sudoer-adm`).  
3. Put Table C OS tools into Table A / `print-sudoers` **or** refuse to run those tools after euid 0 because they are not in Table A.  
4. Invent a Type 2 euid, or `su` / `runuser` to the LPU, in order to write dest.  
4a. Write `/etc/passwd` or `/etc/sudoers` (main file), or invent a blanket “do not write `/etc`” that blocks `/etc/{{username}}/` **or** this product’s Type 1 sudoers.d copy/overwrite/remove exception.  
5. Treat a remaining about-field Gap as a privilege wall on `setup` / `interactive`.  
6. Use `--force` to skip Type 1 authz or to auto-approve.  
7. Document bootstrap as `sudo -n {{APP}} setup`.

**Violating this rule is a critical privilege / invented-wall regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Type map + Tables A/B/C |
| `docs/requirements/requirement-least-privilege-user.md` | F1–F7 identity |
| `docs/requirements/requirement-domain-sudoer-approval.md` | File-based JSON approval |
| `docs/requirements/requirement-shell-cli-interface.md` | Dispatcher / Type 0 catalog |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv ≠ `interactive` |
| `docs/requirements/requirement-shell-local-self-management.md` | Type 0 `uninstall` ≠ F7 |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | Confirm / no-hang |
| `./sudoer-cli` | Ship unit under test |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-SR-PRIV-01** | `tests/test_domain_sr.sh` | have | PREV-T1-EUID / PREV-SUDOERS-D (no dest without euid 0) |
| **TP-SR-PRIV-02** | `tests/test_domain_sr.sh` | have | OPEN-BOOT-ANY; PREV-SUDO-N-BOOT; setup not locked to LPU |
| **TP-SR-PRIV-04** | `tests/test_domain_sr.sh` | have | OPEN-ELEV / OPEN-SUDOER-APPR: approve gate has no exclusive-LPU actor lock |
| **TP-SR-PRIV-03** | `tests/test_domain_sr.sh` | have | OPEN-USERADD / OPEN-NO-FLAG (static: useradd, no Gap stub, no `LIVE_LPU`) |
| **TP-ELEV-08** | `tests/test_cli.sh` | have | `sudo -n` only with F6/hook |
| **TP-SR-05** | `tests/test_domain_sr.sh` | have | Submit / list / show (no self-scope wall) |
| **TP-SR-06** | `tests/test_domain_sr.sh` | have | PREV-DEST-REMOVE |
| **TP-CLI-07** | `tests/test_cli.sh` | have | PREV-EMPTY-INT |
| **TP-LC-05** / **TP-LC-06** | `tests/test_local_lifecycle.sh` | have | OPEN-CONFIRM uninstall; PREV-UNINST-F7 (binary only) |
| **TP-PREV-01** | `tests/test_domain_sr.sh` | have | Alias of TP-SR-PRIV-03: no second lock / no invented create flag |
| **TP-PREV-02** | `tests/test_domain_sr.sh` | have | Alias of TP-SR-03 + FORB-07: `print-sudoers` has no `useradd` |
| **TP-PREV-03** | `tests/test_domain_sr.sh` | have | Alias of TP-SR-PRIV-04 / TP-ELEV-09: elevated sudoer is the approval user |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-14 | Active 1.0.0 | Closed prevention catalog + must-remain-open catalog. Elev is approval. No invented walls. |
| 2026-08-14 | Active 1.1.0 | `/etc` stops are `/etc/passwd` and `/etc/sudoers.d` only. Dest / LPU home = `/etc/{{username}}/` |
| 2026-08-14 | Active 1.2.0 | Exception OPEN-SUDOERS-D-EX: Type 1 copy/overwrite/remove product-owned `/etc/sudoers.d` names |
| 2026-08-15 | Active 1.3.0 | Public `/var/` queues as bound dest |
| 2026-08-18 | Active 1.4.0 | Drop PREV-APPR-ACTOR (second lock). OPEN-SUDOER-APPR. LSU never `useradd`. **TP-PREV-03** |
| 2026-08-18 | Active 1.5.0 | Drop PREV-BEHALF and Type 1 `owner_mismatch`. Approve/reject are not submitter/owner walls. |
| 2026-08-18 | Active 1.6.0 | **OPEN-BEHALF**: A may submit for B; filename uses B. Helpful checks are file integrity, not A=B. |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
