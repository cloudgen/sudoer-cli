**file**: docs/requirements/requirement-class-software-dev.md  
**Status**: Active (Version 1.11.3 – stay-honest VERSION 1.29.0; shared doorbell `sudoer-review-hook`)  
**Area**: class  
**Key**: `requirement-class-software-dev`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This folder’s **project nature** is software you hand people to install: a POSIX `/bin/sh` program. This file keeps leftover stack facts (language, toolchain, OS) that no other live requirement owns.

This file is **not** a second copy of install, output, storage, or writing-style tables (the coding-style related REQ **MUST** exist as the specialize-in home for portable writing lessons).

### 1.1 Human-facing

**In one sentence:** This workspace is software you install: a POSIX `/bin/sh` program, with a dedicated approver account after first-time setup.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Use and install `sudoer-cli` without becoming root | `curl -fsSL …/src/sudoer-cli \| sh` |
| The other role | Host admin who already used password `sudo` | `sudo sudoer-cli setup` |
| Not this file | Domain verbs, dest fences, Type map, writing-style body | `requirement-domain-sudoer-approval` · `requirement-actor-role-subject-approver` · `requirement-shell-script-coding` |

| Includes | Excludes |
|----------|----------|
| Class membership; residual stack; pointers to ARSA, dest-fence, and coding-style REQs | Online install; inventing a dest fence; inventing an extra approver; skipping the coding-style REQ so portable lessons arrive raw |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | live product |
| `docs/requirements/index.md` | registry | Active law list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Confirm class | This is software-development, not an empty seed. Residual stack lives here until a peer owns it. | Read this file + `docs/requirements/index.md` |

---

## 2. Core Rules (Mandatory)

### 2.0 Project class membership

1. **MUST** treat this workspace as **software-development** (shippable software), not genesis-template and not server-maintenance.  
2. **MUST** use basename **`requirement-class-software-dev.md`** as the sole Active class-law file for this class.  
3. **MUST NOT** register an Active `requirement-class-server-maintenance.md` while class is software-development.  
4. **MUST** retain portable harness knowledge; specialized product knowledge lives in this and peer `requirement-*.md` files.  
5. **MUST** apply software-development SSOT/gate posture when claimed (identity, ship unit, precommit when git is used — as applicable).  
5a. When git is used on a **multi-vault host**, **MUST** treat forge push identity as **product repository-user SSOT** (Config `REPO_USER` / project-repository owner), not ambient default SSH face: agents **MUST** run precommit / SSH-profile gates (pre-git report; vault bind via activate or one-shot identity for push). Host vault basenames are **not** product law.  
6. **MUST NOT** invent hollow product docs solely to look specialized; collect real values or defer explicitly.

### 2.1 Residual collection principle (SSOT hygiene)

7. **MUST** treat this file as the **default home** for software-stack facts **not owned** by another Active requirement.  
8. **MUST NOT** duplicate full normative tables that already live in a more specific Active requirement. Prefer a **one-line pointer** to the peer requirement key.  
9. When a new specialized requirement **takes ownership** of a topic previously only listed here, **MUST** update this file in the **same change**: remove or shrink the residual entry and point to the new owner.  
10. **MUST NOT** leave contradictory stack facts across this file and peer requirements.

### 2.2 Programming language(s)

11. **MUST** declare at least one **primary programming language** for the ship unit.  
12. **SHOULD** list secondary languages only when they are real product law.  
13. **MUST** state whether the product is primarily: interpreted, compiled, polyglot, or package-multi-language.  
14. **MUST NOT** freeze a marketing product name as if it were the language name.

### 2.3 Compilers, interpreters, and toolchains

15. **MUST** declare the **target toolchain class** used to build or run the product.  
16. **MUST** state version policy as one of: unconstrained · minimum version · range · pinned.  
17. **SHOULD** record whether cross-compilation is in scope.  
18. **MUST** fail closed in CI/docs claims: do not claim “supports all compilers” without tests or explicit unconstrained policy.

### 2.4 Project / package / build tools

19. **MUST** declare the **primary project or package tool** used for dependencies and builds.  
20. **MUST** declare how dependencies are resolved when the ecosystem supports lockfiles.  
21. **SHOULD** name the test runner and linter/formatter **classes** when they are project law.  
22. **MUST NOT** require a secret token or private registry password in this file.

### 2.5 Runtime and platform (residual)

23. **MUST** declare the intended **primary runtime/OS family** when not fully owned by another architecture requirement.  
24. **SHOULD** declare minimum CPU/arch support only when it is real product law.  
25. **MUST** separate **developer machine** toolchain requirements from **end-user runtime** requirements when they differ.

### 2.6 No-hardcode / dual policy (class file)

26. **MUST NOT** hard-code a single product/app brand, one org’s production hostname, or personal owner identity as universal core law.  
27. **MUST** put live product name, repo slug, and concrete stack choices in **Implementation Notes** after collection — complete when Status is Active.  
28. **MUST NOT** store secrets, PATs, or toy credentials in this file.

### 2.7 Actor / role / subject / approver (consider)

29. Every software-development project **MUST** consider an **actor / role / subject / approver** catalog — **even if there is no dest approver**.  
30. This product **has** dest review: Active `requirement-actor-role-subject-approver` **MUST** print the five-column table. Dest Roles stay on `requirement-domain-sudoer-approval`.  
31. **MUST NOT** skip the consider. **MUST NOT** invent an extra approver.

### 2.8 Dest fence conditions (review and convert)

32. Every software-development project **MUST review** dest fencing conditions.  
33. This product’s dest **Fence** is **incorrect JSON format** (`requirement-incorrect-json-format`). **Well-known sudoer binary** (`requirement-well-known-sudoer-binary-fence`) is dest **warn then ask** plus convert/submit/tester fail-closed. Dest table on `requirement-domain-sudoer-approval` **MUST** still print and **point** at those REQs.  
34. Dest **MUST NOT** fence rows stay on dest tables only.  
35. **MUST NOT** invent a dest fence.  
36. When dest has any dest **Fence**, the product **MUST** ship Type 0 **`fence-test`** as a **test-purpose** verb: **unit test** of dest fence functions against a JSON **file location** in a **local test folder**. **MUST NOT** require `sudo` to run. The only allowed in-tool elev is wrapping **chmod** / **chown** of that folder (check before sudo). **MUST NOT** sudo otherwise. **MUST NOT** queue, dest-write, `setup`, or `approve`. Dest review / queue / host install **MUST NOT** count as that tester. Help **MUST** list test-purpose verbs **apart** from **operational** verbs. Dual mention: CLI-interface REQ **and** domain SSOT. This product: `fence-test --file tests/fixtures/fence-test/pass/login-hook-elev-dns-adm.json`. Per-row testers **MAY** also exist (`test-json-format`, `test-well-known-binary`) and are also test-purpose. Privilege Type 0 does **not** mean “unit test.”

### 2.9 Coding-style related requirement (MUST have)

37. This software-development product **MUST** have an Active coding-style related requirement matching the primary language.  
38. **Intention:** without that REQ, agents bring portable learned lessons **raw** and treat them as this product’s law. That REQ is the **specialize-in home** (adopt, point, or refuse).  
39. This product: Active `requirement-shell-script-coding` (POSIX `/bin/sh`). This class file **points**; it does **not** keep the writing-style body.  
40. **MUST NOT** skip. Honest residual **none** is **not** valid.

### 2.10 Implementation Notes (this project)

| Field | Value (sudoer-cli) |
|-------|---------------------|
| **Project display name** | `sudoer-cli` |
| **Project class** | software-development |
| **Class requirement basename** | `requirement-class-software-dev.md` |
| **Primary language(s)** | `posix-sh` (`/bin/sh`) |
| **Language role** | primary only — single-file shell ship unit under `src/` |
| **Execution model** | **interpreted** — no compile step |
| **Toolchain / interpreter** | POSIX `/bin/sh` (dash/bash-as-sh compatible subset); no compiler |
| **Toolchain version policy** | **unconstrained** among POSIX sh implementations that pass product tests when present |
| **Cross-compile in scope?** | no |
| **Primary project/package tool** | **none** — no language module system; ship unit is the source |
| **Lockfile policy** | not used |
| **Test runner** | POSIX shell suite under `tests/` when present (`tests/run.sh` pattern) |
| **Linter/formatter** | none as project law (shellcheck optional) — see `requirement-shell-script-coding` |
| **Primary runtime / OS family** | POSIX Linux (and compatible UNIX where `/bin/sh` + `mktemp` + `date` exist) |
| **Architectures supported** | any arch with POSIX sh and the external tools the script invokes |
| **Git surface** | used when product is published |
| **Ship unit / install** | yes — `src/sudoer-cli`; **online-installable** (`curl \| sh` via `SCRIPT_URL`) |
| **Product version SSOT** | `VERSION="1.29.0"` hard-assign in `src/sudoer-cli` |
| **Bootstrap origin** | Historical **cli-template**. This product is **sudoer-cli**. No live parent ship unit. |

**Residual ownership table:**

| Topic | Owner | Notes |
|-------|-------|--------|
| Project class membership | **this file** | Fixed |
| Primary language + toolchain policy | **this file** | posix-sh, unconstrained |
| Package/build tool + lockfile | **this file** | none / not used |
| Bootstrap lineage / keep-trim | `requirement-bootstrap-chain` | sudoer-cli specialized from cli-template |
| Privilege / LPU / Type map | `requirement-three-layer-privilege-model` · `requirement-least-privilege-user` | Do not duplicate |
| What is blocked vs must stay open | `requirement-privilege-prevention-set` | Closed prevention catalog; do not invent walls |
| Domain sudoers-approval | `requirement-domain-sudoer-approval` | File-based JSON approval; dest fence table; login hook **points** |
| Grant sudoers file | `requirement-sudoers-file` | Text dual; Cmnd arg escape; visudo -cf; visudo-fail copy; **not** a dest Fence; domain points |
| Login-time review hook | `requirement-login-interactive-review-hook` | Rc snippet; labeled `/usr/local/bin/sudoer-review-hook`; sibling CLIs reuse that doorbell |
| PATH / profile / shell-rc sibling unify | `requirement-shell-path-and-shell-support` | This-login PATH + profile; `rc-test`; do not duplicate; login-hook stays on the login-hook REQ |
| Actor / role / subject / approver consider | `requirement-actor-role-subject-approver` | Dest has approver — not residual None |
| Dest fence: incorrect JSON format | `requirement-incorrect-json-format` | Independent Fence REQ; dest table still prints; Type 0 `test-json-format`; list tester `fence-test` |
| Dest fence: well-known sudoer binary | `requirement-well-known-sudoer-binary-fence` | Dest **warn then ask**; testers/convert fail closed; dest table still prints; Type 0 `test-well-known-binary`; list tester `fence-test` |
| Coding-style related REQ | `requirement-shell-script-coding` | **MUST**; specialize-in home for portable POSIX writing lessons; residual **points** |
| In-tool sudo / chmod wrappers | `requirement-shell-sudo-command` | Sudo-wrapping function; check before sudo; chmod example |
| Project layout / ship path | `requirement-project-folder` | `src/` + bin targets |
| Type 0 CLI surface / flags / dispatch | `requirement-shell-cli-interface` | Do not duplicate |
| Empty argv Type O install-ensure | `requirement-shell-cli-zero-arguments` | Online-installable |
| Numbered TTY start list | `requirement-shell-cli-default-interaction` | Verb `menu` / `main`; empty argv is Type O; invalid choice reprints this layer |
| Online self-managed lifecycle | `requirement-shell-self-management` | install / version-check / self-update / self-uninstall |
| Output SSOT (`out_*`) | `requirement-shell-output-requirements` | Do not duplicate |
| Scratch/cache storage resolve | `requirement-shell-cli-storage` | Do not duplicate |
| Idempotency / re-run safety | `requirement-shell-idempotency` | Do not duplicate |
| Interactive vs non-interactive | `requirement-shell-interactive-vs-noninteractive` | Do not duplicate |
| Modular prefixes / single-file layout | `requirement-shell-modular-function-design` | Do not duplicate |
| Folder archive backup / restore / retention | **intentionally absent** | Not this product’s domain (sibling folder-backup) |
| Companion checksum | `requirement-shell-automatic-checksum` | `${SCRIPT_URL}.sha256` |

---

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Class and stack choices are explicit, not assumed from folder names.  
- **CIAO Principle 5 – SSOT**: Residual stack facts have one home until specialized requirements take ownership.  
- **CIAO Principle 1 – Caution**: Toolchain policies are declared; agents do not invent compilers or online install.  
- **CIAO Principle 21 – Dual Policies**: Portable core; filled Implementation Notes.  
- **CIAO Principle 4 (O) + Principle 20**: Protection Rule against dual stack SSOTs and wrong-class pollution.

---

## 4. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume toolchain and package tools are missing until declared and verified.  
- **Intentional**: Residual collection is deliberate — not a dump of every possible tool.  
- **Anti-fragile**: Unconstrained POSIX sh policy survives multi-env runs when tests pass.  
- **Over-protect**: Protection rule prevents dual stack SSOTs and genesis/class confusion.

---

## 5. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Delete this file while the workspace remains **software-development** with other Active product requirements.  
2. Rename the specialized basename away from `requirement-class-software-dev.md` without an explicit class-model change.  
3. Hard-code secrets, personal owner identity, or production host FQDNs into core rules as universal law.  
4. Duplicate full peer requirement bodies into this residual section.  
5. Leave Implementation Notes as hollow stubs when Status claims Active.  
6. Drop Active **online-install** / remote **self-update** / **self-uninstall** / channel **checksum** law while the product claims `curl \| sh`.  
7. Treat this file as server-maintenance allowlist law, or register an Active server-maintenance class file in parallel.  
8. Invent a second primary language SSOT that contradicts peer modular/CLI requirements.  
9. Skip the actor / role / subject / approver consider, or invent an extra approver.  
10. Skip dest-fence review, leave a dest **Fence** as only a table cell, invent a dest fence, leave dest Fences without Type 0 `fence-test`, treat `sudo` / a sudoers fragment / the waiting folder as that tester, group testers with operational verbs in help, or `sudo` on a tester except wrapping chmod/chown of the local test folder.  
11. Skip `requirement-shell-script-coding`, leave writing style only as residual “when present”, or treat portable coding lessons as product law because that file is missing.  
12. Skip `requirement-shell-sudo-command` when the ship unit has in-tool sudo, or keep sudo-wrapping / check-before-sudo bodies only on the coding-style REQ.

**Violating any of these is considered a critical regression.**

---

## 6. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active registered `requirement-class-software-dev.md` matches software-development class |
| AC-2 | Primary language + toolchain policy + package tool declared in Implementation Notes (complete) |
| AC-3 | Residual ownership table honest: no silent dual SSOT with peer REQs |
| AC-4 | Core rules remain free of frozen secret/host hardcodes |
| AC-5 | No class file conflict with `requirement-class-server-maintenance` |
| AC-6 | Ship unit identity (posix-sh single-file, local install) consistent with peer shell REQs |
| AC-7 | Online install package **absent** from Active registry by design |
| AC-8 | Actor / role / subject / approver considered (Active catalog REQ) |
| AC-9 | Dest fence reviewed (independent REQ per **Fence**); dest Fences ship Type 0 **test-purpose** `fence-test` (local test folder; help listed apart from operational) |
| AC-10 | Coding-style related REQ Active (`requirement-shell-script-coding`); residual **points**; specialize-in intention present |
| AC-11 | Residual **points** at Active `requirement-shell-sudo-command` for sudo-wrapping / check before sudo |

---

## 7. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-bootstrap-chain` | This product is hop 0 / origin |
| `requirement-project-folder` | Layout and install locations |
| `requirement-shell-cli-interface` | Command surface, flags, dispatch |
| `requirement-shell-cli-zero-arguments` | Type O empty argv |
| `requirement-shell-self-management` | Online lifecycle |
| `requirement-shell-automatic-checksum` | Companion digest |
| `requirement-shell-cli-default-interaction` | Numbered start list on `menu` / `main` |
| `requirement-shell-local-self-management` | Local install lifecycle |
| `requirement-shell-output-requirements` | `out_*` SSOT |
| `requirement-shell-cli-storage` | Scratch/cache resolve |
| `requirement-shell-idempotency` | Re-run safety |
| `requirement-shell-interactive-vs-noninteractive` | Mode policy |
| `requirement-shell-modular-function-design` | Prefixes / single-file modularity |
| `requirement-shell-script-coding` | Coding-style related REQ (specialize-in home) |
| `requirement-shell-sudo-command` | Sudo-wrapping function; check before sudo; chmod example |
| `requirement-three-layer-privilege-model` | Type map + Tables A/B/C |
| `requirement-least-privilege-user` | F1–F7 |
| `requirement-privilege-prevention-set` | Closed catalog of what is blocked vs must stay open |
| `requirement-domain-sudoer-approval` | File-based JSON approval |
| `requirement-sudoers-file` | Grant sudoers file: Cmnd arg escape, visudo -cf, visudo-fail copy |
| `requirement-actor-role-subject-approver` | Five-column consider catalog |
| `requirement-incorrect-json-format` | Dest Fence: JSON format |
| `requirement-well-known-sudoer-binary-fence` | Well-known binary: dest warn + testers/convert fail closed |
| `requirement-login-interactive-review-hook` | Approver rc + labeled hook |
| `requirement-shell-path-and-shell-support` | This-login PATH / profile; sibling unify; `rc-test` |
| `docs/requirements/index.md` | Registry SSOT |

---

## 8. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Specialized class law for folder-backup (left genesis; bootstrap trim from selfmanaged) |
| 2026-08-13 | Active 1.1.0 | Retarget to cli-template; drop domain/privilege residual owners |
| 2026-08-13 | Active 1.2.0 | Bootstrap origin = selfmanaged; folder-backup hop retired (no longer maintain bootstrap from it) |
| 2026-08-13 | Active 1.3.0 | This product is hop 0; selfmanaged is not origin |
| 2026-08-13 | Active 1.4.0 | Specialize to sudoer-cli; point residual at privilege + domain REQs |
| 2026-08-14 | Active 1.5.0 | Residual: prevention-set owner; VERSION 1.2.3; `setup` live; `interactive` loop Gap |
| 2026-08-19 | Active 1.6.0 | ARSA catalog + dest-fence review; §1.1 Human-facing |
| 2026-08-20 | Active 1.7.0 | JSON-format dest Fence MUST name Type 0 `test-json-format` |
| 2026-08-20 | Active 1.8.0 | Coding-style related REQ MUST (`requirement-shell-script-coding`); specialize-in home for portable lessons |
| 2026-08-20 | Active 1.9.0 | Residual **points** at `requirement-shell-sudo-command` (sudo-wrapping function; check before sudo; chmod example) |
| 2026-08-20 | Active 1.9.1 | Core-rule sections sequential: 2.6 dual policy · 2.7 ARSA · 2.8 dest fence · 2.9 coding-style · 2.10 Implementation Notes |
| 2026-08-21 | Active 1.9.2 | Dest Fences: JSON format + well-known sudoer binary |
| 2026-08-21 | Active 1.9.3 | Dest Fences ship Type 0 `fence-test` (`--file` / `--dir`) |
| 2026-08-21 | Active 1.9.4 | `fence-test` is JSON-file verification: no sudo, no sudoers fragment, no queue |
| 2026-08-21 | Active 1.9.5 | Test-purpose vs operational verbs; `fence-test` is a unit tester of a local test folder |
| 2026-08-21 | Active 1.9.6 | Dest Fence is JSON format; well-known is dest warn + testers fail closed; VERSION 1.17.0 |
| 2026-08-26 | Active 1.9.7 | Stay-honest Implementation Notes `VERSION` 1.17.1 |
| 2026-08-26 | Active 1.9.8 | Residual **points** at `requirement-sudoers-file` (grant text dual, Cmnd escape, visudo) |
| 2026-09-03 | Active 1.9.9 | Stay-honest Implementation Notes `VERSION` 1.18.0 (login-hook-symlink) |
| 2026-09-03 | Active 1.9.10 | Residual **points** at `requirement-shell-cli-default-interaction`; `VERSION` 1.19.0 |
| 2026-09-03 | Active 1.9.11 | Stay-honest Implementation Notes `VERSION` 1.20.0 (keep-latest duplicate inbound) |
| 2026-09-06 | Active 1.9.12 | Stay-honest Implementation Notes `VERSION` 1.21.0 (YAML login-hook review display) |
| 2026-09-08 | Active 1.10.1 | Stay-honest Implementation Notes `VERSION` 1.23.0 (YAML review body two-space indent) |
| 2026-09-08 | Active 1.10.2 | Residual **points** at `requirement-login-interactive-review-hook` |
| 2026-09-08 | Active 1.10.3 | Stay-honest Implementation Notes `VERSION` 1.24.0 (old-hook review on `interactive`) |
| 2026-10-02 | Active 1.11.3 | Stay-honest Implementation Notes `VERSION` 1.29.0; menu **5** languages |
| 2026-09-13 | Active 1.11.3 | Stay-honest Implementation Notes `VERSION` 1.28.0; shared doorbell `sudoer-review-hook` |
| 2026-09-13 | Active 1.11.2 | Stay-honest Implementation Notes `VERSION` 1.27.0; shared doorbell `login-review-hook` |
| 2026-09-13 | Active 1.11.1 | Stay-honest Implementation Notes `VERSION` 1.26.0; default-interaction invalid-choice retry |
| 2026-09-09 | Active 1.11.0 | Residual **points** at `requirement-shell-path-and-shell-support`; `VERSION` 1.25.0 |

---

**Last Updated**: 2026-09-13  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
