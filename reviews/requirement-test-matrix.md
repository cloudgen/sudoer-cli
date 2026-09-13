# Requirement ↔ test matrix — sudoer-cli

**Updated:** 2026-09-13 (invalid-choice retry on numbered list; **TP-CLI-22**)  
**Product VERSION:** 1.27.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Origin selfmanaged; online verbs live; backup/restore unknown |
| requirement-project-folder | architecture | TP-LC-01 | src ship unit + user bin |
| requirement-shell-cli-interface | shell | TP-CLI-* (incl. **15** / **16** / **17** / **18..22**) | Commands, flags, dispatch; **test-purpose** `test-well-known-binary` / `fence-test` / `rc-test` routed; help lists testers apart from operational; claimed `menu` / `main`; invalid-choice retry |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 · **TP-CLI-18** · **TP-LC-11/14/15/18** · **TP-CURL-02/03/08** | Type O install-ensure; menu/main still numbered list |
| requirement-shell-cli-default-interaction | shell | **TP-CLI-17** · **TP-CLI-18..22** · **TP-ELEV-10** | Case 3 `menu` / `main`; empty argv is Type O; no `$()` of `prompt_ask`; invalid choice reprints this layer |
| requirement-shell-self-management | shell | **TP-LC-01..08/12/13/16/17** · **TP-CLI-04/10** | install / version-check / self-update / self-uninstall / about; PATH companion **call site** |
| requirement-shell-path-and-shell-support | shell | **TP-LC-20..22** · **TP-LC-27..31** · **TP-CLI-04** | This-login PATH / profile; sibling unify; scoped uninstall; heal; `rc-test` |
| requirement-shell-automatic-checksum | shell | **TP-CSUM-01..05** · **TP-CURL-01** | Companion sidecar; pin mismatch/match; help/about omit CHECKSUM |
| requirement-shell-local-self-management | shell | (superseded) | Historical local-copy package; online self-management owns lifecycle |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09, **17**, **TP-SR-21**, **TP-SR-HOOK-07** | JSON / quiet / errors; operator-readable fatals; visudo-fail slots; login-hook skip Next:; default-cli-main-menu-style printers |
| requirement-shell-modular-function-design | shell | (indirect) | no `fb_*`; `app_main` / `out_*` |
| requirement-shell-script-coding | shell | n/a (review-time); indirect TP-CLI-01, TP-ELEV-07, **TP-ELEV-10**, TP-SUDO-* | Specialize-in home; **points** at sudo-command; do-not-capture-read |
| requirement-shell-sudo-command | shell | **TP-SUDO-01..07** | `util_sudo` / `util_chmod`; no raw `sudo chmod`; `lpu_sudo` delegates; owner probe + already-root skip |
| requirement-shell-idempotency | shell | TP-LC-03,07 · **TP-LC-20..22, 27..29** | Re-install / uninstall absent; PATH no-op / heal |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · **TP-ELEV-07** · **TP-SR-INT-05** · **TP-SR-INT-06** · **TP-CLI-19** | Uninstall confirm; TTY measured outside functions; loop does not steal stdin; dest one-off yes/no; `menu` off-TTY no hang |
| requirement-shell-prompt | shell | TP-LC-05 · **TP-ELEV-07** · **TP-SR-INT-06** · **TP-ELEV-10** | `prompt_*` consume `TTY`; dest review one `prompt_yes_no`; `PROMPT_ASK_VALUE` |
| requirement-shell-temp-file-system | shell | **TP-TMP-01**, **TP-TMP-02**, TP-CLI-12, TP-LC-01 | `mktemp` leaves; no `$$` scratch |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-three-layer-privilege-model | architecture | TP-SR-03, TP-SR-PRIV-01, **TP-SR-PRIV-02**, **TP-SR-PRIV-03**, **TP-SR-PRIV-04**, **TP-ELEV-08**, **TP-ELEV-09**, **TP-SR-HOOK-05** | Table A ≠ user grant; Type 1 gate; live setup body; F6 grants `login-review-hook`; no exclusive-LPU approve lock |
| requirement-least-privilege-user | architecture | TP-SR-PRIV-01, **TP-SR-PRIV-02**, **TP-SR-PRIV-03**, **TP-SR-PRIV-04**, **TP-SR-HOOK-01..05** | F1–F7; setup any admin; LSU never `useradd`; setup helps submit; login hook **points** (`login-review-hook`) |
| requirement-login-interactive-review-hook | shell | **TP-SR-HOOK-01..08**, **TP-SR-INT-03**, **TP-SR-PRIV-03** | Rc snippet; `.profile` create-if-absent; shared `/usr/local/bin/login-review-hook`; skip copy with Next:; Type 1 `interactive` replaces old product-binary and `{{APP_NAME}}-hook`; test-mode skip live `ln` |
| requirement-privilege-prevention-set | architecture | **TP-PREV-01**, **TP-PREV-02**, **TP-PREV-03**, TP-SR-PRIV-01..04, TP-ELEV-08/09, TP-SR-05/06, **TP-SR-17**, **TP-SR-18**, TP-CLI-07, TP-LC-05/06 | Closed block vs must-remain-open; OPEN-SUDOER-APPR; OPEN-BEHALF |
| requirement-actor-role-subject-approver | architecture | TP-SR-17, TP-SR-18, TP-SR-PRIV-04 | Catalog only; dest still has Approver; A may file for B |
| requirement-incorrect-json-format | domain | **TP-SR-FENCE-01..17**, **TP-SR-FT-01..07** | Dest Fence before yes/no; Type 0 `test-json-format`; list tester `fence-test`; dest-written `submit_by`; dest-owned `submit_app` / `submit_version`; Type 0 must not plant `submit_by`; pretty stamp first `{` only; garbage JSON display-then-rejected; missing stamp dest **warn then ask** **FENCE-17**; no `set -u` crash **FENCE-16** |
| requirement-well-known-sudoer-binary-fence | domain | **TP-SR-WKBIN-01..11**, **TP-CLI-15**, **TP-SR-FT-01..07** | Closed system prefixes + no interpreter; Type 0 `test-well-known-binary`; list tester `fence-test`; convert/submit fail closed; dest interactive **warn then ask** **WKBIN-11**; nginx / certbot / dns-cli / gitlab-ctl |
| requirement-sudoers-file | domain | **TP-SR-03**, **TP-SR-07..09**, **TP-SR-19..21**, **TP-SR-HOOK-08** | Grant sudoers text dual; Cmnd arg escape `\:`; visudo -cf private copy; visudo-fail names visudo not “host validation”; `*` not glob; not a dest Fence; `login-hook-elev` emit `login-review-hook` |
| requirement-domain-sudoer-approval | domain | **TP-SR-01..21**, **TP-SR-PRIV-01..04**, **TP-CLI-14**, **TP-CLI-15**, **TP-CLI-16**, **TP-SR-INT-01..09**, **TP-SR-HOOK-01..05**, **TP-SR-FENCE-01..17**, **TP-SR-WKBIN-01..11**, **TP-SR-FT-01..07**, **TP-SR-Q-01..03** | Type 0 convert/submit/`test-json-format`/`test-well-known-binary`/`fence-test` **have**; dest-written `submit_by`; dest-owned `submit_app` / `submit_version` **FENCE-13..17**; pretty `commands[]` fidelity **14/15/16**; A-for-B **17/18**; grant sudoers file **points** **19/20/21**; login hook **points** **HOOK-01..05**; dest Fence **FENCE-*** · **WKBIN-*** · **FT-***; interactive fence → rejected **FENCE-12**; warn-then-ask **FENCE-17** / **WKBIN-11**; one-off approval-question **INT-06**; keep-latest duplicate inbound **INT-07**; YAML review **INT-08**; two-space request-body indent **INT-09**; elevated sudoer may approve |

**Absent by design (no TP Core):** folder-archive backup/restore. Online install / self-management / companion checksum are **Core**.

**Honest Gap:** live `useradd`/`userdel` on the host is not exercised (non-root CI). Setup body is proven statically (**TP-SR-PRIV-03**). `interactive` is live (**TP-SR-INT-***).
