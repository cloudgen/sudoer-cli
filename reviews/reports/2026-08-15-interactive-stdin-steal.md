# Product review: sudoer-cli (interactive stdin steal)

**Date:** 2026-08-15  
**Reviewer:** Implement (same session as 1.6.1 fix; formal `/review` follows)  
**Product:** sudoer-cli `VERSION=1.6.1`  
**Ship unit:** `src/sudoer-cli`  
**Scope:** Type 1 `interactive` TTY confirm path after `sudoer-adm` login hook (`source ~/.bashrc`)  
**Method:** Operator paste + disk read of `sr_interactive` / `prompt_yes_no` + suite  
**Baseline:** see `./tests/run.sh` this change  
**Incident:** INC-20260815-001

## Summary

1.6.0 shipped a live review loop that printed approve / reject / quit and then auto-skipped. The hook and `TTY=1` were correct. The id walk redirected stdin over the basename list, so `prompt_yes_no` read EOF. That is fail-closed skip (not auto-approve). 1.6.1 walks ids on fd 3. Law (domain 2.14.0, interactive 1.3.0 AC-6) and **TP-SR-INT-05** now name the redirect shape. Host TTY re-run after install is still open.

## Strengths

| Area | Notes |
|------|--------|
| Fail-closed skip | Empty `read` is No; `--force` still does not approve |
| Helper SSOT | Loop still uses `prompt_yes_no`; no second confirm family |
| Hook | F6 `sudo -n` + TTY guards were not the defect |
| Law split | Domain owns the walk; interactive REQ owns mode; prompt REQ still allows stdin `read` |

## Findings

### SR-INT-01 — Severity: P1 (high)
- **Area:** INT / stdin  
- **Status:** fixed (1.6.1 — ids on fd 3)  
- **Location:** `sr_interactive` `while IFS= read -r _bn <&3` … `done 3<"${_sorted}"`  
- **Description:** 1.6.0 used `done <"${_sorted}"`. With one inbound file every `prompt_yes_no` hit EOF and skipped.  
- **Impact:** Approver on a TTY could not answer. Pending grants stayed inbound (skip), but review was unusable.  
- **Suggestion:** Keep ids off fd 0. Do not “fix” via `/dev/tty` as a second policy gate or a new helper.  
- **Cross-ref:** INC-20260815-001; domain §2.2 item 3; interactive AC-6; **TP-SR-INT-05**  

### SR-INT-02 — Severity: P2 (medium)
- **Area:** TEST  
- **Status:** fixed (shape grep + leftover fd-0 check + class steal/fd3 sim; live quit when euid 0)  
- **Location:** `tests/test_domain_sr.sh`  
- **Description:** INT-01..04 never executed a pending-id prompt on a TTY. “Uses `prompt_yes_no`” greened a broken loop.  
- **Impact:** Same class as fail-closed `setup` tests hiding a Gap stub.  
- **Suggestion:** Keep leftover-fd-0 grep + class sim. Live Type 1 quit (`n/n/y`) remains host/root-only.  
- **Cross-ref:** L-INT-STDIN-01  

### SR-INT-03 — Severity: P3 (low)
- **Area:** UX / `sr_show`  
- **Status:** open  
- **Location:** `sr_show` `cat "${_path}"`  
- **Description:** Interactive dump is one minified JSON line (operator paste was tens of kilobytes).  
- **Impact:** Hard to review; not why answers were impossible.  
- **Suggestion:** Pretty-print for human `show` / `interactive` without changing JSON machine mode. Separate change.  

### SR-HOST-02 — Severity: P2 (medium)
- **Area:** HOST  
- **Status:** open  
- **Location:** host `git` `/usr/local/bin/sudoer-cli` was 1.6.0 at the paste  
- **Description:** In-tree 1.6.1 is not the installed global binary until operator `install` / copy.  
- **Impact:** `source ~/.bashrc` on that host still skips until 1.6.1 is installed.  
- **Suggestion:** Operator CAPA 9 — install 1.6.1, re-run hook, confirm one prompt waits.  
- **Cross-ref:** INC-20260815-001 CAPA 9  

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Auto-approve | No. Empty = No. `--force` does not approve |
| Hook `sudo -n` / F6 | Worked (euid 0, request shown) |
| `TTY=0` / `--json` fail-closed | Still **TP-SR-INT-02** |
| Empty argv ≠ `interactive` | Unchanged Type N help |

## Priority remediation order

1. ~~SR-INT-01~~ fixed in 1.6.1  
2. ~~SR-INT-02~~ **TP-SR-INT-05**  
3. **SR-HOST-02** — install 1.6.1 on the approver host  
4. **SR-INT-03** — pretty-print (optional, separate)

## Related

| Artifact | Role |
|----------|------|
| `docs/incidents/incident-20260815-001-interactive-loop-stole-stdin.md` | Process report |
| `requirement-domain-sudoer-approval` 2.14.0 | Id walk must not steal stdin |
| `requirement-shell-interactive-vs-noninteractive` 1.3.0 | AC-6 |
| `reviews/lessons.md` L-INT-STDIN-01 | Durable failure mode |
| `tests/test_domain_sr.sh` TP-SR-INT-05 | Redirect-shape guard |

**Written by:** Implement  
**Review status:** P1/P2 in-tree fixed; host re-run and pretty-print open
