# Requirement sufficient check — sudoer-cli

**Date:** 2026-08-15  
**Method:** `SK-REQUIREMENT-SUFFICIENT-CHECK` (C-full-product)  
**Ship unit:** `src/sudoer-cli` `VERSION=1.5.1`  
**Suite:** PASS=203 FAIL=0 SKIP=0 (prior run this session)

## Claim

- **ID:** C-full-product  
- **Text:** Specialized Type 0 lifecycle **and** file-based JSON sudoers-request domain (submit, list, convert, Type 1 setup/approve). Interactive loop may remain an honest Gap.

## SSOT preflight

- **Identity:** aligned — `APP_NAME=sudoer-cli`, `VERSION=1.5.1`, `REPO_USER/REPO_NAME=cloudgen/sudoer-cli`, `SCRIPT_URL` empty (local-only).  
- **Foreign residue:** `cli-template` named only as historical bootstrap origin (`requirement-bootstrap-chain`). Intentional.  
- **Conflict:** none → not blocked.

## Registered law

- **Registry rows:** 17 Active  
- **On-disk `requirement-*.md`:** 17 (match; no orphans, no ghosts)  
- **Class gate:** software-development; exactly one `requirement-class-software-dev.md` Active  
- **Domain requirements present:** yes — one Active `requirement-domain-sudoer-approval.md` (2.12.0)

## Live surfaces (summary)

- **Lifecycle:** `install` (`--global`), `uninstall` (`--force`), `where-is-me`, `version`, `about`, `help`, empty argv = help  
- **Domain Type 0:** `sudoers-to-json`, `json-to-sudoers`, `print-sudoers`, `print-sudoers-install-script`, `add|update|remove-sudoer-request`, `list-approving|approved|rejected`, `show`  
- **Domain Type 1:** `setup` / `remove-lpu` (`--uninstall`, `--purge-queues`), `approve`, `reject`, `interactive` (stub)  
- **Flags:** `--quiet/--json/--debug/--force/--global/--file/--action/--purpose/--service/--out/--queue-root/--request-dir/--approved-dir/--rejected-dir/--user/--orphans`  
- **Help-only:** none (every help verb has a dispatcher arm)  
- **Intentionally absent:** online/`SCRIPT_URL`/Type O, `self-update`, backup/restore  

## Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| APP_NAME / VERSION / local install | lifecycle | class-software-dev + local-self-management + CLI interface | ok |
| Empty argv Type N | lifecycle | shell-cli-zero-arguments | ok |
| `out_*` / `--json` / `--quiet` | output | shell-output-requirements | ok |
| Prefixes `sr_` / `lpu_` | other | shell-modular-function-design | ok |
| TTY / confirm / uninstall | interactive | shell-interactive-vs-noninteractive + shell-prompt | ok |
| Scratch / visudo temps | other | shell-temp-file-system + cli-storage | ok |
| Convert / submit / list / show | domain | domain-sudoer-approval | ok |
| Queue paths / 3773 / F4 views / chown | domain + LPU | domain 2.12.0 + LPU 1.10.0 | ok |
| Type 0/1 map, F6 Table A, dest `/etc/sudoers.d/{{service}}-{{user}}` | privilege | three-layer 1.11.0 | ok |
| Block vs must-remain-open | privilege | privilege-prevention-set 1.3.0 | ok |
| `setup` / `remove-lpu` | domain Type 1 | LPU + domain + prevention | ok |
| `approve` / `reject` | domain Type 1 | domain + three-layer | ok |
| `interactive` loop body | domain Type 1 | domain §2.2 (live 2.13.0) | ok |
| Login hook snippet | domain | domain §2.2 (implemented in `setup`) | ok |
| Online / Type O / self-update | — | index “Intentionally absent” | ok (out of claim) |

## Artifact filename + content

| Kind | Filename grammar | Sample basename | Content structure | Sample body (per variant) | Paired convert | Status |
|------|------------------|-----------------|-------------------|---------------------------|----------------|--------|
| Queued request | yes (`sudoer-` + date + service + user + action + n + `.json`) | yes `sudoer-20260814-folder-backup-leolio-add-1.json` | yes closed schema | yes add/update JSON + remove purpose-only | n/a (queued JSON) | ok |
| Text dual | yes Purpose + spec lines | n/a (not queued as text) | yes line grammar | yes add + remove text | yes same grant both ways | ok |
| Installed dest | yes `/etc/sudoers.d/{{service}}-{{username}}` | yes `folder-backup-leolio` | fragment emit rules | via convert samples | n/a | ok |
| F6 draft | Table A line | in LPU/three-layer | yes | print-sudoers contract | n/a | ok |

## TTY measurement (Step 3d)

- **In scope:** yes  
- **Measure outside functions:** yes (`requirement-shell-interactive-vs-noninteractive`)  
- **Helpers consume TTY:** yes (`prompt_*` samples in `requirement-shell-prompt`)  
- **Temp leaves:** yes (`util_mktemp` sample + forbidden `$$` in temp REQ)

## Named workflow machine (Step 3e)

- **In scope:** yes  
- **Named machine + roles + submit-when + verify table:** yes (domain §2.0)

## TTY approver path (Step 3f)

- **In scope:** yes  
- **Authz table:** yes (bootstrap vs F6 approve)  
- **Loop:** specified; **handler is a stub** — labeled Gap  
- **Hook sample:** complete in domain REQ; `setup` writes it  
- **Empty argv:** stays help  
- **Honesty:** Gap labeled — **Pass for law**, not Implemented

## LPU / LPA operator (Step 3g)

- **In scope:** yes  
- **LPU review (F1–F7):** **Pass** vs product REQ + ship unit. F3 preferred-`/etc`; F4 views; F5 `/var/{{APP_NAME}}/` (not bare home); F6 `/etc/sudoers.d/sudoer-adm` Table A; F7 archive + public teardown + `userdel -r`. **Host layout:** live queues still old `/etc/sudoer-adm/sudoer-approving` until `setup` — **Gap** for “live F5,” not a law hole. Portable mold F6 dest `/etc/{{LPU}}/sudoers` is **not** this product’s dest (documented exception).  
- **LPA review:** **Pass** — subject = sudoers grant / sudoer-file; machine = file-based JSON; ≥1 subject.

## Honesty / consistency

- Registry ↔ disk match.  
- Help verbs ⊆ dispatcher.  
- Help/`about` name resolved queue paths (no “no domain fields”).  
- Domain DTV lists TP-SR-Q-01..03 and TP-SR-INT-01/02/04 as **have**.  
- Interactive loop is live (1.6.0).  
- Version SSOT 1.6.0 in ship + class + CLI + local-self-management.

## Verdict

**Sufficient with Gaps**

Law owns every live dispatcher surface for C-full-product. Remaining hole is host-not-migrated F5 (**SR-HOST-01**), not missing requirement files.

## Recommendations

- **P0:** none for coverage (do not invent a new REQ).  
- **P1:** Interactive loop + INT tests **done** (1.6.0). Host `sudo sudoer-cli setup` still needs a password on this session (**SR-HOST-01**).  
- **P2:** DTV + help/about honesty **done**.

**Review status:** Findings only; no requirement rewrite this turn.
