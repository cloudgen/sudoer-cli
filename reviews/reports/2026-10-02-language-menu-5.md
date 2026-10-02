# Review — menu 5 languages (sudoer-cli 1.29.0)

**Date:** 2026-10-02  
**Scope:** Flat numbered list gains row **5** languages, modeled on sshd-cli 1.32.0 codes **51–63**, without importing that product’s client/server/self tree.  
**Verdict:** **Pass**  
**Suite:** `sh tests/run.sh` → **PASS=844 FAIL=0 SKIP=10** (live Type 1 still skipped)

## What changed

- Ship unit `VERSION="1.29.0"`. `src/sudoer-cli.sha256` matches the script.
- Front row **5** is `languages`. Old rows **5–15** are **6–16**. Exit stays **99**. Unused front example is **17**.
- Language board **51–63**. **50** and **64–69** are not printed. **0** / empty is Back and does not save.
- Persistence: `${HOME}/.local/sudoer-cli/language`, mode **0600**, created only by `app_lang_save`. `SUDOER_CLI_LANG` overrides for one process and does not write the file.
- Human `help` and human `about` follow `APP_LANG`. Argv `version` and JSON about stay English. Command tokens stay Latin.
- Both boards call `prompt_ask "$(app_menu_text choice_label)"` in the current shell. English label is `Choice`.

## Law

| File | Version |
|------|---------|
| `requirement-shell-cli-language.md` | 1.0.0 (new) |
| `requirement-shell-cli-default-interaction.md` | 1.3.0 |
| `requirement-shell-cli-storage.md` | 1.2.0 |
| `requirement-shell-modular-function-design.md` | 3.2.2 |
| interface, class, bootstrap | stay-honest `VERSION` 1.29.0 |

Checklist: `docs/checklists/2026-10-02-checklist-language-menu-5.md` (Pass).

## Proof

- **TP-CLI-24** covers the board, each saved sentence and Exit line, mode 600, Back, reserved **50**/**64**/**69**, front **6** = `add-sudoer-request`, front **51** is not a save, unrecognized file left as written, env override, Japanese and Korean help/about, and no language file on `help` or `version`.
- **TP-CLI-20** / **21** / **22** still hold with N=16 and unused **17**.
- **TP-ELEV-10** still forbids `$()` of `prompt_ask`. Catalog lines that quote `sudo -n` are `_mt_out` data, the same sentence the old `out_plain` help line already carried.

## Limits

- The menu runner stubs `prompt_ask` because the live helper reads `/dev/tty` first. A piped `TTY=1` menu would hang there. Off-TTY `menu` still prints help.
- Operational command output is not translated.
- Sibling sshd-cli was read and not edited.
