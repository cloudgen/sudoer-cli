# Requirement ↔ test matrix — sudoer-cli

**Updated:** 2026-08-14  
**Product VERSION:** 1.1.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Online and domain/backup surfaces absent |
| requirement-project-folder | architecture | TP-LC-01 | src ship unit + user bin |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | no `fb_*`; `app_main` / `out_*` |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · **TP-ELEV-07** | Uninstall confirm; TTY measured outside functions |
| requirement-shell-prompt | shell | TP-LC-05 · **TP-ELEV-07** | `prompt_*` consume `TTY`; samples in REQ |
| requirement-shell-temp-file-system | shell | **TP-TMP-01**, **TP-TMP-02**, TP-CLI-12, TP-LC-01 | `mktemp` leaves; no `$$` scratch |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-three-layer-privilege-model | architecture | TP-SR-03, TP-SR-PRIV-01 | Table A ≠ user grant; Type 1 gate |
| requirement-least-privilege-user | architecture | TP-SR-PRIV-01 | F1–F7; live useradd not enabled |
| requirement-domain-sudoer-approval | domain | **TP-SR-01..13**, **TP-SR-PRIV-01**, **TP-CLI-14**, **TP-SR-INT-01..04** | Type 0 convert/submit **have**; Type 1 dest/hook/loop Gap; INT **todo** |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore.

**Honest Gap:** live `useradd`/`userdel` and Type 1 dest install to `/etc` are not exercised (non-root CI). Convert/submit/list/show are live.
