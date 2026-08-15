# Lessons — sudoer-cli

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 | open watch |
| L-ONLINE-01 | Online verbs reintroduced (self-update / SCRIPT_URL UX) | bootstrap-trim + TP-CLI-04/10 | open watch |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-INST-MODE-01 | Install leaves `0711`/`0700` (chmod +x after mktemp) so non-owners cannot run shell ship unit | absolute `chmod 0755` + heal on reinstall; TP-LC-09/10; local-self-management §2.3.1 | open watch |
| L-TRIM-01 | Backup / restore / sudoers verbs reintroduced as if still product law | bootstrap-chain (absent domain); TP-CLI-04/13 | open watch |
| L-PUSH-VAULT-01 | Bare `git push` uses wrong active SSH vault when default face ≠ repository-user | Pre-git report + bound SSH transport; incident 20260810-001 | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared world-writable storage | util_resolve_storage; TP-CLI-12 | open watch |
| L-TTY-01 | Interactive policy from live `[ -t` **inside** `prompt_*` / `about` / `$(…)` (false non-interactive) | Measure `[ -t` outside functions; helpers consume `TTY`; AC-4; **TP-ELEV-07** | watch |
| L-LAW-ROUTE-01 | Registry/REQ still say domain “not yet routed” after convert/submit/help/about are live | Retarget domain + CLI interface in the same change as routing; do not leave “Until routed” paragraphs | watch |
| L-LAW-PRESENT-01 | Domain REQ has verbs/schema but does not **name** the file-based JSON approval machine (roles, submit-when, verify table) | Domain §2.0 in product language; sufficient-check Step 3e | watch |
| L-LAW-INT-01 | “TTY login as LPU approves” with no authz table, hook snippet, or consume-`TTY` loop — or empty argv hijacked | Domain §2.2 hook + loop; Step 3f; empty argv stays help | watch |
| L-TEST-OP-01 | Suite greened Type 1 `setup` via `sh "${SCRIPT}"` fail-closed; operator `sudoer-cli setup` / `sudo sudoer-cli setup` never run (command-not-found / sudo PATH / Gap) | Invoke or simulate bare PATH + sudo-like PATH; do not equate TP-SR-PRIV-01 with operator setup; help must mark Gap; incident 20260814-001 | open (CI still no live `useradd`) |
| L-GAP-HELP-01 | Help / examples tell a human to `sudo … setup` while `lpu_setup` is `sr_die` “not enabled”; review “honest Gap” + fail-closed green hid it | Do not list create/teardown unless the body creates; Gap footnote ≠ working command; **TP-SR-PRIV-03**; incident 20260814-002 | **closed** (setup body live; TP-SR-PRIV-03) |
| L-ERR-OP-01 | Operator errors were jargon only (`Type 1`, `euid 0`, `authorization failed`, `not enabled in this environment`) with no pasteable next command | Human die = what failed + `Next:` command (running path or global bin); no `sudo -n` on bootstrap; TP-SR-PRIV-01 | **closed** (`sr_die` + `Next:`; TP-SR-PRIV-01 / TP-ELEV-08) |
| L-SUDO-MIX-01 | User said Type 1 `setup`; agents wrote “ship unit MUST NOT invoke sudo” and “all sudo ⊆ Table A” | Mix model: password `sudo` OK in script; Table C `sudo useradd` not in sudoers; `-n` not suggested; **requirement-privilege-prevention-set** OPEN-SUDO / OPEN-USERADD | open |
| L-CMD-OPEN-01 | Agents invented a live-command **whitelist** (Table A closed set) with no user denylist | **No denylist ⇒ no restrict.** Table A = F6 fragment only. **requirement-privilege-prevention-set** OPEN-TOOLS / OPEN-UNLISTED / OPEN-TABLE-A | open |
| L-ELEV-OK-01 | After operator `sudo` / root, agents added another privilege wall | **requirement-privilege-prevention-set**: elev *is* consent; only §2.2 rows block; sensitive = confirm/`--force` only | open |
| L-ELEV-BOOT-01 | Wrote first-time `setup` as `sudo -n` / `SUDO_USER==sudoer-adm` — chicken-egg; install is multi-user; `-n` is hook-only after F6 | Split `sr_require_type1_bootstrap` vs F6 `sr_require_type1`; TP-SR-PRIV-02; EM-HYB | open watch |
| L-ELEV-N-01 | Agents paste `sudo -n` from skills/molds as default elev (**knowledge pollution**) | Avoid `-n` unless specialized law specifies NOPASSWD/hook/ticket; **T1-N-POLLUTE**; mold §8.1.4 | open watch |
| L-QUEUE-0777-01 | Inbound **0777** without sticky: world readdir + unlink/replace of others’ grant JSON; approve `mv` of path after `cp` | Inbound **3773**; submit `0640`; archive snapshot then unlink inbound; F7 removes `/var/{{APP_NAME}}/` children; **SR-SEC-01/02** | **closed** (1.5.1; TP-SR-Q-01..03) |
| L-INT-STDIN-01 | `while read … done <id-list` stole stdin from `prompt_yes_no`; login hook printed all three (y/N) and skipped | Read the id list on fd 3; leave fd 0 for prompts; **TP-SR-INT-05** | **closed** (1.6.1) |

**Related-product only (do not re-apply as this origin’s law):** L-DEPOSIT-01, L-SUDOERS-01..05, L-OVERWRITE-01 stay on folder-backup. Type O empty-argv / online-channel lessons stay on products that own those surfaces. This product is hop 0.

**This origin’s kept surfaces:** output SSOT, no basename gate on entry, storage isolation, Type N empty argv.
