# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
