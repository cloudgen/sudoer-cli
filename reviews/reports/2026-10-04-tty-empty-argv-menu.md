# Review — TTY empty argv opens the numbered list (sudoer-cli 1.30.0)

**Date:** 2026-10-04  
**Scope:** No command token, including `--debug`, opens the flat numbered list on a real terminal. A pipe with no command stays Type O self-install.  
**Verdict:** **Pass**  
**Suite:** `sh tests/run.sh` → **PASS=880 FAIL=0 SKIP=10** (live Type 1 still skipped)

## What changed

- Ship unit `VERSION="1.30.0"`. `src/sudoer-cli.sha256` matches the script.
- After flag parse, no command token is empty argv. `--debug`, `--quiet` / `-q`, `--force`, and `--global` with no command follow that path.
- TTY empty argv sets `COMMAND=menu` and draws the existing sixteen-row list (row **5** languages, Exit **99**). It does not install and it does not dump help.
- Off-TTY empty argv sets internal `command=ensure` and keeps `inst_perform_install` / `inst_maybe_install`. Already installed is a success no-op. Quiet still places or fail-closes. There is no public `ensure` verb.
- `--json` with no command is JSON help on a terminal and in a pipe. TTY `menu --json` still draws the list. Off-TTY `menu` is help.
- `app_lang_load` runs once after flag parse, including the TTY menu. `SUDOER_CLI_LANG=ja` on that path shows `99. 終了` and does not write the language file.
- The list stays flat. No domain hierarchy, session line, or menu paint timer was added.

## Law

| File | Version |
|------|---------|
| `requirement-shell-cli-zero-arguments.md` | 1.4.0 |
| `requirement-shell-cli-default-interaction.md` | 1.4.0 |
| `requirement-shell-cli-language.md` | 1.1.0 |
| `requirement-shell-cli-interface.md` | 3.13.0 |
| `requirement-shell-interactive-vs-noninteractive.md` | 1.6.0 |
| `requirement-shell-output-requirements.md` | 1.4.1 |
| `requirement-class-software-dev.md` | 1.11.4 |
| `requirement-bootstrap-chain.md` | 5.3.4 |
| `requirement-domain-sudoer-approval.md` | 2.41.1 |
| `requirement-shell-self-management.md` | 1.2.1 (stay-honest `VERSION` 1.30.0) |

Checklist: `docs/checklists/2026-10-04-checklist-tty-empty-argv-menu.md` (Pass).

## Proof

- **TP-CLI-07** keeps the off-TTY dead-channel non-zero path and adds the TTY list plus `--json` JSON help.
- **TP-CLI-29** covers off-TTY `--debug` (`already installed`, `command=ensure`), off-TTY `--quiet`, `--json --debug` with no `[DEBUG]`, TTY `--debug` (`command=menu`), and Japanese `99. 終了` without a language-file write.
- **TP-LC-11 / 14 / 15** and the curl-install cases still pass for off-TTY install-ensure.
- **TP-CLI-18..22**, **TP-CLI-24**, and **TP-ELEV-10** still hold (N=16, Exit **99**, no `$()` of `prompt_ask`).

## Limits

- The PTY proof uses `python3` `pty.fork` and sends `99` so the live `/dev/tty` read can finish. If `python3` is missing, those rows skip.
- `--json` suppresses human debug, so `--json --debug` does not print `[DEBUG]`.
- Sibling grok-cli was read and not edited. Its domain menu was not copied.
