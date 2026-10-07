**file**: docs/requirements/requirement-shell-script-coding.md  
**Status**: Active (Version 1.4.2 – no silent filename change while saving)  
**Area**: shell  
**Key**: `requirement-shell-script-coding`  
**id**: RQ-SHELL-SCRIPT-CODING  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **specialize-in home** for how the sudoer-cli POSIX `/bin/sh` ship unit is written.

**Intention:** without this file, agents bring portable learned lessons **raw** and treat them as this product’s law. With this file, those lessons are **adopted here**, **pointed** at a peer requirement that already owns the slice, or **refused**.

This file is **not** a second copy of output, prefix, TTY, prompt, or temp tables.

### 1.1 Human-facing

**In one sentence:** How this program is written lives here so agents do not paste portable style into `src/sudoer-cli` as if it were already law.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | One POSIX script | `src/sudoer-cli` |
| The other role | Peer files own slices | `out_*` on the output requirement |
| Not this file | Dest JSON fences, domain verbs | `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Shebang; headers; respect working code; no `\|\|{}` / `&&{}`; ALIGNMENT cites live requirements only; check before sudo (`sudo chmod` example) | Duplicating `out_*`, prefix tables, TTY measure, `prompt_*` bodies, `mktemp` samples |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/sudoer-cli` | ship unit | the code this style governs |
| `docs/requirements/index.md` | registry | this row + peers |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Change a helper | Follow this file and the peers it points at. Do not import a portable lesson that this product did not adopt. | (edit `src/sudoer-cli`) |

---

## Design-time verification

| Gate | Artifact | Phase |
|------|----------|-------|
| Style / writing law | **n/a** — review-time; no unique TP family | Design |
| Indirect smoke | `TP-CLI-01` (`sh -n`); `TP-ELEV-07` (TTY measured outside functions) | Proof |

Record **n/a** for a dedicated coding-style family in `reviews/test-plan.md`.

---

## 2. Core Rules (Mandatory)

### 2.0 Specialize-in home (sacred)

1. **MUST** treat this file as the product home for portable POSIX writing lessons.  
2. **MUST NOT** apply a portable coding lesson as product law unless this file **adopts** it or a **pointed peer** already owns it.  
3. **MUST NOT** skip this file and “just follow the coding skill.”  
4. When a new lesson is learned in a skill or mold and this product should keep it, **MUST** specialize it **here** (or move ownership to the correct peer) in the **same change**.  
5. **MUST NOT** duplicate full normative tables that live on peer requirements.

### 2.1 Interpreter and portability

6. **MUST** use `#!/bin/sh` on the ship unit.  
7. **MUST** stay in the POSIX `/bin/sh` subset that product tests pass (dash / bash-as-sh).  
8. **MUST NOT** add bashisms as default style.

### 2.2 Function headers and Protection Zones

9. Non-trivial functions **MUST** carry a defensive header: one-line purpose, GENERAL PURPOSE, CIAO principles as relevant, Protection / do-not-simplify on critical helpers, Last reviewed when modified.  
10. Critical sections (output printer, install place/remove, storage resolve, dest fence check) **MUST** remain Protection Zones.  
11. **MUST NOT** strip headers or Protection Zones to “clean up” working code.

### 2.3 Control flow and respect for working code

12. New or modified control flow **MUST** use explicit `if` / `then` / `else` / `fi`. **MUST NOT** use `command \|\| { … }` or `command && { … }` except already-stable one-liners inside Protection Zones.  
13. **MUST NOT** rewrite a working function for style, cleanliness, or modernization. Touch it for a bug, a requirement violation, or an explicit redesign.  
14. Nested `case` **SHOULD** stay flat; extract a named helper instead of cascading cases.

### 2.4 Product-source citation

15. Product-source `ALIGNMENT` / “see” comments **MUST** cite only live `docs/requirements/requirement-*.md` rows registered in `index.md`.  
16. **MUST NOT** paste template or skill basenames into the ship unit as behavioral authority.

### 2.5 Nounset defaults

17. Under `set -u`, every bare expansion on a live path **MUST** have a prior default or arity check.  
18. **MUST** default `HOME` (or the approved substitute) **before** any `${HOME}/…` path.  
19. **MUST NOT** hide nounset abort by discarding stderr on external `.` / `source`.

### 2.6 Elevation examples (writing)

20. **MUST NOT** paste `sudo -n` into the ship unit, help, or examples unless a live privilege requirement **names** the NOPASSWD grant or login hook. First-time `setup` uses password `sudo` or an already-root session.

### 2.6b Check before sudo / sudo-wrapping function

21. In-tool sudo **MUST** use the sudo-wrapping function and check before sudo. **chmod example:** `[ -O path ]` then no `sudo chmod` on match.  
22. **Owner:** `requirement-shell-sudo-command` (`util_sudo` / `util_chmod`). This file **points**; it does **not** keep the wrapper bodies.

### 2.6c Filename while saving

23. When this product **saves a file**, the basename that lands **MUST** be the basename the owning requirement already named.  
24. An agent who thinks a filename must change **MUST** tell the operator the old name, the new name, and why **before** any rename. The filename is the identity of the file. A quiet rename breaks the chain of evidence: the name in the requirement is not the name on disk.  
25. This product has more than one requirement. The agent **MUST** ask whether that change is written into the requirement that already owns the file, or into a new standalone requirement.  
26. **MUST NOT** change the filename until that requirement names both the old filename and the new filename, or the operator has confirmed the change. A silent change with neither is forbidden.  
27. These are not a filename change: a scratch leaf moved onto the **same** final basename the caller named; a requirement that already names both an old hook name and `sudoer-review-hook`; a check that refuses a path and does not rewrite it.

### 2.7 Pointed peers (do not duplicate)

| Slice | Owner | This file |
|-------|-------|-----------|
| `out_*` printer, JSON/quiet, operator `Next:` | `requirement-shell-output-requirements` | Point only |
| Function prefixes (`out_`, `inst_`, `app_`, `sr_`, `lpu_`, `prompt_*`, …) | `requirement-shell-modular-function-design` | Point only |
| Interactive vs non-interactive; `[ -t` **outside** functions | `requirement-shell-interactive-vs-noninteractive` | Point only |
| `prompt_yes_no` / `prompt_ask` bodies | `requirement-shell-prompt` | Point only |
| Do not `$()` a `read` helper (`PROMPT_ASK_VALUE`) | `requirement-shell-prompt` · `requirement-shell-cli-default-interaction` | Adopted; point |
| Scratch leaves (`mktemp`; no `$$` names) | `requirement-shell-temp-file-system` | Point only |
| Re-run install/uninstall | `requirement-shell-idempotency` | Point only |
| In-tool sudo / chmod wrappers | `requirement-shell-sudo-command` | Point only |

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Ship unit** | `src/sudoer-cli` |
| **Primary language** | posix-sh (`#!/bin/sh`) |
| **Linter / formatter as law** | **none** — `shellcheck` optional for maintainers |
| **Domain prefixes** | `sr_` / `lpu_` (owned on the modular requirement) |
| **Adopted portable lessons** | POSIX shebang; full headers; Protection Zones; explicit `if`; respect working code; live-requirement ALIGNMENT; HOME-before-paths; no raw `sudo -n`; check before sudo + sudo-wrapping function (bodies on `requirement-shell-sudo-command`); do not `$()` `prompt_ask` / any `read` helper (`PROMPT_ASK_VALUE`) |
| **Refused portable lessons** | Online-install / `curl\|sh` Type O empty-argv; remote self-update; treating `sudo -n` as default elev |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Writing style is chosen here, not assumed from a portable skill.  
- **CIAO Principle 5 – SSOT**: One home for specialized writing lessons; peers keep their slices.  
- **CIAO Principle 20 / CIAO-Lite O**: Protection Zones and “do not rewrite working code” stay product law.  
- **CIAO Principle 21 – Dual Policies**: Portable lessons stay in molds/skills; this file is complete product law.  
- **CIAO Principle 10 / 22**: Check before sudo. Example: do not `sudo chmod` when this login already owns the path.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows cmd, or the same class (no root login on that shell):

| MUST | MUST NOT |
|------|----------|
| Keep **normal user privilege** only | Turn on **admin privilege** or **dedicated system user privilege** |
| Convert, queue, list, help, and local install into the user bin | In-tool `sudo`; wrap `apt` / `dnf`; `useradd`; write `/etc`; recommend `sudo curl | sh` |
| Document setup / approve / interactive as **unused** on that class | Invent a dedicated account on that class |

**This requirement:** helpers stay this-login POSIX; MUST NOT paste in-tool `sudo` / `apt` bodies as if they were live on this class.

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS` is `Windows_NT` and `COMSPEC` names `cmd.exe` (after excluding Git Bash / WSL).

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume a missing coding-style file means portable lessons will leak in raw.  
- **Intentional**: Adopt, point, or refuse — never silent import.  
- **Anti-fragile**: POSIX subset + respect working code survive harsh hosts and later agents.  
- **Over-protect**: This file exists so the next agent cannot treat a coding skill as sudoer-cli law.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Delete this file while the workspace remains software-development with a POSIX ship unit.  
2. Apply a portable writing lesson as product law without adopting it here or pointing at the owning peer.  
3. Duplicate full `out_*`, prefix, TTY, prompt, or temp tables into this file.  
4. Rewrite working functions for style.  
5. Cite templates or skills as ship-unit ALIGNMENT.  
6. Paste `sudo -n` as default elev.  
7. Change the shebang away from `#!/bin/sh` without an explicit product-language change.  
8. Treat “linter none” as permission to skip this requirement.  
9. Keep sudo-wrapping / check-before-sudo bodies here instead of `requirement-shell-sudo-command`.  
10. Probe with `sudo ls` / `sudo stat` to decide whether to sudo.  
11. Silently change a filename while saving a file or while writing code that saves a file. Tell the operator first. Ask whether the change belongs in the owning requirement or in a standalone requirement.

**Violating any of these is a critical regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active registered `requirement-shell-script-coding.md` is the coding-style related REQ for this POSIX product |
| AC-2 | Purpose states the specialize-in intention (without this file, portable lessons arrive raw) |
| AC-3 | Peer slices are pointers, not duplicated bodies |
| AC-4 | Shebang `#!/bin/sh`; explicit `if`; respect working code; live-requirement ALIGNMENT |
| AC-5 | Class residual **points** here |
| AC-6 | Points at `requirement-shell-sudo-command` for sudo-wrapping + check before sudo (chmod example) |

---

## 6. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-class-software-dev.md` | Class MUST + residual pointer |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Type map |
| `docs/requirements/requirement-shell-sudo-command.md` | Sudo-wrapping function; check before sudo; chmod example |
| `docs/requirements/requirement-shell-modular-function-design.md` | Prefixes |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY measure |
| `docs/requirements/requirement-shell-prompt.md` | Prompt bodies; `PROMPT_ASK_VALUE` |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Menu choice must not `$()` `prompt_ask` |
| `docs/requirements/requirement-shell-temp-file-system.md` | Scratch leaves |
| `src/sudoer-cli` | Ship unit |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-10-04 | Active 1.4.2 | No silent filename change while saving. Tell the operator. This product has more than one requirement: ask which requirement records both names |
| 2026-09-06 | Active 1.4.1 | Under command line for normal user only |
| 2026-08-20 | Active 1.0.0 | Specialize-in home for portable POSIX writing lessons |
| 2026-08-20 | Active 1.1.0 | Before `sudo chmod`, non-sudo owner probe (`[ -O path ]`); if match, no elevated chmod |
| 2026-08-20 | Active 1.2.0 | Superclass: check before sudo; `sudo chmod` remains the worked example |
| 2026-08-20 | Active 1.3.0 | Own-or-point: sudo-wrapping bodies on `requirement-shell-sudo-command` |
| 2026-09-03 | Active 1.4.0 | Adopt do-not-capture-read; point at prompt + default-interaction |

**Last Updated**: 2026-10-04  
  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
