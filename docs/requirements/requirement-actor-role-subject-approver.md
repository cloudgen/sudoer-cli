**file**: docs/requirements/requirement-actor-role-subject-approver.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-actor-role-subject-approver`  
**id**: RQ-ACTOR-ROLE-SUBJECT-APPROVER  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **actor / role / subject / submitter / approver** catalog for sudoer-cli. Every software-development product **MUST** consider this catalog. Dest review procedure, dest fence table, and login-hook snippets stay on `requirement-domain-sudoer-approval.md`. Privilege types stay on `requirement-three-layer-privilege-model.md`. The dedicated approver account stays on `requirement-least-privilege-user.md`.

### 1.1 Human-facing

**In one sentence:** For each thing people actually run, this file names who does it, who the grant is for, who may file it, and who may accept it — or writes **None**.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Convert, queue, list, and install without becoming root | `sudoer-cli add-sudoer-request --file request.json` |
| The other role | A host admin who already used password `sudo`, or `sudoer-adm` after first-time setup | `sudo sudoer-cli interactive` |
| Not this file | Dest fence list, login hook, or the Type map | `requirement-domain-sudoer-approval` · `requirement-three-layer-privilege-model` |

| Includes | Excludes |
|----------|----------|
| Five-column catalog for help, install, convert/submit, setup, and review | Dest **Fence** rows; login-hook snippet; inventing an extra `*-adm` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | live verbs |
| `sudoer-cli help` | command | listed verbs |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| File a grant | Anyone may queue JSON for themselves or another login. The filename uses the grant subject. | `sudoer-cli add-sudoer-request --file request.json` |
| Decide | After password `sudo` or a root login, that person may accept or decline. `sudoer-adm` is an extra path, not the only one. | `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

1. **MUST** print the five-column table. Submitter is immediately before Approver.  
2. **MUST NOT** invent an approver so the table looks complete. **None** is valid.  
3. **MUST NOT** absorb dest fence rows or login-hook snippets.  
4. On dest request rows, user identity is the JSON `username` field, not the filename token.

### 2.1 Catalog (this product)

| Actor | Role | Subject | Submitter | Approver |
|-------|------|---------|-----------|----------|
| Ordinary login | help / version / about / where-is-me | None | None | None |
| Ordinary login | install / uninstall | this program | the actor itself | None |
| Ordinary login | convert / submit / list / show | grant login B (JSON `username`) | anyone (A may file for B) | None |
| Host admin (password `sudo` or root login) | first-time setup | dedicated account `sudoer-adm` | None | None (that elev is the approval) |
| Host admin already root | approve / reject / interactive | inbound request / grant login B | None | that admin |
| `sudoer-adm` via the extra sudoers fragment | approve / reject / interactive | inbound request / grant login B | None | `sudoer-adm` (extra path) |

### 2.2 Implementation Notes (this product)

| Field | Value |
|-------|--------|
| Dest review Implemented | yes |
| Dedicated approver account | `sudoer-adm` |
| Dest actor table owner | `requirement-domain-sudoer-approval` (Roles) |
| Dest fence owner | `requirement-incorrect-json-format` (Fence row); dest table still on domain SSOT |

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Who files and who decides is explicit.  
- **CIAO Principle 9 – Privilege map**: Approver on dest rows is already-root work; help/install have Approver **None**.  
- **CIAO Principle 10 – Least privilege**: Do not invent a dedicated account where None is honest.

## 4. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Do not invent `*-adm`.  
- **Intentional**: Five columns, not a collapsed “admin does everything”.  
- **Anti-fragile**: Anyone may file for B; dest still uses B.  
- **Over-protect**: Dest fences stay on dest law.

## 5. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Skip this catalog because dest review exists.  
2. Invent an extra approver account.  
3. Replace dest Roles / dest fence law with this catalog.  
4. Require `SUDO_USER==sudoer-adm` as the only Approver fill.

## 6. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `requirement-class-software-dev.md` | Class consider pointer |
| `requirement-domain-sudoer-approval.md` | Dest Roles + dest fence table |
| `requirement-three-layer-privilege-model.md` | Privilege types |
| `requirement-least-privilege-user.md` | Dedicated account |
| `src/sudoer-cli` | Ship unit |

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
