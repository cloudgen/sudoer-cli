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
| L-HOOK-PROFILE-01 | Hook in `.bashrc` only; missing `~/.profile` (create-first `useradd -M` copies no skel) so SSH login never sources `.bashrc` | Domain §2.2 **check** + **create** source-bashrc sample; never overwrite; Step 3f; **TP-SR-HOOK-01..03** | **closed** (1.7.1) |
| L-HOOK-PROFILE-02 | `setup` created LPU `~/.profile` then `lpu_hook_strip` `mktemp`+`mv` left `root:root` `0600`; login `Permission denied`; hook never fires | After rc rewrite: `chown` LPU + readable mode; heal unreadable existing; **TP-SR-HOOK-04**; install the fixed binary **and** `stat` live `.profile`; incidents **20260818-003** · **20260819-001** | **open** (checkout 1.8.1 has helper; global 1.8.0 + host `.profile` still `root:root` `0600`) |
| L-TEST-OP-01 | Suite greened Type 1 `setup` via `sh "${SCRIPT}"` fail-closed; operator `sudoer-cli setup` / `sudo sudoer-cli setup` never run (command-not-found / sudo PATH / Gap) | Invoke or simulate bare PATH + sudo-like PATH; do not equate TP-SR-PRIV-01 with operator setup; help must mark Gap; incident 20260814-001 | open (CI still no live `useradd`) |
| L-GAP-HELP-01 | Help / examples tell a human to `sudo … setup` while `lpu_setup` is `sr_die` “not enabled”; review “honest Gap” + fail-closed green hid it | Do not list create/teardown unless the body creates; Gap footnote ≠ working command; **TP-SR-PRIV-03**; incident 20260814-002 | **closed** (setup body live; TP-SR-PRIV-03) |
| L-ERR-OP-01 | Operator errors were jargon only (`Type 1`, `euid 0`, `authorization failed`, `not enabled in this environment`) with no pasteable next command | Human die = what failed + `Next:` command (running path or global bin); no `sudo -n` on bootstrap; TP-SR-PRIV-01 | **closed** (`sr_die` + `Next:`; TP-SR-PRIV-01 / TP-ELEV-08) |
| L-SUDO-MIX-01 | User said Type 1 `setup`; agents wrote “ship unit MUST NOT invoke sudo” and “all sudo ⊆ Table A” | Mix model: password `sudo` OK in script; Table C `sudo useradd` not in sudoers; `-n` not suggested; **requirement-privilege-prevention-set** OPEN-SUDO / OPEN-USERADD | open |
| L-CMD-OPEN-01 | Agents invented a live-command **whitelist** (Table A closed set) with no user denylist | **No denylist ⇒ no restrict.** Table A = F6 fragment only. **requirement-privilege-prevention-set** OPEN-TOOLS / OPEN-UNLISTED / OPEN-TABLE-A | open |
| L-ELEV-OK-01 | After operator `sudo` / root, agents added another privilege wall | **OPEN-ELEV** / **OPEN-SUDOER-APPR**; only §2.2 rows block; sensitive = confirm/`--force` only; **TP-ELEV-09** / **CL-LEAST-PRIVILEGE** §H | open watch |
| L-ELEV-BOOT-01 | Wrote first-time `setup` as `sudo -n` / `SUDO_USER==sudoer-adm` — chicken-egg; install is multi-user; `-n` is hook-only after F6 | Bootstrap = euid 0 any admin (**not** `sudo -n`). Do **not** “fix” by locking **approve** to F6/`SUDO_USER==LPU` — that is **L-APPR-ACTOR-01** / **T1-SECOND-LOCK**. TP-SR-PRIV-02 + **TP-SR-PRIV-04** | open watch |
| L-ELEV-N-01 | Agents paste `sudo -n` from skills/molds as default elev (**knowledge pollution**) | Avoid `-n` unless specialized law specifies NOPASSWD/hook/ticket; **T1-N-POLLUTE**; mold §8.1.4 | open watch |
| L-QUEUE-0777-01 | Inbound **0777** without sticky: world readdir + unlink/replace of others’ grant JSON; approve `mv` of path after `cp` | Inbound **3773**; submit `0640`; archive snapshot then unlink inbound; F7 removes `/var/{{APP_NAME}}/` children; **SR-SEC-01/02** | **closed** (1.5.1; TP-SR-Q-01..03) |
| L-INT-STDIN-01 | `while read … done <id-list` stole stdin from `prompt_yes_no`; login hook printed all three (y/N) and skipped | Read the id list on fd 3; leave fd 0 for prompts; **TP-SR-INT-05** | **closed** (1.6.1) |
| L-JSON-CMDS-01 | Pretty (or spaced) `commands[]` decode keeps last `args` only; submit re-encode hides the drop | Split objects without requiring `},{`; fail closed on count mismatch; pretty + compact multi-command suite; incident 20260817-001 | **closed** (1.6.2; TP-SR-14/15/16) |
| L-APPR-ACTOR-01 | Approve-path `SUDO_USER==sudoer-adm` check after password `sudo` is **blockage**, not help; the elevated sudoer **is** the approval user | **OPEN-ELEV** / **OPEN-SUDOER-APPR**; no PREV-APPR-ACTOR; `sr_require_type1` is euid 0 only; setup prints submit next-step; LSU never `useradd`; **TP-SR-PRIV-04** / **TP-PREV-03** / **TP-ELEV-09**; **LM-PRIVILEGE-PREVENTION-SET**; incident 20260818-001 | **closed** (1.7.0; TP-SR-PRIV-04 / TP-PREV-03 / TP-ELEV-09) |
| L-APPR-SYS-01 | Agents “secure” an approval machine with unpublished filters so the **software** decides | Terms **approval-system** / **approval-blockage**; LPA skill **M7**; coverage Step 3e; **PP-A-17** | watch |
| L-ID-SPLIT-01 | `sr_split_service_user` last-hyphen + frozen list + `owner_mismatch` blocked reject of `dns-cli-dns-adm` | No owner/submitter walls; dest from JSON; reject dest-fences then archives; **TP-SR-17**; incident 20260818-002 | **closed** (1.8.1; TP-SR-17 dest uses `dns-cli-dns-adm`) |

**Related-product only (do not re-apply as this origin’s law):** L-DEPOSIT-01, L-SUDOERS-01..05, L-OVERWRITE-01 stay on folder-backup. Type O empty-argv / online-channel lessons stay on products that own those surfaces. This product is hop 0.

**This origin’s kept surfaces:** output SSOT, no basename gate on entry, storage isolation, Type N empty argv.
