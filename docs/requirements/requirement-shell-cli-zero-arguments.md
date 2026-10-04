**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.4.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the sudoer-cli POSIX `/bin/sh` Type 0 CLI.

### 1.0 Product type (template dual-model)

| Field | Value for sudoer-cli |
|-------|------------------------|
| **Empty-argv type** | **Type O — Online-install** off-TTY **plus** TTY numbered menu |
| **Rationale** | Product advertises `curl … \| sh` one-liner install. A pipe with no command is self-install. A real terminal keeps the numbered main menu. |

Type N (non-online-install → empty argv = help) does **not** apply to this product.

**Empty argv** means **no command token** after global-flag parse. Overlay switches (`--debug`, `--quiet`/`-q`, `--force`, `--global`) **do not** disqualify empty argv. `sudoer-cli --debug` **MUST** follow the same empty-argv law as `sudoer-cli` and as `DEBUG=1 sudoer-cli`. `$# -eq 0` at entry is **sufficient** but **not necessary**.

Off-TTY empty argv **MUST NOT** route to help. That path is how `curl -fsSL ${SCRIPT_URL} | sh` first-shot self-install works.

On a **real terminal**, empty argv **MUST** open the numbered start list owned by `requirement-shell-cli-default-interaction` (same handler as `menu` / `main`). Explicit `menu` / `main` remain live. That list includes row **5** languages (`requirement-shell-cli-language`).

**`--json` special case (still empty argv):** `sudoer-cli --json` with no command token **is** empty argv. Outcome **MUST** be **JSON help** — on a TTY **and** off-TTY. **MUST NOT** the numbered list. **MUST NOT** Type O self-install. Distinct from `sudoer-cli menu --json` on a TTY, which still ignores `--json` and draws the list.

It defines what happens when the tool is invoked with **no command and no flags**, including the classic one-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli | /bin/sh
```

Empty argv means **install-ensure** for three detect cases:

| Case | Meaning |
|------|---------|
| **Not installed** | No managed binary at the resolved install path(s) |
| **Installed (local)** | Managed binary at the user path (`USER_BIN` / `${HOME}/.local/bin/sudoer-cli`) |
| **Installed (global)** | Managed binary at the global path (`GLOBAL_BIN` / `/usr/local/bin/sudoer-cli`) |

**Scope:** Empty-argv routing, detect cases (global / local / absent), messages, force boundary, exit status, interaction with TTY / quiet / json.  
**Out of scope (own requirements):** Full command catalog (`requirement-shell-cli-interface.md`); download/checksum detail (`requirement-shell-automatic-checksum.md`); full self-update/uninstall lifecycle (`requirement-shell-self-management.md`); output function catalog (`requirement-shell-output-requirements.md`); general idempotency matrix beyond empty-argv rows (`requirement-shell-idempotency.md`).

### 1.1 Human-facing

**In one sentence:** Typing only `sudoer-cli` at a real terminal opens the numbered main menu (the same list as `sudoer-cli --debug`). Piping the script (`curl … | sh`) places the program or confirms it is already installed — it must not print help and must not open the menu.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the numbered list at a prompt, with or without `--debug` | `sudoer-cli` · `sudoer-cli --debug` |
| The other role | A pipe or a script with no command installs or no-ops | `curl -fsSL …/sudoer-cli \| /bin/sh` |
| Not this file | Row labels, language codes, checksum, update/uninstall | `requirement-shell-cli-default-interaction` · `requirement-shell-cli-language` |

| Includes | Excludes |
|----------|----------|
| No command token, including overlay switches (`--debug`, `--quiet`, `--force`, `--global`) | Domain verbs; `sudoer-cli menu` (that verb is the named list; off-TTY it prints help) |
| Not installed / already in user bin / already in system bin | Domain setup, host packages, dedicated-account ops |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | Program file people install | Live empty-argv behavior |
| `sudoer-cli` with no command | Command | TTY numbered menu; off-TTY self-install |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Start daily work at a prompt | Numbered list, including row **5** languages. It must not install. | `sudoer-cli` then a listed number or `99` |
| Start daily work with diagnostics | Same list. `[DEBUG]` on stderr. | `sudoer-cli --debug` |
| First install from the internet | No program is on disk yet. The pipe has no human to answer a question, so the tool **places itself** (user bin for a normal login; system bin if you already ran as root). Failure must be a real error, not a fake success. | `curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli \| /bin/sh` |
| Run the pipe again when it is already installed | Same one-liner **must succeed and say it is already installed**. It must not dump help and must not require `--force`. | `sudoer-cli` with no terminal (no command) |
| Ask for machine-readable usage | JSON help, even at a prompt. Not the list. Not self-install. | `sudoer-cli --json` |
| Quiet pipe with no command | No yes/no question. The tool still **places** the program (or no-ops if already installed). | `sudoer-cli --quiet` with no terminal |

Jargon: **Type O** (letter) means “a pipe with no command = self-install.” That is **not** Type **0** (digit: you run as yourself). A real terminal with no command is the numbered menu, not Type O.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Definitions (portable + project)

| Term | Definition for sudoer-cli |
|------|----------------------------|
| **Type O** | Online-install empty-argv product type: **off-TTY** empty argv = self-install (this product). |
| **Type N** | Non-online-install empty-argv type: empty argv = help — **out of scope** for sudoer-cli. |
| **Empty argv / zero-arg** | After global-flag parse, **no command token**. `$# -eq 0` is one form. Flags-only overlay argv (`sudoer-cli --debug`, `sudoer-cli --quiet`, `sudoer-cli --force`, `sudoer-cli --global`) is the same form. |
| **Install-ensure / self-install** | Off-TTY only. Converge to “managed `sudoer-cli` binary present”; either perform install or success no-op. |
| **Not installed** | `inst_is_installed` returns false (`inst_get_version` → `not installed`). |
| **Installed (local)** | Executable at `${USER_BIN}/sudoer-cli` (default `USER_BIN=${HOME}/.local/bin`) observed by install-detect SSOT. |
| **Installed (global)** | Executable at `${GLOBAL_BIN}/sudoer-cli` (default `GLOBAL_BIN=/usr/local/bin`) observed by install-detect SSOT. |
| **Force / reinstall** | `FORCE_REINSTALL=1` from `--force` (and related force wiring in `app_main`). Required only for deliberate replace, not for ensure. |

### 2.2 Split meaning of empty argv

1. **Empty argv** is: after global-flag parse, **no command token** was present. `$# -eq 0` at entry to `app_main` is one form. Flags-only overlay argv is the same form.  
2. **Interactive** (`TTY=1`): route to `app_main_menu` (numbered start list, including row **5** languages). **MUST NOT** self-install. **MUST NOT** print the help dump.  
3. **Not interactive** (`TTY=0`): **Type O self-install** (`inst_perform_install` / `inst_maybe_install` as in §2.4). **MUST NOT** print help. **MUST NOT** draw the numbered list. **MUST NOT** prompt on a pipe. Not installed → place. Already installed → success no-op (no `--force` required). `--force` re-downloads.  
4. Overlay switches with no command token **MUST** follow rules 2–3 (they **are** empty argv). `sudoer-cli --debug` **MUST** match `DEBUG=1 sudoer-cli`. `--quiet` / `-q`, `--force`, and `--global` with no command token **MUST** likewise follow empty argv.  
5. **`--json` special case:** `--json` with no command token **is** empty argv. Outcome **MUST** be JSON help on **TTY and off-TTY**. **MUST NOT** the numbered list. **MUST NOT** Type O self-install. `sudoer-cli menu --json` on a TTY remains the list (`requirement-shell-cli-default-interaction`).  
6. Explicit `sudoer-cli help` remains the full-usage path for help text.  
7. Bootstrap **MUST** always call `app_main "$@"` so pipe one-liners reach this contract (no `${0##*/}` product-name gate).  
8. Off-TTY empty argv **MUST NOT** require `install` or `install --force` merely because a previous ensure already succeeded.  
9. The dispatcher **MUST** decide empty argv **after** flag parse. **MUST NOT** use only `$# -eq 0` before parse so overlay flags fall through to default `COMMAND=help`.  
10. `app_lang_load` **MUST** run once after flag parse and before this branch, so the TTY menu and JSON help follow `APP_LANG`. Off-TTY self-install may load the same way (read-only; it does not create the language directory).

### 2.2.1 Specializee contract (bootstrap origin → specialized B)

When this product is used as **bootstrap origin A** for a specialized product **B** (A→B only; never reverse-copy):

| Rule | MUST | MUST NOT |
|------|------|----------|
| Empty argv on B | Keep **off-TTY Type O self-install**. A TTY menu is allowed only when this file says so | Hijack off-TTY empty argv for domain full-setup / host mutation / the review verb `interactive` |
| Domain setup verb | Use an explicit command (e.g. `run`, `setup`, domain verb catalog) | Treat bare `curl \| sh` / empty argv as host domain install |
| Case A helper | If B copies `inst_maybe_install` as first-install SSOT, quiet/json **MUST** call `inst_perform_install` and return its status | Copy a helper that `return 0` under quiet/json without placing the binary |
| Tests | Isolate `HOME`, `USER_BIN`, and **`GLOBAL_BIN`** so host `/usr/local/bin/${APP_NAME}` does not shadow lifecycle CI | Assume empty `HOME` alone hides a real global install |

**Rationale:** Specializees that rebind empty argv to interactive host setup break the online-install contract and confuse install-ensure with domain ops. Host-mutating domain work belongs under explicit verbs with privilege gates (see CLI interface specializee contract).

### 2.3 Normative case matrix

| Case | Detect condition (project) | Off-TTY empty argv, `FORCE_REINSTALL=0` | Off-TTY empty argv / install with force |
|------|----------------------------|--------------------------------|---------------------------------|
| **A. Not installed** | `inst_is_installed` false | Install into privilege-correct path (§2.4) | Same first-time install |
| **B. Installed — local** | User binary present via detect SSOT | Success no-op: already installed; no re-download; **no help** | `inst_perform_install` re-download/replace (user path when non-root) |
| **C. Installed — global** | Global binary present via detect SSOT | Success no-op: already installed; no re-download; **no help** | Re-download/replace (global path when root / global binary policy) |

**TTY empty argv (any detect case, force off, `--json` off):** numbered start list. **MUST NOT** install. **MUST NOT** print help.

**Already-installed rules (Cases B and C, force off, off-TTY):**

1. Exit status **MUST** be `0`.  
2. Human mode **MUST** use `out_success` with an **already installed** message (via `inst_perform_install` no-op path).  
3. Human mode **MAY** add `out_info` tips that `--force` / `self-update` are for **deliberate** reinstall or upgrade — **MUST NOT** imply force is required for a normal one-liner re-run.  
4. JSON mode **MUST** use structured success (`out_json` success type) with already-installed message — **MUST NOT** emit help JSON.  
5. Detect **MUST** treat either global or local managed binary as installed when that is how `inst_is_installed` / `inst_get_version` resolve paths (project SSOT today prefers global when executable there, else user path).

### 2.4 Case A — not installed (modes)

When **no managed binary** is present and the invocation is **off-TTY**, empty argv **MUST** place the program (or fail closed). People picture:

| Mode | What a person sees | What MUST happen |
|------|--------------------|------------------|
| **Interactive** (real terminal, not `--json`) | The numbered main menu | `app_main_menu`. **MUST NOT** ask the install yes/no on this path |
| **Non-interactive** (no terminal / `curl \| sh`) | An auto-install message | Place the program (`inst_maybe_install` non-TTY branch → `inst_perform_install`) |
| **Quiet, off-TTY** | No question | `inst_perform_install` (no prompt). Failure **MUST** be non-zero. **MUST NOT** return success without placing. |
| **`--json`, no command** | JSON help | **MUST NOT** place. **MUST NOT** draw the list. TTY and off-TTY. |
| **Failure** (network, checksum, I/O) | An error | Non-zero exit; no fake success; no help-only output |

**Dispatcher vs helper (same outcome):**

| Path | Quiet, off-TTY, not installed | Human TTY, no command | Pipe, not installed |
|------|-------------------------------|------------------------|---------------------|
| `app_main` empty argv | **MUST** call `inst_perform_install` directly | **MUST** call `app_main_menu`. **MUST NOT** install | **MUST** auto-install (helper non-TTY branch or direct place) |
| `inst_maybe_install` itself | **MUST** call `inst_perform_install` and return its status. **MUST NOT** `return 0` without placing | Note + `prompt_yes_no` when a caller still uses the helper | Auto-install message + place |

Off-TTY quiet empty argv in `app_main` is **not** a license for the helper to no-op. `--json` with no command is **not** this install path. Products copied from this bootstrap that route Case A **only** through the helper **MUST** still place the binary under quiet/json.

**Placement privilege:**

| Invoker | Target |
|---------|--------|
| root (`id -u` 0), e.g. `curl … \| sudo sh` | `${GLOBAL_BIN}/sudoer-cli` → `/usr/local/bin/sudoer-cli` |
| non-root | `${USER_BIN}/sudoer-cli` → `${HOME}/.local/bin/sudoer-cli` |

### 2.5 Equivalence to explicit `install`

| Invocation | Contract |
|------------|----------|
| Off-TTY empty argv | Same ensure semantics as `install` for Cases A/B/C |
| TTY empty argv | Numbered menu. **Not** `install` |
| `install` | Explicit ensure; same detect / no-op / force |
| `install --force` | Deliberate reinstall |
| `help` | Usage only — **not** empty-argv default |

### 2.6 Forbidden empty-argv outcomes

1. Dump full help when off-TTY Case B or C applies.  
2. Silent success when off-TTY Case A should install (or when off-TTY Case B/C should acknowledge already installed).  
3. Require `--force` solely because detect says installed.  
4. Blind re-download every off-TTY empty-argv run without force.  
5. Basename-gate main so `curl \| sh` never hits the empty-argv branch.  
6. Detect only one of global/local incorrectly so a present local install is treated as Case A (or the reverse) contrary to `inst_*` SSOT.  
7. Silent success from `inst_maybe_install` under quiet/json when Case A should place the binary.  
8. Draw the numbered menu on off-TTY empty argv, or hang a pipe.  
9. Replace TTY empty argv with help or with self-install.  
10. Treat flags-only `--debug` / `--quiet` / `--force` / `--global` as help.  
11. Treat flags-only `--json` as self-install or as the TTY numbered list.  
12. Decide empty argv with only `$# -eq 0` before flag parse.

### 2.7 Implementation Notes (this project)

| Item | Value for sudoer-cli |
|------|------------------------|
| **Empty-argv type** | **Type O** off-TTY self-install; TTY numbered menu (not Type N help-default) |
| **Product / binary** | `sudoer-cli` (`APP_NAME`) |
| **Ship unit** | Repo root `src/sudoer-cli` |
| **Dispatcher** | `app_main` — empty argv **after** flag parse. TTY → `COMMAND=menu`. Off-TTY → `COMMAND=ensure` (install functions, not a public verb). `--json` no command → `COMMAND=help` |
| **Install ensure** | Off-TTY `inst_perform_install` (quiet and already-installed no-op; `--force` re-downloads) |
| **Friendly first install** | Off-TTY, not quiet, not installed: `inst_maybe_install` (pipe auto). Quiet **MUST** call `inst_perform_install` (SM-BUG-01 fixed 2026-09-02). TTY empty argv does **not** call these. |
| **Detect SSOT** | `inst_is_installed` ← `inst_get_version` |
| **Global path** | `GLOBAL_BIN` default `/usr/local/bin` |
| **Local path** | `USER_BIN` default `${HOME}/.local/bin` |
| **Force wiring** | `--force` → `FORCE=1` and `FORCE_REINSTALL=1` in `app_main` |
| **Output SSOT** | `out_success` / `out_info` / `out_json` / errors via `out_*` |
| **Channel** | `SCRIPT_URL` (compose from `REPO_USER` / `REPO_NAME` / `APP_NAME`) for download path inside install |
| **Tests** | `tests/test_cli.sh` (**TP-CLI-07** off-TTY Case A; TTY list; **TP-CLI-29** overlay `--debug` / `--quiet`; `--json` JSON help); `tests/test_local_lifecycle.sh` (Case B local + Case C global already-installed → not help; **TP-LC-18** / **TP-INST-MAYBE-01** helper under QUIET/JSON). |

#### Dispatcher algorithm (normative sketch)

```text
app_main:
  parse global flags and command tokens
  app_lang_load once
  if no command token:
    if JSON:
      app_help; return          # JSON help; TTY and off-TTY
    elif TTY:
      app_main_menu; return     # numbered list; includes --debug
    elif QUIET or FORCE or installed:
      inst_perform_install; return
    else:
      inst_maybe_install; return   # pipe auto-install
  else:
    app_run_command
```

#### Message contract (already installed, human)

- Success: `${APP_NAME} is already installed.` (or equivalent via `out_success`)  
- Optional info: force / `self-update` only for deliberate reinstall or upgrade  
- **MUST NOT** print the full `app_help` usage body on the off-TTY ensure path
- TTY empty argv **MUST NOT** print this already-installed line (it draws the menu)

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): One-liner re-runs must not look like broken install or force unnecessary reinstall.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): A pipe installs. A prompt is the daily list. Overlay switches do not change that meaning.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Dual install paths + `curl \| sh`.  
- **CIAO Principle 6 – Single Point of Entry** (https://github.com/cloudgen/ciao): `app_main` owns empty-argv after flag parse, before help default.  
- **CIAO Principle 16 – Interactive vs Non-Interactive** (https://github.com/cloudgen/ciao): Numbered list only when `TTY=1`. Off-TTY must not hang.  
- **CIAO Principle 4 (O) / Principle 20 – Over-protect / Protect Against AI & Human Modification** (https://github.com/cloudgen/ciao): Protection Rule against help-fallback regression.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Real failures non-zero; healthy re-runs success with clear text.  
- **Intentional:** Help is never the empty-argv default for this install CLI.  
- **Anti-fragile:** Global and local detect; idempotent second one-liner.  
- **Over-protect:** Do not “simplify” empty-argv back to `COMMAND:=help` after first install.  
- **SSOT:** `inst_is_installed` / `inst_perform_install` / `inst_maybe_install` / `out_*`.  
- **Idempotent ensure:** Case B/C force off → already installed, exit 0.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route off-TTY empty argv to `app_help` when Case B or C applies (or when Case A should install).  
2. Require `--force` for a healthy already-installed off-TTY empty-argv re-run (local or global).  
3. Handle only Case A and leave B/C as accidental help fallthrough.  
4. Break dual-path detect so local or global installs are misclassified.  
5. Blindly reinstall on every off-TTY empty-argv run without `FORCE_REINSTALL`.  
6. Exit 0 with no install and no already-installed acknowledgment when off-TTY detect says installed.  
7. Reintroduce a basename-only gate that skips `app_main` under `curl \| sh`.  
8. Bypass `out_*` for empty-argv user messages.  
9. Contradict this file in peer requirements by documenting “already installed → help” or “TTY empty argv → self-install” as normative.  
10. Let `inst_maybe_install` return success under quiet/json when Case A should place the binary (silent skip).  
11. Copy this helper into a specialized product as Case A SSOT while keeping a quiet/json `return 0` without `inst_perform_install`.  
12. Draw the numbered menu on off-TTY empty argv, or hang a pipe.  
13. Replace TTY empty argv with help or with self-install.  
14. Treat overlay flags-only (`--debug`, `--quiet`/`-q`, `--force`, `--global`) as help or as a third meaning. `sudoer-cli --debug` **MUST** be empty argv.  
15. Treat flags-only `--json` as Type O self-install, or as the TTY numbered list. It **is** empty argv; the special-case outcome is JSON help (TTY and off-TTY).  
16. Use only `$# -eq 0` before flag parse so overlay flags fall through to default `COMMAND=help`.  
17. Turn TTY empty argv into the review verb `interactive`. The TTY path is the numbered menu.

**Violating this rule is a critical zero-arg / online-install regression.**

---

## 5. Definition of done

This requirement is satisfied when all of the following hold:

1. Off-TTY empty argv + not installed → Case A install path (pipe auto; quiet auto). Quiet through the helper **MUST** place or fail closed — not `return 0` without install.  
2. Off-TTY empty argv + local install present + force off → already-installed success; not help; no re-download.  
3. Off-TTY empty argv + global install present + force off → already-installed success; not help; no re-download.  
4. Off-TTY empty argv + install failure → non-zero exit.  
5. `--force` only for deliberate reinstall; not required for ensure.  
6. `help` works when invoked explicitly.  
7. TTY empty argv, including `sudoer-cli --debug`, draws the numbered list and does not install.  
8. Flags-only `--json` is JSON help on a TTY and off-TTY.  
9. Tests cover Case A failure (not installed, bad channel), already-installed not-help for local (Case B) and global (Case C), and **TP-CLI-29**.  
10. **TP-LC-18** / **TP-INST-MAYBE-01:** not installed + QUIET/JSON through `inst_maybe_install` places or fail closed.  
11. Changes cite `requirement-shell-cli-zero-arguments`.

### Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | have (off-TTY dead channel non-zero, not help; TTY empty argv is the numbered list) |
| **TP-CLI-29** | `tests/test_cli.sh` | have (overlay `--debug` / `--quiet` follow empty argv; `--json` stays JSON help) |
| **TP-LC-11** | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-14** | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-15** | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-18** / **TP-INST-MAYBE-01** | `tests/test_local_lifecycle.sh` | have |
| **TP-CURL-02** | `tests/test_online_curl_install.sh` | have |
| **TP-CURL-03** | `tests/test_online_curl_install.sh` | have |
| **TP-CURL-08** | `tests/test_online_curl_install.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## Under command line for normal user only

This product may run on Termux, Git Bash, Windows cmd, or the same class (this login only).

**This requirement:** a pipe with no command still means **install or re-check install for this login**. On a real terminal, no command (including `--debug`) opens the numbered menu as this login. On that class, off-TTY Case A **MUST** place into `USER_BIN` (this login). **MUST NOT** escalate, wrap `sudo`, or recommend `sudo curl | sh` as the empty-argv path there. Git Bash and Windows cmd **MUST NOT** invoke Termux `pkg`.

| MUST | MUST NOT |
|------|----------|
| Empty-argv ensure as this login | Empty argv that tries to become root on Termux / Git Bash / Windows cmd |
| Quiet/json helper still places or fail closed | Add an admin-privilege empty-argv branch |

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-cli-interface.md` | Full command surface; empty-argv row must match this SSOT |
| `docs/requirements/requirement-shell-idempotency.md` | Ensure re-run / force boundary |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY vs pipe for Case A |
| `docs/requirements/requirement-shell-self-management.md` | self-update / uninstall (not empty-argv default) |
| `docs/requirements/requirement-shell-output-requirements.md` | out_* / JSON purity |
| `docs/requirements/requirement-shell-automatic-checksum.md` | Integrity on install download path |
| Repo root `src/sudoer-cli` | Implementation (`app_main`, `inst_*`) |
| `tests/test_cli.sh`, `tests/test_local_lifecycle.sh`, `tests/test_online_curl_install.sh` | Regression coverage |

---

## 7. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-07-14 | Initial Active v1.0.0: empty argv = install-ensure for not-installed / local / global; forbid help fallthrough | Grok (owner request) |
| 2026-07-14 | v1.1.0: Classify product as Type O (online-install) under dual-type empty-argv template model | Grok |
| 2026-08-11 | v1.2.0: Specializee contract — empty argv stays Type O; domain setup uses explicit verbs; test GLOBAL_BIN isolation | Grok (gitlab-nginx specialize reflection) |
| 2026-09-08 | v1.3.0 | Quiet/json helper places or fail closed (SM-BUG-01) |
| 2026-10-04 | v1.4.0 | Empty argv = no command token. TTY (including `--debug`) opens the numbered menu. Off-TTY stays self-install. `--json` with no command is JSON help. |

---

**Last Updated**: 2026-10-04  
**Owner**: sudoer-cli project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO Principles 1, 2, 3, 6, 16, 4, 20 (v2.10.2) (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

