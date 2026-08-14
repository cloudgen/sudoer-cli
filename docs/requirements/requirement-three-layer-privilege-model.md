**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.2.0)  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**id**: RQ-THREE-LAYER-PRIVILEGE-MODEL  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **Type 0 / Type 1 / Type 2 privilege map**, the **elev Tables A/B/C**, and the **sudoers-fragment emit/install contract** of this product.

Domain verbs that *use* elevation are catalogued in `requirement-domain-sudoer-approval.md`. Type 0 submit vs Type 1 approve is the privilege split of that file-based JSON approval machine. They **MUST NOT** invent a second elev table. This file owns the Type map and the Cmnd set that `print-sudoers` may emit.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map

| Layer | Privilege | Typical actor | This product |
|-------|-----------|---------------|--------------|
| **Type 0** | Invoking user | Any login | Lifecycle, diagnostics, convert (`sudoers-to-json` / `json-to-sudoers`), self-scoped submit, sidecar list/show, draft emit |
| **Type 1** | Elevated host mutation | root, or `sudoer-adm` via F6 (`SUDO_USER==sudoer-adm` and euid 0) | `setup` / `remove-lpu`; `approve` / `reject` / `interactive`; `list-approving --orphans` |
| **Type 2** | Dedicated system-user **execution** context | — | **Not used.** `sudoer-adm` is a **least-privilege-approver** (who may invoke F6), not an euid the CLI must switch into for `/etc` writes |

**Mandatory:**

1. Every exposed verb **MUST** have exactly one type.  
2. Type 1 **MUST** run with euid 0. Authorization for approve/reject/interactive is `SUDO_USER==sudoer-adm` **or** a real root session (`SUDO_USER` empty and `id -un` is root).  
3. The product **MUST NOT** `su` / `runuser` to `sudoer-adm` in order to write `/etc/sudoers.d`.  
4. Regular users **MUST NOT** receive an internal escalate path for approve/reject/setup.  
5. Type 2 execution context **MUST** remain **Not used** unless this requirement is revised.  
6. **Elev model (this product):** **EM-INT** — the only Table A Cmnd is the **global** ship unit (F6). After euid is 0, host writes use **Table C** jobs. There is no EM-EXT package/OS-tool sudoers allowlist. User-grant fragments under `/etc/sudoers.d/{{service}}-{{username}}` are **not** Table A and are **not** F6.  
7. A TTY login as `sudoer-adm` enters Type 1 **only** through F6 (`sudo -n` the **global** binary `interactive`). The LPU euid **MUST NOT** run `approve` / `reject` / `interactive`. Empty argv is not an elev path.

### 2.2 Table A — Sudoers Cmnd set (`print-sudoers` emit ⊆ A)

| ID | Job | Binary (absolute) | Fixed args | Dest | Invoker | Run-as | NOPASSWD | Sudoers line shape |
|----|-----|-------------------|------------|------|---------|--------|----------|--------------------|
| ELEV-F6-CLI | Approver runs all product verbs of the **global** ship unit | `/usr/local/bin/{{APP_NAME}}` | none (whole binary) | — | `sudo {{APP_NAME}} …` | root | yes | `{{LPU_USER}} ALL=(root) NOPASSWD: /usr/local/bin/{{APP_NAME}}` |

Rules:

1. `print-sudoers` / installed F6 fragment **MUST** emit **only** Table A.  
2. Production Pass **MUST** use the **global** managed binary (mode 0755, not writable by the LPU). Local `{{USER_BIN}}/{{APP_NAME}}` **MUST NOT** appear as a production Cmnd.  
3. Residual: whole-binary NOPASSWD includes Type 1 teardown. That residual **MUST** be stated; it is accepted for v1.

### 2.3 Table B — Forbidden elevations

| ID | Forbidden | Why |
|----|-----------|-----|
| FORB-01 | Recursive destroy via sudo except documented `userdel -r` of this LPU | Blast radius |
| FORB-02 | `/bin/sh`, `/bin/bash`, or unrestricted shell as **F6** Cmnd | Residual shell |
| FORB-03 | `ALL=(ALL) ALL` / `NOPASSWD: ALL` | Broad admin |
| FORB-04 | Package managers as F6 Cmnds | Wrong surface |
| FORB-05 | Writes outside product `/etc/sudoers.d` basenames (`{{LPU_USER}}` F6 and `{{service}}-{{username}}` user grants), backup tree, LPU home queues/hooks, `/var/backups/{{APP_NAME}}/` | Bound dest |
| FORB-06 | Elevate `{{USER_BIN}}/{{APP_NAME}}` or ad-hoc `/tmp` binaries | Trust tier |
| FORB-07 | Emitting `useradd` / `visudo` / `rm` as **sudoers Cmnds** | Those are Table C jobs after euid is already 0 |
| FORB-08 | Silent write of `/etc/sudoers.d` from Type 0 | Admin / Type 1 only |

### 2.4 Table C — Root-context jobs (not sudoers Cmnds)

After euid is 0 (setup/approve already authorized), the CLI **MAY** invoke fixed OS tools as **internal jobs**. These rows **MUST NOT** appear in `print-sudoers`.

| ID | Job | Typical tool | Bound dest / operand |
|----|-----|--------------|----------------------|
| JOB-USERADD | Create LPU | `useradd` | username/uid/gid/home from LPU law |
| JOB-MKDIR | Queue / backup dirs | `mkdir` | LPU home subtrees; `/var/backups/{{APP_NAME}}/` |
| JOB-CHMOD | Queue modes | `chmod` | 3773 approving; 0751 approved/rejected/home |
| JOB-VISUDO | Validate fragment | `visudo -cf` | private temp copy only |
| JOB-INSTALL | Install fragment | `install -m 0440` | F6 `{{LPU_USER}}` or user grant `{{service}}-{{username}}` only |
| JOB-RM | Remove product fragment | `rm` | those same product-owned names only |
| JOB-USERDEL | Teardown | `userdel -r` | this LPU only |

### 2.5 Fragment emit / install

1. Type 0 **MAY** emit a draft fragment and an admin install script under volatile storage. Type 0 **MUST NOT** write `/etc/sudoers.d`.  
2. Every sudoers write **MUST** pass `visudo -cf` on a private temp copy first.  
3. Installed fragments **MUST** be mode `0440`, owner `root:root`.  
4. Previous live fragments **MUST** be backed up before replace/remove.  
5. When `print-sudoers-install-script` is routed, the generated script **MUST** support `install` / `uninstall` / `replace` / `status`, require root for mutate actions, write only under volatile storage, and **MUST NOT** install as a Type 0 side effect.  
6. **Trust tier:** production = global managed binary not writable by the LPU; `test_local` = local-only binary — emit **MUST** warn TEST MODE / uninstall-soon; **MUST NOT** claim production-secure.

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **LPU username** | `sudoer-adm` |
| **F6 path** | `/etc/sudoers.d/sudoer-adm` |
| **Table A line** | `sudoer-adm ALL=(root) NOPASSWD: /usr/local/bin/sudoer-cli` |
| **Type 2** | Not used |
| **Routing status** | Type 1 verbs are routed and fail closed without euid 0. Live useradd/userdel, hook install, and `interactive` loop body not enabled. |
| **Test roots** | Fake `SUDOERS_D` only when `SUDOER_CLI_ALLOW_TEST_ROOTS=1` |
| **Elev model** | **EM-INT** (F6 whole-binary) |
| **User-grant dest** | `/etc/sudoers.d/{{service}}-{{username}}` (domain SSOT; same order as `{{APP_NAME}}-{{TARGET_USER}}`) |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 9 – Three Types of Commands**: every verb has one type.  
- **CIAO Principle 10 – Least-Privilege User**: F6 is one binary, not residual ALL.  
- **CIAO Principle 1 – Caution**: visudo before any `/etc` write.  
- **CIAO Principle 4 / 20 – Over-protect**: Table A vs Table C split is sacred.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: fail closed without global binary for production F6.  
- **Intentional**: approver authorizes; root euid writes.  
- **Anti-fragile**: draft outside `/etc`; visudo validate.  
- **Over-protect**: never emit `useradd` into sudoers because it appears in a job table.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Emit `ALL=(ALL) ALL`, `NOPASSWD: ALL`, or a shell as F6.  
2. Put Table C OS tools into Table A / `print-sudoers`.  
3. Collapse Type 2 into “run as root” or invent a Type 2 euid for `/etc` writes.  
4. Elevate the user-local binary for production Pass.  
5. Auto-write `/etc/sudoers.d` from Type 0.  
6. Advertise unrouted Type 1 verbs in `help` before they are dispatched.  
7. Treat a TTY login as `sudoer-adm` as euid-0 without F6, or hook a non-Table-A binary.

**Violating this rule is a critical privilege / LLM-escape regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-least-privilege-user.md` | LPU identity F1–F7 |
| `docs/requirements/requirement-domain-sudoer-approval.md` | File-based JSON approval + verb catalog |
| `docs/requirements/requirement-shell-cli-interface.md` | Dispatcher / Type 0 catalog |
| `./sudoer-cli` | Ship unit under test |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-13** | `tests/test_cli.sh` | have | Unrouted print-sudoers fails closed |
| **TP-SR-03** | `tests/test_domain_sr.sh` | have | visudo private copy; Table A ≠ user grant |
| **TP-SR-06** | `tests/test_domain_sr.sh` | have | `{{service}}-{{user}}` only |
| **TP-SR-PRIV-01** | `tests/test_domain_sr.sh` | have | Type 1 verbs fail closed without euid 0 |
| **TP-SR-INT-01** | `tests/test_domain_sr.sh` | todo | `interactive` without euid 0 → `authz` |

**Last Updated**: 2026-08-14  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
