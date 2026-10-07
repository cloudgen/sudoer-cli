**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 3.14.1) — stay-honest `VERSION` 1.32.0; front **1** approval features; front **7** sudoers; menu **5** languages; TTY empty argv is the numbered list; off-TTY empty argv is Type O; login-hook doorbell `sudoer-review-hook`  
**Area**: shell  
**Key**: `requirement-shell-cli-interface`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of sudoer-cli: live command surface, privilege typing, global flags, dispatcher behavior, help/about contracts, and mode rules.

Help lists only commands that actually run. As yourself you install, convert, queue, list, show, and run the local testers. After password `sudo` you run `setup` and review. Help **MUST** list testers apart from everyday commands. Being a normal login is **not** the same as “unit test.” Domain catalog and fail-closed review are owned by `requirement-domain-sudoer-approval.md` and `requirement-three-layer-privilege-model.md`. Help **MUST NOT** list a verb with no `case` arm. Full lifecycle rules live in `requirement-shell-self-management.md`. (Catalog: Type 0 operational convert/submit/list/show/print-sudoers; Type 0 test-purpose `test-json-format` / `test-well-known-binary` / `fence-test` / `rc-test`; Type 1 `setup` / review.)

### 1.1 Human-facing

**In one sentence:** This program lists and runs commands. Help must not advertise a command that is not wired.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Run listed commands without becoming root | `sudoer-cli help` |
| The other role | Host admin already using sudo for setup and review | `sudo sudoer-cli setup` |
| Not this file | Domain schema, dest fences, empty-argv split, numbered-list membership | `requirement-domain-sudoer-approval` · `requirement-shell-cli-zero-arguments` · `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| Dispatcher; flags; help lists only wired verbs | A help line with no `case` arm |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | dispatcher |
| `sudoer-cli help` | command | listed verbs |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See what is live | Help is the contract. If a verb is missing from help, it is not a live command. | `sudoer-cli help` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every command **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning |
|----------|-----------|---------|
| **Type 0 – CLI lifecycle + diagnostics + domain convert** | Invoking user | Lifecycle (**operational**): `install`, `version-check`, `self-update`, `self-uninstall`, `version`, `about`, `help`, **`menu` / `main`**. Domain Type 0 **operational**: convert / submit / list / show / `print-sudoers` (catalog on domain SSOT). Domain Type 0 **test-purpose**: `test-json-format` / `test-well-known-binary` / `fence-test` (unit test; local test folder; catalog on domain SSOT) |
| **Type 1 – Narrow elevated host ops** | Controlled sudo | Names **routed**; **fail closed** without euid 0. **`setup` / `remove-lpu`**: any host admin already euid 0 (`sudo {{APP}} setup`, password OK; not `sudo -n`; not limited to `sudoer-adm`). Live: useradd, F6, hook; after setup print submit next-step. **`approve` / `reject` / `interactive`**: any already euid-0 host admin (password `sudo`), or F6 `sudoer-adm`, or real root. Review-loop body is **live** |
| **Type 2 – Dedicated system user app ops** | Dedicated app user euid | **Not used** (sudoer-adm is an authorizer, not a Type 2 execution context) |

**Verb purpose (orthogonal to Type):**

| Purpose | Verbs | Target | Sudo |
|---------|-------|--------|------|
| **Test-purpose** (unit test) | `test-json-format`, `test-well-known-binary`, `fence-test` | Local test folder / `--file` under it | Wrap **chmod** / **chown** of that folder only (check before sudo). **MUST NOT** sudo otherwise. **MUST NOT** queue, dest-write, `setup`, or `approve`. |
| **Operational** (run the product) | Lifecycle; `menu` / `main`; convert; submit; list; show; print-sudoers; Type 1 `setup` / `approve` / `reject` / `interactive` | Queues, dest, install | Type-appropriate. Type 0 operational **MUST NOT** write `/etc`. |

Help **MUST** list test-purpose under a heading apart from operational Type 0.

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output |
| `--debug` | `DEBUG=1` | Extra diagnostics on stderr; must not break JSON purity on stdout |
| `--force` | `FORCE=1` / force policy | Skip self-uninstall confirm or force reinstall only where documented |
| `--global` | `FORCE_GLOBAL=1` | Install to `GLOBAL_BIN` |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

**Forbidden flags (trimmed):** `--allow-test-local`, `--disk`, `--ram` (parent domain / sudoers).

### 2.3 Dispatcher and entry rules

1. **Single entry:** `app_main` **MUST** parse global flags and route commands.  
2. **Unknown command:** **MUST** fail loudly with pointer to `help` (via output SSOT).  
3. **Empty argv:** after flag parse, no command token. TTY → numbered list. Off-TTY → **Type O install-ensure**. `--json` with no command → JSON help. Overlay switches (`--debug`, `--quiet`/`-q`, `--force`, `--global`) with no command token follow that split (`requirement-shell-cli-zero-arguments.md`).  
4. **No raw user I/O:** User-facing messages **MUST** go through `out_*`.  
5. Script end **MUST** call `app_main "$@"` (no basename gate that blocks dispatch).  
6. Trimmed parent verbs (`backup`, `restore`, `remove-project-sudoers`) **MUST** fail as unknown. `print-sudoers` and `print-sudoers-install-script` are **domain Type 0** (not trimmed).

### 2.4 Help surface

`help` **MUST** list:

- Usage line  
- Every supported Type 0 command with one-line purpose  
- Global flags  
- Honest install channel (`curl \| sh` / `SCRIPT_URL`); **MUST NOT** advertise `CHECKSUM`

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object.

`help` **MUST** list live domain Type 0 rows per the domain SSOT. `help` **MUST** list **test-purpose** verbs (`test-json-format`, `test-well-known-binary`, `fence-test`, `rc-test`) under a **separate heading** from **operational** Type 0 (convert, submit, list, show, print-sudoers). Operator-facing help **headings and one-liners** **MUST** name the job in people/folder words first (install, convert, queue, unit tests, first-time setup, approve). **MUST NOT** lead those headings with Type 0 / Type 1 / F6 / LPU as the only words. Catalog codes **MAY** follow the plain sentence. `help` **MUST NOT** list a verb with no dispatcher arm.

### 2.5 Implementation Notes (this project)

| Item | Value for sudoer-cli |
|------|-------------------------|
| **Product / binary name** | `sudoer-cli` (`APP_NAME`) |
| **Primary executable** | `src/sudoer-cli` (POSIX `/bin/sh`, single-file ship unit) |
| **Dispatcher** | `app_main` |
| **Output SSOT** | `out_text` + wrappers (`out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_json`, …) |
| **Version SSOT** | `VERSION="1.32.0"` hard-assign in ship unit |
| **Interactive rc write path** | `BASHRC` default `${HOME}/.bashrc`. User-bin `install` PATH ensure creates/modifies this file. Tests/CI **MAY** set `BASHRC` to a file in a temp folder. Dual mention: `requirement-shell-path-and-shell-support`. |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Primary install story** | `curl -fsSL https://raw.githubusercontent.com/cloudgen/sudoer-cli/main/src/sudoer-cli \| sh` → user bin; `sudo curl … \| sudo sh` → global; login-hook-symlink `/usr/local/bin/sudoer-review-hook` after global place |
| **Default CLI main menu** | **Claimed.** TTY empty argv (including `--debug` with no command) opens the numbered list. Off-TTY empty argv is Type O install-ensure. Verb `menu` / `main` opens the same list on a TTY and prints help off-TTY. `--json` with no command is JSON help. Front **1** is approval features (listing included). Front **5** is languages (**51–63**). Front **7** is sudoers. Exit **99**. Topic owner: `requirement-shell-cli-default-interaction`. Language copy: `requirement-shell-cli-language`. Look printers: `util_app_ident` / `out_menu_choice` (**TP-CLI-17**, **TP-CLI-24**, **TP-CLI-29**) |
| **Online channel env** | `SCRIPT_URL` composed `https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/src/${APP_NAME}` |
| **Type 1 / Type 2 commands** | Type 1 **routed, fail closed** without euid 0; setup = any admin sudo (live useradd/F6/hook); approve = same elev (F6 extra); Type 2 **not used** |
| **Dedicated system user** | `sudoer-adm` (authorizer; see LPU REQ) |
| **About** | Type 0 only until domain about pillar is routed |

#### Supported commands (normative for this project)

| Command | Type | Handler family | Required behavior |
|---------|------|----------------|-------------------|
| *(no command token — empty argv)* | Type 0 | TTY → `app_main_menu`; off-TTY → `inst_perform_install` / `inst_maybe_install`; `--json` → `app_help` | TTY numbered list (including `--debug`). Off-TTY **Type O install-ensure**. `--json` with no command is JSON help. Not `interactive` |
| `install` | Type 0 | `inst_perform_install` | Place from `SCRIPT_URL`; user-bin companion PATH/profile (`inst_ensure_companion`). Idempotent unless `--force`. Dual mention: `requirement-shell-self-management` · `requirement-shell-path-and-shell-support` |
| `version-check` | Type 0 | `ver_check` | Local vs remote on channel; fail loud if channel missing |
| `self-update` | Type 0 | `inst_self_update` | Fetch newer from channel; no silent downgrade |
| `self-uninstall` | Type 0 | `inst_self_uninstall` | Remove managed binary; scoped PATH cleanup. Dual mention: `requirement-shell-self-management` · `requirement-shell-path-and-shell-support` |
| `version` | Type 0 | `app_version` | Local `VERSION` only; no network |
| `about` | Type 0 | `app_about` | Diagnostics: install presence, paths, user, shell, TTY, storage, **resolved queue paths**, install channel; **no** `CHECKSUM`; **no** backup/restore fields |
| `help` | Type 0 | `app_help` | Full usage in human mode; short JSON note in JSON mode |
| `menu` / `main` | Type 0 | `app_main_menu` | Numbered TTY start list (same handler as TTY empty argv). Invalid choice reprints this layer (`out_error`; **MUST NOT** `out_die`). Off-TTY `menu` is help. TTY `menu --json` still draws the list. Dual mention on `requirement-shell-cli-default-interaction`. |
| `sudoers-to-json` | Type 0 | `sr_sudoers_to_json` | Named here; text dual / visudo on `requirement-sudoers-file`; convert catalog on domain SSOT |
| `json-to-sudoers` | Type 0 | `sr_json_to_sudoers` | Named here; text dual / visudo on `requirement-sudoers-file`; convert catalog on domain SSOT |
| `test-json-format` | Type 0 **test-purpose** | `sr_test_json_format` | Named here; Fence body on `requirement-incorrect-json-format`. Unit test; local test folder. |
| `test-well-known-binary` | Type 0 **test-purpose** | `sr_test_well_known_binary` | Named here; Fence body on `requirement-well-known-sudoer-binary-fence`. Unit test; local test folder. |
| `fence-test` | Type 0 **test-purpose** | `sr_fence_test` | Named here; JSON-file verification on `requirement-domain-sudoer-approval` (unit test; local test folder; sudo wrap only chmod/chown of that folder; no queue) |
| `rc-test` | Type 0 **test-purpose** | `path_rc_test` | Fixture create / modify / no-op against `--root` tmp/cache. **MUST NOT** write this login’s real `{{HOME}}/.bashrc`. Help lists this **apart** from operational verbs. Dual mention: `requirement-shell-path-and-shell-support`. Sample: `sudoer-cli rc-test --root "$tmpdir" --file bashrc --case create` |
| `print-sudoers` | Type 0 | `sr_print_sudoers` | Named here; Table A emit on domain / three-layer |
| `print-sudoers-install-script` | Type 0 | `sr_print_sudoers_install_script` | Named here; behavior on domain SSOT |
| `add-sudoer-request` | Type 0 | `sr_submit add` | Named here; behavior on domain SSOT |
| `update-sudoer-request` | Type 0 | `sr_submit update` | Named here; behavior on domain SSOT |
| `remove-sudoer-request` | Type 0 | `sr_submit remove` | Named here; behavior on domain SSOT |
| `list-approving` / `list-approved` / `list-rejected` | Type 0 | `sr_list` | Named here; behavior on domain SSOT |
| `list-approving --orphans` | Type 1 | `sr_list_orphans` | Named here; fail-closed without euid 0 |
| `show` | Type 0 | `sr_show` | Named here; behavior on domain SSOT |
| `setup` / `remove-lpu` | Type 1 | `lpu_setup` / `lpu_remove` | Named here; Type map on three-layer; F1–F7 on LPU REQ. After global copy: shared `/usr/local/bin/sudoer-review-hook` on `requirement-login-interactive-review-hook` |
| `approve` / `reject` | Type 1 | `sr_approve` / `sr_reject` | Named here; dest Fence then dest write |
| `interactive` | Type 1 | `sr_interactive` | Named here; one-off yes/no on domain SSOT; hook start on `requirement-login-interactive-review-hook`. Invocation: `sudo sudoer-cli interactive` · hook: `sudo -n /usr/local/bin/sudoer-review-hook interactive` |

#### Global flags (normative wiring)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | `QUIET=1` in `app_main`. With no command token, still empty argv (TTY menu; off-TTY ensure) |
| `--json` | `JSON=1` and `QUIET=1` in `app_main`. With no command token, JSON help on a TTY and off-TTY |
| `--debug` | `DEBUG=1` in `app_main`. With no command token, still empty argv (`sudoer-cli --debug` matches `DEBUG=1 sudoer-cli`) |
| `--force` | `FORCE=1` (and install reinstall policy when applicable). With no command token, still empty argv |
| `--global` | `FORCE_GLOBAL=1`. With no command token, still empty argv |

#### Dispatcher acceptance criteria

1. Unknown token after flag parse → `out_die` with pointer to `sudoer-cli help`.  
2. No command token → TTY numbered list; off-TTY Type O install-ensure; `--json` → JSON help. Overlay flags do not make that help.  
3. Command routing table in `app_main` **must** include every lifecycle row above **and** the live domain Type 0 verbs from the domain SSOT, and **no** trimmed parent verbs (`backup` / `restore` / `remove-project-sudoers`).  
4. Help text **must** stay aligned with that table.

#### Explicitly out of scope

- Domain: `backup`, `restore`  
- Parent leftovers: `backup`, `restore`, `remove-project-sudoers`  
- Type 2 app runtime euid under sudoer-adm  
- Live host `useradd` in non-root CI (setup body is proven statically)  

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Unknown commands fail loud; force gates destructive ops.  
- **CIAO Principle 2 – Intentional**: Every command has one privilege type and one handler family.  
- **CIAO Principle 5 – Single Source of Output**: Central `out_*`.  
- **CIAO Principle 6 – Single Point of Entry**: `app_main` is the dispatcher SSOT.  
- **CIAO Principle 9 – Three Types of Commands**: Type 0 lifecycle + Type 0 domain; Type 1 fail-closed.  
- **CIAO Principle 10 – Least-Privilege User**: No invented system-user requirement for binary lifecycle.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang in non-interactive mode.  
- **CIAO Principle 4 / 20 – Over-protect**: Protection Rule blocks privilege and UX regressions.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows cmd, or the same class (no root login on that shell):

| MUST | MUST NOT |
|------|----------|
| Keep **normal user privilege** only | Turn on **admin privilege** or **dedicated system user privilege** |
| Convert, queue, list, help, and local install into the user bin | In-tool `sudo`; wrap `apt` / `dnf`; `useradd`; write `/etc`; recommend `sudo curl | sh` |
| Document setup / approve / interactive as **unused** on that class | Invent a dedicated account on that class |

**This requirement:** dispatcher and help stay this-login commands; setup / approve / interactive stay unused on this class.

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS` is `Windows_NT` and `COMSPEC` names `cmd.exe` (after excluding Git Bash / WSL).

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail closed on unknown verbs, including trimmed parent verbs.  
- **Intentional**: Lifecycle Type 0 plus domain Type 0; Type 1 setup live; review loop live.  
- **Anti-fragile**: Same dispatcher contract as parent.  
- **Over-protect**: Do not reintroduce parent `backup` / `restore`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. List a verb in `help` that has no dispatcher arm, or reintroduce `backup` / `restore`.  
2. Change off-TTY empty argv from Type O install-ensure back to help while `SCRIPT_URL` is the product channel, or replace TTY empty argv with help or with self-install.  
3. Bypass `out_*` for user-facing messages.  
4. Hide the install channel in help/about, or advertise `CHECKSUM` as everyday UX.  
5. Collapse Type 1/2 into “just run as root.”  
6. Mix **test-purpose** verbs into **operational** help grouping, or treat a tester as submit / dest review / `setup` / host install.  
7. `sudo` on a test-purpose verb except wrapping **chmod** / **chown** of the **local test folder** (check before sudo).  
8. Drop `rc-test` from the dual-mention table without updating `requirement-shell-path-and-shell-support`, mix it into operational help grouping, or treat it as install / `setup`.

**Violating this rule is a critical CLI-surface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Help lists lifecycle Type 0 **and** every named domain/Type 1 verb in the Supported commands table (`sudoers-to-json` / `json-to-sudoers` / `test-json-format` / `test-well-known-binary` / `fence-test` / `rc-test` / `print-sudoers` / `print-sudoers-install-script` / `add-sudoer-request` / `update-sudoer-request` / `remove-sudoer-request` / `list-*` / `show` / `setup` / `remove-lpu` / `approve` / `reject` / `interactive` / `menu` / `main`) |
| AC-2 | Help and about omit `backup` / `restore` / `remove-project-sudoers` |
| AC-3 | Unknown and trimmed verbs exit non-zero |
| AC-4 | TTY empty argv is the numbered list. Off-TTY empty argv is Type O install-ensure. `--json` with no command is JSON help |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv |
| `requirement-shell-cli-default-interaction` | Dual mention of `menu` / `main`; numbered-list membership |
| `requirement-shell-self-management` | version-check / self-update / self-uninstall / about |
| `requirement-shell-cli-zero-arguments` | Type O empty argv |
| `requirement-shell-automatic-checksum` | companion `${SCRIPT_URL}.sha256` |
| `requirement-shell-output-requirements` | `out_*` |
| `requirement-bootstrap-chain` | Historical origin |
| `requirement-domain-sudoer-approval` | File-based JSON approval + verb catalog (Type 0 routed; Type 1 setup live) |
| `requirement-sudoers-file` | Dual mention of convert visudo / Cmnd arg escape |
| `requirement-incorrect-json-format` | Dual mention of Type 0 `test-json-format` |
| `requirement-well-known-sudoer-binary-fence` | Dual mention of Type 0 `test-well-known-binary` |
| `requirement-domain-sudoer-approval` | Dual mention of Type 0 `fence-test` |
| `requirement-three-layer-privilege-model` | Type 1 / Table A |
| `requirement-privilege-prevention-set` | Closed catalog of what Type 0 / Type 1 block vs must stay open |
| `requirement-shell-path-and-shell-support` | PATH / profile; `BASHRC`; dual mention `install` / `rc-test` / `self-uninstall` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-01..16** | `tests/test_cli.sh` | have | includes stripped-verb fail-closed + convert / `test-json-format` / `test-well-known-binary` / `fence-test` / `rc-test` routed |
| **TP-CLI-17** | `tests/test_cli.sh` | have | default-cli-main-menu-style printers (claimed menu uses them) |
| **TP-CLI-18..21** | `tests/test_cli.sh` | have | `menu` / `main` routed; off-TTY help; membership; interactive `--json` still list |
| **TP-LC-*** | `tests/test_local_lifecycle.sh` | have | online lifecycle |
| **TP-CURL-*** | `tests/test_online_curl_install.sh` | have | `curl \| sh` pipe |
| **TP-SR-PRIV-03** | `tests/test_domain_sr.sh` | have | live setup body (static) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-06 | Active 3.10.2 | Under command line for normal user only |
| 2026-08-03 | Active 1.0.0 | folder-backup Type 0 + domain verbs |
| 2026-08-13 | Active 2.0.0 | cli-template Type 0 only |
| 2026-08-13 | Active 3.0.0 | Specialize sudoer-cli; domain catalog owned by domain SSOT |
| 2026-08-14 | Active 3.1.0 | Type 0 domain live; `print-sudoers` not trimmed; Type 1 fail-closed Gap |
| 2026-08-14 | Active 3.1.1 | Type 1: TTY login review only via F6 + `interactive` |
| 2026-08-14 | Active 3.1.2 | Type 1 split: bootstrap any-admin `sudo setup`; approve stays F6 |
| 2026-08-14 | Active 3.2.0 | Live `setup`/`remove-lpu`; review loop still Gap |
| 2026-08-14 | Active 3.3.0 | Point prevention catalog (no invented Type 1 wall) |
| 2026-08-18 | Active 3.4.0 | Approve = any elevated sudoer (F6 extra); setup helps submit |
| 2026-08-20 | Active 3.5.0 | Dual mention Type 0 `test-json-format` |
| 2026-08-20 | Active 3.6.0 | Supported commands table names every routed domain / Type 1 verb (dual mention) |
| 2026-08-21 | Active 3.7.0 | Dual mention Type 0 `test-well-known-binary` |
| 2026-08-21 | Active 3.8.0 | Dual mention Type 0 `fence-test` |
| 2026-08-21 | Active 3.8.1 | `fence-test` examples: JSON file location; no `sudo` |
| 2026-08-21 | Active 3.8.2 | Test-purpose vs operational verbs; help lists testers apart; `VERSION` 1.15.2 |
| 2026-08-21 | Active 3.8.2 | Ship unit `VERSION` 1.15.3; test-purpose Next uses running checkout |
| 2026-08-21 | Active 3.8.2 | Stay-honest Implementation Notes `VERSION` 1.16.0 |
| 2026-08-21 | Active 3.8.2 | Stay-honest Implementation Notes `VERSION` 1.17.0 |
| 2026-08-26 | Active 3.8.3 | Stay-honest Implementation Notes `VERSION` 1.17.1 |
| 2026-08-26 | Active 3.8.4 | Convert verbs **point** at `requirement-sudoers-file` (text dual / visudo) |
| 2026-09-03 | Active 3.9.0 | Login-hook-symlink after global copy; default main menu **not** claimed; look printers **TP-CLI-17**; `VERSION` 1.18.0 |
| 2026-09-03 | Active 3.10.0 | Claimed case-3 `menu` / `main`; empty argv stays help; `VERSION` 1.19.0 |
| 2026-09-03 | Active 3.10.1 | Stay-honest Implementation Notes `VERSION` 1.20.0 |
| 2026-09-06 | Active 3.10.3 | Stay-honest Implementation Notes `VERSION` 1.21.0 |
| 2026-10-04 | Active 3.14.1 | Stay-honest `VERSION` 1.32.0. Login-hook path check does not rename a command filename. |
| 2026-10-04 | Active 3.14.0 | Stay-honest `VERSION` 1.31.0. Front **1** approval features. Front **7** sudoers. Languages stay **51–63**. Exit stays **99**. |
| 2026-10-04 | Active 3.13.0 | Stay-honest `VERSION` 1.30.0. TTY empty argv (including `--debug`) is the numbered list. Off-TTY empty argv stays Type O. `--json` with no command is JSON help. |
| 2026-10-02 | Active 3.12.3 | Stay-honest `VERSION` 1.29.0; menu **5** languages |
| 2026-09-13 | Active 3.12.3 | Stay-honest `VERSION` 1.28.0; hook doorbell `sudoer-review-hook` |
| 2026-09-13 | Active 3.12.2 | Stay-honest `VERSION` 1.27.0; hook doorbell `login-review-hook` |
| 2026-09-13 | Active 3.12.1 | Stay-honest `VERSION` 1.26.0; `menu` invalid-choice retry dual mention |
| 2026-09-09 | Active 3.12.0 | Dual mention Type 0 `rc-test`; `BASHRC` env; `VERSION` 1.25.0 |

---

**Last Updated**: 2026-10-04 (3.13.0 — TTY empty argv menu)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
