**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.0.1)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for sudoer-cli’s **numbered start list** on a real terminal. Empty argv already means help. The list is therefore the live commands **`menu`** and **`main`**, not a bare `sudoer-cli`.

### 1.1 Human-facing

**In one sentence:** Type `sudoer-cli menu` at a real terminal to open a numbered list of live work commands; typing only the program name still prints help.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the numbered list at a prompt | `sudoer-cli menu` |
| The other role | A script or pipe must not hang on that list | `sudoer-cli menu </dev/null` |
| Not this file | What happens when you type only the program name | `requirement-shell-cli-zero-arguments` |

| Includes | Excludes |
|----------|----------|
| Numbered live work commands; Exit **99** (fifteen rows); look with nametag and gray italic descriptions | The `help` row; install / uninstall / where-is-me / setup; version / about; unit-test commands; `menu` / `main` as a choice; a hang in a pipe |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | `app_main_menu` |
| `sudoer-cli menu` | command | the numbered list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the start list | The first line is the program nametag with version. Each row is `command: what it does`. Last extra number is Exit. | `sudoer-cli menu` |
| Leave without running a command | Type the Exit number, or `exit` / `quit`. | `99` |
| Run with no arguments | Help still prints. The list is not that path. | `sudoer-cli` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim and case

1. This product **claims** a numbered start list.  
2. A specialized zero-argument requirement **exists** (`requirement-shell-cli-zero-arguments`). This product is **not** online-installable.  
3. **Case 3 applies.** Empty argv **MUST** stay Type N help. This requirement **MUST NOT** attach the list to empty argv.  
4. The list **MUST** be live commands **`menu`** and **`main`** (same handler).

### 2.2 `menu` / `main` mode check (case 3)

| Invocation | `--json` | MUST | MUST NOT |
|------------|----------|------|----------|
| Interactive (`TTY=1`) `sudoer-cli menu` (or `main`) | **Ignore** (even if `JSON=1`) | Draw the numbered list and read a choice | JSON help; hang |
| Non-interactive (`TTY=0`) `sudoer-cli menu` (or `main`) | **Follow** | Help: human when `JSON=0`; JSON help when `JSON=1` | Draw the list; hang; silent return |

`--quiet` off-TTY is still the help path. **MUST NOT** swallow help under `--quiet` on that path.

`TTY` **MUST** be measured outside functions. Helpers consume `TTY`.

### 2.3 Numbered list

0. **Look:** header **MUST** print live `APP_NAME(VERSION)` with **bold** name and *italic* version on a real terminal (`**sudoer-cli**(*{{VERSION}}*)` in markdown). Numbered `what it does` text **MUST** be *italic* and light gray on a real terminal; the number and command name stay ordinary. Off-TTY / JSON: plain. Typical printers: `util_app_ident` + `out_menu_choice`. **MUST NOT** a bare `sudoer-cli` on that header. **MUST NOT** print the description unstyled on a real terminal. Proof **TP-CLI-17**.  
1. Show the numbered list at the beginning of the interactive menu path.  
2. Each numbered command row is one live **operational** command that is **not** excluded below, numbered **1 … N**.  
3. The printed line **MUST** be `command: what it does` (the command token, colon, space, then the one-line meaning from help).  
4. **MUST NOT** list `help`.  
5. **MUST NOT** list install / setup, self-managed place/remove (`install`, `uninstall`, `where-is-me`), diagnostics (`version`, `about`), **any** unit-test command (`test-json-format`, `test-well-known-binary`, `fence-test`), gap names, or **`menu` / `main` itself**.  
6. Last extra row is **Exit** (not a command token). Exit number **MUST** be:

| Command rows **N** | Exit number |
|--------------------|-------------|
| **N ≤ 8** | **9** |
| **9 ≤ N ≤ 98** | **99** |
| **99 ≤ N ≤ 998** | **999** |

**MUST NOT** number Exit as **N+1** when the all-nines rule applies. Unused integers between **N** and Exit are omitted.

7. Accept a **number** or the **verb token**; run the matching handler. Exit number (or `exit` / `quit`) returns 0.  
8. **Do not capture `read`:** the choice **MUST** be read in the **current shell**. **MUST NOT** `_choice=$(prompt_ask …)` / `$()` / backticks of **any** function whose body contains `read`. Call `prompt_ask "Choice" ""` then `_choice="${PROMPT_ASK_VALUE}"`. Sending the prompt to stderr does **not** license `$()`. Proof **TP-ELEV-10**.  
9. Handler: `app_main_menu` (`app_*`). Extra fields: TTY one-at-a-time with the same call shape, **or** print `Next: sudoer-cli <verb> …` and return — **MUST NOT** hang off-TTY.  
10. Non-interactive help paths **MUST** reuse `app_help`. **MUST NOT** invent a second JSON help catalog.

### 2.4 Implementation Notes (this project)

| Item | Value for sudoer-cli |
|------|----------------------|
| **Product** | `sudoer-cli` |
| **Claimed** | **yes** |
| **Case** | **3** (zero-argument REQ owns empty argv; menu is verb `menu` / `main`) |
| **Handler** | `app_main_menu` / `app_main_menu_print`; dispatch via `app_run_command` |
| **Empty argv** | Still Type N help (`requirement-shell-cli-zero-arguments`) |
| **N** | **15** operational rows after exclusions → Exit **99** |
| **Numbered rows (kept-list order)** | `sudoers-to-json`, `json-to-sudoers`, `print-sudoers`, `print-sudoers-install-script`, `add-sudoer-request`, `update-sudoer-request`, `remove-sudoer-request`, `list-approving`, `list-approved`, `list-rejected`, `show`, `remove-lpu`, `approve`, `reject`, `interactive` |
| **Excluded (live but not numbered)** | `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`, `setup`, `test-json-format`, `test-well-known-binary`, `fence-test`, `menu`, `main` |
| **Choice `read`** | Current-shell `prompt_ask "Choice" ""` then `${PROMPT_ASK_VALUE}` |
| **Extra operands** | Existing handlers fail closed with `Next:` (no hang) |
| **Gap vs live** | **Live** — dispatcher accepts `menu` / `main` |

**Invocation samples (topic-owner):**

```text
sudoer-cli menu
sudoer-cli main
sudoer-cli menu --json
```

On a real terminal, `sudoer-cli menu --json` still draws the list. In a pipe, `sudoer-cli menu` prints help; `sudoer-cli menu --json` prints JSON help.

### 2.5 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Empty argv stays help; the list has a named verb.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang in a pipe; `--json` on a real terminal still shows the list.  
- **CIAO Principle 1 – Caution**: Install, setup, and unit-test commands are not numbered choices.  
- **CIAO Principle 5 – SSOT of output**: Header and rows go through `util_app_ident` / `out_menu_choice`.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows cmd, or the same class (no root login on that shell):

| MUST | MUST NOT |
|------|----------|
| Keep **normal user privilege** only | Turn on **admin privilege** or **dedicated system user privilege** |
| Convert, queue, list, help, and local install into the user bin | In-tool `sudo`; wrap `apt` / `dnf`; `useradd`; write `/etc`; recommend `sudo curl | sh` |
| Document setup / approve / interactive as **unused** on that class | Invent a dedicated account on that class |

**This requirement:** the numbered list still works as this login; it MUST NOT number setup / approve as if they were live on this class.

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS` is `Windows_NT` and `COMSPEC` names `cmd.exe` (after excluding Git Bash / WSL).

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Do not steal empty argv; do not hang automation.  
- **Intentional**: Case 3 recorded; `menu` / `main` named.  
- **Anti-fragile**: Labels come from help one-liners; Exit follows the all-nines rule.  
- **Over-protect**: Choice `read` stays in this shell (`PROMPT_ASK_VALUE`).

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Invent menu labels instead of `command: what it does` from help.  
2. Put `help`, install / setup, version, about, unit-test commands, or `menu` / `main` itself on the numbered list.  
3. Number Exit as **N+1** when the all-nines rule applies (fifteen rows → **99. Exit**, not `16. Exit`).  
4. Draw the list in non-interactive mode, hang, or swallow help under `--quiet` off-TTY.  
5. Attach the list to empty argv while `requirement-shell-cli-zero-arguments` owns that path.  
6. Treat interactive `menu --json` as JSON help.  
7. Ignore `--json` on non-interactive `menu`.  
8. Capture the choice with `$()` / backticks of `prompt_ask` (or any `read` helper).  
9. Print a bare `sudoer-cli` header without live `VERSION`, or unstyled descriptions on a real terminal.

**Violating this rule is a critical dispatcher / TTY-menu regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Empty argv still prints help (not the list) |
| AC-2 | `menu` and `main` are live dispatcher tokens, same handler |
| AC-3 | Interactive `menu` draws the numbered list and ignores `--json` |
| AC-4 | Non-interactive `menu` prints help; `--json` prints JSON help; no hang |
| AC-5 | Numbered rows exclude help, install/setup, version/about, testers, and `menu`/`main` |
| AC-6 | Fifteen command rows → Exit **99** |
| AC-7 | Choice uses current-shell `PROMPT_ASK_VALUE` (no `$()` of `prompt_ask`) |
| AC-8 | Header is `sudoer-cli(VERSION)` bold/italic; descriptions italic + light gray on TTY |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv stays help |
| `requirement-shell-cli-interface` | Dual mention of `menu` / `main`; dispatcher table |
| `requirement-shell-interactive-vs-noninteractive` | No hang; `TTY` measured outside functions |
| `requirement-shell-prompt` | `prompt_ask` / `PROMPT_ASK_VALUE` |
| `requirement-shell-output-requirements` | `util_app_ident` / `out_menu_choice` |
| `requirement-actor-role-subject-approver` | Who-is-who already Active (dest has approver) |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-07** | `tests/test_cli.sh` | have | Empty argv still help (case 3) |
| **TP-CLI-17** | `tests/test_cli.sh` | have | Look printers; claimed menu header uses them |
| **TP-CLI-18** | `tests/test_cli.sh` | have | `menu` / `main` routed; empty argv still help |
| **TP-CLI-19** | `tests/test_cli.sh` | have | Off-TTY `menu` is help; `--json` is JSON help; `--quiet` does not swallow |
| **TP-CLI-20** | `tests/test_cli.sh` | have | Membership + Exit **99** |
| **TP-CLI-21** | `tests/test_cli.sh` | have | Interactive `menu --json` still draws the list (JSON ignored) |
| **TP-ELEV-10** | `tests/test_cli.sh` | have | No `$()` of `prompt_ask`; `PROMPT_ASK_VALUE` on the menu path |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-06 | Active 1.0.1 | Under command line for normal user only |
| 2026-09-03 | Active 1.0.0 | Claimed case 3; live `menu` / `main`; empty argv stays help |

---

**Last Updated**: 2026-09-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
