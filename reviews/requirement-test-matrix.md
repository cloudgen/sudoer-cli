# Requirement ↔ test matrix — sudoer-cli

**Updated:** 2026-08-17  
**Product VERSION:** 1.6.2  
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
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · **TP-ELEV-07** · **TP-SR-INT-05** | Uninstall confirm; TTY measured outside functions; loop does not steal stdin |
| requirement-shell-prompt | shell | TP-LC-05 · **TP-ELEV-07** | `prompt_*` consume `TTY`; samples in REQ |
| requirement-shell-temp-file-system | shell | **TP-TMP-01**, **TP-TMP-02**, TP-CLI-12, TP-LC-01 | `mktemp` leaves; no `$$` scratch |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-three-layer-privilege-model | architecture | TP-SR-03, TP-SR-PRIV-01, **TP-SR-PRIV-02**, **TP-SR-PRIV-03**, **TP-ELEV-08** | Table A ≠ user grant; Type 1 gate; live setup body; sudo escalation check |
| requirement-least-privilege-user | architecture | TP-SR-PRIV-01, **TP-SR-PRIV-02**, **TP-SR-PRIV-03** | F1–F7; setup any admin; live setup body (static) |
| requirement-privilege-prevention-set | architecture | **TP-PREV-01**, **TP-PREV-02**, TP-SR-PRIV-01..03, TP-ELEV-08, TP-SR-05/06, TP-CLI-07, TP-LC-05/06 | Closed block vs must-remain-open; no invented walls |
| requirement-domain-sudoer-approval | domain | **TP-SR-01..16**, **TP-SR-PRIV-01..03**, **TP-CLI-14**, **TP-SR-INT-01..05**, **TP-SR-Q-01..03** | Type 0 convert/submit **have**; pretty `commands[]` fidelity **14/15/16**; setup live (static); interactive loop **have**; public queues **have** |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore.

**Honest Gap:** live `useradd`/`userdel` on the host is not exercised (non-root CI). Setup body is proven statically (**TP-SR-PRIV-03**). `interactive` is live (**TP-SR-INT-***).
