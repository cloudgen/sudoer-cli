**file**: docs/requirements/requirement-shell-temp-file-system.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-temp-file-system`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **scratch file leaves** in sudoer-cli: unique names, cleanup, and modes.

**Root resolve** stays in `requirement-shell-cli-storage` (`util_resolve_storage`, `EFFECTIVE_STORAGE_DIR`, export `TMPDIR`). This file owns **how** a temp file is created under that root.

### 1.1 Human-facing

**In one sentence:** Scratch files are created with mktemp. Predictable `$$` names are forbidden. Cleanup is required.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Convert or visudo a private copy | `sudoer-cli json-to-sudoers --file request.json` |
| The other role | Root of the scratch tree | `requirement-shell-cli-storage` |
| Not this file | Queued grant JSON | `requirement-domain-sudoer-approval` |

| Includes | Excludes |
|----------|----------|
| `mktemp`; cleanup; no `$$` paths | Predictable names; leaving visudo copies behind |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | `util_mktemp` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Convert JSON | The program makes a private sudoers copy, checks it, then removes the copy. | `sudoer-cli json-to-sudoers --file request.json` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Split of ownership

| Layer | Owner | Owns |
|-------|-------|------|
| Root | `requirement-shell-cli-storage` | Isolation, priority, create-before-return, `TMPDIR` |
| Leaf | **this requirement** | `mktemp` names, no predictable `$$` paths, cleanup |

### 2.2 Unique leaves (mandatory)

1. Scratch files **MUST** be created with `mktemp` (or `mktemp -d`) under `${TMPDIR}` after storage resolve (`${TMPDIR}/${APP_NAME}.XXXXXX` shape).  
2. **MUST NOT** use predictable names as the only entropy: `/tmp/sr-enc.$$`, `/tmp/sr-parse.in.$$`, `/tmp/${APP_NAME}.tmp`, fixed `sudoer-cli-….sh` under `/tmp`.  
3. `$$` in `ps -p $$` (current PID query) is **not** a temp path and is allowed.  
4. One helper **SHOULD** own creation: `util_mktemp` (stdout path; class-B). Callers **MUST NOT** invent a second leaf policy.  
5. If `mktemp` fails → **fail closed** via `out_*` / `sr_die`.

### 2.3 Cleanup

1. Remove the file on the success path after the last read.  
2. Remove on failure paths (including `sr_die` / `out_die`) — register the path and clean in a process `trap` and/or the fatal helper.  
3. Re-runs **MUST NOT** require leftover `$$` files to be absent (idempotent).

### 2.4 Consumers (this product)

| Consumer | Family | Rule |
|----------|--------|------|
| Install stage | install staging | already `mktemp` under storage root |
| `visudo -cf` private copy | convert / approve | `mktemp`; never in-place `/etc/passwd` or `/etc/sudoers.d` |
| Convert encode/parse/infer/decode scratch | convert | `util_mktemp`; never `sr-*.$$` |
| Approve private body | Type 1 | `mktemp` |
| Admin script / draft emit | print helpers | `mktemp` (not a fixed basename under `/tmp`) |

Domain **JSON schema** and **sudoers grammar** stay in `requirement-domain-sudoer-approval`. This REQ does not redefine those samples.

### 2.5 Sufficient samples

```sh
util_mktemp() {
    : "${TMPDIR:=/tmp}"
    : "${APP_NAME:=sudoer-cli}"
    _um=$(mktemp "${TMPDIR}/${APP_NAME}.XXXXXX") || {
        out_text out_error "mktemp failed"
        exit 1
    }
    SCRATCH_FILES="${SCRATCH_FILES-} ${_um}"
    printf '%s' "${_um}"
}

util_scratch_cleanup() {
    for _sf in ${SCRATCH_FILES-}; do
        if [ -n "${_sf}" ]; then
            rm -f "${_sf}"
        fi
    done
    SCRATCH_FILES=""
}
```

```sh
# Convert scratch (correct)
_tf=$(util_mktemp)
printf '%s' "${_cmds}" >"${_tf}"
while IFS='|' read -r _a _b _c _d || [ -n "${_c-}" ]; do
    :
done <"${_tf}"
rm -f "${_tf}"
```

```sh
# Forbidden
printf '%s' "${_cmds}" >"${TMPDIR:-/tmp}/sr-enc.$$"
```

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **Helper** | `util_mktemp` / `util_scratch_cleanup` in `src/sudoer-cli` |
| **Root** | `TMPDIR=${EFFECTIVE_STORAGE_DIR}` set in `app_main` |
| **Trap** | `EXIT` cleanup of `SCRATCH_FILES` |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 11 – Temps:** unique names, cleanup, not museum copies.  
- **Principle 1:** no symlink-race predictable paths (CWE-377 class).  
- **Principle 22:** modes via `chmod`/`install -m` on the path, not sticky script umask.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** `mktemp` or fail closed.  
- **Intentional:** storage = root; this REQ = leaf.  
- **Anti-fragile:** works when `/tmp` is shared; isolation is the root.  
- **Over-protect:** trap plus explicit `rm`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Reintroduce `/tmp/sr-*.$$` or other PID-only scratch names.  
2. Skip cleanup on `sr_die` / `out_die`.  
3. Invent a second root chain that contradicts storage resolve.  
4. Treat this REQ as domain JSON/sudoers schema (those stay on the domain SSOT).

**Violating this rule is a critical temp-safety regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Convert/parse/infer/encode/decode scratch uses `mktemp` / `util_mktemp` |
| AC-2 | No `/tmp/sr-*.$$` (or `${TMPDIR}/sr-*.$$`) in the ship unit |
| AC-3 | Convert suite still passes after the leaf change |
| AC-4 | Samples in §2.5 remain complete |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-storage` | Root + `TMPDIR` |
| `requirement-shell-local-self-management` | Install stage `mktemp` |
| `requirement-domain-sudoer-approval` | Convert/approve consumers |
| `requirement-project-folder` | Path classes |
| `docs/requirements/index.md` | Registry |

---

## 7. Design-time verification

| TP-ID | Intent | Suite |
|-------|--------|-------|
| TP-TMP-01 | Static: no predictable `sr-*.$$` scratch paths | `tests/test_cli.sh` |
| TP-TMP-02 | Convert still succeeds after `mktemp` leaves | `tests/test_domain_sr.sh` (TP-SR-03) |
| TP-CLI-12 | Isolated storage root / `TMPDIR` parent | `tests/test_cli.sh` |
| TP-LC-01 | Install stage unique leaf | `tests/test_local_lifecycle.sh` |

---

## 8. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-14 | Active 1.0.0 | Leaf `mktemp`; ban `$$` scratch |

---

**Last Updated**: 2026-08-14  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
