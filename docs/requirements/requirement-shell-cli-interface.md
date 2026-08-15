**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 3.3.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-interface`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of sudoer-cli: live command surface, privilege typing, global flags, dispatcher behavior, help/about contracts, and mode rules.

The **live** dispatcher is Type 0 lifecycle **plus** Type 0 domain convert/submit/list/show/print-sudoers. Domain catalog and Type 1 fail-closed behavior are owned by `requirement-domain-sudoer-approval.md` and `requirement-three-layer-privilege-model.md`. Help **MUST NOT** list a verb with no `case` arm. Full lifecycle rules live in `requirement-shell-local-self-management.md`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every command **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning |
|----------|-----------|---------|
| **Type 0 – CLI lifecycle + diagnostics + domain convert** | Invoking user | Lifecycle: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`. Domain Type 0: convert / submit / list / show / `print-sudoers` (catalog on domain SSOT) |
| **Type 1 – Narrow elevated host ops** | Controlled sudo | Names **routed**; **fail closed** without euid 0. **`setup` / `remove-lpu`**: any host admin already euid 0 (`sudo {{APP}} setup`, password OK; not `sudo -n`; not limited to `sudoer-adm`). Live: useradd, F6, hook. **`approve` / `reject` / `interactive`**: F6 `sudoer-adm` or real root. Review-loop body is **live** |
| **Type 2 – Dedicated system user app ops** | Dedicated app user euid | **Not used** (sudoer-adm is an authorizer, not a Type 2 execution context) |

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output |
| `--debug` | `DEBUG=1` | Extra diagnostics on stderr; must not break JSON purity on stdout |
| `--force` | `FORCE=1` / force policy | Skip uninstall confirm or force reinstall only where documented |
| `--global` | `FORCE_GLOBAL=1` | Install to `GLOBAL_BIN` |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

**Forbidden flags (trimmed):** `--allow-test-local`, `--disk`, `--ram` (parent domain / sudoers).

### 2.3 Dispatcher and entry rules

1. **Single entry:** `app_main` **MUST** parse global flags and route commands.  
2. **Unknown command:** **MUST** fail loudly with pointer to `help` (via output SSOT).  
3. **Empty argv:** **Type N → help** (`requirement-shell-cli-zero-arguments.md`).  
4. **No raw user I/O:** User-facing messages **MUST** go through `out_*`.  
5. Script end **MUST** call `app_main "$@"` (no basename gate that blocks dispatch).  
6. Trimmed parent verbs (`backup`, `restore`, `remove-project-sudoers`) **MUST** fail as unknown. `print-sudoers` and `print-sudoers-install-script` are **domain Type 0** (not trimmed).

### 2.4 Help surface

`help` **MUST** list:

- Usage line  
- Every supported Type 0 command with one-line purpose  
- Global flags  
- Honest note that this product is local-only (no curl\|sh)

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object.

`help` **MUST** list live domain Type 0 rows per the domain SSOT. `help` **MUST NOT** list a verb with no dispatcher arm.

### 2.5 Implementation Notes (this project)

| Item | Value for sudoer-cli |
|------|-------------------------|
| **Product / binary name** | `sudoer-cli` (`APP_NAME`) |
| **Primary executable** | `src/sudoer-cli` (POSIX `/bin/sh`, single-file ship unit) |
| **Dispatcher** | `app_main` |
| **Output SSOT** | `out_text` + wrappers (`out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_json`, …) |
| **Version SSOT** | `VERSION="1.6.1"` hard-assign in ship unit |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Primary install story** | User bin: `~/.local/bin/sudoer-cli`; global `/usr/local/bin/sudoer-cli` for production F6 |
| **Online channel env** | **Not product UX** (trimmed) |
| **Type 1 / Type 2 commands** | Type 1 **routed, fail closed** without euid 0; setup = any admin sudo (live useradd/F6/hook); approve = F6; Type 2 **not used** |
| **Dedicated system user** | `sudoer-adm` (authorizer; see LPU REQ) |
| **About** | Type 0 only until domain about pillar is routed |

#### Supported commands (normative for this project)

| Command | Type | Handler family | Required behavior |
|---------|------|----------------|-------------------|
| *(no args — empty argv)* | Type 0 | `app_main` → `app_help` | **Type N help** — not install |
| `install` | Type 0 | `inst_local_install` | Copy running ship unit to privilege-correct bin; idempotent unless `--force` |
| `uninstall` | Type 0 | `inst_local_uninstall` | Remove managed binary; confirm unless `--force` |
| `where-is-me` | Type 0 | `app_where_is_me` | Running + install paths + installed flag |
| `version` | Type 0 | `app_version` | Local `VERSION` only; no network |
| `about` | Type 0 | `app_about` | Diagnostics: install presence, paths, user, shell, TTY, storage, **resolved queue paths**; **no** channel one-liner; **no** backup/restore fields |
| `help` | Type 0 | `app_help` | Full usage in human mode; short JSON note in JSON mode |

#### Global flags (normative wiring)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | `QUIET=1` in `app_main` |
| `--json` | `JSON=1` and `QUIET=1` in `app_main` |
| `--debug` | `DEBUG=1` in `app_main` |
| `--force` | `FORCE=1` (and install reinstall policy when applicable) |
| `--global` | `FORCE_GLOBAL=1` |

#### Dispatcher acceptance criteria

1. Unknown token after flag parse → `out_die` with pointer to `sudoer-cli help`.  
2. Zero-arg → help (not install).  
3. Command routing table in `app_main` **must** include every lifecycle row above **and** the live domain Type 0 verbs from the domain SSOT, and **no** trimmed parent verbs (`backup` / `restore` / `remove-project-sudoers`).  
4. Help text **must** stay aligned with that table.

#### Explicitly out of scope

- Online: `version-check`, `self-update`, `self-uninstall`, channel `install` via URL  
- Domain: `backup`, `restore`  
- Parent leftovers: `backup`, `restore`, `remove-project-sudoers`  
- Type 2 app runtime euid under sudoer-adm  
- `sr_interactive` review-loop body (live)  

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

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail closed on unknown verbs, including trimmed parent verbs.  
- **Intentional**: Lifecycle Type 0 plus domain Type 0; Type 1 setup live; review loop still Gap.  
- **Anti-fragile**: Same dispatcher contract as parent.  
- **Over-protect**: Do not reintroduce parent `backup` / `restore`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. List a verb in `help` that has no dispatcher arm, or reintroduce `backup` / `restore`.  
2. Change empty argv from Type N help to install-ensure.  
3. Bypass `out_*` for user-facing messages.  
4. Advertise an online install channel in help/about.  
5. Collapse Type 1/2 into “just run as root.”

**Violating this rule is a critical CLI-surface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Help lists lifecycle Type 0 **and** `sudoers-to-json` / `json-to-sudoers` / `add-sudoer-request` / `print-sudoers` |
| AC-2 | Help and about omit `backup` / `restore` / `remove-project-sudoers` |
| AC-3 | Unknown and trimmed verbs exit non-zero |
| AC-4 | Empty argv is help |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv |
| `requirement-shell-local-self-management` | install / uninstall / where-is-me |
| `requirement-shell-output-requirements` | `out_*` |
| `requirement-bootstrap-chain` | Historical origin |
| `requirement-domain-sudoer-approval` | File-based JSON approval + verb catalog (Type 0 routed; Type 1 setup live) |
| `requirement-three-layer-privilege-model` | Type 1 / Table A |
| `requirement-privilege-prevention-set` | Closed catalog of what Type 0 / Type 1 block vs must stay open |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-01..14** | `tests/test_cli.sh` | have | includes stripped-verb fail-closed + convert routed |
| **TP-LC-*** | `tests/test_local_lifecycle.sh` | have | lifecycle |
| **TP-SR-PRIV-03** | `tests/test_domain_sr.sh` | have | live setup body (static) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup Type 0 + domain verbs |
| 2026-08-13 | Active 2.0.0 | cli-template Type 0 only |
| 2026-08-13 | Active 3.0.0 | Specialize sudoer-cli; domain catalog owned by domain SSOT |
| 2026-08-14 | Active 3.1.0 | Type 0 domain live; `print-sudoers` not trimmed; Type 1 fail-closed Gap |
| 2026-08-14 | Active 3.1.1 | Type 1: TTY login review only via F6 + `interactive` |
| 2026-08-14 | Active 3.1.2 | Type 1 split: bootstrap any-admin `sudo setup`; approve stays F6 |
| 2026-08-14 | Active 3.2.0 | Live `setup`/`remove-lpu`; review loop still Gap |
| 2026-08-14 | Active 3.3.0 | Point prevention catalog (no invented Type 1 wall) |

---

**Last Updated**: 2026-08-14  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
