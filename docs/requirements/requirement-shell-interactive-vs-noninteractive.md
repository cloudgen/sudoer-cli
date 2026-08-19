**file**: docs/requirements/requirement-shell-interactive-vs-noninteractive.md  
**Status**: Active (Version 1.3.0)  
**Area**: shell  
**Key**: `requirement-shell-interactive-vs-noninteractive`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for how sudoer-cli behaves in **interactive** (human + TTY) versus **non-interactive** (automation, CI/CD, pipes, `--json` / often `--quiet`) environments.

### 1.1 Human-facing

**In one sentence:** Whether a human is at a terminal is measured once, outside helpers. The review loop must not steal stdin from the prompt.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Confirm on a real terminal | `sudo sudoer-cli interactive` |
| The other role | Automation with --json must not hang | `sudoer-cli --json version` |
| Not this file | Prompt helper bodies | `requirement-shell-prompt` |

| Includes | Excludes |
|----------|----------|
| TTY measured outside functions; helpers consume TTY; review loop does not steal stdin | Live `[ -t` inside `prompt_*`; empty argv as review |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | TTY / prompt |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Review on a TTY | The program already knows it is interactive. Prompts still need a terminal. Pipes must fail closed, not hang. | `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Definitions

| Mode | Definition |
|------|------------|
| **Interactive** | Human + usable TTY; confirmations allowed when not overridden by machine flags |
| **Non-interactive** | No human available: CI, scripts, pipes, `--json` (and often `--quiet`). **Must never hang** waiting for input |

### 2.2 Detection (mode SSOT)

| Signal | Variable / check | Meaning |
|--------|------------------|---------|
| TTY | `TTY=1` when stdin and stdout are terminals **at measurement time** | Interactive UX possible |
| Quiet | `QUIET=1` | Suppress non-essential human chatter |
| JSON | `JSON=1` (implies quiet) | Machine output; no human hang |
| Debug | `DEBUG=1` | Extra stderr diagnostics |
| Force | `FORCE=1` | Skip confirms / force reinstall where documented |

**TTY measurement (no-retest):**

1. Live `[ -t 0 ]` / `[ -t 1 ]` that decide **interactive capability** **MUST** run in the **main process, outside functions** (script top after defaults). After `--json` / `--quiet` parse, `app_main` **MAY** refresh the same globals in the main process.  
2. A dedicated **direct mode setter** that **assigns** `TTY` (never invoked only via `$(…)`) counts as main-process measurement.  
3. Helpers (`prompt_*`, `out_*` color, `app_about`, domain confirm) **MUST consume** `TTY` / `JSON` / `QUIET` / `FORCE`. They **MUST NOT** re-test live `[ -t 0 ]` / `[ -t 1 ]` as the sole interactive-policy gate (prompt, color, confirm, “can we prompt?”).  
4. Allowed exception: probing **whether this invocation’s stdin is a pipe vs a terminal** to choose a **data source** (e.g. `--file` xor stdin) is not interactive-capability SSOT.  
5. “Never call `[ -t` anywhere” is **wrong** — entry / main-process measurement is required.

Rules:

1. Prompt decisions **MUST** use shared `prompt_*` helpers — not ad-hoc `read` in domain logic.  
2. After flags are parsed in `app_main`, subsequent code **MUST** see updated mode globals.  
3. Do **not** invent a second parallel mode system per command.

### 2.3 Behavioral matrix (this product)

| Action | Interactive | Non-interactive |
|--------|-------------|-----------------|
| `uninstall` | Confirm unless `--force` | **Fail closed** without `--force` (`confirm_required`) |
| `install` | May inform; no required confirm for first install | Proceed without hang |
| `interactive` (Type 1) | Review loop when `TTY=1` and authz holds (domain SSOT). Id walk **MUST NOT** redirect stdin over `prompt_yes_no` | **Fail closed** `confirm_required` — no hang. `--json` same. `--force` does **not** auto-approve |
| Login hook (LPU `.bashrc`) | May launch `sudo -n … interactive` once | **Skip** (`scp` / `SSH_ORIGINAL_COMMAND` / no TTY / no `PS1`). `sudo -n` failure is a warning; login continues |
| Missing required operand | Clear error | Clear error; non-zero exit |

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **No curl\|sh auto-install path** | Local-only; non-interactive does not mean Type O install-ensure |
| **Prompt helper** | `prompt_yes_no` for uninstall (and any future destructive confirm); helpers **read `TTY`**, they do not re-test `[ -t` |  
| **TTY SSOT** | Set once at script top (`[ -t 0 ] && [ -t 1 ] && TTY=1`); consume thereafter |
| **Domain review** | `interactive` loop and hook snippet owned by `requirement-domain-sudoer-approval`; this file owns mode / no-hang |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 16 – Interactive vs Non-Interactive**  
- **Principle 1 – Caution**: Never hang automation  
- **Principle 14 – Traceability**: Errors visible under quiet/json contracts

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail closed on destructive ops without force in non-interactive.  
- **Intentional:** One mode SSOT.  
- **Anti-fragile:** CI-safe.  
- **Over-protect:** No bare `read` in domain paths.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Hang on stdin in non-interactive/json modes.  
2. Auto-yes destructive uninstall without `--force` in non-interactive mode.  
3. Scatter unguarded `read` calls outside `prompt_*`.  
4. Treat non-interactive as license to skip required validation.  
5. Re-test live `[ -t 0 ]` / `[ -t 1 ]` **inside functions** as the interactive-policy gate (`prompt_*`, `app_about`, color, “can we prompt?”). Measure outside functions; helpers consume `TTY`.  
6. Let the login hook hang `scp` / CI, or `exit` the login shell when `sudo -n` fails.  
7. Treat a TTY login as license to turn empty argv into `interactive`.  
8. Walk `interactive` ids with a stdin redirect (`done <file` / here-doc) so `prompt_yes_no` hits EOF and auto-skips.

**Violating this rule is a critical interaction-mode regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Non-interactive uninstall without force fails closed |
| AC-2 | JSON mode never prompts |
| AC-3 | Lifecycle commands never hang waiting for optional confirm by default |
| AC-4 | Interactive capability is measured **outside functions**; `prompt_*` / `out_*` / `app_about` consume `TTY` (no live `[ -t` policy gate) |
| AC-5 | `interactive` without `TTY=1` fails closed; hook skips non-interactive login |
| AC-6 | When `TTY=1`, `sr_interactive` **MUST** leave fd 0 for `prompt_yes_no` (walk ids on another fd). Auto-skip from EOF on the id file is forbidden |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Flags |
| `requirement-shell-local-self-management` | Uninstall confirm |
| `requirement-shell-output-requirements` | Quiet/json emission; colors consume `TTY` |
| `requirement-shell-modular-function-design` | `prompt_*` consume `TTY` |
| `requirement-shell-prompt` | Helper bodies + samples |
| `requirement-domain-sudoer-approval` | `interactive` loop + login hook |
| `requirement-shell-cli-zero-arguments` | Empty argv ≠ review |
| `docs/requirements/index.md` | Registry |

---

## 7. Design-time verification

| TP-ID | Intent | Suite |
|-------|--------|-------|
| TP-LC-05 | Uninstall JSON without force fails closed | `tests/test_local_lifecycle.sh` |
| TP-ELEV-07 | Static: `prompt_*` / `app_about` consume `TTY` | `tests/test_cli.sh` |
| TP-SR-INT-02 | `interactive` non-TTY / `--json` fail closed | `tests/test_domain_sr.sh` |
| TP-SR-INT-05 | Review loop does not steal stdin from `prompt_yes_no` | `tests/test_domain_sr.sh` |

---

## 8. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Interactive vs non-interactive for folder-backup |
| 2026-08-14 | Active 1.1.0 | TTY measured outside functions; helpers consume `TTY` (no-retest) |
| 2026-08-14 | Active 1.2.0 | Matrix: Type 1 `interactive` + login hook; no-hang / no empty-argv hijack |
| 2026-08-15 | Active 1.3.0 | AC-6: `TTY=1` loop must not steal stdin; **TP-SR-INT-05** |

---

**Last Updated**: 2026-08-15  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
