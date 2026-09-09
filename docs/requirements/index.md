# Requirements index

**Product:** sudoer-cli — a POSIX `/bin/sh` program a normal login can install with `curl | sh`, convert, and queue. A host admin who already used password sudo sets up `sudoer-adm` and reviews waiting files. Numbered list is `menu` / `main` (empty argv is install-ensure). (Catalog: Type 0 lifecycle + domain convert/submit live; Type 1 `setup` / `interactive` live.)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; live origin **selfmanaged** (A→B). Online / Type O **present**.  
**Updated:** 2026-09-09 (shell-rc topic-owner `requirement-shell-path-and-shell-support`; this-login PATH + `rc-test`)

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, online-installable); ARSA + dest-fence + **coding-style** + **sudo-command** + **sudoers-file** + **login-interactive-review-hook** + **cli-default-interaction** pointers; dest Fences ship Type 0 **test-purpose** `fence-test` (local test folder) | class | Active (1.10.3) | `requirement-class-software-dev.md` | 2026-09-08 |
| requirement-bootstrap-chain | Live origin selfmanaged; this product is sudoer-cli; Type O channel; exactly one Active domain SSOT | architecture | Active (5.3.1) | `requirement-bootstrap-chain.md` | 2026-09-08 |
| requirement-project-folder | Project layout (`src/`), install bins; LPU home / `/etc/{{username}}/` are host paths | architecture | Active (3.1.0) | `requirement-project-folder.md` | 2026-08-14 |
| requirement-shell-cli-interface | Shell CLI interface (Type 0 lifecycle + Type 0 operational convert/submit + Type 0 **test-purpose** `test-json-format` / `test-well-known-binary` / `fence-test` / `rc-test`; Type 1 any-elevated approve; login-hook-symlink after global copy; claimed `menu` / `main`; help headings people-first) | shell | Active (3.12.0) | `requirement-shell-cli-interface.md` | 2026-09-09 |
| requirement-shell-cli-zero-arguments | Empty argv Type O install-ensure (numbered list is `menu` / `main`) | shell | Active (1.3.0) | `requirement-shell-cli-zero-arguments.md` | 2026-09-07 |
| requirement-shell-cli-default-interaction | Numbered TTY start list on verb `menu` / `main` (empty argv is Type O) | shell | Active (1.1.0) | `requirement-shell-cli-default-interaction.md` | 2026-09-07 |
| requirement-shell-self-management | Online self-management: install / version-check / self-update / self-uninstall / about; PATH companion **call site** | shell | Active (1.2.0) | `requirement-shell-self-management.md` | 2026-09-09 |
| requirement-shell-automatic-checksum | Automatic companion-digest integrity (`${SCRIPT_URL}.sha256`) | shell | Active (1.1.0) | `requirement-shell-automatic-checksum.md` | 2026-09-07 |
| requirement-shell-local-self-management | Historical local-copy package; **superseded** by online self-management | shell | Superseded (1.5.1) | `requirement-shell-local-self-management.md` | 2026-09-07 |
| requirement-shell-output-requirements | Central `out_*` output SSOT; colors consume `TTY`; operator-readable fatals (happened / Next:); visudo-fail worked example; default-cli-main-menu-style printers used by claimed `menu` / `main` | shell | Active (1.3.1) | `requirement-shell-output-requirements.md` | 2026-09-03 |
| requirement-shell-modular-function-design | Single-file modular prefixes; domain `sr_` / `lpu_` reserved; `prompt_*` consume `TTY`; `util_sudo` / `util_chmod` | shell | Active (3.2.1) | `requirement-shell-modular-function-design.md` | 2026-09-06 |
| requirement-shell-script-coding | POSIX writing-style specialize-in home; **points** at sudo-command for wrappers; do-not-capture-read | shell | Active (1.4.1) | `requirement-shell-script-coding.md` | 2026-09-06 |
| requirement-shell-sudo-command | Sudo-wrapping function; check before sudo; chmod example (`util_sudo` / `util_chmod`) | shell | Active (1.0.1) | `requirement-shell-sudo-command.md` | 2026-09-06 |
| requirement-shell-idempotency | Re-run safety for install / uninstall / PATH companion (setup heal is target law) | shell | Active (1.3.0) | `requirement-shell-idempotency.md` | 2026-09-09 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm policy; TTY measured outside functions; Type 1 `interactive` + hook; loop must not steal stdin; dest one-off yes/no; `menu` / `main` no-hang | shell | Active (1.5.1) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-09-06 |
| requirement-shell-prompt | `prompt_*` helper bodies; consume `TTY`; dest review uses one `prompt_yes_no`; `PROMPT_ASK_VALUE` | shell | Active (1.2.1) | `requirement-shell-prompt.md` | 2026-09-06 |
| requirement-shell-cli-storage | Scratch/cache resolve; visudo copies under resolver + pid | shell | Active (1.1.1) | `requirement-shell-cli-storage.md` | 2026-09-06 |
| requirement-shell-temp-file-system | Scratch **leaves**: `mktemp`; no `$$` paths; cleanup | shell | Active (1.0.0) | `requirement-shell-temp-file-system.md` | 2026-08-14 |
| requirement-three-layer-privilege-model | Type 0/1 map; Type 0 **test-purpose** testers vs **operational** Type 0; F6 extra path + login-hook-symlink; any elevated sudoer may approve; sudo-wrapping / check before sudo; grant visudo **points** at sudoers-file; hook **points** at `requirement-login-interactive-review-hook` | architecture | Active (1.15.2) | `requirement-three-layer-privilege-model.md` | 2026-09-08 |
| requirement-least-privilege-user | sudoer-adm F1–F7; home create `/etc/sudoer-adm`; F5 `/var/{{APP_NAME}}/` 3773 + F4 views; LSU never `useradd`; login hook **points** at `requirement-login-interactive-review-hook` | architecture | Active (1.14.2) | `requirement-least-privilege-user.md` | 2026-09-08 |
| requirement-privilege-prevention-set | Closed catalog; OPEN-SUDOER-APPR; OPEN-DECIDE; OPEN-BEHALF; no PREV-BEHALF; PREV-JSON-VISUDO owner sudoers-file; F6 grants hook name | architecture | Active (1.6.4) | `requirement-privilege-prevention-set.md` | 2026-09-06 |
| requirement-actor-role-subject-approver | Actor / role / subject / submitter / approver catalog (dest has approver) | architecture | Active (1.0.0) | `requirement-actor-role-subject-approver.md` | 2026-08-19 |
| requirement-incorrect-json-format | Dest **Fence**: incorrect JSON format (independent REQ; dest table still prints; Type 0 **test-purpose** `test-json-format`; dest-written `submit_by`; dest-owned `submit_app` / `submit_version`; dest review missing stamp is warn-then-ask; garbage JSON display-then-rejected) | domain | Active (1.5.0) | `requirement-incorrect-json-format.md` | 2026-08-21 |
| requirement-well-known-sudoer-binary-fence | Well-known sudoer binary (closed system prefixes + no interpreter Cmnd; dest **warn then ask**; Type 0 testers/convert fail closed; Type 0 **test-purpose** `test-well-known-binary`; list tester `fence-test`) | domain | Active (1.2.0) | `requirement-well-known-sudoer-binary-fence.md` | 2026-08-21 |
| requirement-sudoers-file | Grant sudoers file (text dual; visudo-legal Cmnd arg escape; visudo -cf; operator-readable visudo-fail; stay-honest sibling service grants) | domain | Active (1.1.0) | `requirement-sudoers-file.md` | 2026-08-26 |
| requirement-login-interactive-review-hook | Login-time review hook: rc snippet, `.profile` create-if-absent, labeled `/usr/local/bin/{{APP_NAME}}-hook`; Type 1 `interactive` reviews `{{APP_NAME}}-adm` rc and replaces an old product-binary hook | shell | Active (1.1.0) | `requirement-login-interactive-review-hook.md` | 2026-09-08 |
| requirement-shell-path-and-shell-support | Shell-rc PATH + this-login profile ensure (sibling unify, scoped uninstall, heal, `rc-test`); login-hook stays on the login-hook REQ | shell | Active (1.0.0) | `requirement-shell-path-and-shell-support.md` | 2026-09-09 |
| requirement-domain-sudoer-approval | **Domain SSOT** — A may submit for B; filename uses B; human decides via one-off yes/no; dest fence table; Type 0 **test-purpose** `fence-test` / `test-json-format` / `test-well-known-binary`; dest-owned `submit_app` / `submit_version`; dest-written `submit_by`; JSON-format fence match → rejected; missing stamp / untrusted Cmnd warn then ask; grant sudoers file **points** at `requirement-sudoers-file`; login hook **points** at `requirement-login-interactive-review-hook`; leftover Self-scope dropped (OPEN-BEHALF); worked samples `alice` / `webservice`; §1.1 Decide names warn-then-ask; submit `/var/{{APP_NAME}}/sudoer-request`; keep-latest duplicate inbound; YAML review display indented two spaces per request | domain | Active (2.40.0) | `requirement-domain-sudoer-approval.md` | 2026-09-08 |

## Intentionally absent

| Surface | Status on sudoer-cli |
|---------|----------------------|
| Folder archive backup / restore / retention | **Absent** |
| Type 2 execution context (run as LPU euid for `/etc` writes) | **Absent** — sudoer-adm is an authorizer |
| `--purge-grants` on LPU teardown | **Absent** in v1 |

**Install mode:** **online-installable** (`curl | sh` + `install` + `version-check` + `self-update` + `self-uninstall`). Not dual-mode. Global 0755 is the production trust path for F6.

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for sudoer-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only**.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md`.  
6a. **Coding-style related REQ:** software-development requires Active `requirement-shell-script-coding` (language-matched specialize-in home). **MUST NOT** skip so portable lessons arrive raw.  
6b. **In-tool sudo:** POSIX products that invoke sudo inside the ship unit require Active `requirement-shell-sudo-command` (sudo-wrapping function; check before sudo; chmod example). Coding-style **points**.  
7. **Domain SSOT:** exactly one Active `requirement-domain-sudoer-approval.md`. That file **presents** the file-based JSON approval machine (roles, submit-when, JSON verify, dest fence table, Type 1 authz, interactive loop) plus the four pillars. Help **must not** list a verb with no dispatcher arm. Type 0 domain is **routed**; Type 1 `setup` and `interactive` are **live**. Grant sudoers **file** is owned by `requirement-sudoers-file`; login hook (rc snippet + labeled `/usr/local/bin/{{APP_NAME}}-hook`) is owned by `requirement-login-interactive-review-hook`; domain **points**.  
8. **Do not drop** online install / Type O while the product claims `curl | sh`. **Do not reintroduce** Type 2 execution without explicit user order and registry update.  
9. **Prevention set:** `requirement-privilege-prevention-set.md` is the closed catalog of what this product **blocks** and what it **must not block**. Do **not** invent a wall that is not a row in that file.  
10. **Dest Fence:** dest **Fence** is incorrect JSON format (`requirement-incorrect-json-format`). Well-known sudoer binary (`requirement-well-known-sudoer-binary-fence`) is dest **warn then ask** plus convert/submit/tester fail-closed. Dest tables still print and point at those REQs. Dest Fences **MUST** ship Type 0 **test-purpose** `fence-test` (unit test of a **local test folder**; sudo wrap **only** chmod/chown of that folder; **no** queue / dest / setup). Help **MUST** list testers apart from operational verbs. **MUST NOT** invent an extra dest fence. visudo reject is **not** a dest Fence (`requirement-sudoers-file`).  
11. **ARSA:** `requirement-actor-role-subject-approver` is the consider catalog. Do **not** invent an extra approver.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
