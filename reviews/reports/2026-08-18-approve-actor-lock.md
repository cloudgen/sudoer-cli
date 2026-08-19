# Report: approve-path actor lock — review / checklist / test-plan gates

**Date:** 2026-08-18  
**Mode:** review-plan + checklist alignment  
**Status:** Gates **have**. Suite this run recorded in `reviews/test-plan.md`.  
**Incident:** `INC-20260818-001`  
**Lesson:** `L-APPR-ACTOR-01` (closed) · do **not** re-read `L-ELEV-BOOT-01` as “approve stays F6”

## Why this report exists

Law and the ship unit dropped the exclusive-`sudoer-adm` approve lock in 1.7.0. A later review could still **re-teach** the wall if:

- **CL-LEAST-PRIVILEGE** had no elev-is-approval section  
- **SK-REQUIREMENT-SUFFICIENT-CHECK** Step 3f Pass was “euid 0 + approver `SUDO_USER`”  
- **L-ELEV-BOOT-01** prevention said “split bootstrap vs F6 `sr_require_type1`”  
- Full review greened without **TP-ELEV-09** / **AL-***  

Those holes are closed in this change.

## Gates that must stay true

| ID | Surface | Must fail the review if |
|----|---------|-------------------------|
| **AL-1** | `sr_require_type1` | Reads `SUDO_USER` and dies unless it is the LPU |
| **AL-2** | prevention-set §2.2.1 | Republishes **PREV-APPR-ACTOR** as a block |
| **AL-3** | `help` | Approve path is “only F6 / sudoer-adm or root” |
| **AL-6** | suite | **TP-SR-PRIV-04** / **TP-PREV-03** / **TP-ELEV-09** not run |
| **AL-7** | lessons | “Fix setup chicken-egg by locking approve to F6” |

**Checklists (blank — run every privilege / approval review):**

| Checklist | Section |
|-----------|---------|
| **CL-LEAST-PRIVILEGE** | **§H** Elev is approval |
| **CL-FILE-BASED-JSON-APPROVAL** | §5 authz + Protection 4 |
| **CL-SHELL-TTY-PRIVILEGE-TRAPS** | **T1-SECOND-LOCK** + Protection 5 |
| **CL-HOST-MUTATING-DOMAIN** | §2 after-elev actor lock |
| **CL-SECURITY-REVIEW** | Configuration and privileges (T1-SECOND-LOCK) |

**Coverage skill:** **SK-REQUIREMENT-SUFFICIENT-CHECK** 1.6.0 Step 3f — exclusive `SUDO_USER=={{APPROVER}}` is a **Fail**.

## Verdict

**Pass** on the review-plan / checklist / proof-mold gates for **T1-SECOND-LOCK**. Re-run **AL-1..7** on every full product review. Do not mark R9/R14 have without **TP-ELEV-09**.

**Written by:** Implement (single-agent)  
**Review status:** gates live; suite must stay green on TP-SR-PRIV-04
