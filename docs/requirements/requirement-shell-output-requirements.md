**file**: docs/requirements/requirement-shell-output-requirements.md  
**Status**: Active (Version 1.4.0) — skip/warn that still needs action fills happened / Next: (login-hook `sudo -n` fail)  
**Area**: shell  
**Key**: `requirement-shell-output-requirements`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **all CLI output** of sudoer-cli: human messages, machine JSON, channel split (stdout vs stderr), and mode behavior (normal / quiet / JSON / debug).

This origin owns the `out_*` family. Domain verbs **MUST** use the same `out_*` family (convert/submit messages are live).

### 1.1 Human-facing

**In one sentence:** Status lines come from one printer. Blocking errors **and** skip/warn lines that still need a next step say what happened and what to type next.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Read human status and Next: on fatals | `sudoer-cli version` |
| The other role | Machine JSON is status, not the grant file | `sudoer-cli --json version` |
| Not this file | Grant JSON in the waiting folder | `requirement-domain-sudoer-approval` |

| Includes | Excludes |
|----------|----------|
| `out_*`; colors consume TTY; operator fatals include Next:; skip/warn that still needs action includes Next: | A second printer family; JSON status as the queued grant; a skip line that only says “skipped” |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | `out_*` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See a fatal | The line names the problem in people words, then Next: a command. | `sudoer-cli nosuch` |
| Login as `sudoer-adm` and review did not start | The skip line says the passwordless grant is missing, you still have a shell, and Next: a host-admin command. | `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Sacred core rule

**All user-facing and machine-facing product output MUST go through the centralized output system.**

| Forbidden outside the output module | Prefer |
|-------------------------------------|--------|
| Raw `echo` / bare `printf` for **user messages** | `out_info`, `out_success`, `out_warn`, `out_error`, `out_plain`, … |
| Direct `printf` of JSON from command logic | `out_json` / `out_json_error` |
| Ad-hoc `echo >&2` diagnostics | `out_warn` / `out_error` / `out_debug` |
| Second parallel print helper that bypasses mode guards | Extend `out_text` / wrappers only |

### 2.1.1 Allowed `printf` / `echo` exceptions

| Exception class | Rule |
|-----------------|------|
| **A. Inside output SSOT** | Only `out_text`, `out_json`, and `out_json_error` may `printf` to fd 1/2 for product human or JSON lines |
| **B. Function return-via-stdout** | Helpers may `printf '%s' "$value"` solely for `$(…)` capture (data return, not UI) |
| **C. File I/O (redirected)** | Writing install staging files is file mutation; user-visible status still via `out_*` |
| **D. Tool protocol / computation pipes** | e.g. feeding `tar`/`gzip`/`sha256sum` via pipes; product status still via `out_*` |
| **E. Command-sub fallbacks** | Logic defaults only (`id -un \|\| echo "unknown"`) |
| **F. Planted login-rc snippet** | `.bashrc` / `.profile` hook **MAY** `printf` to stderr when `sudo -n` fails (the CLI is not running). Copy **MUST** still fill happened / means / Next: (`requirement-login-interactive-review-hook`). **MUST NOT** print only `interactive hook skipped`. |

### 2.2 Output function catalog

| Function | Purpose | Typical channel | Quiet | JSON |
|----------|---------|-----------------|-------|------|
| `out_text` | SSOT for human levels | Level-dependent | Filters | Suppress all human levels |
| `out_info` | Informational | stdout | Suppress | Suppress human |
| `out_success` | Success / OK | stdout | Suppress | Suppress human |
| `out_warn` | Warning | stderr | Should still show | Prefer structured status when designed |
| `out_error` | Error | stderr | Always show (human) | Prefer `out_json_error` / `out_die` |
| `out_die` | Fatal + exit 1 | stderr (+ JSON error when JSON) | Always | Emits JSON error then exits |
| `out_plain` | Plain text, no prefix | stdout | Suppress under quiet | Suppress under JSON |
| `out_menu_choice` | Numbered menu row; TTY *italic* + light-gray explain (default-cli-main-menu-style) | stdout | Suppress under quiet | Suppress under JSON |
| `util_app_ident` | Identity token **bold** name / *italic* version (`APP_NAME(VERSION)`); pipeline capture into `out_*` | pipeline | n/a | plain when JSON |
| `out_msg_n` | Prompt fragment without newline | stdout | Suppress under quiet/json | Never for machines |
| `out_json` | Machine success/status object | stdout | N/A | Only when `JSON=1` |
| `out_json_error` | Machine error object | as designed for fatal path | N/A | Only when `JSON=1` |

### 2.3 Channel contract

| Channel | Allowed content (via `out_*` only) |
|---------|-------------------------------------|
| **stdout (fd 1)** | Human info/success/plain in normal mode; **exactly one** JSON value in JSON mode for success/status |
| **stderr (fd 2)** | Errors, warnings, debug/diagnostics |

Rules:

1. Fatal paths use `out_die` / `out_json_error`. Operator-facing fatals **MUST** fill these slots (order recommended):

| Slot | Required | Meaning |
|------|----------|---------|
| **What happened** | yes | One concrete sentence a person who just ran the command can parse |
| **What it means** | SHOULD | Plain restatement if the first sentence uses a product noun |
| **What to do next** | yes | A pasteable **`Next:`** command, a path, or who to ask |
| **Do not** | when dangerous | Only if a wrong next step exists |

**MUST NOT** emit only `Type 1` / `euid 0` / `authorization failed` / “host validation”. JSON `message` **MUST** be the same operator sentence. Quiet **MUST** still show the error.

**Worked visudo-fail** (grant text dual — body on `requirement-sudoers-file`): **What happened** `visudo rejected this grant` (quote visudo’s syntax line). **What it means** the sudoers file would be illegal; do not approve. **Next:** `json-to-sudoers --file …`. **Do not** say “host validation”.

**Operator-facing skip / warn that still needs action** (login continues; not `out_die`): the same three slots **MUST** fill. Printer is `out_warn` when the CLI is running. Planted login-rc **MAY** `printf` (exception **F**).

| Slot | Login-hook `sudo -n` fail (this product) |
|------|------------------------------------------|
| **What happened** | Login review did not start. |
| **What it means** | `sudoer-adm` cannot run the review command without a password (the passwordless grant is not installed yet). You still have a shell. |
| **What to do next** | `Next: from a host admin, run: sudo sudoer-cli interactive` |
| **Do not** | Do not print only `interactive hook skipped`. Do not `exit` the login shell. |

2. JSON mode: no colors, banners, or progress mixed into stdout JSON.  
3. Capture pattern: `sudoer-cli --json <cmd> 2>err.log`.  
4. **No secrets** on either channel (tokens, passwords, private keys, full private key material).

### 2.4 Mode behavior

| Mode | Contract |
|------|----------|
| Normal (TTY) | Prefixed human messages; colors only when **`TTY=1`** and not quiet/json (consume the mode SSOT; do not re-test `[ -t 1 ]` in `out_*`) |
| Quiet | Suppress info/success/plain; still show errors (and should show warnings) |
| JSON | Force quiet; structured JSON only on success path; structured errors on failure |
| Debug | Extra diagnostics on stderr; suppressed under JSON purity rules for stdout |

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **Ship unit** | `src/sudoer-cli` |
| **Human prefixes** | `[INFO]`, `[OK]`, `[WARN]`, `[ERROR]` (or equivalent consistent set) |
| **Default CLI main menu style** | Look printers live: `util_app_ident` + `out_menu_choice`. Header nametag **sudoer-cli**(*VERSION*) (bold name, italic version on TTY). Numbered `explain` *italic* + light gray on TTY; number and short-descript unstyled; off-TTY / JSON plain. Claimed numbered list is verb `menu` / `main` (`requirement-shell-cli-default-interaction`; empty argv stays help). About identity title uses `util_app_ident`. |
| **Domain messages** | Convert / submit / list / show / Type 1 fatals use the same `out_*` family. Fatals fill happened / means / Next: |
| **Login-hook skip** | Planted `.bashrc` `printf` (exception **F**): happened + login continues + `Next: sudo sudoer-cli interactive`. Owner of snippet: `requirement-login-interactive-review-hook`. |
| **Banned jargon (whole message)** | `Type 1`, `euid 0`, `authorization failed`, `host validation`, `host sudoers checker` |
| **Worked fatal** | visudo-fail: `visudo rejected this grant. visudo said: N:M: syntax error. That means the sudoers file would be illegal. … Next: sudoer-cli json-to-sudoers --file request.json` |
| **Bootstrap role** | This product is hop 0; `out_*` is this origin’s family |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 5 – Single Source of Output**  
- **Principle 14 – Security & Traceability** (stdout vs stderr)  
- **Principle 1 – Caution** (fail loud, never silent corruption of JSON pipes)

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Never hide fatal errors under quiet.  
- **Intentional:** One emitter family.  
- **Anti-fragile:** JSON/human/quiet all work offline.  
- **Over-protect:** Do not “simplify” by scattering echo.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Introduce a second product messaging stack beside `out_*`.  
2. Print user-facing banners with raw `echo` outside allowed exceptions.  
3. Mix human text into JSON stdout success paths.  
4. Log secrets or private key material.  
5. Remove quiet/json contracts for “simplicity.”  
6. Re-test live `[ -t 1 ]` inside `out_*` for color — consume `TTY` set outside functions.  
7. Ship a blocking error that only insiders can parse, or give JSON a different story than the human `[ERROR]` line.  
8. Say “host validation” when visudo rejects (`requirement-sudoers-file`).  
9. Draw a claimed numbered list off default-cli-main-menu-style, skip `out_menu_choice` / `util_app_ident`, emit CSI off-TTY or under JSON, or print a bare `APP_NAME` on an identity header.  
10. Ship an operator skip/warn that still needs a next step (including planted login-rc `sudo -n` fail) as only `interactive hook skipped` — fill happened / means / Next:.

**Violating this rule is a critical output SSOT regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All product messages route through `out_*` |
| AC-2 | JSON mode produces structured success/error without human interleave |
| AC-3 | Quiet still surfaces errors |
| AC-4 | Lifecycle messaging uses the same SSOT |
| AC-5 | Fatals fill happened / Next:; visudo-fail names visudo (**TP-SR-21**) |
| AC-6 | Login-hook `sudo -n` fail skip copy fills happened / Next: (**TP-SR-HOOK-07**) |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-08** | `tests/test_cli.sh` | have | unknown verb fatal + Next: |
| **TP-CLI-17** | `tests/test_cli.sh` | have | default-cli-main-menu-style printers: TTY bold/italic ident + gray italic explain; off-TTY plain |
| **TP-SR-21** | `tests/test_domain_sr.sh` | have | visudo-fail operator-readable slots |
| **TP-SR-HOOK-07** | `tests/test_domain_sr.sh` | have | Login-hook skip copy: happened + Next: (not only `interactive hook skipped`) |

**Matrix:** `reviews/requirement-test-matrix.md`

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Modes and flags |
| `requirement-shell-cli-default-interaction` | Claimed `menu` / `main` uses `util_app_ident` / `out_menu_choice` |
| `requirement-shell-interactive-vs-noninteractive` | Prompt vs auto |
| `requirement-sudoers-file` | visudo-fail operator copy (worked fatal) |
| `requirement-login-interactive-review-hook` | Planted-rc skip copy (worked skip/warn) |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Output SSOT for folder-backup |
| 2026-08-13 | Active | Retarget to cli-template; drop domain message law |
| 2026-08-14 | Active 1.1.0 | Colors consume `TTY`; do not re-test `[ -t 1 ]` in `out_*` |
| 2026-08-14 | Active 1.1.1 | Implementation Notes: domain messages live; fatals use `Next:` |
| 2026-08-26 | Active 1.2.0 | Operator-readable fatal slots (happened / means / Next:); visudo-fail worked example; **TP-SR-21** |
| 2026-09-03 | Active 1.3.0 | Look printers `util_app_ident` / `out_menu_choice` (default-cli-main-menu-style). Main menu **not** claimed. **TP-CLI-17**. |
| 2026-09-03 | Active 1.3.1 | Printers used by claimed `menu` / `main` (`requirement-shell-cli-default-interaction`) |
| 2026-09-13 | Active 1.4.0 | Skip/warn that still needs action fills happened / Next:. Planted login-rc `printf` exception **F**. Worked login-hook `sudo -n` fail. **TP-SR-HOOK-07**. |

---

**Last Updated**: 2026-09-13  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
