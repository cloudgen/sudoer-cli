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

**Ship unit:** `src/sudoer-cli` (**VERSION 1.34.0**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `test-plan.md`

**Review focus:** Type 0 **online-installable** lifecycle (`curl \| sh`, off-TTY Type O empty argv, `self-update` / `self-uninstall`) **and** routed Type 0 domain convert/submit/list/show. Type 1 `setup` / `interactive` live (static **TP-SR-PRIV-03** / **TP-SR-INT-05**; no host `useradd` in CI). Numbered start list is TTY empty argv and `menu` / `main` (off-TTY empty argv is Type O; row **5** languages; invalid choice reprints this layer). **Every full review** re-runs **AL-1..7** / **TP-ELEV-09** (no exclusive-LPU approve lock). Latest report: `reports/2026-10-04-tty-empty-argv-menu.md`.
