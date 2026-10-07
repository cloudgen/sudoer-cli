# Test plan — sudoer-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/sudoer-cli`  
**Product VERSION:** 1.32.0  
**Last plan update:** 2026-10-04 (TTY empty argv is the numbered list; off-TTY stays Type O)  
**Last suite run:** PASS=922 FAIL=0 SKIP=10 (2026-10-07; 1.32.0 login-hook path check; live Type 1 skipped)  
**Domain subject token:** `SR` = sudoer-request (`requirement-domain-sudoer-approval` → family **TP-SR-***, not `TP-DOM-*`)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Empty argv split (TTY menu; off-TTY Type O) | have | TP-CLI-07 · **TP-CLI-18** · **TP-CLI-29** · **TP-LC-11/14/15** · **TP-CURL-02/03/08** |
| Numbered start list (TTY empty argv and `menu` / `main`) | have | **TP-CLI-07** · **TP-CLI-18..22** · **TP-CLI-24** · **TP-CLI-29** · **TP-ELEV-10** |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| Online lifecycle verbs + SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Trimmed parent verbs fail closed | have | TP-CLI-13 |
| Channel install / self-update / self-uninstall / mode 0755 | have | TP-LC-01..18 |
| Backup / restore | n/a | Absent by design (not a backup product) |
| Domain sudoers-request (convert / submit / queues) | have | **TP-SR-01..21** + **TP-SR-PRIV-01..04** + **TP-SR-FENCE-01..17** — `tests/test_domain_sr.sh` |
| Privilege prevention set (closed block vs must-remain-open) | have | **TP-PREV-01..03** (aliases of PRIV-03 / SR-03 / PRIV-04) |
| Routed convert known; junk still unknown | have | **TP-CLI-14** |
| no-retest-tty (measure `[ -t` outside functions) | have | **TP-ELEV-07** |
| Unique `mktemp` leaves (no `$$` scratch) | have | **TP-TMP-01**, **TP-TMP-02** |
| Password-sudo / package Type 1 ladder | n/a | Not claimed; fail-closed is TP-SR-PRIV-01 |
| Sudo escalation check (avoid `-n` unless specified) | have | **TP-ELEV-08** + **TP-SR-PRIV-02** |
| No second actor lock after elev (**T1-SECOND-LOCK**) | have | **TP-ELEV-09** + **TP-SR-PRIV-04** + **TP-PREV-03** — **required** on full review (what-to-review **AL-6**) |
| Online curl / companion checksum | have | **TP-CURL-01..09** · **TP-CSUM-01..05** |
| Coding-style related REQ (POSIX writing lessons) | n/a | Review-time; `requirement-shell-script-coding`; indirect TP-CLI-01 / TP-ELEV-07 |
| Sudo-wrapping function + check before sudo (chmod example) | have | **TP-SUDO-01..07** |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help online lifecycle + domain; no backup/restore; no CHECKSUM | test_cli | requirement-shell-cli-interface · bootstrap-chain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON storage; queue paths allowed | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-07 | off-TTY empty argv Type O (dead channel non-zero, not help); TTY empty argv is the numbered list; `--json` no command is JSON help | test_cli | requirement-shell-cli-zero-arguments · requirement-shell-cli-default-interaction | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs routed (not unknown) | test_cli | requirement-bootstrap-chain · requirement-shell-self-management | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | backup/restore/`remove-project-sudoers` unknown (`print-sudoers` is domain) | test_cli | requirement-bootstrap-chain · interface | **have** |
| TP-CLI-14 | Convert routed (xor fail ≠ unknown); junk unknown | `tests/test_cli.sh` | requirement-shell-cli-interface · domain SSOT | **have** |

### TP-SUDO (sudo-wrapping function + check before sudo)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-SUDO-01 | `util_sudo` and `util_chmod` defined | test_cli | requirement-shell-sudo-command | **have** |
| TP-SUDO-02 | `sudo "$@"` only once (`util_sudo`) | test_cli | requirement-shell-sudo-command | **have** |
| TP-SUDO-03 | no raw `sudo chmod` | test_cli | requirement-shell-sudo-command | **have** |
| TP-SUDO-04 | `lpu_sudo` / callers use `util_sudo` | test_cli | requirement-shell-sudo-command | **have** |
| TP-SUDO-05 | owned file: `util_chmod` sets mode without sudo | test_cli | requirement-shell-sudo-command | **have** |
| TP-SUDO-06 | missing path: `util_chmod` nonzero, no sudo | test_cli | requirement-shell-sudo-command | **have** |
| TP-SUDO-07 | already-root: `util_sudo` runs without sudo | test_cli | requirement-shell-sudo-command | **have** |

### TP-LC (online lifecycle on local channel)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01 | install → USER_BIN | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-02 | installed binary version | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-03 | reinstall already-installed | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-04 | about JSON installed + script_url | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-05 | self-uninstall JSON no force fail-closed | test_local_lifecycle | interactive-vs-noninteractive · self-management | **have** |
| TP-LC-06 | self-uninstall --force removes | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-07 | self-uninstall absent no-op | test_local_lifecycle | idempotency | **have** |
| TP-LC-08 | about shows installed | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-09 | installed mode is `0755` | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-10 | reinstall without force heals `0711` → `0755` | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-11 | empty argv when local-installed is ensure, not help | test_local_lifecycle | requirement-shell-cli-zero-arguments | **have** |
| TP-LC-12 | version-check JSON + human vs local channel | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-13 | self-update already-latest | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-14 | empty argv first install places binary | test_local_lifecycle | requirement-shell-cli-zero-arguments | **have** |
| TP-LC-15 | empty argv when global-installed is ensure, not help | test_local_lifecycle | requirement-shell-cli-zero-arguments | **have** |
| TP-LC-16 | self-update downgrade refuse without --force | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-17 | self-update --force allows downgrade | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-18 | `inst_maybe_install` JSON/QUIET places or fail closed | test_local_lifecycle | requirement-shell-cli-zero-arguments | **have** |
| TP-LC-20 | `BASHRC` env create-if-missing | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-21 | `BASHRC` env modify dongle | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-22 | `BASHRC` env VERSION+exact-PATH no-op | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-27 | sibling exact PATH already present | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-28 | uninstall keeps shared PATH while USER_BIN has files | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-29 | already-installed heal missing PATH | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-30 | uninstall does not delete `.profile` | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-31 | `rc-test` create/modify/noop against `--root` | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |

### TP-CSUM (companion digest)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CSUM-01 | Publisher sidecar matches ship unit | test_local_lifecycle | requirement-shell-automatic-checksum | **have** |
| TP-CSUM-02 | Human --force install shows link / value / PASS | test_local_lifecycle | requirement-shell-automatic-checksum | **have** |
| TP-CSUM-03 | CHECKSUM pin mismatch aborts | test_local_lifecycle | requirement-shell-automatic-checksum | **have** |
| TP-CSUM-04 | CHECKSUM pin match installs | test_local_lifecycle | requirement-shell-automatic-checksum | **have** |
| TP-CSUM-05 | help/about omit CHECKSUM | test_cli (TP-CLI-04/06) | requirement-shell-automatic-checksum · interface | **have** |

### TP-CURL (`curl \| sh` pipe)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CURL-01 | Local channel ship unit + companion | test_online_curl_install | requirement-shell-automatic-checksum | **have** |
| TP-CURL-02 | First `curl \| sh` places USER_BIN binary | test_online_curl_install | requirement-shell-cli-zero-arguments | **have** |
| TP-CURL-03 | Second pipe already-installed, not help, not silent | test_online_curl_install | requirement-shell-cli-zero-arguments | **have** |
| TP-CURL-04 | Hostile `.bashrc` under set -u still loud | test_online_curl_install | interactive-vs-noninteractive | **have** |
| TP-CURL-05 | Bad URL curl is not silent | test_online_curl_install | interactive-vs-noninteractive | **have** |
| TP-CURL-06 | Product supports `sh` (no bash-required gate) | test_online_curl_install | requirement-shell-cli-interface | **have** |
| TP-CURL-07 | `curl \| sh -s -- version` | test_online_curl_install | requirement-shell-cli-interface | **have** |
| TP-CURL-08 | Unreachable channel empty argv non-zero, not silent | test_online_curl_install | requirement-shell-cli-zero-arguments | **have** |
| TP-CURL-09 | Published online channel smoke | test_online_curl_install | self-management | **optional** |

### TP-SR (sudoers-request domain — Type 0 routed)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-SR-01 | Basename `sudoer-DATE-service-user-action-n.json` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-02 | Request JSON schema; remove = purpose only | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-03 | sudoers ↔ JSON; visudo on private copy | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval · requirement-sudoers-file | **have** |
| TP-SR-04 | `--queue-root` / per-dir resolve; reject relative | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-05 | Submit (A may name B); print `request_id` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-06 | Dest `{{service}}-{{user}}`; never `*-remove` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-07 | REQ add sample JSON → three canonical sudoers lines | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval · requirement-sudoers-file | **have** |
| TP-SR-08 | REQ remove sample JSON → `# Purpose:` only | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval · requirement-sudoers-file | **have** |
| TP-SR-09 | REQ add sudoers sample → JSON `service=webservice` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval · requirement-sudoers-file | **have** |
| TP-SR-10 | Mixed nginx + gitlab-ctl → `unknown_service` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-11 | Remove JSON with `commands` → `remove_extra_fields` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-12 | Relative `--queue-root` → `invalid_name` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-13 | `request_id` includes `sudoer-` prefix and `.json` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-14 | pretty add-sample JSON → all three Cmnd lines | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval 2.15.0 | **have** |
| TP-SR-15 | pretty add-sample submit inbound keeps all three `path`s | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval 2.15.0 | **have** |
| TP-SR-16 | pretty folder-backup backup+restore keeps both verbs | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval 2.15.0 | **have** |
| TP-SR-17 | JSON `username` B (`dns-adm`) + service `dns-cli` → request_id and dest use B (not last-hyphen `adm`) | `tests/test_domain_sr.sh` | domain · OPEN-BEHALF · ARSA | **have** |
| TP-SR-18 | `remove-sudoer-request --file` for B keeps JSON `username` / dest B | `tests/test_domain_sr.sh` | domain · OPEN-BEHALF | **have** |
| TP-SR-19 | json-to-sudoers `--ownership user:group` → escaped colon; visudo Pass | `tests/test_domain_sr.sh` | requirement-sudoers-file | **have** |
| TP-SR-20 | json-to-sudoers `--ownership *` keeps star; visudo Pass | `tests/test_domain_sr.sh` | requirement-sudoers-file | **have** |
| TP-SR-21 | visudo reject says “visudo rejected”; quotes syntax; Next json-to-sudoers; no “host validation” | `tests/test_domain_sr.sh` | requirement-sudoers-file | **have** |
| TP-SR-FENCE-01 | `interactive` / `approve` / `reject` call dest Fence **before** `prompt_yes_no` | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-02 | Isolated fence: not a JSON object → fail closed, people words, no yes/no | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-03 | Isolated fence: basename action ≠ JSON action → `field_mismatch` | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-04 | Isolated fence: filename subject ≠ JSON `username` is **not** a fence | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-05 | Type 0 `test-json-format` accepts `tests/fixtures/login-hook-elev-dns-adm.json` (`kind` login-hook-elev) | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-06 | `test-json-format` not-a-JSON-object → fail closed, people words, Next test-json-format | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-07 | `test-json-format` unknown key → `invalid_json` | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-08 | `test-json-format` on request-id basename: action mismatch → `field_mismatch` | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-09 | Dest-stamped `submit_by` is well-formed (queue owner converted into JSON) | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-10 | Type 0 `add-sudoer-request` must not plant `submit_by` | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-11 | Dest `submit_by` stamp hits only the first `{` (pretty `commands[]` stay unstamped) | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-12 | `interactive` displays a fence match, then moves inbound → rejected; no yes/no; no dest write. Standalone approve/reject stay inbound | `tests/test_domain_sr.sh` | requirement-incorrect-json-format · domain | **have** |
| TP-SR-FENCE-13 | Add/update missing or non-string `submit_app` / `submit_version` → `invalid_json` | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-14 | Sibling `submit_app` (`dns-cli`) is dest-legal JSON (not a fence) | `tests/test_domain_sr.sh` | requirement-incorrect-json-format | **have** |
| TP-SR-FENCE-15 | Type 0 convert/submit stamps live Config; inbound overwrite of sibling app/version; dest allowlist; interactive `queued by {app} {version}` | `tests/test_domain_sr.sh` | requirement-incorrect-json-format · domain | **have** |
| TP-SR-FENCE-16 | Interactive: well-formed grant after a JSON-format Fence-match in the same loop reaches yes/no; no `SR_D_SUBMIT_APP` `set -u` crash | `tests/test_domain_sr.sh` | requirement-incorrect-json-format · domain · INC-20260821-002 | **have** |
| TP-SR-FENCE-17 | Interactive: missing `submit_app` warns then asks (not dest-drain) | `tests/test_domain_sr.sh` | requirement-incorrect-json-format · domain · INC-20260821-002 | **have** |
| TP-SR-WKBIN-01 | Type 0 `test-well-known-binary` accepts login-hook-elev fixture (`/usr/local/bin/dns-cli`) | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-02 | webservice nginx-ctl paths (`systemctl` / `journalctl` / `/usr/sbin/nginx`) pass | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-03 | `/usr/local/bin/nginx-cli request` passes | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-04 | `/usr/bin/certbot` passes | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-05 | `.ci-homes/…/gbin/dns-cli` fences (`untrusted_path`) | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-06 | `~/.local/bin/certbot` fences | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-07 | `/usr/bin/python3` fences | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-08 | `/usr/local/bin/../home/…` fences | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-09 | dest fence runner: CI gbin fail-closed (no yes/no); golden fixture pass | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-10 | Type 0 submit refuses CI gbin | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence | **have** |
| TP-SR-WKBIN-11 | Dest interactive warns on `.ci-homes` gbin and still asks yes/no | `tests/test_domain_sr.sh` | requirement-well-known-sudoer-binary-fence · INC-20260821-002 | **have** |
| TP-CLI-15 | `test-well-known-binary` is routed (xor fail is not unknown) | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-SR-FT-01 | Type 0 `fence-test --file` accepts login-hook-elev fixture | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-FT-02 | `fence-test --file` not-a-JSON-object → fail closed | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-FT-03 | `fence-test --file` CI gbin → `untrusted_path` | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval · well-known fence | **have** |
| TP-SR-FT-04 | `fence-test --dir` pass corpus succeeds | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-FT-05 | `fence-test --dir --expect-match` match corpus succeeds | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-FT-06 | `fence-test --dir` xor `--file` fail closed | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-SR-FT-07 | `--expect-match` without `--dir` fail closed | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval | **have** |
| TP-CLI-16 | `fence-test` is routed (xor fail is not unknown) | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-17 | default-cli-main-menu-style printers: TTY bold/italic ident + gray italic explain; off-TTY plain (claimed menu uses them) | `tests/test_cli.sh` | requirement-shell-output-requirements · requirement-shell-cli-interface · requirement-shell-cli-default-interaction | **have** |
| TP-CLI-18 | `menu` / `main` routed; off-TTY empty argv is Type O (not the list) | `tests/test_cli.sh` | requirement-shell-cli-default-interaction · requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-29 | Overlay `--debug` / `--quiet` follow empty argv; TTY `--debug` is the numbered list; `--json --debug` is JSON help; `SUDOER_CLI_LANG=ja` shows `99. 終了` and does not write the language file | `tests/test_cli.sh` | requirement-shell-cli-zero-arguments · requirement-shell-cli-default-interaction · requirement-shell-cli-language | **have** |
| TP-CLI-19 | Off-TTY `menu` is help; `--json` JSON help; `--quiet` does not swallow | `tests/test_cli.sh` | requirement-shell-cli-default-interaction · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-CLI-20 | Membership: front **1** approval features and **7** sudoers; listing under approval; no help/install/setup/testers/`menu`; Exit **99** in `app_menu_text` `line_exit` | `tests/test_cli.sh` | requirement-shell-cli-default-interaction · requirement-shell-cli-language | **have** |
| TP-CLI-21 | Interactive `menu --json` still draws the list | `tests/test_cli.sh` | requirement-shell-cli-default-interaction | **have** |
| TP-CLI-22 | Invalid TTY menu choice retries this layer (`out_error` + reprint; unused `17`; unknown name; **MUST NOT** `out_die` / unknown-argv). Portable **TP-CLI-19** already names off-TTY `menu` help. | `tests/test_cli.sh` | requirement-shell-cli-default-interaction | **have** |
| TP-CLI-24 | Menu **5** languages **51–63** (same names as sibling grok-cli; **50** and **64–69** unprinted); save mode 0600; Back does not write; front **1** approval including listing; front **7** sudoers; front **6** is not a row; `SUDOER_CLI_LANG` does not rewrite; ja/ko help and about | `tests/test_cli.sh` | requirement-shell-cli-language · requirement-shell-cli-default-interaction · requirement-shell-cli-storage | **have** |
| TP-ELEV-10 | No `$()` of `prompt_ask`; `prompt_ask "$(app_menu_text choice_label)"` on the front board and the language board (portable TP-CLI-16 hosted here) | `tests/test_cli.sh` | requirement-shell-cli-default-interaction · requirement-shell-prompt · requirement-shell-cli-language | **have** |
| TP-SR-PRIV-01 | Type 1 verbs: non-root fail-closed, no `/etc` write | `tests/test_domain_sr.sh` | requirement-domain-sudoer-approval · three-layer | **have** |
| TP-SR-PRIV-02 | Bootstrap `setup` is any euid 0 (not `sudo -n`, not `sudoer-adm`); approve still requires euid 0 | `tests/test_domain_sr.sh` | requirement-three-layer-privilege-model · domain | **have** |
| TP-SR-PRIV-04 | Approve gate has no exclusive-`sudoer-adm` actor lock; setup prints submit next-step | `tests/test_domain_sr.sh` | prevention-set OPEN-SUDOER-APPR · domain | **have** |
| TP-SR-PRIV-03 | Live setup body: useradd, collision, F6, hook (static; no host useradd in CI) | `tests/test_domain_sr.sh` | requirement-least-privilege-user · domain | **have** |
| TP-SR-INT-01 | `interactive` without euid 0 → `authz` | `tests/test_domain_sr.sh` | domain · three-layer | **have** |
| TP-SR-INT-02 | `interactive` `--json` / `TTY=0` → `confirm_required`, no hang | `tests/test_domain_sr.sh` | domain · interactive | **have** |
| TP-SR-INT-03 | Hook snippet skips non-interactive / `SSH_ORIGINAL_COMMAND`; no `exit` | `tests/test_domain_sr.sh` | domain | **have** |
| TP-SR-INT-04 | Empty inbound `interactive` exits 0 (live as root; static otherwise) | `tests/test_domain_sr.sh` | domain | **have** |
| TP-SR-INT-05 | `interactive` loop reads ids on fd 3 so `prompt_yes_no` keeps stdin | `tests/test_domain_sr.sh` | domain · prompt | **have** |
| TP-SR-INT-06 | Dest review is one-off `prompt_yes_no` (yes=approve, no/Enter=reject; no skip/quit; no three chained y/N) | `tests/test_domain_sr.sh` | domain · prompt · approval-question | **have** |
| TP-SR-INT-07 | Duplicate inbound same dest: keep latest; older superseded → rejected; other dest stays | `tests/test_domain_sr.sh` | domain · duplicate-inbound-request | **have** |
| TP-SR-INT-08 | Login-hook / `interactive` prints YAML review body; waiting file stays JSON; Type 0 `show` still dumps JSON | `tests/test_domain_sr.sh` | domain · login-interactive-review-hook | **have** |
| TP-SR-INT-09 | Login-hook / `interactive` indents `queued by` + YAML review lines by two spaces; Request id / approval question / superseded notes stay flush-left | `tests/test_domain_sr.sh` | domain · login-interactive-review-hook | **have** |
| TP-SR-HOOK-01 | `setup` checks LPU `.profile`; missing → create source-bashrc sample | `tests/test_domain_sr.sh` | login-interactive-review-hook · LPU | **have** |
| TP-SR-HOOK-02 | Existing `.profile` is not overwritten | `tests/test_domain_sr.sh` | login-interactive-review-hook | **have** |
| TP-SR-HOOK-03 | Created `.profile` sources `.bashrc` (markers) | `tests/test_domain_sr.sh` | login-interactive-review-hook | **have** |
| TP-SR-HOOK-04 | After create/rewrite, `.profile` / `.bashrc` `chown` the LPU (fail-closed) | `tests/test_domain_sr.sh` | login-interactive-review-hook · LPU | **have** |
| TP-SR-HOOK-05 | Shared doorbell `/usr/local/bin/sudoer-review-hook`: create when missing; do not overwrite; heal rewrites old product-binary, `{{APP_NAME}}-hook`, and `login-review-hook`; F6 grants `sudoer-review-hook`; test-mode skips live `/usr/local/bin` | `tests/test_domain_sr.sh` | login-interactive-review-hook · LPU · three-layer | **have** |
| TP-SR-HOOK-06 | Type 1 `interactive` reviews `{{APP_NAME}}-adm` rc: old `{{APP_NAME}} interactive` / `{{APP_NAME}}-hook` / `login-review-hook` becomes `sudoer-review-hook`; already-common rc is not rewritten | `tests/test_domain_sr.sh` | login-interactive-review-hook | **have** |
| TP-SR-HOOK-07 | Login-hook `sudo -n` fail skip copy: happened + login continues + `Next: sudo {{APP_NAME}} interactive`; not only `interactive hook skipped` | `tests/test_domain_sr.sh` | login-interactive-review-hook · shell-output-requirements | **have** |
| TP-SR-HOOK-08 | `json-to-sudoers` of `kind=login-hook-elev` emits `/usr/local/bin/sudoer-review-hook` even when inbound JSON still names the sibling product binary | `tests/test_domain_sr.sh` | sudoers-file · login-interactive-review-hook | **have** |
| TP-SR-HOOK-09 | Snippet `sudo -n` path is a F6 `NOPASSWD` Cmnd; `lpu_install_f6` rewrites stale F6 that grants only the product binary or still names `*-hook` | `tests/test_domain_sr.sh` | login-interactive-review-hook · three-layer | **have** |
| TP-SR-Q-01 | Public `/var` queues + 3773/0700/0755 | `tests/test_domain_sr.sh` | domain · LPU | **have** |
| TP-SR-Q-02 | Submit 0640; approve snapshot archive; owner check | `tests/test_domain_sr.sh` | domain | **have** |
| TP-SR-Q-03 | F7 removes public `/var/{{APP_NAME}}/` children | `tests/test_domain_sr.sh` | domain · LPU | **have** |

### TP-ELEV (TTY / Type 1 detection)

This product claims **fail-closed Type 1** (approve/setup without euid 0), **not** a password-sudo package ladder. Dual elev TP-ELEV-01..05 are **n/a** with that reason — do not mark **have**. Default: **avoid `sudo -n` unless specified** (this product specifies `-n` only for the F6 login hook).

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-ELEV-01 | JSON never selects password-sudo | — | — | **n/a** (no password-sudo elev) |
| TP-ELEV-02 | Forced `TTY=1` ⇒ sudo-tty mode | — | — | **n/a** |
| TP-ELEV-03 | Static: no `mode=$(detect)` elev | — | — | **n/a** (no elev detect helper) |
| TP-ELEV-04 | Review-plan honesty for Type 1 package elev | — | — | **n/a** |
| TP-ELEV-05 | Human password apt | — | — | **n/a** |
| TP-ELEV-07 | Static no-retest-tty: `prompt_*` / `app_about` consume `TTY` | `tests/test_cli.sh` | requirement-shell-prompt · interactive AC-4 | **have** |
| TP-ELEV-08 | Avoid `sudo -n` unless specified: no invoke; help/refuse outer `sudo`; any `-n` text only with F6/hook | `tests/test_cli.sh` | three-layer · domain · mold §8.1.4 | **have** |
| TP-ELEV-09 | No second actor lock: approve gate must not require `SUDO_USER==sudoer-adm` | `tests/test_domain_sr.sh` (TP-SR-PRIV-04) | prevention-set OPEN-SUDOER-APPR | **have** |

### TP-PREV (prevention set — closed block vs must-remain-open)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-PREV-01 | No second lock after euid 0: setup body is `useradd`, not Gap / `LIVE_LPU` / “not enabled” | `tests/test_domain_sr.sh` (TP-SR-PRIV-03) | requirement-privilege-prevention-set · LPU | **have** |
| TP-PREV-02 | `print-sudoers` / F6 emit has no `useradd` (Table C stays a script job) | `tests/test_domain_sr.sh` (TP-SR-03) | requirement-privilege-prevention-set · three-layer | **have** |
| TP-PREV-03 | No exclusive-LPU actor lock on approve after euid 0 (OPEN-SUDOER-APPR) | `tests/test_domain_sr.sh` (TP-SR-PRIV-04) | requirement-privilege-prevention-set · three-layer · domain | **have** |

### TP-TMP (scratch leaves)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-TMP-01 | Static: no `sr-*.$$` scratch | `tests/test_cli.sh` | requirement-shell-temp-file-system | **have** |
| TP-TMP-02 | Convert still works after `mktemp` leaves | `tests/test_domain_sr.sh` (TP-SR-03) | requirement-shell-temp-file-system | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Online **TP-CURL** / **TP-CSUM** are Core for this product (online-installable). Do not reintroduce folder-archive backup/restore as Core.  
4. Domain Type 0 convert/submit/list/show are **routed**. Type 1 `setup`/`approve` fail closed without euid 0 (**TP-SR-PRIV-01**). Bootstrap vs exclusive-LPU is **TP-SR-PRIV-02**. `setup` body is **TP-SR-PRIV-03**. Approve has no second actor lock (**TP-SR-PRIV-04** / **TP-PREV-03** / **TP-ELEV-09**). There is no Gap and no flag on `useradd`. Closed block vs must-remain-open is **requirement-privilege-prevention-set** (**TP-PREV-01/02/03**).  
5. **TP-SR-07..09** MUST use the worked samples from `requirement-domain-sudoer-approval` (alice / webservice).  
6. Convert tests that call `visudo` **MUST** skip honestly if `visudo` is absent (not silent pass).  
7. Subject family is **TP-SR-*** (sudoer-request). Do not mint `TP-DOM-*` or copy `TP-TIMER-*`.  
8. **TP-ELEV-07** / **TP-ELEV-08** / **TP-TMP-01** are static greps on the ship unit; do not mark **have** without the suite asserts.
