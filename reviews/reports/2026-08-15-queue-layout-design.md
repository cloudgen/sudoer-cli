# Product review: sudoer-cli (public queue + F4 views)

**Date:** 2026-08-15  
**Reviewer:** council (Review)  
**Product:** sudoer-cli `VERSION=1.5.0`  
**Ship unit:** `src/sudoer-cli`  
**Scope:** Updated F4/F5 queue design (public `/var/{{APP_NAME}}/`, home views, chown-on-approve) vs product law and the operator spec  
**Method:** Disk read of REQs + ship unit + terms; suite `./tests/run.sh`  
**Baseline:** PASS=194 FAIL=0 SKIP=0 (this tree)

## Summary

The split is coherent: Type 0 submits to a well-known public tree; Type 1 approve/reject walks `${LPU_HOME}/…` views; LPU home comes from passwd, not a hardcoded `/etc/sudoer-adm` queue path. That matches the intended “everyone can submit / approver uses home symlink / chown to sudoer-adm” story.

The weak point is **0777 without sticky** on a hostile inbound dropbox that still holds grant JSON. Combined with approve’s `cp` then `mv` of the **path** (not the validated copy), a peer can swap the inode after visudo. Law also still says “at approve, owner still matches the subject” while the ship unit `chown`s first and never stats the submitter. Live host still has the old `/etc/sudoer-adm/sudoer-approving` trio — `setup` has not been re-run.

## Strengths

| Area | Notes |
|------|--------|
| Submit vs approve paths | Public real dirs for Type 0; F4 views for Type 1; `--queue-root` still a test override |
| No hardcoded queue home | `lpu_resolve_home` uses `getent passwd`; create default F3 stays `/etc/sudoer-adm` |
| Public root naming | `/var/${APP_NAME}` not a frozen second product string |
| Setup migrate | Old `${LPU_HOME}/sudoer-approving` real dir is copied into `sudoer-request` then replaced |
| Tests | 194 pass, including TP-SR-Q-01 static checks for 0777/0700/0755, `/var`, chown helper |
| Law versions | LPU 1.9.0, domain 2.11.0, three-layer 1.10.0, prevention 1.3.0, index same-change |

## Findings

### SR-SEC-01 — Severity: P1 (high)
- **Area:** SEC / inbound mode  
- **Status:** fixed (1.5.1 — inbound **3773**, submit `0640`)  
- **Location:** `lpu_mkdir_f5` `chmod 3773` on `/var/{{APP_NAME}}/sudoer-request`; `requirement-least-privilege-user` §2.5; domain §2.2  
- **Description:** Operator-ordered **0777** is world-**read**, world-**write**, and **not sticky**. Anyone can `ls` the dropbox, usually `cat` pending JSON (typical umask 022 → 0644 files), and **unlink or replace** another user’s request. The previous 3773 design was other-`wx`, no other-`r`, plus sticky.  
- **Impact:** Pending sudoers-grant proposals leak; a neighbor can delete or squat names (`n` DoS already accepted, now also overwrite).  
- **Suggestion:** Keep “everyone can create” with **1777** (sticky) at minimum. Prefer **3733/3773** (no other-read) if submitters do not need to readdir. Submit should `chmod 0640` the new file.  
- **Cross-ref:** domain “do not trust a world-writable drop”; `L-STOR-01`  

### SR-SEC-02 — Severity: P1 (high)
- **Area:** SEC / approve TOCTOU  
- **Status:** fixed (1.5.1 — `sr_archive_validated` copies snapshot, unlinks inbound)  
- **Location:** `sr_approve` / `sr_archive_validated`  
- **Description:** Dest install uses the **private copy**. The archive move uses the **original path**. On a 0777 unsticky dir, another uid can unlink and replace `${_path}` after `cp` and before `mv`. Approved archive then is not the JSON that was visudo’d.  
- **Impact:** Installed grant can disagree with the archived evidence.  
- **Suggestion:** `mv` the validated `_priv` into the approved view (or `ln`/`rename` the same inode after `O_NOFOLLOW` + fstat). Re-check device+inode before dest write. Add sticky so unlink-of-others fails.  
- **Cross-ref:** domain hostile-dropbox paragraph  

### SR-LAW-01 — Severity: P2 (medium)
- **Area:** LAW  
- **Status:** fixed (1.5.1 — `stat` owner before snapshot; `owner_mismatch`; orphans compare owner)  
- **Location:** `sr_approve` / `sr_reject` / `sr_list --orphans`  
- **Description:** Law and ship unit disagree. After the new chown-first step, an owner==subject check would always fail (owner is `sudoer-adm`).  
- **Impact:** Self-scope at approve is theater; a swapped file is not caught by owner.  
- **Suggestion:** Record owner **before** chown (or drop the owner clause and say identity is basename+body only). `list-approving --orphans` comments “owner mismatch” but only flags non-regular files.  
- **Cross-ref:** `sr_list` orphans loop  

### SR-F7-01 — Severity: P2 (medium)
- **Area:** F7  
- **Status:** fixed (1.5.1 — `lpu_remove_public_queues` after archive)  
- **Location:** `lpu_remove` / `lpu_remove_public_queues`  
- **Description:** F7 archives the **real** `/var/{{APP_NAME}}/` children then `userdel -r`. It does **not** remove `/var/{{APP_NAME}}`. After teardown the 0777 inbound can remain, still world-writable, possibly with leftover JSON.  
- **Impact:** Orphan world-writable dropbox after the LPU is gone.  
- **Suggestion:** After archive, `rm` the three children and `rmdir` the public root if empty; or document that `/var/{{APP_NAME}}` is retained on purpose.  
- **Cross-ref:** LPU F7; prevention-set OPEN teardown  

### SR-HOST-01 — Severity: P2 (medium)
- **Area:** HOST  
- **Status:** open  
- **Location:** live `/etc/sudoer-adm/sudoer-approving` (3773) still present; `/var/sudoer-cli` not created this session  
- **Description:** Law and CLI default to `/var/sudoer-cli/sudoer-request`. Type 0 submit on this host will fail closed (`queue directory does not exist`) until `sudo sudoer-cli setup` is re-run.  
- **Impact:** Design is not live. Dual mental model until migrate.  
- **Suggestion:** Run `sudo sudoer-cli setup` (heal/migrate). Confirm F4 views and 0777/0700/0755 on disk.  
- **Cross-ref:** stay-honest; `lpu_mkdir_f5` migrate of `sudoer-approving`  

### SR-NAM-01 — Severity: P3 (low)
- **Area:** DOC  
- **Status:** open  
- **Location:** `sudoer-request.md` vs directory `/var/{{APP_NAME}}/sudoer-request`  
- **Description:** Same stem is a **file** term and an **inbound directory** basename. `list-approving` still names the state `approving`.  
- **Impact:** Agents will mix “the request” and “the request dir.”  
- **Suggestion:** Keep the must-not-confuse row (already added). Say “inbound dir” vs “request file” in help/about. Optional later: `list-request` alias.  

### SR-INT-01 — Severity: P3 (low)
- **Area:** GAP  
- **Status:** open (pre-existing)  
- **Location:** `sr_interactive` stub  
- **Description:** F4 views are unused by the review loop (still `confirm_required`).  
- **Impact:** Login hook still cannot approve. Not a regression of this layout.  
- **Suggestion:** When the loop is built, resolve queues once and walk `sr_approver_dir request`.  

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Symlink **direction** | Home views → public `/var` real dirs. Matches “submit to `/var`” and “approve via `${LPU_HOME}` symlink.” The phrase “symlink `/var` → `/etc`” was treated as a reversed arrow. |
| Group `sudoer-adm:sudoer-adm` | Used; `sudoer-adm:sudoer:adm` treated as a typo |
| Create-default F3 `/etc/sudoer-adm` | Still preferred-/etc; not used as a frozen queue path |
| `--queue-root` tests | Children are `sudoer-request` / approved / rejected; Type 1 tests still fail-closed without root |
| Type 0 dest `/etc` | Submit still does not write `/etc/sudoers.d` |
| Suite | 194 PASS |

## Priority remediation order

1. **SR-SEC-02** — archive the validated inode, not a replaceable path.  
2. **SR-SEC-01** — sticky and/or no-other-read on inbound; `chmod 0640` on submit.  
3. **SR-LAW-01** — fix or drop the approve-time owner clause; capture owner before chown if kept.  
4. **SR-F7-01** — tear down or honestly retain `/var/{{APP_NAME}}`.  
5. **SR-HOST-01** — `sudo sudoer-cli setup` on this host.  
6. P3 naming / interactive loop.

## Related

| Artifact | Role |
|----------|------|
| `requirement-least-privilege-user.md` 1.9.0 | F4/F5 |
| `requirement-domain-sudoer-approval.md` 2.11.0 | Submit dest + chown |
| `src/sudoer-cli` 1.5.0 | `sr_resolve_queues`, `lpu_mkdir_f5`, `sr_approve` |
| `docs/checklists/2026-08-15-checklist-file-based-json-approval.md` | Layout gate |

**Written by:** council Review  
**Review status:** Findings open (no code change this turn)
