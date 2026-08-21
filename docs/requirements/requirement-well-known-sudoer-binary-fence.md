**file**: docs/requirements/requirement-well-known-sudoer-binary-fence.md  
**Status**: Active (Version 1.1.1 – testers are test-purpose verbs)  
**Area**: domain  
**Key**: `requirement-well-known-sudoer-binary-fence`  
**id**: RQ-WELL-KNOWN-SUDOER-BINARY-FENCE  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is **one dest Fence**: **well-known sudoer binary**. Dest `approve` / `reject` / `interactive` **MUST** fail closed when any add/update `commands[].path` is not a well-known system binary (no dest write) and **MUST NOT** ask yes/no for that file. Dest `interactive` **MUST** display the match and **then** move that inbound file to the rejected queue. The dest fence table on `requirement-domain-sudoer-approval.md` **MUST** still print this row and **point here**. Convert and submit **MUST** fail closed on the same match so a home-tree or interpreter path is not queued. This Fence **MUST NOT** be folded into incorrect JSON format.

### 1.1 Human-facing

**In one sentence:** If a waiting grant would let sudo run a program that lives in a normal user’s files (or run the Python interpreter itself), dest review says so in plain words, does not ask you to accept it, and moves that file to the rejected folder.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The host admin already using `sudo`, reviewing inbound files | `sudo sudoer-cli interactive` |
| The other role | The person who dropped the file in the waiting folder | `sudoer-cli add-sudoer-request --file request.json` |
| Not this file | JSON schema / who submitted / file owner | `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Path under `/home/…`, `~/.local/bin`, a venv, `.ci-homes/…/gbin`; `..` traversal; `python3` / `env` / `pip` as the command | JSON-format fail; file owner; who submitted; `remove` (no commands); F6 Table A emit |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/sudoer-cli/sudoer-request` | waiting folder | inbound files |
| `src/sudoer-cli` | ship unit | dest fail-closed copy |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Test command paths | Check the grant against this Fence without becoming root and without putting it in the waiting folder. | `sudoer-cli test-well-known-binary --file request.json` |
| Test every dest fence | Run the closed dest fence list (this Fence after JSON format) on one file or a folder of cases. | `sudoer-cli fence-test --file request.json` |
| Review a home-tree grant | Dest shows the path is not a well-known system binary. It does not ask yes/no. The file goes to the rejected folder. | `sudo sudoer-cli interactive` |
| Fix and re-queue | Point `commands[].path` at a system binary such as `/usr/local/bin/dns-cli` or `/usr/sbin/nginx`. | `sudoer-cli add-sudoer-request --file request.json` |

---

## 2. Core Rules / Requirements (Mandatory)

1. **MUST** name **exactly this** dest Fence: well-known sudoer binary.  
2. **MUST** run **after** the incorrect-JSON-format Fence (need a well-formed `commands[]`).  
3. **MUST NOT** run on `action=remove` (no commands).  
4. **MUST** match when **any** `commands[].path`:
   - is not absolute, or contains a `..` path segment, **or**
   - the last path component is an interpreter or launcher: `python`, `python2`, `python3`, `python3.*`, `python[0-9]`, `python[0-9].*`, `pypy`, `pypy3`, `pypy[0-9]*`, `env`, `pip`, `pip3`, **or**
   - does **not** start with one of the closed prefixes: `/bin/`, `/sbin/`, `/usr/bin/`, `/usr/sbin/`, `/usr/libexec/`, `/usr/local/bin/`, `/usr/local/sbin/`, `/opt/gitlab/bin/` (Omnibus `gitlab-ctl`; not open `/opt/`).  
5. When the named path **exists** and `realpath` is available, dest **MUST** re-check the resolved path against the same rules (symlink to a home tree is a match). A **missing** path is not a pass: the string rules still apply.  
6. **MUST NOT** use live `[ -w file ]` as the match (a gone home path is still plantable after dest write).  
7. **MUST NOT** add open `/opt/`, `/snap/bin/`, `/home/`, `/etc/nginx/`, `/var/www/`, or `/usr/lib/python3/` as trusted prefixes in v1. `/opt/gitlab/bin/` is the only `/opt/` leaf (dest `gitlab` family). Revising the closed prefix list is a versioned change of this REQ.  
8. On match: dest **MUST** display the match in people/folder words (what happened / what it means / next). **MUST NOT** ask the approval question for that file. Standalone `approve` / `reject` **MUST** fail closed with the same sentence; that file **stays inbound**. Dest `interactive` **MUST**, after that display, move inbound → rejected (same archive contract as the JSON-format Fence). **MUST NOT** dest-write `/etc/sudoers.d`.  
9. Convert (`sudoers-to-json` / `json-to-sudoers`) and Type 0 submit add/update **MUST** fail closed on the same match (no queue).  
10. Machine code **MUST** be `untrusted_path` (not `invalid_json`).  
11. **MUST** ship Type 0 **test-purpose** `test-well-known-binary` (stdin **xor** `--file PATH`; unit test of a **local test folder**). Dest review verbs **MUST NOT** count as that tester. Dual mention: this file **and** `requirement-shell-cli-interface`. Invocation: `sudoer-cli test-well-known-binary --file request.json`. The closed dest fence **list** tester is Type 0 **test-purpose** **`fence-test`** (JSON **file location** in a local test folder; **MUST NOT** require `sudo` to run; sudo wrap **only** chmod/chown of that folder; **MUST NOT** require a sudoers fragment or the waiting folder). Help **MUST** list testers apart from operational verbs. Dual mention: `requirement-domain-sudoer-approval` **and** `requirement-shell-cli-interface`. Sample: `tests/fixtures/fence-test/pass/login-hook-elev-dns-adm.json`. Invocation: `sudoer-cli fence-test --file tests/fixtures/fence-test/pass/login-hook-elev-dns-adm.json`.  
12. Dest **MUST NOT** fence rows (file-ownership, who submitted, JSON `username` ≠ dest LPU, dest-written `submit_by`) **MUST NOT** live in this file.  
13. **MUST NOT** fold this Fence into `requirement-incorrect-json-format`.

### 2.1 Implementation Notes (this project)

| Field | Value |
|-------|--------|
| Dest table | `requirement-domain-sudoer-approval` § dest approval fencing conditions (this row after incorrect JSON format) |
| Type 0 test-purpose verb | `test-well-known-binary` — handler `sr_test_well_known_binary`; stdin **xor** `--file PATH`; unit test; local test folder |
| Invocation sample | `sudoer-cli test-well-known-binary --file request.json` |
| List tester (test-purpose) | `fence-test` — handler `sr_fence_test`; stdin **xor** `--file PATH` **xor** `--dir DIR` |
| Helpers | `sr_path_is_well_known` · `sr_cmds_require_well_known` · `sr_well_known_fence_die` |
| Pass examples | `/usr/local/bin/dns-cli` · `/usr/local/bin/nginx-cli` · `/usr/sbin/nginx` · `/bin/systemctl` · `/usr/bin/journalctl` · `/usr/bin/certbot` · `/usr/bin/mkdir` · `/bin/true` · `/usr/bin/gitlab-ctl` · `/opt/gitlab/bin/gitlab-ctl` |
| Fence examples | `.ci-homes/…/gbin/dns-cli` · `~/.local/bin/certbot` · `…/.venv/bin/certbot` · `/usr/bin/python3` · `/usr/bin/env` · `/usr/local/bin/../home/…/x` |
| Typical machine code | `untrusted_path` |
| Display | Operator `[ERROR]` in people/folder words; JSON `message` same sentence |
| Incident | Live dest applied a gone `.ci-homes` gbin (**INC-20260821-001**). This Fence is the dest refuse. |

### 2.x Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: NOPASSWD of a user-writable path is replace-after-approve.  
- **CIAO Principle 10 – Least privilege**: sudo must run packaged / global managed binaries, not a checkout or venv.  
- **CIAO Principle 16 – Interactive**: Fence before the approval question; drain inbound after display.  
- **CIAO Principle 21 – Dual policies**: Closed prefix list + interpreter basename; no unpublished extra refuse.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail closed on home-tree / interpreter Cmnds.  
- **Intentional**: One Fence, one file; allowlist of well-known prefixes, not a `/home/` denylist.  
- **Anti-fragile**: Convert and submit fail the same match; Type 0 tester without dest elev.  
- **Over-protect**: Interpreters (`python3`, `env`) fail even under `/usr/bin/`.

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Fold this Fence into incorrect JSON format.  
2. Ask yes/no on a match.  
3. Treat file owner or who submitted as this Fence.  
4. Delete the dest table row that points here.  
5. Use `[ -w path ]` as the match, or treat a missing path as trusted.  
6. Add `/home/`, open `/opt/`, `/snap/bin/`, or `/usr/lib/python3/` to the trusted prefixes without a versioned revision. `/opt/gitlab/bin/` is the only `/opt/` leaf.  
7. Treat dest `approve` / `reject` / `interactive` as the Type 0 tester.  
8. Leave this Fence without Type 0 `test-well-known-binary`.  
8b. Treat dest review as `fence-test`, or leave dest Fences without Type 0 `fence-test`.  
9. Dest-write `/etc/sudoers.d` on a match.

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-SR-WKBIN-01** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-02** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-03** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-04** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-05** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-06** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-07** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-08** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-09** | `tests/test_domain_sr.sh` | have |
| **TP-SR-WKBIN-10** | `tests/test_domain_sr.sh` | have |
| **TP-CLI-15** | `tests/test_cli.sh` | have |
| **TP-SR-FT-01..07** | `tests/test_domain_sr.sh` | have |
| **TP-CLI-16** | `tests/test_cli.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `requirement-domain-sudoer-approval.md` | Dest table + review loop |
| `requirement-incorrect-json-format.md` | JSON-format Fence (runs first) |
| `requirement-shell-cli-interface` | Dual mention of `test-well-known-binary` |
| `requirement-domain-sudoer-approval` | Dual mention of Type 0 `fence-test` (closed dest fence list) |
| `src/sudoer-cli` | Ship unit |

**Last Updated**: 2026-08-21  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
