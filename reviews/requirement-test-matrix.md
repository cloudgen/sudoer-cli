# Requirement ↔ test matrix — sudoer-cli

**Updated:** 2026-08-21 (1.15.2 test-purpose vs operational verbs)  
**Product VERSION:** 1.15.3  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Online and domain/backup surfaces absent |
| requirement-project-folder | architecture | TP-LC-01 | src ship unit + user bin |
| requirement-shell-cli-interface | shell | TP-CLI-* (incl. **15** / **16**) | Commands, flags, dispatch; **test-purpose** `test-well-known-binary` / `fence-test` routed; help lists testers apart from operational |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | no `fb_*`; `app_main` / `out_*` |
| requirement-shell-script-coding | shell | n/a (review-time); indirect TP-CLI-01, TP-ELEV-07, TP-SUDO-* | Specialize-in home; **points** at sudo-command |
| requirement-shell-sudo-command | shell | **TP-SUDO-01..07** | `util_sudo` / `util_chmod`; no raw `sudo chmod`; `lpu_sudo` delegates; owner probe + already-root skip |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · **TP-ELEV-07** · **TP-SR-INT-05** · **TP-SR-INT-06** | Uninstall confirm; TTY measured outside functions; loop does not steal stdin; dest one-off yes/no |
| requirement-shell-prompt | shell | TP-LC-05 · **TP-ELEV-07** · **TP-SR-INT-06** | `prompt_*` consume `TTY`; dest review one `prompt_yes_no` |
| requirement-shell-temp-file-system | shell | **TP-TMP-01**, **TP-TMP-02**, TP-CLI-12, TP-LC-01 | `mktemp` leaves; no `$$` scratch |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-three-layer-privilege-model | architecture | TP-SR-03, TP-SR-PRIV-01, **TP-SR-PRIV-02**, **TP-SR-PRIV-03**, **TP-SR-PRIV-04**, **TP-ELEV-08**, **TP-ELEV-09** | Table A ≠ user grant; Type 1 gate; live setup body; no exclusive-LPU approve lock |
| requirement-least-privilege-user | architecture | TP-SR-PRIV-01, **TP-SR-PRIV-02**, **TP-SR-PRIV-03**, **TP-SR-PRIV-04**, **TP-SR-HOOK-01..04** | F1–F7; setup any admin; LSU never `useradd`; setup helps submit; hook checks/creates `~/.profile`; rc owned by LPU |
| requirement-privilege-prevention-set | architecture | **TP-PREV-01**, **TP-PREV-02**, **TP-PREV-03**, TP-SR-PRIV-01..04, TP-ELEV-08/09, TP-SR-05/06, **TP-SR-17**, **TP-SR-18**, TP-CLI-07, TP-LC-05/06 | Closed block vs must-remain-open; OPEN-SUDOER-APPR; OPEN-BEHALF |
| requirement-actor-role-subject-approver | architecture | TP-SR-17, TP-SR-18, TP-SR-PRIV-04 | Catalog only; dest still has Approver; A may file for B |
| requirement-incorrect-json-format | domain | **TP-SR-FENCE-01..15**, **TP-SR-FT-01..07** | Dest Fence before yes/no; Type 0 `test-json-format`; list tester `fence-test`; dest-written `submit_by`; dest-owned `submit_app` / `submit_version`; Type 0 must not plant `submit_by`; pretty stamp first `{` only; interactive display-then-rejected |
| requirement-well-known-sudoer-binary-fence | domain | **TP-SR-WKBIN-01..10**, **TP-CLI-15**, **TP-SR-FT-01..07** | Closed system prefixes + no interpreter; Type 0 `test-well-known-binary`; list tester `fence-test`; convert/submit fail closed; nginx / certbot / dns-cli / gitlab-ctl |
| requirement-domain-sudoer-approval | domain | **TP-SR-01..18**, **TP-SR-PRIV-01..04**, **TP-CLI-14**, **TP-CLI-15**, **TP-CLI-16**, **TP-SR-INT-01..06**, **TP-SR-HOOK-01..04**, **TP-SR-FENCE-01..15**, **TP-SR-WKBIN-01..10**, **TP-SR-FT-01..07**, **TP-SR-Q-01..03** | Type 0 convert/submit/`test-json-format`/`test-well-known-binary`/`fence-test` **have**; dest-written `submit_by`; dest-owned `submit_app` / `submit_version` **FENCE-13..15**; pretty `commands[]` fidelity **14/15/16**; A-for-B **17/18**; dest Fence **FENCE-*** · **WKBIN-*** · **FT-***; interactive fence → rejected **FENCE-12**; one-off approval-question **INT-06**; elevated sudoer may approve; hook `.profile`; rc owned by LPU |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore.

**Honest Gap:** live `useradd`/`userdel` on the host is not exercised (non-root CI). Setup body is proven statically (**TP-SR-PRIV-03**). `interactive` is live (**TP-SR-INT-***).
