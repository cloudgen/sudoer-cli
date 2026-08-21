# Review reports index — sudoer-cli

| Date | Report | Scope | Verdict | Suite |
|------|--------|-------|---------|-------|
| 2026-08-21 | `reports/2026-08-21-shell-cli-test.md` | Shell CLI suite review; dest-owned `submit_app`/`submit_version` honesty | **Pass** (FENCE-13..15 strengthened; plan VERSION aligned) | PASS=427 FAIL=0 SKIP=3 |
| 2026-08-19 | `reports/2026-08-19-dest-fence.md` | Dest Fence before yes/no; OPEN-BEHALF remove-for-B; version SSOT 1.8.1 | **Pass** (bugs closed; TP-SR-FENCE-01..04, TP-SR-17/18) | PASS=299 FAIL=0 SKIP=2 |
| 2026-08-18 | `reports/2026-08-18-approve-actor-lock.md` | **T1-SECOND-LOCK** / OPEN-SUDOER-APPR: checklists, AL-* review gate, TP-ELEV-09 | **Pass** (gates live; re-check every full review) | see `test-plan.md` |
| 2026-08-17 | `reports/2026-08-17-requirement-coverage.md` | C-full-product coverage + folder-backup requirement alignment | **Sufficient with Gaps** (pretty JSON + honesty Issues 1–2 closed; sibling command-identity open) | PASS=244 FAIL=0 SKIP=2 |
| 2026-08-15 | `reports/2026-08-15-interactive-stdin-steal.md` | `interactive` id walk stole stdin; 1.6.1 fd 3 | **Partial** (P1/P2 in-tree fixed; **SR-HOST-02** / pretty-print open) | see suite |
| 2026-08-15 | `reports/2026-08-15-requirement-coverage.md` | Requirement sufficient check (C-full-product) | **Sufficient with Gaps** | PASS=203 |
| 2026-08-15 | `reports/2026-08-15-queue-layout-design.md` | Public `/var` queues + F4 views; 1.5.1 remediations 1–4 | **Partial** (P1/P2 queue items fixed; **SR-HOST-01** still open) | see suite |
| 2026-08-14 | `reports/2026-08-14-sudo-escalation-check.md` | Sudo escalation check (**T1-BOOTSTRAP-N**, **T1-N-POLLUTE**, TP-ELEV-08) | **Pass** on check; Gap live useradd | see `test-plan.md` |
| 2026-08-14 | `reports/2026-08-14-revisions-and-test-plan.md` | Revisions + test plan (domain routed, no-retest-tty) | **Revise** | PASS=119 FAIL=0 SKIP=0 |
| 2026-08-13 | Bootstrap origin = this product | hop 0; no live parent (selfmanaged / folder-backup not origins) | living | see `tests/run.sh` |

Related products **selfmanaged** and **folder-backup** keep their own reviews. They are **not** this product’s law, origin, or evidence.
