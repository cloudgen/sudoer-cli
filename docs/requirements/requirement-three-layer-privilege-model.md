**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.12.0)  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**id**: RQ-THREE-LAYER-PRIVILEGE-MODEL  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **Type 0 / Type 1 / Type 2 privilege map**, the **elev Tables A/B/C**, and the **sudoers-fragment emit/install contract** of this product.

Domain verbs that *use* elevation are catalogued in `requirement-domain-sudoer-approval.md`. Type 0 submit vs Type 1 approve is the privilege split of that file-based JSON approval machine. They **MUST NOT** invent a second elev table. This file owns the Type map and the Cmnd set that `print-sudoers` may emit.

The **closed catalog** of what the product blocks — and what it **must not** block after elev — is owned by `requirement-privilege-prevention-set.md`. This file **MUST NOT** grow a parallel unpublished wall.

### 1.1 Human-facing

**In one sentence:** A normal login converts and queues. A host admin who already used password sudo may set up the dedicated account and decide inbound files.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Convert and submit without becoming root | `sudoer-cli add-sudoer-request --file request.json` |
| The other role | Already-root host admin, or `sudoer-adm` after setup | `sudo sudoer-cli setup` |
| Not this file | Prevention catalog; dest Fence body | `requirement-privilege-prevention-set` · `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Who may run what; extra sudoers fragment is an extra path, not the only approver | Requiring `SUDO_USER` to be `sudoer-adm` after password sudo; Type 2 dest-write |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | elev tables |
| `sudoer-cli print-sudoers` | command | fragment text only |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Set up once | Password sudo is the approval for setup. The extra fragment is for later review without a password. | `sudo sudoer-cli setup` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map

| Layer | Privilege | Typical actor | This product |
|-------|-----------|---------------|--------------|
| **Type 0** | Invoking user | Any login | Lifecycle, diagnostics, convert (`sudoers-to-json` / `json-to-sudoers`), submit (A may name B; filename uses B), sidecar list/show, draft emit |
| **Type 1 bootstrap** | Elevated host mutation | **Any** host admin already euid 0 (`sudo {{APP}} setup` — **password sudo OK**) | `setup` / `remove-lpu`. F6 / `sudoer-adm` **must not** be required (chicken-egg). |
| **Type 1 approve** | Elevated host mutation | **Any** host admin already euid 0 (password `sudo` — `SUDO_USER` may be any login); **or** `sudoer-adm` via F6; **or** a real root login | `approve` / `reject` / `interactive`; `list-approving --orphans`. F6 is an extra path, not the exclusive one |
| **Type 2** | Dedicated system-user **execution** context | — | **Not used.** `sudoer-adm` is a **least-privilege-approver** (who may invoke F6), not an euid the CLI must switch into for dest writes |

**Mandatory:**

1. Every exposed verb **MUST** have exactly one type.  
2. Type 1 **MUST** run with euid 0. **Bootstrap** (`setup` / `remove-lpu`) **MUST** accept **any** euid-0 session (`SUDO_USER` may be any host admin). **Approve** (`approve` / `reject` / `interactive`) **MUST** accept the same: **any** already euid-0 host admin (password `sudo`), **or** `SUDO_USER==sudoer-adm` via F6, **or** a real root session. **MUST NOT** fail because `SUDO_USER` is a host admin other than `sudoer-adm`. The LPU **euid** without `sudo` still fails (not euid 0).  
3. The product **MUST NOT** `su` / `runuser` to `sudoer-adm` in order to write dest. **MUST NOT** write `/etc/passwd` or `/etc/sudoers` (main file). Type 1 **MAY** copy, overwrite, and remove **product-owned** files under `/etc/sudoers.d/` (F6 `sudoer-adm`; grant `{{service}}-{{username}}`). Type 0 **MUST NOT** write `/etc/sudoers.d`. LPU home is `/etc/{{LPU_USER}}/`.  
4. **Mix model (EM-HYB).** The ship unit **MAY** invoke password `sudo` when it needs elev. **`sudo -n` is not suggested** (no NOPASSWD ticket as the default). Usual human path: `sudo {{APP}} setup` (password OK). Do **not** document bootstrap as `sudo -n`. Table C jobs are **`sudo useradd` / `sudo userdel` inside the script** — they are **not** sudoers Cmnds.  
5. Type 2 execution context **MUST** remain **Not used** unless this requirement is revised.  
6. **Elev model (this product):** **EM-HYB**. **Bootstrap** = password `sudo` (outer **or** in-tool; any host admin). **Day-to-day F6** = NOPASSWD on the **global** ship unit only. After euid is 0, host writes use **Table C** jobs. There is no package/OS-tool sudoers allowlist. User-grant files under `/etc/sudoers.d/{{service}}-{{username}}` are **not** Table A and are **not** F6.  
7. A TTY login as `sudoer-adm` enters approve Type 1 **only** through F6. The login hook **MAY** use `sudo -n` **only after F6 exists** (so `.bashrc` does not hang). That is the only specified `-n`. `sudo -n` is **not** the bootstrap elev and **MUST NOT** be written as `sudo -n {{APP}} setup`. The LPU euid **MUST NOT** run `approve` / `reject` / `interactive`. Empty argv is not an elev path.  
8. Install is **multi-user**: any login may local-install; any host admin may global-install and bootstrap. Do **not** treat `sudoer-adm` as the only installer.  
9. **Elev is approval.** Password `sudo` or a root login **is** the operator’s approval for that Type 1 invocation — **setup and approve alike**. **MUST NOT** invent a second lock (including `SUDO_USER` must be `sudoer-adm` on approve). Sensitive undo-hard steps **MUST** use TTY confirm or `--force` only. **No invented live-command whitelist.** Table A is **only** the F6 sudoers line. Table B is **sudoers-forbidden**, **not** a live-command denylist. **No denylist ⇒ no extra restrict:** Type 1 `setup` **MAY** invoke the OS tools it needs (`sudo useradd`, `mkdir`, `visudo`, …). The closed block / must-remain-open rows are `requirement-privilege-prevention-set.md`.

### 2.2 Table A — F6 sudoers lines only (not a live-command whitelist)

| ID | Job | Binary (absolute) | Fixed args | Dest | Invoker | Run-as | NOPASSWD | Sudoers line shape |
|----|-----|-------------------|------------|------|---------|--------|----------|--------------------|
| ELEV-F6-CLI | Approver runs all product verbs of the **global** ship unit | `/usr/local/bin/{{APP_NAME}}` | none (whole binary) | — | `sudo {{APP_NAME}} …` | root | yes | `{{LPU_USER}} ALL=(root) NOPASSWD: /usr/local/bin/{{APP_NAME}}` |

Rules:

1. `print-sudoers` / installed F6 fragment **MUST** emit **only** Table A.  
2. Production Pass **MUST** use the **global** managed binary (mode 0755, not writable by the LPU). Local `{{USER_BIN}}/{{APP_NAME}}` **MUST NOT** appear as a production Cmnd.  
3. Residual: whole-binary NOPASSWD includes Type 1 teardown. That residual **MUST** be stated; it is accepted for v1.

### 2.3 Table B — Forbidden **in the F6 fragment** (not a live-command denylist)

| ID | Forbidden | Why |
|----|-----------|-----|
| FORB-01 | Recursive destroy via sudo except documented `userdel -r` of this LPU | Blast radius |
| FORB-02 | `/bin/sh`, `/bin/bash`, or unrestricted shell as **F6** Cmnd | Residual shell |
| FORB-03 | `ALL=(ALL) ALL` / `NOPASSWD: ALL` | Broad admin |
| FORB-04 | Package managers as F6 Cmnds | Wrong surface |
| FORB-05 | Writes outside product `/etc/sudoers.d` names (F6 `{{LPU_USER}}`, grant `{{service}}-{{username}}`), live LPU home, `/etc/sudoers.bak/`, `/var/backups/{{APP_NAME}}/`, `/var/{{APP_NAME}}/` | Bound dest |
| FORB-06 | Elevate `{{USER_BIN}}/{{APP_NAME}}` or ad-hoc `/tmp` binaries | Trust tier |
| FORB-07 | Emitting `useradd` / `visudo` / `rm` as **sudoers Cmnds** | Account create is **`sudo useradd` inside the ship unit**, not a grant in F6 / `print-sudoers` |
| FORB-08 | Write `/etc/passwd` or `/etc/sudoers` (main) from any type; Type 0 write `/etc/sudoers.d`; Type 1 write a **foreign** sudoers.d name | Use `useradd`/`userdel`; Type 1 may copy/overwrite/remove product-owned sudoers.d names |

### 2.4 Table C — Root-context jobs (not sudoers Cmnds)

The CLI invokes these as **internal jobs**. Account create/teardown **MUST** be `sudo useradd` / `sudo userdel` (password `sudo`; **not** `sudo -n`). These rows **MUST NOT** appear in F6 or `print-sudoers`.

| ID | Job | Typical tool | Bound dest / operand |
|----|-----|--------------|----------------------|
| JOB-USERADD | Create LPU | `sudo useradd` | username/uid/gid/home from LPU law |
| JOB-MKDIR | Queue / backup dirs | `mkdir` | `/var/{{APP_NAME}}/` + children; LPU home views; `/var/backups/{{APP_NAME}}/` |
| JOB-CHMOD | Queue modes | `chmod` | public root 0755; inbound 3773; approved/rejected 0700; home 0751; submit files 0640 |
| JOB-CHOWN | Request file owner | `chown` | Type 1 approve/reject → `{{LPU_USER}}:{{LPU_USER}}` |
| JOB-VISUDO | Validate fragment | `visudo -cf` | private temp copy only |
| JOB-INSTALL | Install fragment | `install -m 0440` | F6 `{{LPU_USER}}` or user grant `{{service}}-{{username}}` only |
| JOB-RM | Remove product fragment | `rm` | those same product-owned names only |
| JOB-USERDEL | Teardown | `sudo userdel -r` | this LPU only |

### 2.5 Fragment emit / install

1. Type 0 **MAY** emit a draft fragment and an admin install script under volatile storage. Type 0 **MUST NOT** write `/etc/passwd`, `/etc/sudoers`, or `/etc/sudoers.d`. Type 1 dest is `/etc/sudoers.d/{{service}}-{{username}}` (copy / overwrite / remove).  
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
| **Routing status** | Type 1 `setup`/`remove-lpu` live (useradd/userdel, F6, hook). Approve dest write when authorized. `interactive` loop live (ids not on stdin). |
| **Test roots** | Fake `SUDOER_CLI_GRANT_ROOT` only when `SUDOER_CLI_ALLOW_TEST_ROOTS=1` |
| **Elev model** | **EM-HYB** mix — password `sudo` OK (outer or in-tool); `-n` not suggested; F6 NOPASSWD after grant exists |
| **User-grant dest** | `/etc/sudoers.d/{{service}}-{{username}}` (domain SSOT; Type 1 copy/overwrite/remove exception) |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 9 – Three Types of Commands**: every verb has one type.  
- **CIAO Principle 10 – Least-Privilege User**: F6 is one binary, not residual ALL.  
- **CIAO Principle 1 – Caution**: visudo before dest copy/overwrite under `/etc/sudoers.d/`.  
- **CIAO Principle 4 / 20 – Over-protect**: Table A vs Table C split is sacred.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: fail closed without global binary for production F6.  
- **Intentional**: approver authorizes; root euid writes.  
- **Anti-fragile**: draft outside `/etc/passwd` and `/etc/sudoers.d`; visudo validate.  
- **Over-protect**: never emit `useradd` into sudoers because it appears in a job table.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Emit `ALL=(ALL) ALL`, `NOPASSWD: ALL`, or a shell as F6.  
2. Put Table C OS tools into Table A / `print-sudoers`.  
2a. Invent a **live-command whitelist** or a **live-command denylist** the user did not publish. **No denylist ⇒ no restrict** on live tools the Type 1 job needs.  
3. Collapse Type 2 into “run as root” or invent a Type 2 euid for dest writes.  
4. Elevate the user-local binary for production Pass.  
5. Write `/etc/passwd` or `/etc/sudoers` (main), or ban this product’s Type 1 copy/overwrite/remove of product-owned `/etc/sudoers.d` names.  
6. Advertise unrouted Type 1 verbs in `help` before they are dispatched.  
7. Treat a TTY login as `sudoer-adm` as euid-0 without F6, or hook a non-Table-A binary.  
8. Require `SUDO_USER==sudoer-adm` for `setup` / `remove-lpu` (F6 does not exist yet), **or** for `approve` / `reject` / `interactive` after password `sudo`. That actor check is blockage, not help.  
9. Write bootstrap / first-time setup as `sudo -n`. **`sudo -n` is not suggested** except the F6 login hook.  
10. Treat “mix model” as a ban on in-tool password `sudo`, or as a ban on Table C `useradd` after euid 0.  
11. Add a product block that is not a row in `requirement-privilege-prevention-set.md`, or close a must-remain-open row in that file.

**Violating this rule is a critical privilege / LLM-escape regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-least-privilege-user.md` | LPU identity F1–F7 |
| `docs/requirements/requirement-privilege-prevention-set.md` | Closed catalog of what is blocked vs must stay open |
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
| **TP-SR-PRIV-02** | `tests/test_domain_sr.sh` | have | Bootstrap setup ≠ F6; not `sudo -n`; not only `sudoer-adm` |
| **TP-SR-PRIV-03** | `tests/test_domain_sr.sh` | have | Live setup body: useradd, collision, F6, hook (static) |
| **TP-SR-PRIV-04** | `tests/test_domain_sr.sh` | have | Approve gate has no exclusive-`sudoer-adm` actor lock (OPEN-ELEV) |
| **TP-ELEV-09** | `tests/test_domain_sr.sh` | have | Alias of TP-SR-PRIV-04 / TP-PREV-03 |
| **TP-SR-INT-01** | `tests/test_domain_sr.sh` | have | `interactive` without euid 0 → `authz` |

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
