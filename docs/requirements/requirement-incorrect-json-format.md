**file**: docs/requirements/requirement-incorrect-json-format.md  
**Status**: Active (Version 1.0.0)  
**Area**: domain  
**Key**: `requirement-incorrect-json-format`  
**id**: RQ-INCORRECT-JSON-FORMAT  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is **one dest Fence**: **incorrect JSON format**. Dest `approve` / `reject` / `interactive` **MUST** fail closed on a match and **MUST NOT** ask yes/no for that file. The dest fence table on `requirement-domain-sudoer-approval.md` **MUST** still print this row and **point here**.

### 1.1 Human-facing

**In one sentence:** If the waiting file is not a well-formed grant JSON, dest review says so in plain words and does not ask you to accept it.

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
| Review a broken file | Dest shows what is wrong. It does not ask yes/no. Next file. | `sudo sudoer-cli interactive` |
| Fix and re-queue | Convert or submit again so the JSON is a complete grant. | `sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "…"` |

---

## 2. Core Rules / Requirements (Mandatory)

1. **MUST** name **exactly this** dest Fence: incorrect JSON format.  
2. **MUST** match when **any** of: not a regular file; symlink; not one parseable JSON object; closed-schema fail (`schema_version`, unknown keys); invalid field types or enums; basename grammar fail; basename **action** ≠ JSON `action`.  
3. **MUST NOT** treat basename **subject token** ≠ JSON `username` as this Fence. User SSOT is the JSON field.  
4. On match: dest **MUST** display the match in people/folder words (what happened / what it means / next). **MUST NOT** ask approve / reject / skip as a decision for that file. Standalone `approve` / `reject` **MUST** fail closed with the same sentence.  
5. **MUST NOT** ask yes/no before this Fence runs.  
6. Dest **MUST NOT** fence rows (file-ownership, who submitted, JSON `username` ≠ `sudoer-adm`, dest-written `submit_by`) **MUST NOT** live in this file.

### 2.1 Implementation Notes (this product)

| Field | Value |
|-------|--------|
| Dest table | `requirement-domain-sudoer-approval` § dest approval fencing conditions |
| Typical machine codes | `invalid_json`, `schema_version`, `field_mismatch`, `invalid_name`, `not_regular` |
| Display | Operator `[ERROR]` in people/folder words; JSON `message` same sentence |

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Broken inbound is not a human decision.  
- **CIAO Principle 16 – Interactive**: Fence before prompt.  
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

## 6. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `requirement-domain-sudoer-approval.md` | Dest table + review loop |
| `requirement-actor-role-subject-approver.md` | Who may decide (not this Fence) |
| `src/sudoer-cli` | Ship unit |

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
