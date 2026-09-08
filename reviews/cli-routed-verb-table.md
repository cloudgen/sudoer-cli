# CLI routed-verb table — sudoer-cli

**Product:** sudoer-cli  
**Ship unit:** `src/sudoer-cli`  
**Dispatcher:** `app_main` → `app_run_command`  
**Scan date:** 2026-09-03  
**Mode:** full (no previous table)  
**Copied:** 0 · **Re-checked:** all live tokens

Inventory from the dispatcher. Help is not a route. Empty argv is not a verb.

## Live

| verb | handler | privilege | last modified date | human-readable |
|------|---------|-----------|--------------------|----------------|
| install | `inst_perform_install` | you | 2026-09-07 | `install: Place sudoer-cli from the install channel` |
| version-check | `ver_check` | you | 2026-09-07 | `version-check: Compare local version to the install channel` |
| self-update | `inst_self_update` | you | 2026-09-07 | `self-update: Fetch a newer copy from the install channel` |
| self-uninstall | `inst_self_uninstall` | you | 2026-09-07 | `self-uninstall: Remove the managed binary (confirm or --force)` |
| version | `app_version` | you | missing | `version: Show local version` |
| about | `app_about` | you | 2026-08-13 | `about: Show diagnostics and resolved queue paths` |
| help | `app_help` | you | missing | `help: Show this help` |
| menu | `app_main_menu` | you | 2026-09-03 | `menu: Numbered list of live work commands (real terminal)` |
| main | `app_main_menu` | you | 2026-09-03 | `main: Numbered list of live work commands (real terminal)` |
| sudoers-to-json | `sr_sudoers_to_json` | you | missing | `sudoers-to-json: Convert sudoers fragment to request JSON` |
| json-to-sudoers | `sr_json_to_sudoers` | you | missing | `json-to-sudoers: Convert request JSON to sudoers fragment` |
| test-json-format | `sr_test_json_format` | you | missing | `test-json-format: Test a grant JSON file against the dest JSON-format fence (does not queue)` |
| test-well-known-binary | `sr_test_well_known_binary` | you | missing | `test-well-known-binary: Test grant command paths against the well-known system-binary fence (does not queue)` |
| fence-test | `sr_fence_test` | you | missing | `fence-test: Test dest fence functions against a local JSON file (no sudo; does not queue)` |
| print-sudoers | `sr_print_sudoers` | you | missing | `print-sudoers: Print the sudoers fragment that lets sudoer-adm review without a password` |
| print-sudoers-install-script | `sr_print_sudoers_install_script` | you | missing | `print-sudoers-install-script: Emit admin install script` |
| add-sudoer-request | `sr_submit` | you | missing | `add-sudoer-request: Queue an add request (JSON or sudoers)` |
| update-sudoer-request | `sr_submit` | you | missing | `update-sudoer-request: Queue an update request` |
| remove-sudoer-request | `sr_submit` | you | missing | `remove-sudoer-request: Queue a purpose-only remove (--service)` |
| list-approving | `sr_list` | you | missing | `list-approving: List waiting requests` |
| list-approved | `sr_list` | you | missing | `list-approved: List accepted requests` |
| list-rejected | `sr_list` | you | missing | `list-rejected: List declined requests` |
| show | `sr_show` | you | missing | `show: Show a known request` |
| setup | `lpu_setup` | change-the-computer | missing | `setup: Create the dedicated approver account (sudoer-adm)` |
| remove-lpu | `lpu_remove` | change-the-computer | missing | `remove-lpu: Remove the dedicated approver account (sudoer-adm)` |
| approve | `sr_approve` | change-the-computer | missing | `approve: Copy/overwrite dest in /etc/sudoers.d (product names only)` |
| reject | `sr_reject` | change-the-computer | missing | `reject: Decline a waiting request` |
| interactive | `sr_interactive` | change-the-computer | missing | `interactive: Review waiting requests one file at a time (not empty argv)` |

**Live count:** 27

## Not-yet-wired

| verb | handler | privilege | last modified date | human-readable | status |
|------|---------|-----------|--------------------|----------------|--------|
| backup | — | — | — | — | **forbidden** (trimmed parent) |
| restore | — | — | — | — | **forbidden** (trimmed parent) |
| remove-project-sudoers | — | — | — | — | **forbidden** (trimmed parent) |

**Not-yet-wired count:** 3

Honesty: inventory from `app_run_command` case arms. Dates from handler comment `Last updated:` / `Last reviewed:`; `missing` is recorded, not invented.
