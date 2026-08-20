# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.13.0] - 2026-08-20

### Changed

- Dest **`interactive`** (login hook included): a dest **Fence** match is **displayed**, then the waiting file is **moved to the rejected queue**. **MUST NOT** ask yes/no. **MUST NOT** dest-write `/etc/sudoers.d`. **MUST NOT** stamp `submit_by`. Standalone `approve` / `reject` still fail closed and leave the file inbound. Domain **2.25.0**; dest Fence **1.3.0**. **TP-SR-FENCE-12**.
- Ship unit **`VERSION="1.13.0"`**.

## [1.12.0] - 2026-08-20

### Changed

- Dest **`interactive`** review asks a **one-off approval question**: **yes** = approve, **no** (or Enter) = reject. Prompt text is **`Approve this request (y/N)?`**. **MUST NOT** offer skip / quit / maybe, and **MUST NOT** chain Approve then Reject then Quit as three `(y/N)` questions. Term **`approval-question`**. Domain **2.24.0**; interactive **1.4.0**; prompt **1.1.0**; dest Fence **1.2.1**. **TP-SR-INT-06**. Direct `approve` / `reject` with a request id stay non-interactive.
- `setup` **heals** a stale `/usr/local/bin/sudoer-cli` when its `VERSION` does not match the running ship unit (login hook otherwise keeps the old three `(y/N)` walk).
- Ship unit **`VERSION="1.12.0"`**.
- CLI-interface **3.6.0** names every routed domain / Type 1 verb on the Supported commands table (dual mention). Class **1.9.1** core-rule sections sequential. **TP-SUDO-05..07** runtime check-before-sudo.
- Add/review requirement skills gate dest **approval-question**: **`SK-CREATE-SPECIFIC-REQUIREMENT` 3.19.0**, **`SK-REQUIREMENT-REVIEW` 2.19.0**, **`SK-REQUIREMENT-ELICITATION` 2.12.0**, **`SK-REQUIREMENT-SUFFICIENT-CHECK` 1.13.0**. **`CL-FILE-BASED-JSON-APPROVAL`**. Fail skip/quit/three chained `(y/N)` when authoring or reviewing dest review law.

### Fixed

- Dest `submit_by` stamp inserts only at the **first** `{` in the grant JSON. Pretty `commands[]` objects are not re-stamped. **TP-SR-FENCE-11**.

## [1.11.0] - 2026-08-20

### Added

- **`requirement-shell-sudo-command` 1.0.0**: in-tool sudo SSOT. **Sudo-wrapping function** `util_sudo` is the only `sudo "$@"` call site. **`util_chmod`** implements **check before sudo** via `[ -O path ]` — if this login owns the path, **no** `sudo chmod`. **`lpu_sudo`** calls `util_sudo`. **TP-SUDO-01..04**.
- Term **sudo-wrapping-function** (+ human-intro): the helper that owns every in-tool `sudo` and **MUST** run check before sudo. chmod remains the worked example.

### Changed

- Ship unit **`VERSION="1.11.0"`**. chmod call sites go through `util_chmod`.
- Coding style **1.3.0** **points** at sudo-command (does not keep wrapper bodies). Class **1.9.0** residual pointer. Modular **3.2.0** prefix table. Three-layer **1.14.0**.
- Mold **`LM-SHELL-SCRIPT-CODING` 3.13.0** §8.3 wrapping-function samples. **`SK-SH-SCRIPT-CODING` 2.16.0**. **`SK-CREATE-SPECIFIC-REQUIREMENT` 3.18.0**. **`SK-CREATE-CLASS-REQUIREMENT` 1.9.0**.

## [1.10.0] - 2026-08-20

### Added

- Dest-written **`submit_by`**: original Unix owner of the waiting file, converted into JSON after dest format-check. Closed-schema allowlist includes this key. Dest **MUST NOT** fence if it is present or missing. Type 0 `add-sudoer-request` **MUST NOT** plant it. `interactive` reads the owner first, takes LPU ownership when euid 0, then stamps `submit_by` if the JSON is well-formed. **TP-SR-FENCE-09..10**.
- **`requirement-shell-script-coding`**: specialize-in home for portable POSIX writing lessons. Software-dev class **MUST** have a language-matched coding-style related REQ. **Intention:** without it, agents bring portable learned lessons **raw**.
- Coding style **1.1.0**: before any `sudo chmod`, probe ownership with a **non-sudo** command (`[ -O path ]`). If this login already owns the path, do **not** `sudo chmod`. Mold **`LM-SHELL-SCRIPT-CODING`** §8.3.
- Term **check-before-sudo**: before any `sudo <cmd>`, non-sudo probe; skip sudo on match. **`sudo chmod`** is the worked example. Coding style **1.2.0**; three-layer **1.13.0**; mold §8.3 generalized.

### Changed

- Domain **2.23.0**; dest Fence REQ **1.2.0**. Maximal grant JSON is the seven identity/schema keys plus dest-stamped `submit_by`.
- Class **1.8.0**: coding-style related REQ is MUST (`requirement-shell-script-coding` **1.0.0**). Skills: **`SK-CREATE-CLASS-REQUIREMENT` 1.8.0**, **`SK-CREATE-SPECIFIC-REQUIREMENT` 3.17.0**, review **2.18.0**, elicitation **2.11.0**, sufficient-check **1.12.0**, **`SK-SH-SCRIPT-CODING` 2.13.0**. Term `coding-style-requirement`.

## [1.9.0] - 2026-08-20

### Added

- Type 0 **`test-json-format`**: test a grant JSON file against the dest JSON-format Fence without dest elev and without the waiting folder (`stdin` xor `--file`). Golden fixture `tests/fixtures/login-hook-elev-dns-adm.json`. **TP-SR-FENCE-05..08**.
- Closed schema optional **`kind`**: `type-2-switch` or `login-hook-elev`.

### Changed

- Dest JSON-format Fence law **1.1.0** requires this Type 0 tester. Domain **2.22.0**; CLI **3.5.0**; class **1.7.0**. Portable fence mold: any JSON-format dest Fence must name a Type 0 test subcommand.

## [1.8.1] - 2026-08-19

### Fixed

- After `setup` writes or rewrites the LPU `.profile` / `.bashrc` (including hook strip via `mktemp`+`mv`), those files are **`chown`’d to `sudoer-adm`** with mode **0644**. A swallowed `chown` left `root:root` and the login user could not read the hook (**L-HOOK-PROFILE-02**). Existing `.profile` bodies are still not overwritten; owner/mode is healed.
- Dest **Fence** (incorrect JSON) runs **before** yes/no: `interactive` does not prompt on a broken waiting file; standalone `approve` / `reject` fail closed with the same sentence. Basename **action** must match JSON `action` (`field_mismatch`). Filename subject ≠ JSON `username` is not a fence.
- `remove-sudoer-request` keeps JSON `username` / `service` (purpose-only means no `commands`, not no subject). A may queue a remove for B.

### Added

- Terms **shell-profile** and **shell-bashrc**. Skills **`SK-CREATE-SHELL-PROFILE`** / **`SK-CREATE-SHELL-BASHRC`**. Domain **2.21.0**; LPU **1.13.0**; ARSA catalog; dest Fence REQ; **TP-SR-HOOK-04**; **TP-SR-17** / **TP-SR-18**; **TP-SR-FENCE-01..04**.

## [1.8.0] - 2026-08-18

### Removed

- `owner_mismatch` on `approve` / `reject` (file owner vs parsed subject). That check blocked reject of legal `dns-cli-dns-adm` names (**INC-20260818-002**).
- `self_scope` on convert and submit (JSON / sudoers User must equal `id -un`).
- Type 1 `field_mismatch` of JSON `username`/`service` against a last-hyphen parse.

### Changed

- Approve dest uses JSON `username` / `service` when present (so hyphenated service+user does not write `…-adm`).
- `reject` archives the file without parsing the subject.
- Prevention-set **1.6.0** drops **PREV-BEHALF**; **OPEN-DECIDE**; **OPEN-BEHALF**. Domain **2.19.0** (A may submit for B; filename uses B). Term **approval-role-table**.

## [1.7.1] - 2026-08-18

### Fixed

- `setup` **checks** the LPU `~/.profile` and **creates** it when missing (sources `.bashrc` so an SSH login shell reaches the hook). An existing `.profile` is never overwritten. Create-first `useradd -M` copies no skel, so a missing `.profile` previously left the hook dead.
- Domain **2.17.0**; LPU **1.12.0**; **TP-SR-HOOK-01..03**. Coverage skill Step 3f now requires the check + create sample.

## [1.7.0] - 2026-08-18

### Fixed

- `approve` / `reject` / `interactive` no longer die when `SUDO_USER` is a host admin other than `sudoer-adm`. Password `sudo` **is** the approval. The remaining gate is euid 0. LPU login without `sudo` still fails.
- Incident **INC-20260818-001**; prevention-set **1.4.0** (**OPEN-SUDOER-APPR**; **PREV-APPR-ACTOR** removed); three-layer **1.12.0**; domain **2.16.0**; **TP-SR-PRIV-04** / **TP-PREV-03** / **TP-ELEV-09**.

### Changed

- `setup` prints a submit next-step (`add-sudoer-request` as yourself, then `sudo … interactive`). Type 0 / an ordinary login still never `useradd`.
- Help lists `sudo sudoer-cli interactive` as any-admin after setup.

## [1.6.2] - 2026-08-17

### Fixed

- JSON `commands[]` decode now splits objects on `}` + optional space + `,` + `{`, not only the compact token `},{`. Pretty-printed grants (folder-backup dual) no longer collapse to the last `args`. Decode **fails closed** if `"path"` count ≠ decoded command count.
- Convert/submit fatals for mixed service, unknown service, visudo reject, and incomplete `commands[]` decode now use plain words plus a pasteable **`Next:`** (do not approve; fix the file and convert again). Machine `code` values are unchanged.
- README explains file-based JSON approval in operator language (folders are state; JSON is the request).
- Incident **INC-20260817-001**; domain **2.15.0**; **TP-SR-14 / 15 / 16**.

## [1.6.1] - 2026-08-15

### Fixed

- `interactive` no longer redirects the review loop over stdin. `prompt_yes_no` can wait on the TTY, so login as `sudoer-adm` (`source ~/.bashrc` / hook) can answer approve / reject / quit instead of auto-skipping.
- Incident **INC-20260815-001**; domain **2.14.0**; interactive REQ **1.3.0** AC-6; **TP-SR-INT-05**.

## [1.6.0] - 2026-08-15

### Added

- Type 1 **`interactive`** review loop: TTY only; `--json` / non-TTY / `--quiet` fail closed; `prompt_yes_no` approve / reject / quit / skip; `--force` does not auto-approve; empty inbound exits 0.
- Tests **TP-SR-INT-01 / 02 / 04**. Domain DTV lists **TP-SR-Q-01..03**.

### Changed

- `about` / `help` say Type 0 diagnostics **include resolved queue paths** (no “no domain fields”).
- `SECURITY.md` matches Type 1 `setup` / `approve` / `interactive`, public `/var/sudoer-cli` queues, and product-owned `/etc/sudoers.d` writes.

## [1.5.1] - 2026-08-15

### Fixed

- Inbound queue mode is **3773** (sticky+setgid, no other-read), not 0777. Submit `chmod 0640`s the new file.
- `approve` / `reject` snapshot the inbound file, install that snapshot in the archive, then unlink the inbound name (no `mv` of a replaceable path).
- Owner is `stat`ed **before** any `chown` and must equal the filename subject (`owner_mismatch`).
- F7 removes the three `/var/{{APP_NAME}}/` children and `rmdir`s the public root if empty.

## [1.5.0] - 2026-08-15

### Changed

- Type 0 submit dest is **`/var/sudoer-cli/sudoer-request`** (mode **0777**, owner `sudoer-adm:sudoer-adm`). Accepted/declined archives are **`/var/sudoer-cli/sudoer-approved`** and **`/var/sudoer-cli/sudoer-rejected`** (mode **0700**). Public root `/var/sudoer-cli` is **0755** `sudoer-adm:sudoer-adm`.
- Approver (external sudo) uses F4 views under the **live LPU home** (`${LPU_HOME}/sudoer-request` → public request, same for approved/rejected). Queue paths do not hardcode `/etc/sudoer-adm`.
- Type 1 `approve` / `reject` **chown** the request file to `sudoer-adm:sudoer-adm` and keep that owner after the move.
- Inbound directory basename is **`sudoer-request`** (not `sudoer-approving`). `list-approving` remains the inbound list verb.

### Requirements

- LPU **1.9.0**, domain **2.11.0**, three-layer **1.10.0**, prevention-set **1.3.0**.

## [1.4.1] - 2026-08-14

### Fixed

- `setup` can run `useradd` after the operator already used `sudo`. When euid is 0, `lpu_sudo` runs `useradd`/`groupadd`/`userdel` directly (no second password `sudo`). Home `/etc/sudoer-adm` is created first; `useradd` uses `-M` so the default `HOME=/home` does not block it.

## [1.4.0] - 2026-08-14

### Changed

- Type 1 **exception:** copy, overwrite, and remove **product-owned** files under `/etc/sudoers.d/` (F6 `sudoer-adm`; grant `{{service}}-{{username}}`). Type 0 still does not write that tree. Still never write `/etc/passwd` or `/etc/sudoers`. LPU home stays `/etc/sudoer-adm`.

## [1.3.0] - 2026-08-14

### Added

- Product law `requirement-privilege-prevention-set`: closed catalog of what is blocked vs what must stay open after elev.

### Changed

- Dest is **`/etc/{{username}}/{{service}}`**. LPU home is **`/etc/sudoer-adm`**. F6 file is **`/etc/sudoer-adm/sudoers`**.
- The ship unit **must not** write `/etc/passwd` or `/etc/sudoers.d`. There is no blanket “do not write `/etc`”.
- Three-layer **1.8.0**, LPU **1.7.0**, domain **2.9.0**, prevention-set **1.1.0**.

## [1.2.3] - 2026-08-14

### Changed

- LPU create/teardown invokes **`sudo useradd` / `sudo groupadd` / `sudo userdel`** from the ship unit (password `sudo`; never `sudo -n`). F6 / `print-sudoers` still **must not** contain `useradd` (FORB-07).

## [1.2.2] - 2026-08-14

### Fixed

- `setup` / `remove-lpu` always `useradd` / `userdel` after euid 0. Removed `lpu_live_host` and `SUDOER_CLI_LIVE_LPU_TEST` — that skip was a bug, not a requirement. Nobody ordered a Gap or a flag to enable create.

## [1.2.1] - 2026-08-14

### Fixed

- Operator errors for `setup` / `approve` / `reject` / `interactive` / queues / LPU collision now say **what failed** and print a **`Next:`** line with a pasteable command (checkout path or global binary). Jargon-only text (`Type 1`, `euid 0`, `authorization failed`, `not enabled in this environment`) is gone from those paths.

## [1.2.0] - 2026-08-14

### Added

- Live Type 1 **`setup` / `remove-lpu`**: create/teardown `sudoer-adm` (UID/GID 1776, home `/home/sudoer-adm`), F5 queues, F6 `/etc/sudoers.d/sudoer-adm`, and the login-hook snippet. Any host admin already euid 0 (`sudo src/sudoer-cli setup` or `sudo sudoer-cli setup`; password sudo OK). Missing global binary is installed from the running ship unit so F6 is never written to a missing path. Collision on UID/GID/name fails closed. `remove-lpu` archives queues (unless `--purge-queues`), strips the hook, backs up F6, then `userdel -r`. Live `{{service}}-{{user}}` grants stay.

### Changed

- Help no longer labels `setup` as a Gap. The `sr_interactive` review loop remains a Gap.

## [1.1.1] - 2026-08-14

### Fixed

- Type 1 **bootstrap** (`setup` / `remove-lpu`) is any host admin already euid 0 (`sudo sudoer-cli setup`, password sudo allowed). It is **not** `sudo -n` and **not** limited to `sudoer-adm` (that account does not exist yet). Day-to-day `approve` / `reject` / `interactive` still require F6 `sudoer-adm` or a real root login. Login-hook `sudo -n` stays post-F6 only so `.bashrc` cannot hang.

## [1.1.0] - 2026-08-14

### Added

- Type 0 domain: `sudoers-to-json` / `json-to-sudoers`, `add` / `update` / `remove-sudoer-request`, list/show, `print-sudoers`.
- Domain tests `tests/test_domain_sr.sh` (TP-SR-01..13, TP-SR-PRIV-01).
- Domain law: file-based JSON approval; dest convention `{{service-name}}-{{username}}` (e.g. `folder-backup-leolio`).

### Changed

- Request id is `sudoer-DATE-{{service}}-{{user}}-action-n.json` (service before user).
- Approved dest is `/etc/sudoers.d/{{service}}-{{user}}`, matching project-sudoers-file `{{APP_NAME}}-{{TARGET_USER}}`.
- Type 1 names (`setup`, `approve`, `reject`, `interactive`) are routed and fail closed without euid 0. Live `useradd` and dest install landed in **1.2.0**.

## [1.0.0] - 2026-08-13

### Added

- **sudoer-cli** specialized **A → B** from **cli-template** Type 0 architecture (no live parent ship unit).
- Ship unit `src/sudoer-cli` (`APP_NAME=sudoer-cli`, `REPO_NAME=sudoer-cli`, `VERSION=1.0.0`).
- Type 0 local self-managed CLI: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`.
- Empty argv **Type N** help (local-only; no curl|sh; `interactive` is not empty argv).
- Suite **TP-CLI-01..13** and **TP-LC-01..10**.
- Law: class software-dev + bootstrap-chain + Type 0 shell family.
- Law: `requirement-three-layer-privilege-model`, `requirement-least-privilege-user`, domain SSOT `requirement-domain-sudoer-approval` (**target law**; verbs not yet routed).

### Changed

- Identity SSOT: `APP_NAME=sudoer-cli`, `REPO_NAME=sudoer-cli`, forge **cloudgen/sudoer-cli** (private).
- Historical origin is **cli-template** (git archive). Do not reverse-copy this body onto that origin.
- About: Type 0 diagnostics only until domain about pillar is routed.
- Install **locations unchanged**: local `${USER_BIN}` **and** global `${GLOBAL_BIN}`. “Local-only” means **no online channel**.
- Author-email **wongcf22@gmail.com**, product version **1.0.0**.

### Removed (not this product’s live surfaces)

- Live `src/cli-template` ship unit (architecture preserved in this file and git).
- Online install / Type O / `SCRIPT_URL` UX.
- Folder-archive `backup` / `restore` domain.
