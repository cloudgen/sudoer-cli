**file**: docs/requirements/requirement-incorrect-json-format.md  
**Status**: Active (Version 1.3.0) — interactive displays a fence match, then moves that file to rejected  
**Area**: domain  
**Key**: `requirement-incorrect-json-format`  
**id**: RQ-INCORRECT-JSON-FORMAT  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is **one dest Fence**: **incorrect JSON format**. Dest `approve` / `reject` / `interactive` **MUST** fail closed on a match (no dest write) and **MUST NOT** ask yes/no for that file. Dest `interactive` (the login-hook review verb) **MUST** display the match and **then** move that inbound file to the rejected queue. The dest fence table on `requirement-domain-sudoer-approval.md` **MUST** still print this row and **point here**. Any JSON-format dest Fence **MUST** ship a Type 0 test subcommand that runs these checks without dest elev and without requiring the waiting folder.

### 1.1 Human-facing

**In one sentence:** If the waiting file is not a well-formed grant JSON, dest review says so in plain words, does not ask you to accept it, and moves that file to the rejected folder.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The host admin already using `sudo`, reviewing inbound files | `sudo sudoer-cli interactive` |
| The other role | The person who dropped the file in the waiting folder | `sudoer-cli add-sudoer-request --file request.json` |
| Not this file | Who may run dest verbs; file owner; who submitted | `requirement-three-layer-privilege-model` · dest **MUST NOT** fence rows |

| Includes | Excludes |
|----------|----------|
| Not a regular file; not one JSON object; closed-schema fail; bad types/enums; basename grammar fail; basename **action** ≠ JSON `action` | Filename subject token ≠ JSON `username`; file owner; who submitted; missing dest-written `submit_by` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/sudoer-cli/sudoer-request` | waiting folder | inbound files |
| `src/sudoer-cli` | ship unit | dest fail-closed copy |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Test a grant JSON | Check the file against this Fence without becoming root and without putting it in the waiting folder. | `sudoer-cli test-json-format --file request.json` |
| Review a broken file | Dest shows what is wrong. It does not ask yes/no. The file goes to the rejected folder. Next file. | `sudo sudoer-cli interactive` |
| Fix and re-queue | Convert or submit again so the JSON is a complete grant. | `sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "…"` |

---

## 2. Core Rules / Requirements (Mandatory)

1. **MUST** name **exactly this** dest Fence: incorrect JSON format.  
2. **MUST** match when **any** of: not a regular file; symlink; not one parseable JSON object; closed-schema fail (`schema_version`, unknown keys); invalid field types or enums; basename grammar fail; basename **action** ≠ JSON `action`.  
3. **MUST NOT** treat basename **subject token** ≠ JSON `username` as this Fence. User SSOT is the JSON field.  
4. On match: dest **MUST** display the match in people/folder words (what happened / what it means / next). **MUST NOT** ask the approval question (one-off yes/no) for that file. Standalone `approve` / `reject` **MUST** fail closed with the same sentence; that file **stays inbound**.  
4a. Dest `interactive` (including the login hook) **MUST**, **after** that display, move the file inbound → rejected (snapshot + LPU owner + mode `0640` + unlink inbound). **MUST NOT** dest-write `/etc/sudoers.d`. **MUST NOT** stamp `submit_by`. **MUST NOT** call standalone `reject` re-validate to drain it (that re-validate would fail closed and leave the file inbound).  
5. **MUST NOT** ask yes/no before this Fence runs. **MUST NOT** move before the display.  
6. Dest **MUST NOT** fence rows (file-ownership, who submitted, JSON `username` ≠ `sudoer-adm`, dest-written `submit_by`) **MUST NOT** live in this file.  
7. **MUST** ship a Type 0 test subcommand for this Fence. Dest `approve` / `reject` / `interactive` **MUST NOT** count as that verb. The test verb **MUST** take stdin **xor** `--file PATH`, **MUST NOT** write `/etc/passwd` or `/etc/sudoers.d`, **MUST NOT** queue, and **MUST NOT** require the waiting folder. Basename grammar and basename **action** match apply **only** when the input basename already matches request-id grammar.

### 2.1 Implementation Notes (this product)

| Field | Value |
|-------|--------|
| Dest table | `requirement-domain-sudoer-approval` § dest approval fencing conditions |
| Type 0 test verb | `test-json-format` — handler `sr_test_json_format`; stdin **xor** `--file PATH` |
| Invocation sample | `sudoer-cli test-json-format --file request.json` |
| Golden fixture (Type 0 drop) | `tests/fixtures/login-hook-elev-dns-adm.json` (`kind` `login-hook-elev`; no `submit_by`) |
| Maximal dest-stamped fixture | `tests/fixtures/maximal-dest-stamped-login-hook-elev.json` (all closed-schema keys including `submit_by`) |
| Optional `kind` | Closed-schema allowlist includes `kind`. When present: `type-2-switch` or `login-hook-elev` |
| Dest-written `submit_by` | Allowed key. Converted queue Unix owner. Type 0 **MUST NOT** plant it. Dest **MUST NOT** treat it as unknown |
| Typical machine codes | `invalid_json`, `schema_version`, `field_mismatch`, `invalid_name`, `not_regular` |
| Display | Operator `[ERROR]` in people/folder words; JSON `message` same sentence |
| Interactive on match | Display first, then archive inbound → rejected. Standalone approve/reject stay inbound |

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Broken inbound is not a human decision.  
- **CIAO Principle 16 – Interactive**: Fence before prompt; after display, drain inbound so the login hook does not re-show the same broken file.  
- **CIAO Principle 21 – Dual policies**: Complete dest Fence; no invented extra fences.

## 4. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail closed on bad JSON.  
- **Intentional**: One Fence, one file.  
- **Anti-fragile**: Dest table still prints.  
- **Over-protect**: MUST NOT fence rows stay off this file.

## 5. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Fold a second dest Fence into this file.  
2. Ask yes/no on a match.  
3. Treat file owner or who submitted as this Fence.  
4. Delete the dest table row that points here.  
5. Leave this JSON-format Fence without Type 0 `test-json-format`, or treat dest review verbs as that test.  
6. Leave a fenced inbound file in the waiting folder after `interactive` displayed it.  
7. Dest-write `/etc/sudoers.d` on a fence match.  
8. Ask yes/no, or move, **before** the display.

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-SR-FENCE-01** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-02** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-03** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-04** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-05** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-06** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-07** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-08** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-09** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-10** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-11** | `tests/test_domain_sr.sh` | have |
| **TP-SR-FENCE-12** | `tests/test_domain_sr.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`.

## 6. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `requirement-domain-sudoer-approval.md` | Dest table + review loop |
| `requirement-actor-role-subject-approver.md` | Who may decide (not this Fence) |
| `src/sudoer-cli` | Ship unit |
| `requirement-shell-cli-interface` | Dual mention of `test-json-format` |

**Last Updated**: 2026-08-20 (1.3.0 interactive display-then-rejected)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
