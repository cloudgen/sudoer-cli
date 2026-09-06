# Product review: sudoer-cli (human readability + coverage)

**Date:** 2026-09-06  
**Reviewer:** council (Explore / Plan / Implement / Review / Security)  
**Product:** sudoer-cli `VERSION=1.20.0`  
**Ship unit:** `src/sudoer-cli`  
**Scope:** README Description/menu capture; registered `requirement-*.md` §1.1; requirements vs tests vs checklists  
**Method:** disk read of registry, ship unit help/menu, `tests/`, `reviews/`; suite run after remediations  
**Baseline:** `./tests/run.sh` PASS=513 FAIL=0 SKIP=7 (2026-09-06)

## Summary

README Description already used people/folder words. The numbered start list and `help` still led with Type 0 / F6 / LPU as the only explanation on several rows. Related shell requirements lacked the named section **Under command line for normal user only**. `reviews/what-to-review.md` still cited ship unit **1.17.0** / domain **2.31.0**. Those gaps are fixed in this change. Product-law coverage for convert/submit/review/menu remains owned; filled product checklists under `docs/checklists/` stay gitignored (harness-only runs).

## Strengths

| Area | Notes |
|------|--------|
| README voice pack | One sentence, three boxes, practice table; empty argv = help |
| §1.1 Human-facing | Present on all 24 registered requirements |
| Domain samples | Filename grammar + add/remove JSON + sudoers dual live on domain SSOT |
| TP map | `reviews/requirement-test-matrix.md` names a TP family for every Active REQ |
| Menu claim | Case 3 `menu` / `main`; **TP-CLI-18..21** · **TP-ELEV-10** already in suite |

## Findings

### SR-DOC-01 — Severity: P1 (high)
- **Area:** operator help / numbered list
- **Status:** fixed
- **Location:** `src/sudoer-cli` `app_help` / `app_main_menu_print`; README Quick Installation capture
- **Description:** Live labels were `Emit F6 Table A draft (Type 0; …)`, `Teardown LPU`, `TTY review loop`. README pasted that capture (write-readme §4.3: fix the binary, do not clean the fence).
- **Impact:** A newcomer cannot tell what `print-sudoers` or `remove-lpu` does.
- **Suggestion:** People-first one-liners; headings name the job. Done.
- **Cross-ref:** `requirement-shell-cli-interface` 3.10.2; **TP-CLI-04** / **TP-CLI-20**

### SR-REQ-01 — Severity: P1 (high)
- **Area:** related shell REQs
- **Status:** fixed
- **Location:** 15 registered shell / privilege / domain files
- **Description:** Named section **Under command line for normal user only** was missing. Type 1 setup/approve stay Linux-with-sudo; Termux / Git Bash / Windows cmd must keep admin privilege unused.
- **Impact:** Review checklist B Fail; agents could enable `sudo` / `useradd` on that class.
- **Suggestion:** Exact heading + tailored **This requirement:** row. Done.
- **Cross-ref:** authoring step 27; N/A for output-only files

### SR-REV-01 — Severity: P2 (medium)
- **Area:** review plan drift
- **Status:** fixed
- **Location:** `reviews/what-to-review.md`, `reviews/README.md`
- **Description:** Plan still said VERSION **1.17.0** and domain **2.31.0** while ship unit / registry were 1.20.0 / 2.37.x.
- **Impact:** Reviewers load stale gates.
- **Suggestion:** Align VERSION, domain, latest report. Done.

### SR-CL-01 — Severity: P2 (medium)
- **Area:** filled checklists
- **Status:** deferred
- **Location:** `docs/checklists/` (gitignored via `docs/**`)
- **Description:** On-disk filled runs are almost all harness-knowledge H1/H2. Product blanks (`checklist-file-based-json-approval`, `checklist-least-privilege`, `checklist-operator-readable-error`, `plan-and-requirements`) have no tracked filled copy. Public proof lives in `reviews/` + `tests/`.
- **Impact:** Agents looking only at `docs/checklists/` see no product audit trail.
- **Suggestion:** Keep `reviews/` as the git-tracked proof surface. Optional local filled CL for `cli-default-interaction` this turn.

### SR-IDX-01 — Severity: P3 (low)
- **Area:** registry honesty
- **Status:** fixed
- **Location:** `requirement-shell-idempotency.md` vs `index.md`
- **Description:** File header was 1.1.0 while registry said 1.2.0.
- **Impact:** Status skew.
- **Suggestion:** Synced to **1.2.1** with the named section.

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Registry ↔ disk | 24 registered files; no orphans; no ghosts |
| README section order | Title, banners, Description, Features, Quick Installation (menu capture), Usage, … Last Update |
| Dual mention `menu` / `main` | CLI-interface + default-interaction |
| Dest approval question | one-off yes/no; **TP-SR-INT-06** |
| Keep-latest duplicate inbound | **TP-SR-INT-07** |
| Online install | Intentionally absent |
| Type 2 dest-write | Intentionally absent |

## Priority remediation order

1. ~~People-first help/menu labels~~ (this change)
2. ~~Named **Under command line** section on related shell REQs~~ (this change)
3. ~~Stale review-plan VERSION~~ (this change)
4. Optional later: tracked filled `checklist-file-based-json-approval` / `checklist-least-privilege` if the user wants those on git (today they would be ignored under `docs/**`)

## Related

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `reviews/requirement-test-matrix.md` | RTM |
| `reviews/test-plan.md` | TP map |
| `tests/run.sh` | Suite |
| `reviews/cli-routed-verb-table.md` | Dispatcher inventory |

**Written by:** council  
**Review status:** Findings 1–3 and 5 fixed; SR-CL-01 deferred (honest gitignore)
