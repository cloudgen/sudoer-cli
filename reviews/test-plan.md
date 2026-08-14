# Test plan — sudoer-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/sudoer-cli`  
**Product VERSION:** 1.0.0  
**Last plan update:** 2026-08-14  
**Last suite run:** PASS=121 FAIL=0 SKIP=0 (2026-08-14)  
**Domain subject token:** `SR` = sudoer-request (`requirement-domain-sudoer-approval` → family **TP-SR-***, not `TP-DOM-*`)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Type N empty argv = help | have | TP-CLI-07 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| No online verbs / no SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Trimmed parent verbs fail closed | have | TP-CLI-13 |
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| Backup / restore | n/a | Absent by design (not a backup product) |
| Domain sudoers-request (convert / submit / queues) | have | **TP-SR-01..13** + **TP-SR-PRIV-01** — `tests/test_domain_sr.sh` |
| Routed convert known; junk still unknown | have | **TP-CLI-14** |
| no-retest-tty (measure `[ -t` outside functions) | have | **TP-ELEV-07** |
| Unique `mktemp` leaves (no `$$` scratch) | have | **TP-TMP-01**, **TP-TMP-02** |
| Password-sudo / package Type 1 ladder | n/a | Not claimed; fail-closed is TP-SR-PRIV-01 |
| Online curl / companion checksum | n/a | Local-only product |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help local verbs; no online; no backup/restore/sudoers | test_cli | requirement-shell-cli-interface · bootstrap-chain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON storage; no domain fields | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-07 | empty argv Type N help | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | backup/restore/print-sudoers/`setup` unknown | test_cli | requirement-bootstrap-chain · interface | **have** |
| TP-CLI-14 | Convert routed (xor fail ≠ unknown); junk unknown | `tests/test_cli.sh` | requirement-shell-cli-interface · domain SSOT | **have** |

### TP-LC (local lifecycle)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01 | install → USER_BIN | test_local_lifecycle | requirement-shell-local-self-management | **have** |
| TP-LC-02 | installed binary version | test_local_lifecycle | local self-management | **have** |
| TP-LC-03 | reinstall already-installed | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-04 | where-is-me | test_local_lifecycle | local self-management | **have** |
| TP-LC-05 | uninstall JSON no force fail-closed | test_local_lifecycle | interactive-vs-noninteractive | **have** |
| TP-LC-06 | uninstall --force removes | test_local_lifecycle | local self-management | **have** |
| TP-LC-07 | uninstall absent no-op | test_local_lifecycle | idempotency | **have** |
| TP-LC-08 | about shows installed | test_local_lifecycle | local self-management | **have** |
| TP-LC-09 | installed mode is `0755` | test_local_lifecycle | local self-management §2.3.1 | **have** |
| TP-LC-10 | reinstall without force heals `0711` → `0755` | test_local_lifecycle | local self-management §2.3.1 | **have** |

### TP-SR (sudoers-request domain — Type 0 routed)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-SR-01 | Basename `sudoer-DATE-service-user-action-n.json` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-02 | Request JSON schema; remove = purpose only | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-03 | sudoers ↔ JSON; visudo on private copy | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-04 | `--queue-root` / per-dir resolve; reject relative | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-05 | Self-scope submit; print `request_id` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-06 | Dest `{{service}}-{{user}}`; never `*-remove` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-07 | REQ add sample JSON → three canonical sudoers lines | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-08 | REQ remove sample JSON → `# Purpose:` only | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-09 | REQ add sudoers sample → JSON `service=webservice` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-10 | Mixed nginx + gitlab-ctl → `unknown_service` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-11 | Remove JSON with `commands` → `remove_extra_fields` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-12 | Relative `--queue-root` → `invalid_name` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-13 | `request_id` includes `sudoer-` prefix and `.json` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-PRIV-01 | Type 1 verbs: non-root fail-closed, no `/etc` write | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval · three-layer | **have** |
| TP-SR-INT-01 | `interactive` without euid 0 → `authz` | `tests/test_domain_sr.sh` | domain · three-layer | **todo** |
| TP-SR-INT-02 | `interactive` `TTY=0` / `--json` → `confirm_required`, no hang | `tests/test_domain_sr.sh` | domain · interactive | **todo** |
| TP-SR-INT-03 | Hook snippet skips non-interactive / `SSH_ORIGINAL_COMMAND`; no `exit` | `tests/test_domain_sr.sh` | domain | **todo** |
| TP-SR-INT-04 | Empty inbound `interactive` (when loop live) exits 0 | `tests/test_domain_sr.sh` | domain | **todo** |

### TP-ELEV (TTY / Type 1 detection)

This product claims **fail-closed Type 1** (approve/setup without euid 0), **not** a password-sudo package ladder. Dual elev TP-ELEV-01..05 are **n/a** with that reason — do not mark **have**.

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-ELEV-01 | JSON never selects password-sudo | — | — | **n/a** (no password-sudo elev) |
| TP-ELEV-02 | Forced `TTY=1` ⇒ sudo-tty mode | — | — | **n/a** |
| TP-ELEV-03 | Static: no `mode=$(detect)` elev | — | — | **n/a** (no elev detect helper) |
| TP-ELEV-04 | Review-plan honesty for Type 1 package elev | — | — | **n/a** |
| TP-ELEV-05 | Human password apt | — | — | **n/a** |
| TP-ELEV-07 | Static no-retest-tty: `prompt_*` / `app_about` consume `TTY` | `tests/test_cli.sh` | requirement-shell-prompt · interactive AC-4 | **have** |

### TP-TMP (scratch leaves)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-TMP-01 | Static: no `sr-*.$$` scratch | `tests/test_cli.sh` | requirement-shell-temp-file-system | **have** |
| TP-TMP-02 | Convert still works after `mktemp` leaves | `tests/test_domain_sr.sh` (TP-SR-03) | requirement-shell-temp-file-system | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM or TP-FOLDER-BACKUP as Core without product-mode change.  
4. Domain Type 0 convert/submit/list/show are **routed**. Type 1 `setup`/`approve` fail closed without euid 0 (**TP-SR-PRIV-01**). Live `useradd`/`userdel` is a **Gap**.  
5. **TP-SR-07..09** MUST use the worked samples from `requirement-domain-sudoer-approval` (alice / webservice).  
6. Convert tests that call `visudo` **MUST** skip honestly if `visudo` is absent (not silent pass).  
7. Subject family is **TP-SR-*** (sudoer-request). Do not mint `TP-DOM-*` or copy `TP-TIMER-*`.  
8. **TP-ELEV-07** / **TP-TMP-01** are static greps on the ship unit; do not mark **have** without the suite asserts.
