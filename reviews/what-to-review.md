# What to review — sudoer-cli

**Living checklist** (review plan). Product: **sudoer-cli** (Type 0 live; **Type 0 domain convert/submit/list/show routed**; Type 1 fail-closed).  
**Class:** software-development · **one** Active domain SSOT (`requirement-domain-sudoer-approval` **2.4.0**) · **local-only** install channel.  
**Always load first:** `reviews/lessons.md`  
**Latest report:** `reviews/reports/2026-08-14-revisions-and-test-plan.md` (**Revise**)

**Last plan update:** 2026-08-14  
**Ship unit VERSION:** 1.0.0  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + shell + three-layer + LPU + **domain 2.4.0** |
| P2 | Confirm ship unit `src/sudoer-cli` | `APP_NAME` / `VERSION` hard-assign (**1.0.0**) |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** still local-only | No SCRIPT_URL product UX |
| P6 | Confirm trimmed verbs stay unknown | backup / restore / print-sudoers |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual |
| Bootstrap chain | `requirement-bootstrap-chain.md` | sudoer-cli specialized from cli-template |
| Project folder | `requirement-project-folder.md` | `src/`, bins; no `/var/backup` |
| CLI interface | `requirement-shell-cli-interface.md` | Type 0 commands, flags, dispatch |
| Empty argv Type N | `requirement-shell-cli-zero-arguments.md` | Empty = help |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; mode 0755 |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors; colors consume `TTY` |
| Modular design | `requirement-shell-modular-function-design.md` | Type 0 prefixes; `sr_` / `lpu_` reserved; `prompt_*` consume `TTY` |
| Interactive vs noninteractive | `requirement-shell-interactive-vs-noninteractive.md` | Confirm policy; **TTY measured outside functions** |
| Prompt helpers | `requirement-shell-prompt.md` | `prompt_*` samples consume `TTY` |
| Temp leaves | `requirement-shell-temp-file-system.md` | `mktemp`; no `$$` scratch |
| Three-layer | `requirement-three-layer-privilege-model.md` | EM-INT F6; Table A ≠ user grant |
| LPU | `requirement-least-privilege-user.md` | F1–F7; dest `{{service}}-{{user}}` |
| Domain SSOT | `requirement-domain-sudoer-approval.md` | JSON samples; convert; queues; host-mutating |
| Idempotency | `requirement-shell-idempotency.md` | Re-install |
| Storage | `requirement-shell-cli-storage.md` | Isolation |

**Do not review as this product’s law:** folder-archive backup / restore (absent).

**Do review as live:** convert / submit / list / show / `print-sudoers` (Type 0). Type 1 `setup` / `approve` / `reject` / `interactive` / LPU create are **fail-closed** (no live `useradd` / `/etc` dest in CI).

## This-pass gates (2026-08-14)

| # | Check | Status |
|---|--------|--------|
| R1 | Domain / registry say Type 0 routed and Type 1 Gap (no blanket “not yet routed”) | **closed** (L-LAW-ROUTE-01) |
| R2 | CLI interface still lists `print-sudoers` as unknown trimmed parent | **closed** (CLI 3.1.0: domain Type 0) |
| R3 | no-retest-tty: `[ -t` only outside functions; `prompt_*` / `about` consume `TTY` | **have** TP-ELEV-07 (code + suite) |
| R4 | Type 1 fail-closed without root (no `/etc` write) | **have** TP-SR-PRIV-01 |
| R5 | Password-sudo / package elev TP-ELEV-01..05 | **n/a** (not claimed) |
| R6 | About queue fields vs TP-CLI-06 / domain pillar 4 | **open** (partial) |
| R7 | Domain §2.0 presents file-based JSON approval (roles, submit-when, JSON verify) | **have** (domain 2.2.0+) |
| R8 | Type 1 authz + hook snippet + interactive loop law; dest `{{service}}-{{user}}`; hook/loop/dest still Gap | **have** law (domain 2.4.0); impl **Gap** |
