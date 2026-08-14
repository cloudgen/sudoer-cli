# Reviews — sudoer-cli

Public product review surface (peer of `tests/`).

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map |
| `requirement-test-matrix.md` | Requirement → TP families |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |

**Ship unit:** `src/sudoer-cli` (**VERSION 1.0.0**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `test-plan.md`

**Review focus:** Type 0 local lifecycle **and** routed Type 0 domain convert/submit/list/show. No backup/restore. Type 1 dest/`useradd` not live in CI. Latest report: `reports/2026-08-14-revisions-and-test-plan.md`.
