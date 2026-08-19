# Report: sudo escalation check — sudoer-cli 1.1.1

**Date:** 2026-08-14  
**Updated:** 2026-08-14 (avoid `sudo -n` unless specified / **T1-N-POLLUTE**)  
**Mode:** revision (sudo escalation)  
**Status:** Check **have** (TP-ELEV-08 + TP-SR-PRIV-02). Live `useradd` still Gap.  
**Lessons loaded:** yes (`L-ELEV-BOOT-01`, `L-ELEV-N-01`, `L-TEST-OP-01`)  
**Suite this run:** recorded in `reviews/test-plan.md` after `./tests/run.sh`

## Summary

Two defects, one class: **`sudo -n` leaked as default elev**.

1. **T1-BOOTSTRAP-N** — first-time `setup` was gated as if `sudo -n` + `SUDO_USER==sudoer-adm`. `-n` is a NOPASSWD **ticket check**, not escalation. Install is multi-user.  
2. **T1-N-POLLUTE** — skills/molds taught `root → sudo -n → password sudo` as the portable ladder, so agents paste `-n` into products that never specified a grant.

**Revision:** Default is already-root or outer `sudo` (password OK). Write `sudo -n` **only** when specialized law **specifies** it. This product specifies `-n` only for the F6 login hook after the grant exists. **TP-ELEV-08** proves: no invocation; help/refuse are outer `sudo`; any help `-n` sits next to F6/hook.

## Escalation check (what must stay true)

| Path | Allowed elev | Forbidden |
|------|----------------|-----------|
| Local `install` | invoking user → `USER_BIN` | require root / `-n` |
| Global `install` / `setup` | already-root **or** outer `sudo` (password OK, any admin) | `sudo -n`; require `sudoer-adm` |
| `approve` / `reject` / `interactive` | any already euid-0 host admin (password `sudo`), F6 `sudoer-adm`, or real root login | LPU euid without sudo; non-root |
| Login hook (law, not installed) | `sudo -n` **only after F6** (this product **specifies** it) | password `sudo` in `.bashrc`; `-n` as default / bootstrap |
| Skills / molds / help | omit `-n` unless law names the grant | copy `-n` from a mold as boilerplate |

Ship unit **MUST** check `id -u` for Type 1. After password `sudo`, do **not** require `SUDO_USER==sudoer-adm`. Mix model: the ship unit **MAY** invoke password `sudo` for Table C jobs (`useradd`).

## Findings

### SC-ELEV-01 — Severity: P1 — **fixed** (1.1.1)

- **Area:** Type 1 bootstrap authz  
- **Location:** `sr_require_type1` used to reject any `SUDO_USER` ≠ `sudoer-adm`  
- **Description:** Chicken-egg. `setup` creates `sudoer-adm` / F6 but required them first.  
- **Suggestion (done):** `sr_require_type1_bootstrap` = euid 0 only. Approver verbs also euid 0 only after INC-20260818-001 (F6 is extra, not exclusive).  
- **Test:** TP-SR-PRIV-02, TP-ELEV-08  
- **Cross-ref:** incident `20260814-001`; `L-ELEV-BOOT-01`; mold §8.1.4  

### SC-ELEV-02 — Severity: P2 — **fixed**

- **Area:** TEST  
- **Description:** Review treated TP-SR-PRIV-01 as “setup reviewed.” No portable elev-check row.  
- **Suggestion (done):** **TP-ELEV-08**. Keep TP-ELEV-01..05 **n/a**.  
- **Test:** `tests/test_cli.sh` TP-ELEV-08  

### SC-ELEV-05 — Severity: P1 — **fixed** (this update)

- **Area:** DOC / skill / style SSOT  
- **Description:** Portable ladder listed `sudo -n` as a default rung. That is **knowledge pollution**.  
- **Suggestion (done):** Mold §8.1.4 + skill v2.8.0: **avoid `-n` unless specified**. Subclass **T1-N-POLLUTE**. Lesson **L-ELEV-N-01**. TP-ELEV-08 now fails help that mentions `-n` without F6/hook.  
- **Test:** TP-ELEV-08 (specified-exception assert)  

### SC-ELEV-03 — Severity: P2 — **open**

- **Area:** TEST / operator PATH  
- **Description:** Suite still invokes `sh "${SCRIPT}"`, not bare `sudoer-cli` / sudo secure_path.  
- **Suggestion:** Isolated `command -v` cases (no host sudo).  
- **Test:** L-TEST-OP-01  

### SC-ELEV-04 — Severity: P3 — **open** (Gap, honest)

- **Area:** live `useradd` / hook  
- **Description:** `lpu_setup` still dies `live useradd setup is not enabled`. Hook `-n` is law-only.  
- **Suggestion:** Do not close as “setup works.” Enable live LPU only on explicit operator order.  

## Non-findings

| Check | Result |
|-------|--------|
| In-tool `sudo -n` invocation | Absent (TP-ELEV-08) |
| Help `sudo -n sudoer-cli setup` / `install` | Absent |
| Help `-n` only with specified F6/hook | Present (this product specifies hook) |
| Approve gate euid 0 only (any elevated sudoer) | Present (TP-SR-PRIV-04 / TP-ELEV-09) |
| Package password-sudo ladder TP-ELEV-01..05 | Still **n/a** (not claimed) |
| no-retest-tty TP-ELEV-07 | **have** |

## Verdict

**Pass** on the sudo escalation **check** and the default-avoid-`-n` rule. **Revise** remains for live `useradd` (Gap) and operator PATH cases.

## Related

| Artifact | Role |
|----------|------|
| `src/sudoer-cli` `sr_require_type1_bootstrap` | Bootstrap gate |
| `reviews/test-plan.md` **TP-ELEV-08** | This check |
| `docs/templates/requirements/template-shell-script-coding.md` §8.1.4 | Style SSOT |
| `docs/skills/skill-sh-script-coding.md` v2.8.0 | Avoid `-n` unless specified |
| `docs/incidents/incident-20260814-001-setup-operator-path-untested.md` | Operator PATH |

**Written by:** Implement (single-agent; not multi-agent council)  
**Review status:** SC-ELEV-01/02/05 fixed; SC-ELEV-03/04 open
