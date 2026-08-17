# Report: requirement coverage + folder-backup alignment — sudoer-cli 1.6.2

**Date:** 2026-08-17  
**Mode:** `SK-REQUIREMENT-REVIEW` (class/registry/bootstrap + 0-ID + 0-LP) + `SK-REQUIREMENT-SUFFICIENT-CHECK` (C-full-product) + sibling alignment vs `/home/leolio/prjs/folder-backup`  
**Status:** Issues 1–2 closed in the 1.6.2 honesty pass; Issue 3 (sibling command-identity) still open  
**Suite:** PASS=244 FAIL=0 SKIP=2 (`./tests/run.sh` this turn)  
**Lessons loaded:** `reviews/lessons.md` (L-JSON-CMDS-01 closed in 1.6.2)

Original pass was findings-only. Same-day honesty pass retargeted version notes and the CLI Gap sentence; README now explains file-based JSON approval.

---

## Summary

Registered product law still owns every live dispatcher verb for a full-product claim. Domain **2.15.0** plus TP-SR-14/15/16 close the pretty-`commands[]` hole from INC-20260817-001. Honesty notes now cite **1.6.2** and the review loop is documented as live. Remaining product-law hole is sibling alignment: folder-backup forbids OS-tool grants, but sudoer-cli accepts a pinned `service=folder-backup` body whose only Cmnd is `/usr/bin/mkdir` (suite TP-SR-01). Do **not** copy folder-backup’s `requirement-sudoer-json-file` (`{{PRJ_NAME}}` only) onto this allocator.

---

## Requirement review

### Registry inventory + foreign/orphan gate (Step −1)

- **Registered on disk (in-scope):** 17 Active rows ↔ 17 `requirement-*.md`  
- **Orphans:** none  
- **Ghosts:** none  
- **Foreign candidates:** `cli-template` named only as historical origin (`requirement-bootstrap-chain`). `folder-backup` appears as a **worked sibling grant** (basename/dest/samples), not as this product’s identity.  
- **Scope this turn:** registry-only + explicit sibling comparison (user-named folder-backup).  
- **Uncommitted law in the working tree:** domain 2.14.0 → **2.15.0** (codec fidelity) + registry row; treated as live dest law.

### Bootstrap / rewrite gate (Step 0)

- **Risk:** yes — sibling product named for alignment; historical bootstrap is **cli-template**, not folder-backup.  
- **Direction:** cli-template → sudoer-cli (specialized). folder-backup is a **peer submitter**, not origin A.  
- **Edits applied:** none to `docs/requirements/**`.  
- **Reverse-direction evidence:** none.

### Class gate (Step −2)

- **Class:** software-development  
- **Class file:** Active `requirement-class-software-dev.md` (exactly one)  
- **Residual stack:** posix-sh, local-only — present  
- **Verdict:** Pass

### ID notation (Step 0-ID)

- Domain DTV primary-cites **TP-SR-***, **TP-CLI-***, **TP-LC-*** — Pass  
- Optional `RQ-DOMAIN-SUDOER-APPROVAL` / `RQ-LEAST-PRIVILEGE-USER` stem-matched — Pass  
- No harness inventory dump in `index.md` — Pass  
- **§B2:** Pass

### Least privilege / LLM escape (Step 0-LP)

- Privilege REQs present; Type 0/1 map; Type 2 explicitly unused  
- **LPU review (F1–F7):** Pass vs `requirement-least-privilege-user` 1.10.0 + static TP-SR-PRIV-03. Host `useradd` still not in CI (honest Gap).  
- **LPA review (M1–M6):** Pass — machine = file-based JSON approval; subject = sudoer-file; hierarchy LPU → LPA → `sudoer-adm`; dest writes after F6 as root; no sibling dest invented as this product’s F6.  
- **CL-LEAST-PRIVILEGE / CL-LLM-ESCAPE:** recommend on any later host-apply pass.  
- **§B3:** Pass (law); host apply remains Gap.

---

## Requirement sufficient check

### Claim

- **ID:** C-full-product  
- **Text:** Type 0 lifecycle + file-based JSON sudoers-request domain (convert/submit/list/show/print-sudoers) + Type 1 `setup` / `interactive` / approve. Online / backup / Type 2 out of claim (registry “Intentionally absent”).

### SSOT preflight

- **Identity:** aligned — `APP_NAME=sudoer-cli`, `VERSION="1.6.2"`, `REPO_USER/REPO_NAME=cloudgen/sudoer-cli`, `SCRIPT_URL` empty.  
- **Conflict:** notes in class / CLI interface / local-self-management still say **`VERSION=1.6.1`** while the ship unit is **1.6.2** → honesty finding, not a dual-owner identity block.  
- **Blocked-pending-user:** no.

### Registered law

- Registry rows: **17**  
- Domain requirements present: yes — one Active `requirement-domain-sudoer-approval` **2.15.0**

### Live surfaces (summary)

- **Lifecycle:** `install` (`--global`), `uninstall` (`--force`), `where-is-me`, `version`, `about`, `help`, empty argv = help  
- **Domain Type 0:** `sudoers-to-json`, `json-to-sudoers`, `print-sudoers`, `print-sudoers-install-script`, `add|update|remove-sudoer-request`, `list-approving|approved|rejected`, `show`  
- **Domain Type 1:** `setup` / `remove-lpu`, `approve`, `reject`, `interactive`  
- **Help-only:** none (`remove-lpu` listed with `setup`)  
- **Intentionally absent:** online / Type O / `self-update` / backup / restore / `generate-sudoer-request` (that last verb is **folder-backup’s** submitter generate)

### Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| APP_NAME / local install 0755 | lifecycle | class + local-self-management + CLI interface | ok |
| Empty argv Type N | lifecycle | shell-cli-zero-arguments | ok |
| `out_*` / `--json` / `Next:` | output | shell-output-requirements 1.1.1 | ok |
| Prefixes `sr_` / `lpu_` | other | shell-modular-function-design | ok |
| TTY / confirm / uninstall / interactive no-hang | interactive | interactive 1.3.0 + prompt | ok |
| Scratch / visudo temps | other | temp-file-system + cli-storage | ok |
| Convert / submit / list / show / print-sudoers | domain | domain-sudoer-approval | ok |
| Pretty `commands[]` fidelity | domain | domain 2.15.0 · TP-SR-14/15/16 | ok |
| Queue 3773 / F4 / dest `{{service}}-{{user}}` | domain + LPU | domain + LPU + three-layer | ok |
| Type 0/1 map, F6 Table A, bootstrap vs F6 | privilege | three-layer + prevention-set | ok |
| `setup` / `remove-lpu` / approve / interactive | Type 1 | domain + LPU + three-layer | ok |
| Service catalog vs pinned `folder-backup` | domain | catalog table = webservice/gitlab infer only; pin accepts other names | **Gap** (see Issue 3) |
| Online / Type O / backup / generate-sudoer-request | — | index absent / sibling-owned | ok (out of claim) |

### Artifact filename + content

| Kind | Filename grammar | Sample basename | Content structure | Sample body (per variant) | Paired convert | Status |
|------|------------------|-----------------|-------------------|---------------------------|----------------|--------|
| Queued request | yes `sudoer-`+date+service+user+action+n+`.json` | yes `sudoer-20260814-folder-backup-leolio-add-1.json` | yes closed schema | yes add JSON + remove purpose-only | n/a | ok |
| Text dual | yes Purpose + spec lines | n/a | yes | yes add + remove | yes same grant | ok |
| Installed dest | yes `/etc/sudoers.d/{{service}}-{{username}}` | yes `folder-backup-leolio` | yes | via convert | n/a | ok |
| F6 draft | Table A | LPU / three-layer | yes | print-sudoers | n/a | ok |

### TTY measurement (Step 3d)

- **In scope:** yes  
- **Measure outside functions:** yes (interactive REQ)  
- **Helpers consume TTY:** yes (prompt REQ samples)  
- **Temp leaves:** yes (`util_mktemp` + forbidden `$$`)

### Named workflow machine (Step 3e)

- **In scope:** yes  
- Named machine + roles + submit-when + verify table: **yes** (domain §2.0)

### TTY approver path (Step 3f)

- **In scope:** yes  
- Authz + consume-`TTY` loop + hook snippet + empty argv stays help: **yes** (live; TP-SR-INT-*)  
- About LPU/F6/trust-tier fields: **honest Gap**

### LPU / LPA operator (Step 3g)

- **In scope:** yes  
- LPU: **Pass** (static). Host create: Gap.  
- LPA: **Pass**

### Honesty / consistency

- Help verbs ⊆ dispatcher.  
- Domain 2.15.0 + suite TP-SR-14/15/16 match INC-20260817-001.  
- `requirement-shell-cli-interface` Design Principles still say “review loop still Gap” while the loop is live (1.6.1+).  
- Class / CLI / local-self-management Implementation Notes still freeze `VERSION=1.6.1`.  
- `reviews/test-plan.md` header still 1.6.1; `what-to-review.md` already 1.6.2.

### Verdict

**Sufficient with Gaps**

Law owns the live surface for C-full-product. Gaps are honesty drift and an undecided sibling command-identity rule — not missing requirement files.

---

## Folder-backup alignment

**Peer SSOT:** `/home/leolio/prjs/folder-backup` (hard-disk; no `/dev/shm/folder-backup`).  
**Peer role:** Type 0 submitter + Type 1 **deposit**. Not this product’s bootstrap origin.

### Registry shape (folder-backup)

17 registered files (class + bootstrap + project-folder + three-layer + **sudoer-json-file** + folder-archive-backup ×3 + shell suite + **operator-readable-error** + domain-folder-backup). No LPU, no prevention-set, no separate prompt/temp REQs.

### Shared keys (both products)

| Key | Alignment |
|-----|-----------|
| class-software-dev, bootstrap-chain, project-folder | Same class; different A→B story (folder-backup still names cli-template→itself) |
| shell-cli-interface, zero-arguments Type N, local-self-management 0755 | Aligned local-only Type N |
| shell-output-requirements | Both `out_*`. sudoer-cli adds `Next:` on fatals. folder-backup split **wording** into `requirement-operator-readable-error` |
| modular, idempotency, storage | Aligned Type 0 |
| interactive-vs-noninteractive | Both require `[ -t` outside functions; helpers consume `TTY`. folder-backup embeds prompt samples in this file; sudoer-cli split `requirement-shell-prompt` |
| three-layer | **Same dest convention** `/etc/sudoers.d/{{APP_NAME}}-{{user}}` / `{{service}}-{{user}}`. **Different Type 1 job:** deposit vs approve/setup |

### Only on folder-backup (intentional)

| Key | Why not copy onto sudoer-cli |
|-----|------------------------------|
| `requirement-folder-archive-backup` + retention daily/total | Backup product law. This origin trimmed those verbs (L-TRIM-01). |
| `requirement-sudoer-json-file` | Submitter grant identity: **`{{PRJ_NAME}}` only**, verbs `backup`/`restore`, no OS tools. Allocator must accept **many** services (webservice/gitlab + pinned product names). Copying PRJ_NAME-only here would break nginx grants. |
| `requirement-operator-readable-error` | Dedicated copy SSOT (2026-08-17). sudoer-cli already requires `Next:` in output 1.1.1. Optional later specialize — not required for C-full-product. |
| `generate-sudoer-request` | Independent **readable draft** for the submitter. This product’s equivalent is convert + `add-sudoer-request` (allocator writes inbound). |

### Only on sudoer-cli (intentional)

| Key | Why folder-backup does not need a peer |
|-----|----------------------------------------|
| least-privilege-user + prevention-set | Approver account + closed block catalog |
| shell-prompt + shell-temp-file-system | Type 1 review loop + visudo temps |
| domain-sudoer-approval | Allocator machine (roles, queues, dest transform) |

### Aligned on purpose (keep)

1. **Installed dest:** both name `/etc/sudoers.d/folder-backup-<user>` as the worked grant dest.  
2. **Pretty JSON codec:** both updated 2026-08-17 — pretty and compact are the same grant; last-`args` silent drop forbidden.  
3. **Local-only / no Type O / no self-update.**  
4. **Type 0 never writes `/etc`.**  
5. **Inbound public + sibling allocate:** folder-backup submit must not `mkdir` inbound; sudoer-cli Type 0 must not `mkdir` the trio.

### Drift / decide (do not silently “fix”)

| Topic | folder-backup | sudoer-cli today | Recommendation |
|-------|---------------|------------------|----------------|
| Command identity for `service=folder-backup` | MUST be `${GLOBAL_BIN}/folder-backup` + `backup`/`restore` only; `mkdir`/`cp`/`tar` withdrawn | Pinned `service` + any absolute paths accepted. Suite **TP-SR-01** submits `/usr/bin/mkdir` as folder-backup and expects **0** | **P1 — ask.** Either (A) allocator stays generic (retarget TP-SR-01 to a legal sibling body; document pin-any-paths) or (B) catalog grows a folder-backup family and reject OS tools at submit **and** approve |
| Service catalog table | n/a (owns one product) | Infer table lists only webservice + gitlab; hyphenated pin + basename split know `folder-backup` | If (A): say pin-only product names are allowed and infer table is not the full allowlist. If (B): add the family row (revision of domain REQ) |
| Operator error wording | Own REQ, three slots, banned jargon | Folded `Next:` in output REQ; Type 1 fatals already tested (TP-SR-PRIV-01 / TP-ELEV-08) | P2 optional specialize `requirement-operator-readable-error` |
| Shared Type 0 prompt/temp | Samples live in interactive REQ | Separate REQs | sudoer-cli is thicker because of the review loop — keep |

---

## Issues

### Issue 1 -- Severity: suggestion
- File: docs/requirements/requirement-class-software-dev.md:88
- Description: Implementation Notes still freeze `VERSION="1.6.1"`; ship unit is `VERSION="1.6.2"`. Same stale value in `requirement-shell-cli-interface.md:71` and `requirement-shell-local-self-management.md:85`. `reviews/test-plan.md` header is also 1.6.1.
- Suggestion: Retarget those notes (and the test-plan header) to 1.6.2 in one authorized honesty pass. Do not invent a second version SSOT.
- Lesson: stay-honest
- Test: TP-CLI-02/03 already read the ship unit
- Status: closed (1.6.2 honesty pass — class / CLI / local-self-management / test-plan now cite 1.6.2)

### Issue 2 -- Severity: suggestion
- File: docs/requirements/requirement-shell-cli-interface.md:132
- Description: Design Principles still say “review loop still Gap” while domain 2.14.0+ and TP-SR-INT-* treat `sr_interactive` as live. §2.5 “Explicitly out of scope” also lists the live loop.
- Suggestion: Strike the Gap sentence; point loop ownership at the domain REQ only.
- Lesson: L-LAW-ROUTE-01
- Test: TP-SR-INT-01..05
- Status: closed (CLI Design Principles now say “review loop live”; out-of-scope row is live-host useradd in non-root CI, not the loop)

### Issue 3 -- Severity: bug (law vs sibling / suite policy)
- File: docs/requirements/requirement-domain-sudoer-approval.md:239
- Description: Catalog v1 infers only `webservice` and `gitlab`. Explicit pin of `folder-backup` is allowed in §2.0 and in `sr_service_infer` when `_si_force` is set and no infer hit. That lets a folder-backup request whose Cmnds are `/usr/bin/mkdir` queue (tests/test_domain_sr.sh:423–428). folder-backup `requirement-sudoer-json-file` 1.2.0 forbids that encoding. Approving such an inbound would install OS-tool NOPASSWD under `/etc/sudoers.d/folder-backup-<user>`.
- Suggestion: User choice — (A) keep generic allocator; change TP-SR-01 fixture to the legal backup+restore sample; write in the domain REQ that pin does not inherit sibling command-identity; or (B) add a folder-backup infer/pin family (`{{GLOBAL_BIN}}/folder-backup` + `backup`/`restore` only) and fail closed on OS tools at submit and approve. Do not copy the whole sibling REQ as this product’s law.
- Lesson: L-JSON-CMDS-01 adjacent; sibling identity
- Test: TP-SR-01 (today encodes the hole); TP-SR-16 is the legal pretty body
- Status: open

### Issue 4 -- Severity: nit
- File: docs/requirements/requirement-domain-sudoer-approval.md:363
- Description: About LPU/F6/trust-tier fields remain an honest Gap. Not a missing REQ.
- Suggestion: Keep Gap until implemented; do not fake fields.
- Status: open

---

## Recommendations

- **P0:** none for “register a new requirement file.”  
- **P1:** Answer Issue 3 (generic pin vs sibling command-identity) before treating folder-backup grants as a closed two-product contract. Issues 1–2 closed in the 1.6.2 honesty pass.  
- **P2:** Optional `requirement-operator-readable-error` specialize from the genesis mold (folder-backup already did). Host `sudo sudoer-cli setup` still needs a password on this session (prior SR-HOST-01).

**Review status:** Findings only. Confirm before any requirement rewrite.

---

## Addendum — folder-backup explore pass (same turn)

A second read-only pass over `/home/leolio/prjs/folder-backup/docs/requirements/` confirmed the same verdicts. Extra disk-truth:

### Folder-backup only (not sudoer-cli work)

1. **Internal stale paragraph:** three-layer §2.5 still calls §2.3.4a a “legacy OS-tool deposit” text dual, while §2.3.4a is now the `folder-backup backup`/`restore` dual. That is folder-backup honesty debt.  
2. **CLI vs domain catalog:** folder-backup CLI “Supported commands” omits `restore`, `print-sudoers-install-script`, and `remove-project-sudoers` that domain pillar A lists. Domain is the fuller catalog.  
3. **Interactive file date:** index “Updated” 2026-08-03 vs file Last Updated 2026-08-15 (no-retest already in the file).  
4. **`/etc/{{username}}/{{service}}` is not their live grant dest.** Live dest is `/etc/sudoers.d/folder-backup-<user>`. `/etc/{{username}}` on that product is restore whitelist / other path classes.

### Extra sudoer-cli nits (same report, not new P0)

5. Convert `--out` is the allocator analog of independent generate. Domain already says convert never queues and never writes `/etc`. A one-line dest-forbid (not inbound, not deleted temp) would make the sibling pairing explicit — **P2**, do not add a `generate-sudoer-request` verb.  
6. Class residual owner table does not point at `requirement-shell-prompt` or `requirement-shell-temp-file-system` even though both are Active — **P2** hygiene.  
7. CLI help AC-1 lists convert/submit/`print-sudoers` but not routed Type 1 names (`setup` / `interactive` / `approve`) — same honesty family as Issue 2.

No change to **Sufficient with Gaps**. No change to Issue 3 (generic pin vs sibling command-identity).
