# Report: shell CLI test review — sudoer-cli 1.16.0

**Date:** 2026-08-21
**Mode:** `SK-SHELL-CLI-TEST` suite review then implement
**Status:** closed (suite honesty + dest-owned stamp asserts)
**Suite:** PASS=427 FAIL=0 SKIP=3

## Summary

`./tests/run.sh` was already green at **PASS=418** on checkout **1.16.0**, but the living test plan still named **1.15.3** / **PASS=357** and omitted **TP-SR-FENCE-13..15** rows even though the suite ran those IDs. Dest-owned `submit_app` / `submit_version` coverage was static grep plus a combined missing-both-keys case. Convert did not assert live `PRODUCT_VERSION`. CI-gbin fixtures used a host home path. Those gaps are closed in this change. Live Type 1 (`useradd` / `interactive` on euid 0) remains an honest skip.

## Issues

### Issue 1 -- Severity: bug
- File: reviews/test-plan.md:6
- Description: Plan header froze **1.15.3** and last suite **PASS=357** (1.13.0). **TP-SR-FENCE-13..15** existed in `tests/test_domain_sr.sh` and the RTM, but had no TP rows. Stay-honest miss: green suite ≠ mapped coverage.
- Suggestion: Align VERSION, last-run counts, and list FENCE-13..15 as **have**.
- Lesson: L-TEST-OP-01 (suite green is not operator/plan truth)
- Test: TP-SR-FENCE-13..15
- Status: closed

### Issue 2 -- Severity: bug
- File: tests/test_domain_sr.sh:112
- Description: **TP-SR-02** only grepped `"submit_version":"` so an empty or wrong version would pass. **TP-SR-FENCE-15** grepped function bodies for the key names, not inbound bytes after convert/submit. Sibling `dns-cli` JSON was not proven overwritten to dest Config on queue.
- Suggestion: Assert `"submit_version":"${PRODUCT_VERSION}"` on convert; read queued files after submit and after OPEN-BEHALF; keep dest-allowlist / `queued by ${SR_D_SUBMIT_APP}` static greps.
- Lesson: L-JSON-CMDS-01 (emit-only / substring is not inbound fidelity)
- Test: TP-SR-02 · TP-SR-FENCE-15
- Status: closed

### Issue 3 -- Severity: suggestion
- File: tests/test_domain_sr.sh:716
- Description: **TP-SR-FENCE-13** fenced a body missing *both* keys, labeled as missing `submit_app`. Missing `submit_version` alone and a non-string `submit_app` were untested.
- Suggestion: Separate missing-version and numeric `submit_app` cases.
- Test: TP-SR-FENCE-13
- Status: closed

### Issue 4 -- Severity: nit
- File: tests/fixtures/fence-test/match/ci-homes-gbin.json:14
- Description: Fixture and WKBIN-05 inline JSON used `/home/leolio/prjs/dns-cli/.ci-homes/home.Nh7l39/gbin/dns-cli` (operator tree). Fence match is `.ci-homes` / home, not that host inode.
- Suggestion: Synthetic `/home/alice/prjs/dns-cli/.ci-homes/home.TEST/gbin/dns-cli`. Incident file keeps the live dest path.
- Lesson: L-CMND-PATH-01
- Test: TP-SR-WKBIN-05 · TP-SR-FT-05
- Status: closed

### Issue 5 -- Severity: nit
- File: docs/requirements/requirement-shell-cli-interface.md:103
- Description: Implementation Notes froze `VERSION="1.15.3"` (class residual still **1.13.0**) while ship unit is **1.16.0**. Same class of drift as the 2026-08-17 coverage report.
- Suggestion: Cite live ship `VERSION="1.16.0"`.
- Status: closed

## Strengths

| Area | Notes |
|------|--------|
| Isolation | Temp `HOME` / `USER_BIN` / redirected `GLOBAL_BIN`; no public network; no `/etc` write |
| POSIX runner | `set -u`, trap cleanup, PASS/FAIL/SKIP |
| Domain + dest Fence | Convert/submit/queues, JSON-format Fence, well-known binary, `fence-test` corpora |
| Type 1 honesty | Fail-closed without euid 0; live `useradd`/`interactive` skipped, not faked |
| Operator-readable fatals | Mixed-family / decode-lost / setup refuse assert `Next:` (not JSON `code` only) |
| Parameterized version | Helpers read `VERSION=` from the ship unit |

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Runner / isolation / no public net | Pass |
| Type N empty argv = help | TP-CLI-07 |
| Trimmed parent verbs unknown | TP-CLI-13 |
| no-retest-tty | TP-ELEV-07 |
| Avoid `sudo -n` unless F6/hook | TP-ELEV-08 |
| OPEN-SUDOER-APPR | TP-SR-PRIV-04 / TP-PREV-03 / TP-ELEV-09 |
| Pretty `commands[]` fidelity | TP-SR-14/15/16 |
| Golden login-hook-elev path | `/usr/local/bin/dns-cli` |
| Password-sudo package ladder TP-ELEV-01..05 | n/a (not claimed) |
| Live Type 1 | Honest SKIP=3 |

## Checklist verdicts

| Checklist | Verdict |
|-----------|---------|
| **CL-SHELL-CLI-TEST** | **Pass** (domain present; Type 1 package ladder n/a; fail-closed Type 1 covered) |
| **CL-SHELL-TTY-PRIVILEGE-TRAPS** | **Pass** for claimed fail-closed Type 1 (TP-ELEV-07/08/09). Dual password-sudo package TP-ELEV-01..05 remain n/a |
| **CL-OPERATOR-READABLE-ERROR** | **Pass** on reviewed fatals (TP-SR-10, TP-SR-PRIV-01, fence testers) |

## Priority remediation order

1. Closed in this change: plan honesty, inbound stamp asserts, FENCE-13 cases, host path, VERSION cites.
2. Open outside suite: host dest `/etc/sudoers.d/dns-cli-dns-adm` still names `.ci-homes` (**L-CMND-PATH-01** CAPA 7). Not a test rewrite.

## Related

| Artifact | Role |
|----------|------|
| `tests/run.sh` | Suite entry |
| `reviews/test-plan.md` | TP map |
| `requirement-incorrect-json-format` 1.4.0 | dest-owned keys |
| INC-20260821-001 | CI-home Cmnd path |
| INC-20260821-002 | Dest interactive dest-drain / `SR_D_SUBMIT_APP` set -u (after this review; **TP-SR-FENCE-15** grep missed it) |

**Written by:** Review + Implement (council session)
**Review status:** Findings closed
