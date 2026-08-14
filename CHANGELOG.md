# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-08-14

### Added

- Type 0 domain: `sudoers-to-json` / `json-to-sudoers`, `add` / `update` / `remove-sudoer-request`, list/show, `print-sudoers`.
- Domain tests `tests/test_domain_sr.sh` (TP-SR-01..13, TP-SR-PRIV-01).
- Domain law: file-based JSON approval; dest convention `{{service-name}}-{{username}}` (e.g. `folder-backup-leolio`).

### Changed

- Request id is `sudoer-DATE-{{service}}-{{user}}-action-n.json` (service before user).
- Approved dest is `/etc/sudoers.d/{{service}}-{{user}}`, matching project-sudoers-file `{{APP_NAME}}-{{TARGET_USER}}`.
- Type 1 names (`setup`, `approve`, `reject`, `interactive`) are routed and fail closed without euid 0. Live `useradd` / dest write to `/etc` remains a Gap.

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
