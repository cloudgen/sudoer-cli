# What to review — sudoer-cli

**Living checklist** (review plan). Product: **sudoer-cli** (Type 0 live; **Type 0 domain convert/submit/list/show/`test-json-format` routed**; Type 1 `setup` / `interactive` live).  
**Class:** software-development · **one** Active domain SSOT (`requirement-domain-sudoer-approval` **2.24.0**) · **local-only** install channel.  
**Always load first:** `reviews/lessons.md`  
**Latest report:** `reviews/reports/2026-08-19-dest-fence.md` (dest Fence + OPEN-BEHALF). Prior: 2026-08-18 approve-actor-lock (T1-SECOND-LOCK). Fidelity: INC-20260817-001. Actor lock: INC-20260818-001.

**Last plan update:** 2026-08-20  
**Ship unit VERSION:** 1.12.0  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + shell + three-layer + LPU + **prevention-set 1.6.0** + **domain 2.24.0** + ARSA + dest Fence + coding-style + sudo-command |
| P2 | Confirm ship unit `src/sudoer-cli` | `APP_NAME` / `VERSION` hard-assign (**1.12.0**) |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip parent backup L-SUDOERS except **L-JSON-CMDS-01** |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP; **must include TP-SR-14/15/16**, **TP-SR-PRIV-04** / **TP-ELEV-09** / **TP-PREV-03**, and **TP-SR-HOOK-01..04** |
| P5 | Confirm install **channel** still local-only | No SCRIPT_URL product UX |
| P6 | Confirm trimmed verbs stay unknown | backup / restore / `remove-project-sudoers` (`print-sudoers` is domain) |
| P7 | **JSON re-encode fidelity** | Complete section below. **Revise/Block** if skipped. |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual |
| Bootstrap chain | `requirement-bootstrap-chain.md` | sudoer-cli specialized from cli-template |
| Project folder | `requirement-project-folder.md` | `src/`, bins; no `/var/backup` |
| CLI interface | `requirement-shell-cli-interface.md` | Type 0 commands, flags, dispatch |
| Empty argv Type N | `requirement-shell-cli-zero-arguments.md` | Empty = help |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; mode 0755 |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors; colors consume `TTY`; **operator-readable fatals** (`Next:`) |
| Modular design | `requirement-shell-modular-function-design.md` | Type 0 prefixes; `sr_` / `lpu_` reserved; `prompt_*` consume `TTY` |
| Coding style | `requirement-shell-script-coding.md` | Specialize-in home; without it, portable lessons arrive raw |
| Sudo command | `requirement-shell-sudo-command.md` | Sudo-wrapping function; check before sudo; chmod example |
| Interactive vs noninteractive | `requirement-shell-interactive-vs-noninteractive.md` | Confirm policy; **TTY measured outside functions** |
| Prompt helpers | `requirement-shell-prompt.md` | `prompt_*` samples consume `TTY` |
| Temp leaves | `requirement-shell-temp-file-system.md` | `mktemp`; no `$$` scratch |
| Three-layer | `requirement-three-layer-privilege-model.md` | EM-HYB: any elevated sudoer may setup **and** approve; F6 extra; Table A ≠ user grant |
| LPU | `requirement-least-privilege-user.md` | F1–F7; home `/etc/sudoer-adm`; dest `/etc/{{username}}/` |
| Prevention set | `requirement-privilege-prevention-set.md` | Closed block catalog + must-remain-open; no invented walls |
| ARSA | `requirement-actor-role-subject-approver.md` | Five-column catalog; dest has Approver; do not invent `*-adm` |
| Dest Fence | `requirement-incorrect-json-format.md` | Incorrect JSON fail-closed before yes/no |
| Domain SSOT | `requirement-domain-sudoer-approval.md` | JSON samples; convert; queues; dest fence table; **pretty `commands[]` fidelity**; dest one-off yes/no |
| Idempotency | `requirement-shell-idempotency.md` | Re-install |
| Storage | `requirement-shell-cli-storage.md` | Isolation |

**Do not review as this product’s law:** folder-archive backup / restore (absent).

**Do review as live:** convert / submit / list / show / `print-sudoers` (Type 0). Type 1 `setup` / `interactive` live in the ship unit (static **TP-SR-PRIV-03** / **TP-SR-INT-***); host `useradd` is not run in non-root CI.

## This-pass gates (2026-08-14)

| # | Check | Status |
|---|--------|--------|
| R1 | Domain / registry say Type 0 routed; Type 1 names fail-closed (no blanket “not yet routed”) | **closed** (L-LAW-ROUTE-01) |
| R2 | CLI interface still lists `print-sudoers` as unknown trimmed parent | **closed** (CLI 3.1.0: domain Type 0) |
| R3 | no-retest-tty: `[ -t` only outside functions; `prompt_*` / `about` consume `TTY` | **have** TP-ELEV-07 (code + suite) |
| R4 | Type 1 fail-closed without root (no `/etc` write) | **have** TP-SR-PRIV-01 |
| R5 | Password-sudo / package elev TP-ELEV-01..05 | **n/a** (not claimed) |
| R6 | About queue fields vs TP-CLI-06 / domain pillar 4 | **closed** (about JSON `queue_request` / approved / rejected; TP-CLI-06) |
| R7 | Domain §2.0 presents file-based JSON approval (roles, submit-when, JSON verify) | **have** (domain 2.2.0+) |
| R8 | Type 1 authz + hook snippet + interactive loop; dest `/etc/sudoers.d/{{service}}-{{user}}`; setup/hook/loop live; `.profile` check/create | **have** (domain 2.17.0; TP-SR-PRIV-03; TP-SR-INT-01/02/04/05; **TP-SR-HOOK-01..03**) |
| R9 | Sudo escalation check: avoid `-n` unless specified; any-admin outer `sudo`; approve is same elev (not exclusive F6) | **have** TP-ELEV-08 + TP-SR-PRIV-02 + **TP-SR-PRIV-04** / **TP-ELEV-09** |
| R10 | Prevention set: only published rows block; elev is approval; no Gap/`LIVE_LPU`/live-command whitelist; no exclusive-LPU approve lock | **have** law (prevention-set 1.6.0); TP-PREV-01/02/03 |
| R11 | `interactive` id walk does not steal stdin from `prompt_yes_no` | **have** (1.6.1; TP-SR-INT-05; INC-20260815-001) |
| R12 | Pretty `commands[]` survive decode/re-encode (not last-`args` only) | **have** (1.6.2; TP-SR-14/15/16; INC-20260817-001) — **re-check every review** |
| R13 | Blocking CLI errors are operator-readable (what happened + `Next:`; **`CL-OPERATOR-READABLE-ERROR`**) | **have** convert/submit (1.6.2; TP-SR-10 human + Next) + Type 1 (TP-SR-PRIV-01 / TP-ELEV-08) — **re-check every review** |
| R14 | Approve-path actor lock after password `sudo` is gone (OPEN-SUDOER-APPR) | **have** (1.7.0; TP-SR-PRIV-04 / TP-PREV-03 / TP-ELEV-09; INC-20260818-001) — **re-check every review** |
| R15 | Hyphenated service **and** hyphenated username (`dns-cli` + `dns-adm` dest is not `…-adm`); dest uses JSON | **have** (1.8.1; **TP-SR-17**; INC-20260818-002; **L-ID-SPLIT-01**) |
| R17 | Dest Fence first: `interactive` / `approve` / `reject` fail closed on incorrect JSON **before** yes/no; action mismatch; subject token ≠ JSON username is **not** a fence | **have** (1.8.1; **TP-SR-FENCE-01..04**; `requirement-incorrect-json-format`) |
| R19 | Type 0 `test-json-format` tests the JSON-format Fence without dest elev; golden login-hook-elev fixture | **have** (1.9.0; **TP-SR-FENCE-05..08**) |
| R20 | Dest `interactive` asks one-off yes/no (yes=approve, no/Enter=reject; no skip/quit; no three chained y/N) | **have** (1.12.0; domain 2.24.0; **TP-SR-INT-06**) |
| R18 | OPEN-BEHALF: A may submit/remove for B; inbound and dest use B | **have** (1.8.1; **TP-SR-17** / **TP-SR-18**) |
| R16 | After hook install, LPU can **read** `${LPU_HOME}/.profile` (not `root:root` `0600`); existence is not enough | **open** (checkout 1.8.1 + **TP-SR-HOOK-04**; host still `root:root` `0600`; global **1.8.0**; **L-HOOK-PROFILE-02**; INC-20260818-003 · INC-20260819-001) |

## JSON re-encode / convert fidelity — review plan gate

**In scope when:** `json-to-sudoers`, `sudoers-to-json`, `add-sudoer-request`, or `sr_json_decode_to_fields` is reviewed. Always in scope for a full product review.  
**Incomplete review (Revise/Block)** if skipped.  
**Law:** domain **2.15.0** codec fidelity · L-JSON-CMDS-01 · INC-20260817-001.

| ID | Check | Pass | Fail |
|----|--------|------|------|
| **JR-1** | Pretty fixture | Review used the **pretty** add sample (newlines between `commands[]` objects), not only `_sr_sample_json` compact one-liner | Compact-only convert greened |
| **JR-2** | Convert | `json-to-sudoers` of pretty add sample yields **all three** Cmnd lines (systemctl, journalctl, nginx `-t`) | Only last command remains |
| **JR-3** | Submit re-encode | `add-sudoer-request --file` pretty JSON → inbound still has every `path` | Inbound compact last-command only |
| **JR-4** | Caller dialect | Pretty folder-backup dual (`backup` + `restore`) convert keeps **both** verbs | Restore-only (INC-20260817-001) |
| **JR-5** | Fail closed | Decode object count ≠ `"path"` count → `invalid_json` (no silent last-wins) | Drop without error |
| **JR-6** | Suite | **TP-SR-14**, **15**, **16** **have** and ran | Only TP-SR-03/07 compact round-trip |
| **JR-7** | Host inbound (if present) | Count `commands` on live `/var/sudoer-cli/sudoer-request/*.json`; do not approve a collapsed grant | Purpose “backup and restore” with one `args` |

**Splitter smell (Block if still the only split):** `sed 's/},{/}\\n{/g'` without `[[:space:]]*` around the comma.

**High-risk symbol:** `sr_json_decode_to_fields` / `sr_submit` re-encode.

## Approve-path actor lock — review plan gate

**In scope when:** `approve` / `reject` / `interactive` / `sr_require_type1` / Type 1 authz table is reviewed. Always in scope for a full product review.  
**Incomplete review (Revise/Block)** if skipped.  
**Law:** prevention-set **1.4.0** OPEN-SUDOER-APPR · L-APPR-ACTOR-01 · INC-20260818-001 · **T1-SECOND-LOCK**.  
**Checklists:** **CL-LEAST-PRIVILEGE §H** · **CL-FILE-BASED-JSON-APPROVAL §5** · **CL-SHELL-TTY-PRIVILEGE-TRAPS** T1-SECOND-LOCK.

| ID | Check | Pass | Fail |
|----|--------|------|------|
| **AL-1** | Gate | `sr_require_type1` after euid 0 does **not** compare `SUDO_USER` to `sudoer-adm` | Die “only sudoer-adm” / `!= "sudoer-adm"` |
| **AL-2** | Law pair | **OPEN-SUDOER-APPR** present; **PREV-APPR-ACTOR** is **not** a §2.2 block row | Both OPEN-ELEV and exclusive-LPU block published |
| **AL-3** | Help | Approve is password `sudo` (any admin); F6 extra | “after F6; sudoer-adm or real root” as the only path |
| **AL-4** | Setup help-submit | `lpu_setup` prints `add-sudoer-request` next-step | Setup ends at “LPU ready” with no submit next |
| **AL-5** | Type 0 never `useradd` | `sr_submit` has no `useradd` | Ordinary login creates the LPU |
| **AL-6** | Suite | **TP-SR-PRIV-04**, **TP-PREV-03**, **TP-ELEV-09** **have** and ran | Only TP-SR-PRIV-02 “approve keeps F6” greened |
| **AL-7** | Review lesson | **L-ELEV-BOOT-01** is **not** used to lock approve to F6 | “Split bootstrap vs F6 approve” as the standing fix |

**Actor-lock smell (Block if still the only approve gate):** `SUDO_USER` != `sudoer-adm` → `authz` after euid is already 0.

**High-risk symbol:** `sr_require_type1`.
