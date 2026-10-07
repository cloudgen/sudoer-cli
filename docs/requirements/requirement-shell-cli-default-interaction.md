**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.6.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for sudoer-cli’s **numbered start list** on a real terminal. `requirement-shell-cli-zero-arguments` (**case 3**) **defers TTY empty argv** to this menu and **owns off-TTY empty argv as Type O self-install**. The list is also the live commands **`menu`** and **`main`**.

### 1.1 Human-facing

**In one sentence:** At a real terminal, `sudoer-cli` or `sudoer-cli --debug` opens a numbered list of live work commands; a pipe with no command installs or confirms install.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the numbered list at a prompt | `sudoer-cli` or `sudoer-cli --debug` |
| The other role | A script or pipe must not hang on that list | `sudoer-cli </dev/null` installs; `sudoer-cli menu </dev/null` prints help |
| Not this file | Off-TTY empty argv (Type O self-install) | `requirement-shell-cli-zero-arguments` |

| Includes | Excludes |
|----------|----------|
| TTY empty argv (including `--debug` with no command) numbered list; `menu` / `main` on a real terminal; row **1** approval features (including listing); row **5** languages; row **7** sudoers; row **8** self-management (**81–87**); Exit **99**; look with nametag and gray italic descriptions; a wrong number or name reprints **this** list so you can pick again | Off-TTY empty argv (Type O); `--json` with no command (JSON help); the `help` row; setup; unit-test commands; `menu` / `main` as a choice; a hang in a pipe; quitting the program because you typed `2`, `6`, or `17` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | `app_main_menu` |
| `sudoer-cli menu` | command | the numbered list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the start list | The first line is the program nametag with version. Each row is `command: what it does`. Last extra number is Exit. | `sudoer-cli` or `sudoer-cli menu` |
| Leave without running a command | Type the Exit number, or `exit` / `quit`. | `99` |
| Type a number that is not on the list | Stay on **this** list. The program says that number is not listed, reprints the same list, and waits. Unused front numbers (examples `2`, `6`, `17`) count. | `17` then a listed number or `99` |
| Open approval work | Row **1** opens queue, list, show, decide, and the approver account. Listing is on that layer. | `1` then `4` for `list-approving` |
| Open sudoers text | Row **7** opens convert and print. | `7` then `1` for `sudoers-to-json` |
| Open self-management | Row **8** opens install, version, about, version-check, self-update, self-uninstall, and self-install. Row **82** runs about. | `8` then `84` for `version-check` |
| Run with no arguments in a pipe | That path is install-ensure. It does not draw this list. | `curl … \| sh` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim and case

1. This product **claims** a numbered start list.  
2. A specialized zero-argument requirement **exists** (`requirement-shell-cli-zero-arguments`). This product **is** online-installable.  
3. **Case 3 applies.** That requirement **defers TTY empty argv** to this menu. Off-TTY empty argv is Type O self-install on that requirement. This file **MUST NOT** print help for bare off-TTY empty argv, and **MUST NOT** install on TTY empty argv.  
4. The list **MUST** also be live commands **`menu`** and **`main`** (same handler). TTY empty argv, including `sudoer-cli --debug` with no command token, sets `COMMAND=menu` and uses that handler.

### 2.2 `menu` / `main` and TTY empty argv (case 3)

| Invocation | `--json` | MUST | MUST NOT |
|------------|----------|------|----------|
| Interactive (`TTY=1`) empty argv, including `--debug` / `--quiet` / `--force` / `--global` with no command token | n/a (`--json` is the next row) | Draw the numbered list and read a choice | Help dump; Type O self-install; hang |
| Interactive (`TTY=1`) `sudoer-cli menu` (or `main`) | **Ignore** (even if `JSON=1`) | Draw the numbered list and read a choice | JSON help; hang |
| `--json` with no command token (TTY or off-TTY) | **Follow** | JSON help | Numbered list; Type O self-install |
| Non-interactive (`TTY=0`) `sudoer-cli menu` (or `main`) | **Follow** | Help: human when `JSON=0`; JSON help when `JSON=1` | Draw the list; hang; silent return |
| Non-interactive (`TTY=0`) empty argv | n/a | Type O self-install (`requirement-shell-cli-zero-arguments`) | This list; help dump |

`--quiet` off-TTY is still the help path. **MUST NOT** swallow help under `--quiet` on that path.

`TTY` **MUST** be measured outside functions. Helpers consume `TTY`.

### 2.3 Numbered list

0. **Look:** header **MUST** print live `APP_NAME(VERSION)` with **bold** name and *italic* version on a real terminal (`**sudoer-cli**(*{{VERSION}}*)` in markdown). Numbered `what it does` text **MUST** be *italic* and light gray on a real terminal; the number and command name stay ordinary. Off-TTY / JSON: plain. Typical printers: `util_app_ident` + `out_menu_choice`. **MUST NOT** a bare `sudoer-cli` on that header. **MUST NOT** print the description unstyled on a real terminal. Proof **TP-CLI-17**.  
1. Show the numbered list at the beginning of the interactive menu path.  
2. The front board uses fixed family numbers, not a dense **1 … N** list: **1** approval features, **5** languages, **7** sudoers, **8** self-management. Front **6** is not a row. Operational verbs are not front tokens. Lifecycle verbs are tokens on the self-management layer (**81–87**), not on the front board.  
3. Each printed row **MUST** be `name: what it does` (the short name, colon, space, then the one-line meaning). On a family layer the short name is the Latin command token. On the front board the short name is the family label (`approval features` in English, `sudoers`, or the languages short).  
4. **MUST NOT** list `help`.  
5. The front board **MUST NOT** list install, setup, diagnostics (`version`, `about`), **any** unit-test command (`test-json-format`, `test-well-known-binary`, `fence-test`), gap names, or **`menu` / `main` itself**. The self-management layer (front **8**) **MUST** number **81** `install`, **82** `version`, **83** `about`, **84** `version-check`, **85** `self-update`, **86** `self-uninstall`, and **87** `self-install`. Row **82** **MUST** run `about` (diagnostics). Argv `version` stays the one-line version. On this product **81** and **87** both call `inst_perform_install` (the install already places this CLI; there is no separate payload). **MUST NOT** number `setup`, `help`, `uninstall`, `where-is-me`, unit-test commands, or `menu` / `main` on that layer.  
6. Last extra row is **Exit** (not a command token). Exit number **MUST** be:

| Command rows **N** | Exit number |
|--------------------|-------------|
| **N ≤ 8** | **9** |
| **9 ≤ N ≤ 98** | **99** |
| **99 ≤ N ≤ 998** | **999** |

This product does **not** apply that dense table to the front board or to a family layer. Family numbers are reserved (**1**, **5**, **7**, **8**, self-management **81–87**, and language block **50–69**). Every layer that prints Exit **MUST** print **99**. The sudoers family and the self-management layer still print **99. Exit**, not **9. Exit**. **MUST NOT** number Exit as **9** or **17**. Front **8** is self-management, not Exit. Unused front integers are omitted.

7. Accept a **number** or the **verb token**; run the matching handler. Exit number (or `exit` / `quit`) returns 0.  
8. **Do not capture `read`:** the choice **MUST** be read in the **current shell**. **MUST NOT** `_choice=$(prompt_ask …)` / `$()` / backticks of **any** function whose body contains `read`. Call `prompt_ask "$(app_menu_text choice_label)" ""` then `_choice="${PROMPT_ASK_VALUE}"`. English `choice_label` is `Choice`, so the visible prompt is `Choice: `. The language board uses the same call. Sending the prompt to stderr does **not** license `$()`. Proof **TP-ELEV-10**.  
8c. **Invalid choice retries this layer:** a **menu layer** is one numbered list that owns the current choice (the front board, the approval family, the sudoers family, the self-management layer, and the language board are each a layer). An **invalid choice** is any input that is **not** a listed number, **not** a listed name on **this** layer, and **not** this layer’s Exit / `exit` / `quit` (unused front integers such as `2`, `6`, and `17` count; a buried verb such as `list-approving` is not a front token). On an invalid choice the CLI **MUST**: print a loud operator-readable error via `out_error` (not `out_die`); **reprint this layer’s list**; **re-prompt** in the current shell. **MUST NOT** terminate the process. **MUST NOT** leave this layer. **MUST NOT** treat the pick as unknown argv. Nested layers obey the same rule. Back / empty / EOF on the language board returns to the front board and does not save. On an approval, sudoers, or self-management layer, **0** / `back` / empty is Back and **99** / `exit` / `quit` leaves the whole menu. Empty line on the front board leaves. EOF / failed `read` **MUST** leave this layer without spinning (a family layer treats that empty pick as Back, then the front board leaves on the next empty pick). Proof **TP-CLI-22** (portable **TP-CLI-19** already names off-TTY `menu` help on this product). Language copy and rows **51–63**: `requirement-shell-cli-language`. Proof **TP-CLI-24**.  
9. Handler: `app_main_menu` (`app_*`). Extra fields: TTY one-at-a-time with the same call shape, **or** print `Next: sudoer-cli <verb> …` and return — **MUST NOT** hang off-TTY.  
10. Non-interactive help paths **MUST** reuse `app_help`. **MUST NOT** invent a second JSON help catalog.

### 2.4 Implementation Notes (this project)

| Item | Value for sudoer-cli |
|------|----------------------|
| **Product** | `sudoer-cli` |
| **Claimed** | **yes** |
| **Case** | **3** (zero-argument REQ exists; that REQ defers TTY empty argv here; off-TTY empty argv is Type O, not this file) |
| **Handler** | `app_main_menu` / `app_main_menu_print`; TTY empty argv and `menu` / `main` |
| **Empty argv** | TTY → this menu (including `--debug` with no command); off-TTY → Type O self-install (`requirement-shell-cli-zero-arguments`; not this handler); `--json` with no command → JSON help |
| **Front rows** | **1** approval features, **5** languages, **7** sudoers, **8** self-management, then Exit **99**. Front **6** is not a row |
| **Approval layer (opened by 1)** | `add-sudoer-request`, `update-sudoer-request`, `remove-sudoer-request`, `list-approving`, `list-approved`, `list-rejected`, `show`, `remove-lpu`, `approve`, `reject`, `interactive`, then **0** Back and Exit **99** |
| **Sudoers layer (opened by 7)** | `sudoers-to-json`, `json-to-sudoers`, `print-sudoers`, `print-sudoers-install-script`, then **0** Back and Exit **99** |
| **Self-management layer (opened by 8)** | **81** `install`, **82** `version` (runs `about`), **83** `about`, **84** `version-check`, **85** `self-update`, **86** `self-uninstall`, **87** `self-install` (same handler as `install`), then **0** Back and Exit **99** |
| **Excluded (live but not numbered)** | `uninstall`, `where-is-me`, `help`, `setup`, `test-json-format`, `test-well-known-binary`, `fence-test`, `menu`, `main`. Argv `version` stays the one-liner and is not a front token |
| **Choice `read`** | Current-shell `prompt_ask "$(app_menu_text choice_label)" ""` then `${PROMPT_ASK_VALUE}` (English label `Choice`) on the front board and on each family layer |
| **Invalid choice** | `out_error` + reprint this layer + re-prompt. Unused front `2` / `6` / `17` and unknown names. A buried verb is not a front token. Nested language, approval, sudoers, and self-management layers retry that layer. Empty line on the front board leaves. **TP-CLI-22** · **TP-CLI-24** |
| **Extra operands** | Existing handlers fail closed with `Next:` (no hang) |
| **Gap vs live** | **Live** — dispatcher accepts `menu` / `main` |

**Invocation samples (topic-owner):**

```text
sudoer-cli
sudoer-cli --debug
sudoer-cli menu
sudoer-cli main
sudoer-cli menu --json
sudoer-cli --json
```

On a real terminal, bare `sudoer-cli` and `sudoer-cli --debug` draw the list. `sudoer-cli menu --json` still draws the list. `sudoer-cli --json` with no command prints JSON help on a terminal and in a pipe. In a pipe, bare `sudoer-cli` is Type O self-install; `sudoer-cli menu` prints help; `sudoer-cli menu --json` prints JSON help.

### 2.5 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: TTY empty argv is this list; off-TTY empty argv stays Type O; `menu` / `main` stay named.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang in a pipe; `--json` on a real terminal still shows the list.  
- **CIAO Principle 1 – Caution**: Setup and unit-test commands are not numbered choices. Install and the other lifecycle verbs are numbered only under front **8**.  
- **CIAO Principle 5 – SSOT of output**: Header and rows go through `util_app_ident` / `out_menu_choice`.  
- **CIAO Principle 3 – Anti-fragile**: A typo on any menu layer reprints **that** layer; it does not dump the operator out of the program.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows cmd, or the same class (no root login on that shell):

| MUST | MUST NOT |
|------|----------|
| Keep **normal user privilege** only | Turn on **admin privilege** or **dedicated system user privilege** |
| Convert, queue, list, help, and local install into the user bin | In-tool `sudo`; wrap `apt` / `dnf`; `useradd`; write `/etc`; recommend `sudo curl | sh` |
| Document setup / approve / interactive as **unused** on that class | Invent a dedicated account on that class |

**This requirement:** the numbered list still works as this login; it MUST NOT number setup / approve as if they were live on this class. Invalid-choice retry stays Type 0 TTY UX on that class — retry **MUST NOT** require elevation.

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS` is `Windows_NT` and `COMSPEC` names `cmd.exe` (after excluding Git Bash / WSL).

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Do not steal off-TTY empty argv; do not hang automation.  
- **Intentional**: Case 3 recorded; `menu` / `main` named.  
- **Anti-fragile**: Labels come from help one-liners; Exit follows the all-nines rule.  
- **Over-protect**: Choice `read` stays in this shell (`PROMPT_ASK_VALUE`). A bad pick `out_error`s and reprints; it does not `out_die`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Invent front labels other than **1** approval features, **5** languages, **7** sudoers, and **8** self-management, or invent family-layer tokens other than the live command one-liners.  
2. Put `help`, setup, unit-test commands, or `menu` / `main` itself on any numbered list. Put `install`, `version`, `about`, `version-check`, `self-update`, `self-uninstall`, or `self-install` on the front board. Those seven live on **81–87** only.  
3. Number Exit as **9** or **17** on the front board or on a family layer. Exit stays **99**. Front **8** is self-management, not Exit.  
4. Draw the list in non-interactive mode, hang, or swallow help under `--quiet` off-TTY.  
5. Attach the list to **off-TTY** empty argv, or replace **TTY** empty argv (including `--debug` with no command) with help or with self-install, while `requirement-shell-cli-zero-arguments` defers the TTY path here.  
6. Treat interactive `menu --json` as JSON help.  
7. Ignore `--json` on non-interactive `menu`.  
8. Capture the choice with `$()` / backticks of `prompt_ask` (or any `read` helper).  
9. Print a bare `sudoer-cli` header without live `VERSION`, or unstyled descriptions on a real terminal.  
10. **`out_die` / exit** on an invalid TTY menu choice (unused number such as `17` when `17` is not listed, unknown name, nested-layer typo) — **MUST** `out_error`, reprint **this** layer, and re-prompt (**TP-CLI-22**). **MUST NOT** treat that pick as unknown argv.

**Violating this rule is a critical dispatcher / TTY-menu regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | TTY empty argv, including `--debug` with no command, draws the numbered list. Off-TTY empty argv is Type O (not the list, not help). `--json` with no command is JSON help |
| AC-2 | `menu` and `main` are live dispatcher tokens, same handler |
| AC-3 | Interactive `menu` draws the numbered list and ignores `--json` |
| AC-4 | Non-interactive `menu` prints help; `--json` prints JSON help; no hang |
| AC-5 | The front board excludes help, install, setup, version, about, testers, and `menu`/`main`. The self-management layer numbers **81–87** and excludes setup, help, testers, and `menu`/`main` |
| AC-6 | Front rows are **1** approval features (listing included on that layer), **5** languages, **7** sudoers, and **8** self-management, then Exit **99**. Front **6** is not a row |
| AC-7 | Choice uses current-shell `PROMPT_ASK_VALUE` (no `$()` of `prompt_ask`) |
| AC-8 | Header is `sudoer-cli(VERSION)` bold/italic; descriptions italic + light gray on TTY |
| AC-9 | Invalid choice at any menu layer prints `[ERROR]`, reprints **this** layer, and re-prompts; process stays alive (**TP-CLI-22**) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Defers TTY empty argv here; owns off-TTY Type O self-install |
| `requirement-shell-cli-language` | Row **5** and block **50–69** |
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
| **TP-CLI-07** | `tests/test_cli.sh` | have | Off-TTY empty argv is Type O (not help); TTY empty argv is this list |
| **TP-CLI-17** | `tests/test_cli.sh` | have | Look printers; claimed menu header uses them |
| **TP-CLI-18** | `tests/test_cli.sh` | have | `menu` / `main` routed; off-TTY empty argv is Type O (not the list) |
| **TP-CLI-29** | `tests/test_cli.sh` | have | Overlay `--debug` / `--quiet` follow empty argv; TTY `--debug` is this list; `--json` stays JSON help |
| **TP-CLI-19** | `tests/test_cli.sh` | have | Off-TTY `menu` is help; `--json` is JSON help; `--quiet` does not swallow |
| **TP-CLI-20** | `tests/test_cli.sh` | have | Front families **1**, **7**, and **8**; listing stays under approval; self-management is **81–87**; Exit **99** |
| **TP-CLI-21** | `tests/test_cli.sh` | have | Interactive `menu --json` still draws the list (JSON ignored) |
| **TP-CLI-22** | `tests/test_cli.sh` | have | Invalid choice at any menu layer reprints that layer (`out_error`; unused `17`; unknown name; **MUST NOT** `out_die`). Portable **TP-CLI-19** already names off-TTY `menu` help here. |
| **TP-CLI-24** | `tests/test_cli.sh` | have | Row **5** opens the language board (**51–63**). Front **1** opens approval (including listing). Front **7** opens sudoers. Front **8** opens self-management **81–87** (row **82** runs about). Front **6** is not a row. |
| **TP-ELEV-10** | `tests/test_cli.sh` | have | No `$()` of `prompt_ask`; `prompt_ask "$(app_menu_text choice_label)"` on both boards |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-10-07 | Active 1.6.0 | Front **8** self-management, rows **81–87**, same card as sibling sshd-cli. Row **82** runs about. **81** and **87** share `inst_perform_install`. Exit stays **99**. Proof **TP-CLI-20** · **TP-CLI-24**. |
| 2026-10-04 | Active 1.5.0 | Front **1** approval features (listing included). Front **7** sudoers (convert and print). Front **5** languages. Exit stays **99**. Front **6** is not a row. Proof **TP-CLI-20** · **TP-CLI-24**. |
| 2026-10-04 | Active 1.4.0 | TTY empty argv, including `--debug` with no command, draws this list. Off-TTY empty argv stays Type O. `--json` with no command is JSON help. Proof **TP-CLI-07** · **TP-CLI-29**. |
| 2026-10-02 | Active 1.3.0 | Row **5** languages; operational rows shift to **6–16**; Exit **99**; unused example **17**. Language copy: `requirement-shell-cli-language`. Proof **TP-CLI-24**. |
| 2026-09-13 | Active 1.2.0 | Invalid choice at any menu layer retries that layer (`out_error` + reprint; **MUST NOT** `out_die`). Proof **TP-CLI-22**. |
| 2026-09-06 | Active 1.1.0 | Under command line for normal user only |
| 2026-09-03 | Active 1.0.0 | Claimed case 3; live `menu` / `main`; empty argv stays help |

---

**Last Updated**: 2026-10-07  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
