# Report: revisions + test plan — sudoer-cli 1.0.0

**Date:** 2026-08-14  
**Mode:** review (no ship-unit edit)  
**Status:** Issue 1 + 2 **closed** (2026-08-14 wording Pass A: domain 2.1.0 · CLI 3.1.0). Issues 3–4 closed earlier (TTY/temps). Pass B (about LPU/F6 fields; live useradd) still Gap.  
**Lessons loaded:** yes (`reviews/lessons.md`)  
**Suite this run:** PASS=119 FAIL=0 SKIP=0 (`./tests/run.sh`)

## Summary

Type 0 + Type 0 domain convert/submit/list/show are **live** and covered. The **test-plan have-rows match the suite**. Two honesty problems block a Pass:

1. Product law still says domain is **“not yet routed”** while help, dispatcher, about queues, and **TP-SR-*** all treat it as routed.  
2. Interactive **AC-4 / no-retest-tty** is now law; `prompt_*` / `app_about` still live-retest `[ -t`; **TP-ELEV-07** is correctly **todo**.

Password-sudo **TP-ELEV-01..05** are **n/a** (this product does not claim a Type 1 package/password ladder). Negative Type 1 is **TP-SR-PRIV-01** (have).

## Issues

### Issue 1 -- Severity: bug (law honesty)

- File: `docs/requirements/index.md:3`, `requirement-domain-sudoer-approval.md:2`, `:225`, `:233`
- Description: Registry + domain SSOT still say **target law / not yet routed**. Help/about “Until routed” paragraphs forbid listing domain verbs and queue fields. Ship unit + suite do the opposite (`help` lists `sudoers-to-json`; `about` emits `queue_*`; TP-SR-01..13 **have**).
- Suggestion: Bump domain notes to **routed Type 0**; keep live `useradd` / `/etc` dest as Gap. Sync CLI interface “live dispatcher is Type 0 lifecycle only” and the `print-sudoers` unknown row.
- Lesson: L-LAW-ROUTE-01
- Test: TP-SR-*, TP-CLI-04, TP-CLI-14
- Status: open

### Issue 2 -- Severity: bug (law vs CLI interface)

- File: `docs/requirements/requirement-shell-cli-interface.md:11`, `:24`, `:48`
- Description: CLI REQ still: help must not list unrouted domain verbs; `print-sudoers` **MUST** fail as unknown (trimmed parent). Tests **require** `print-sudoers` in help (TP-CLI-04) and convert routed (TP-CLI-14). Domain pillar 3 requires those rows once routed.
- Suggestion: Retarget CLI interface: trimmed unknown set is `backup` / `restore` / `remove-project-sudoers` only; `print-sudoers` is domain. State Type 0 domain verbs as live; Type 1 remain fail-closed.
- Test: TP-CLI-04, TP-CLI-13
- Status: open

### Issue 3 -- Severity: bug (no-retest-tty)

- File: `src/sudoer-cli:978`, `:1049`, `:1476`, `:1530`
- Description: `requirement-shell-interactive-vs-noninteractive` **1.1.0 AC-4** requires `[ -t` only outside functions. Ship unit still re-tests in `prompt_ask`, `prompt_yes_no`, `app_about`. Top-level `TTY=1` (line 98) and `out_text` are correct. `sr_read_input:1568` is the allowed data-source probe.
- Suggestion: Helpers consume `${TTY}`. Then implement **TP-ELEV-07** static grep and mark **have**.
- Lesson: L-TTY-01
- Test: TP-ELEV-07 (todo)
- Status: open

### Issue 4 -- Severity: suggestion (about coverage)

- File: `tests/test_cli.sh` TP-CLI-06; `src/sudoer-cli` `app_about` JSON
- Description: About now emits `queue_request` / `queue_approved` / `queue_rejected`. TP-CLI-06 still described as “no domain fields” and does not assert queues. Domain pillar 4 also wants LPU present? / F6 / trust tier — those fields are not in about JSON.
- Suggestion: Split: TP-CLI-06 keeps Type 0 + no parent backup fields; add TP-CLI-15 (or TP-SR-ABOUT) for routed queue keys; Gap for missing LPU/F6 about fields until law is retargeted.
- Test: TP-CLI-06 (have, incomplete vs routed about)
- Status: open

### Issue 5 -- Severity: suggestion (review-plan layout)

- File: `reviews/test-plan.md`
- Description: **TP-ELEV-07** sat under the TP-CLI table. Password-sudo **TP-ELEV-01..05** were omitted rather than **n/a** with reason (product-review §2.4 + SK-SHELL-CLI-TEST).
- Suggestion: Own **TP-ELEV** section (done this pass). Do not mark 01–05 have.
- Test: TP-ELEV-07
- Status: closed (plan layout)

### Issue 6 -- Severity: nit (stale review copy)

- File: `reviews/what-to-review.md:45`, `reviews/README.md:18`, `docs/requirements/index.md:3`
- Description: Living review text still said domain is target law / not live dispatcher.
- Suggestion: Corrected what-to-review + README this pass. Registry header still stale (Issue 1).
- Status: closed (reviews surface) / open (requirements header)

## Verdict

**Revise** — suite green is not the same as law/plan honesty.

| Claim | Verdict |
|-------|---------|
| TP-CLI-01..14 / TP-LC-01..10 / TP-SR-01..13 / TP-SR-PRIV-01 **have** | Pass (suite matches) |
| Domain “not yet routed” | Fail |
| no-retest-tty / AC-4 | Fail (law > code; TP honest todo) |
| Type 1 password ladder TP-ELEV-01..05 | N/A |
| Type 1 fail-closed | Pass (TP-SR-PRIV-01) |

## Follow-ups (authorized implement)

1. Retarget domain + CLI interface notes to **routed Type 0**.  
2. Switch `prompt_*` / `app_about` to `${TTY}`; add TP-ELEV-07 grep.  
3. About: assert queue keys; decide LPU/F6 fields vs Gap.
