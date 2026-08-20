**file**: docs/requirements/requirement-shell-prompt.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-shell-prompt`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **how** sudoer-cli writes `prompt_*` helpers: yes/no confirm and value ask.

**Mode policy** (when a human may be prompted, how `TTY` is measured) stays in `requirement-shell-interactive-vs-noninteractive`. This file owns helper **bodies**, contracts, and worked samples.

### 1.1 Human-facing

**In one sentence:** Yes/no and ask helpers read TTY. They do not re-test the terminal themselves.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Answer a confirm | `sudo sudoer-cli interactive` |
| The other role | Non-interactive must not hang on a prompt | `--json` / no TTY |
| Not this file | When prompting is allowed | `requirement-shell-interactive-vs-noninteractive` |

| Includes | Excludes |
|----------|----------|
| Complete `prompt_yes_no` / `prompt_ask` bodies that consume TTY | Ad-hoc `read`; `--force` auto-approve; a second confirm family; a four-way dest menu |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | `prompt_*` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Confirm one file | Type yes to accept or no to reject. Enter is no. There is no skip or quit. | `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Ownership

| Helper | Role | Return |
|--------|------|--------|
| `prompt_yes_no` | Destructive / optional confirm | Exit **0** yes, **1** no/cancel |
| `prompt_ask` | Value with default | Chosen string on **stdout** (class-B; safe for `$(prompt_ask …)`) |

1. Domain and lifecycle **MUST NOT** call raw `read` for user-visible confirms.  
2. Prompt **question text** **MUST** go through `out_msg_n` / `out_*` — never raw product `printf` for the question.  
3. `prompt_ask` **MAY** `printf` the **return value only** (class-B). Human hints use `out_info`.

### 2.2 Consume mode SSOT (no-retest)

Helpers **MUST** read `TTY`, `JSON`, `QUIET`, and optional `INTERACTIVE`. They **MUST NOT** use live `[ -t 0 ]` / `[ -t 1 ]` as the interactive-policy gate.

| Condition | `prompt_yes_no` | `prompt_ask` |
|-----------|-----------------|--------------|
| `JSON=1` or `QUIET=1` | return 1 (no) | print default; return 0 |
| `TTY` is not `1` and `INTERACTIVE` is not `1` | return 1 | print default; return 0 |
| else | ask; `read` | ask; `read`; print answer or default |

`read` **SHOULD** use `/dev/tty` when the helper is designed for `$(prompt_ask)` so capture does not steal the answer. Direct `if prompt_yes_no; then` **MAY** `read` from stdin when `TTY=1`.

Measuring `[ -t` remains **outside functions** (interactive REQ).

### 2.3 Sufficient samples (normative shape)

These samples **are** the helper contract. Specialize names only if a later REQ says so.

```sh
prompt_yes_no() {
    : "${JSON:=0}"
    : "${QUIET:=0}"
    : "${TTY:=0}"
    local message="${1-}"
    if [ "${JSON}" -eq 1 ] || [ "${QUIET}" -eq 1 ]; then
        return 1
    fi
    if [ "${TTY}" -ne 1 ]; then
        return 1
    fi
    out_msg_n "${message} (y/N)? "
    local answer=""
    read -r answer || true
    case "${answer}" in
        [Yy]*|[Yy][Ee][Ss]*) return 0 ;;
        *) return 1 ;;
    esac
}
```

```sh
prompt_ask() {
    : "${JSON:=0}"
    : "${QUIET:=0}"
    : "${TTY:=0}"
    : "${INTERACTIVE:=0}"
    local message="${1-}"
    local default="${2-}"
    local current="${3-}"
    if [ "${JSON}" -eq 1 ] || [ "${QUIET}" -eq 1 ]; then
        printf '%s' "${default}"
        return 0
    fi
    if [ "${TTY}" -ne 1 ] && [ "${INTERACTIVE}" -ne 1 ]; then
        printf '%s' "${default}"
        return 0
    fi
    if [ -n "${current}" ]; then
        out_info "Current: ${current}"
    fi
    if [ -n "${default}" ]; then
        out_info "Default: ${default}"
    fi
    out_msg_n "${message}: "
    local answer=""
    if [ -c /dev/tty ] && ( : </dev/tty ) 2>/dev/null; then
        read -r answer </dev/tty || true
    else
        read -r answer || true
    fi
    if [ -z "${answer}" ]; then
        printf '%s' "${default}"
    else
        printf '%s' "${answer}"
    fi
}
```

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **Ship unit** | `src/sudoer-cli` |
| **Live confirm** | `uninstall` uses `prompt_yes_no` unless `--force` |
| **Dest review** | `interactive` uses **one** `prompt_yes_no` per unfenced inbound file (yes=approve, no/Enter=reject). Domain SSOT owns that mapping. **MUST NOT** add a second helper or a skip/quit menu |
| **Value ask** | `prompt_ask` reserved; domain must not add ad-hoc `read` |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 16**: Prompt helpers implement mode policy.  
- **Principle 1**: Never hang under json/quiet/non-TTY.  
- **Principle 5**: Question text via `out_*`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Default / no when machine mode.  
- **Intentional:** One yes/no helper; one ask helper.  
- **Anti-fragile:** Capture-safe ask (`/dev/tty` when openable).  
- **Over-protect:** Do not “simplify” to raw `read`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Re-test live `[ -t 0 ]` / `[ -t 1 ]` inside `prompt_*` as the policy gate.  
2. Replace `out_msg_n` with raw `printf` for the question.  
3. Auto-yes on json/quiet/non-TTY.  
4. Add a second confirm family beside `prompt_yes_no`.  
5. Turn dest review into three chained `(y/N)` questions (Approve / Reject / Quit) or a skip/quit menu. The dest approval question uses this helper **once**.

**Violating this rule is a critical prompt regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | `prompt_yes_no` / `prompt_ask` gate on `TTY`/`JSON`/`QUIET` only |
| AC-2 | No live `[ -t` policy check inside those functions |
| AC-3 | Uninstall JSON without force still fail-closed (no hang) |
| AC-4 | Samples in §2.3 remain complete (not a field table only) |
| AC-5 | Dest `interactive` uses this helper once per unfenced file (domain SSOT; **TP-SR-INT-06**) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-interactive-vs-noninteractive` | Mode SSOT; TTY measured outside functions |
| `requirement-shell-output-requirements` | `out_msg_n` / `out_info` |
| `requirement-shell-local-self-management` | Uninstall confirm |
| `requirement-domain-sudoer-approval` | Dest review one-off yes/no (approval-question) |
| `requirement-shell-modular-function-design` | `prompt_` prefix |
| `docs/requirements/index.md` | Registry |

---

## 7. Design-time verification

| TP-ID | Intent | Suite |
|-------|--------|-------|
| TP-LC-05 | Uninstall JSON no force fail-closed | `tests/test_local_lifecycle.sh` |
| TP-ELEV-07 | Static: `prompt_*` / `app_about` consume `TTY`; no live `[ -t` policy gate | `tests/test_cli.sh` |
| TP-SR-INT-06 | Dest review is one `prompt_yes_no` (yes=approve, no=reject) | `tests/test_domain_sr.sh` |

---

## 8. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-14 | Active 1.0.0 | Prompt helper SSOT; samples consume `TTY` |
| 2026-08-20 | Active 1.1.0 | Dest review uses this helper once (approval-question); no skip/quit family |

---

**Last Updated**: 2026-08-20  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
