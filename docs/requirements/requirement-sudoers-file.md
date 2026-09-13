**file**: docs/requirements/requirement-sudoers-file.md  
**Status**: Active (Version 1.3.0) — `login-hook-elev` sudoers emit/dest-write **MUST** use `/usr/local/bin/sudoer-review-hook`  
**Area**: domain  
**Key**: `requirement-sudoers-file`  
**id**: RQ-SUDOERS-FILE  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **grant sudoers file**: the `sudoers(5)` **text dual** of inbound request JSON. Convert emits it, submit materializes it, dest writes it under `/etc/sudoers.d/{{service}}-{{username}}` after a human yes. It owns **Cmnd arg escape**, **visudo -cf** on a private copy, **re-encode fidelity**, and the **visudo-fail** operator copy (what happened / what it means / Next:).

**Stay-honest command identity:** inbound dest grants are **service-catalog** Cmnds (`nginx`, `gitlab-ctl`, `take-ownership`, …). They are **not** `{{GLOBAL_BIN}}/sudoer-cli` only. That own-binary row is for a product’s **own** elev JSON. This dest writes **sibling** grants. F6 Table A (`sudoer-adm` → `sudoer-cli`) stays on `requirement-three-layer-privilege-model`.

The dest fence table on `requirement-domain-sudoer-approval.md` **MUST** still print convert/submit/dest and **point here**. This is **not** a dest Fence: visudo reject is fail-closed (no dest write, no queue). JSON-format Fence and well-known-binary warn stay on their own REQs. Printer channels stay on `requirement-shell-output-requirements`.

### 1.1 Human-facing

**In one sentence:** The grant that dest would install must be visudo-legal text: special characters in command arguments are backslash-escaped, then visudo checks a private copy before anyone queues or writes `/etc/sudoers.d`.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Convert a grant to sudoers text, or dest-write after yes | `sudoer-cli json-to-sudoers --file request.json` |
| The other role | Host `visudo` parses that text | `visudo -cf /tmp/sudoer-visudo.XXXXXX` |
| Not this file | JSON schema; home-tree Cmnd path; F6 Table A; printer family | `requirement-incorrect-json-format` · `requirement-well-known-sudoer-binary-fence` · `requirement-three-layer-privilege-model` · `requirement-shell-output-requirements` |

| Includes | Excludes |
|----------|----------|
| Text dual `# Purpose:` + User-spec lines; Cmnd arg `\:` `\#` `\,`; `set -f` so `*` is not a glob; visudo -cf private copy; visudo-fail people words | JSON closed-schema; dest Fence drain; well-known path prefixes; F6 `sudoer-adm` fragment; feeding JSON to visudo |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/etc/sudoers.d/{{service}}-{{username}}` | live grant file | dest-write after visudo Pass **and** human yes |
| `src/sudoer-cli` | ship unit | render, escape, visudo, dest-write |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Convert JSON → sudoers | Emit visudo-legal text. Colon in `--ownership user:group` becomes `user\:group`. | `sudoer-cli json-to-sudoers --file request.json` |
| Convert sudoers → JSON | visudo the input first. Round-trip unescapes args so JSON has `alice:ops`. | `sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "…"` |
| Submit add/update | Same visudo check **before** the waiting folder. | `sudoer-cli add-sudoer-request --file request.json` |
| Dest-write | After yes: visudo the rendered grant, then copy under `/etc/sudoers.d/`. | `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 Stay-honest command identity

1. **MUST** name **exactly this** topic: the **grant sudoers file** (text dual of request JSON).  
2. Dest inbound `commands[].path` **MAY** be a service-catalog binary (`/usr/sbin/nginx`, `/usr/local/bin/take-ownership`, …). **MUST NOT** claim every dest grant path is `/usr/local/bin/sudoer-cli`.  
3. Dest **MUST NOT** treat visudo reject as a dest **Fence**. Convert / submit / dest-write **MUST** fail closed.  
4. When `kind` is `login-hook-elev`, convert (`json-to-sudoers`), Type 0 submit visudo, and Type 1 dest-write **MUST** emit `commands[].path` as `/usr/local/bin/sudoer-review-hook` (live doorbell on `requirement-login-interactive-review-hook`). Inbound JSON that still names the sibling product binary or `{{service}}-hook` **MUST** be rewritten in the sudoers **text**. JSON-format Fence / `test-json-format` **MUST NOT** rewrite inbound JSON. Type 2 switch grants stay the submitted path. F6 Table A emit stays on `requirement-three-layer-privilege-model` and **MUST** grant the same doorbell.

### 2.1 Text dual

Canonical rendered User-spec line **MUST** be:

```text
{{username}} ALL=({{runas}}) {{tags:}} {{path}} {{args…}}
```

Add/update fragments **MUST** start with `# Purpose: {{purpose}}` then one line per command. Remove **MUST** be comment-only (`# Purpose:`); **MUST NOT** dest-write a `*-remove` fragment.

JSON and text **MUST** list the same argv set. A text file with extra OS-tool lines is **not** a dual of the JSON that dest accepted.

### 2.2 Re-encode / convert fidelity

Pretty-printed JSON and compact JSON are **the same grant**.

1. Decode / convert / re-encode **MUST** preserve every `commands[]` object (`path`, `args`, `runas`, `tags`).  
2. **MUST NOT** silently drop objects so `purpose` still lists verbs that `commands` lost.  
3. `sudoers-to-json` / `json-to-sudoers` **MUST** round-trip User + Cmnds. Extra comments/whitespace besides Purpose are not preserved. JSON whitespace inside `commands[]` is not semantics.

### 2.3 visudo-legal text dual

1. Cmnd **args** that contain sudoers-special characters (`:`, `#`, `,`, `\`) **MUST** be backslash-escaped (`user\:group`). Escape order **MUST** be: backslash first, then `:`, `#`, `,`. Round-trip unescape **MUST** restore the JSON arg (`"alice:ops"`).  
2. A trailing sudoers `*` operand **MUST NOT** be expanded as a shell glob. Render and parse **MUST** `set -f` while splitting args. JSON `"*"` stays a quoted string.  
3. Parse of a `NOPASSWD:` line **MUST** split after `NOPASSWD:` — **MUST NOT** split on the last colon.  
4. **MUST** run `visudo -cf` on a **private** `mktemp` copy (never in-place `/etc/sudoers` or `/etc/sudoers.d`) at `json-to-sudoers` (except comment-only remove), `sudoers-to-json` (re-rendered text), Type 0 submit add/update (before queue), and Type 1 dest-write add/update (after human yes).  
5. Comment-only remove **MUST** skip visudo. JSON is **never** fed to visudo (**PREV-JSON-VISUDO**).  
6. If `visudo` is **not** on `PATH`, skip `-cf` (debug). **MUST NOT** invent a substitute “host validation” checker. Tests that prove visudo-legal text **MUST** assume `visudo` is present.

### 2.4 Operator-readable visudo-fail

If visudo rejects the text: fail closed, machine code `visudo_fail`. Printer stays `out_die` (`requirement-shell-output-requirements`). Copy **MUST** fill:

| Slot | This product |
|------|----------------|
| **What happened** | **`visudo rejected this grant`**. Quote visudo’s syntax line when present (`visudo said: N:M: syntax error`). |
| **What it means** | The sudoers file would be illegal. Do not approve it. |
| **What to do next** | `Next:` `json-to-sudoers --file …` until visudo accepts it. |
| **Do not** | Do not approve. Do not say “host validation” or “host sudoers checker”. |

JSON `message` **MUST** be the same sentence. **MUST NOT** dest-write. **MUST NOT** queue.

### 2.5 Dest path / peers

1. **MUST NOT** write `/etc/passwd` or the main `/etc/sudoers` file. Type 0 convert/submit **MUST NOT** write `/etc/sudoers.d`. Type 1 dest is `/etc/sudoers.d/{{service}}-{{username}}` only after visudo Pass **and** a human yes.  
2. **MUST NOT** fold this law into `requirement-incorrect-json-format` or `requirement-well-known-sudoer-binary-fence`. F6 Table A emit/install visudo **MUST** stay on `requirement-three-layer-privilege-model`.  
3. Domain SSOT **MUST** still print the canonical line, worked samples, and convert verbs, and **point here**.

### 2.6 Implementation Notes (this product)

| Field | Value |
|-------|--------|
| Render | `sr_render_sudoers` |
| Escape / unescape | `sr_sudoers_escape_arg` · `sr_sudoers_unescape_arg` |
| visudo helper | `sr_visudo_text` (`visudo -cf` on `mktemp`; strip temp path from visudo’s first syntax line) |
| Parse | `sr_parse_sudoers` (split after `NOPASSWD:`; `set -f`) |
| Convert | `sr_json_to_sudoers` · `sr_sudoers_to_json` |
| Submit / dest | `sr_submit` add/update visudo before queue; `sr_approve` visudo before dest-write |
| Typical machine code | `visudo_fail` |
| Display | Operator `[ERROR]` in people/folder words; JSON `message` same sentence |
| Worked escape | `--ownership alice:ops` → sudoers `alice\:ops` → JSON `"alice:ops"` |
| Worked star | `--ownership *` stays `*` (not a glob) |
| visudo skip | `command -v visudo` missing → skip `-cf` |
| Command identity | Sibling service-catalog Cmnds (not `/usr/local/bin/sudoer-cli` only). F6 Table A stays three-layer |
| **login-hook-elev path** | Convert / dest-write **MUST** emit `/usr/local/bin/sudoer-review-hook`. Helper: `sr_rewrite_login_hook_elev_cmds` |
| Operator-readable slots | visudo-fail: happened / means / Next json-to-sudoers; JSON `message` same sentence |

### 2.x Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: visudo before queue and before dest copy under `/etc/sudoers.d/`.  
- **CIAO Principle 2 – Intentional**: one file owns grant text, escape, and visudo copy.  
- **CIAO Principle 5 – Single Source of Output**: visudo fail names visudo, not a fake host checker.  
- **CIAO Principle 21 – Dual policies**: not a dest Fence; convert/submit/dest-write share the same check.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Illegal sudoers text never reaches `/etc/sudoers.d`.  
- **Intentional**: Escape is for visudo syntax (`:` is not a Runas splitter in args).  
- **Anti-fragile**: Convert, submit, and dest-write run the same visudo helper.  
- **Over-protect**: Unescaped colon is proven illegal (`visudo -cf` fail) so convert **MUST** escape.

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Fold this into a dest Fence, or dest-drain inbound solely because visudo failed.  
2. Feed request JSON to `visudo` without materializing sudoers text.  
3. Emit Cmnd args with raw `:`, `#`, or `,` (unescaped `user:group` is illegal sudoers).  
4. Expand a trailing `*` as a shell glob when rendering or parsing.  
5. Split a NOPASSWD Cmnd on the **last** colon (that breaks `\:` in args).  
6. Say “host validation” or “host sudoers checker” when visudo rejects.  
7. Dest-write `/etc/sudoers.d` or queue add/update when visudo rejects.  
8. Delete the domain SSOT pointer, or move F6 Table A visudo into this file.  
9. Write `/etc/passwd` or the main `/etc/sudoers` file.  
10. Claim dest inbound grants must be `/usr/local/bin/sudoer-cli` only.  
11. Give JSON a different visudo-fail story than the human `[ERROR]` line.  
12. Dest-write or convert a `login-hook-elev` grant that still names `{{APP_NAME}}-hook` or the sibling product binary instead of `/usr/local/bin/sudoer-review-hook`.

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-SR-03** | `tests/test_domain_sr.sh` | have | sudoers ↔ JSON; visudo private copy |
| **TP-SR-07** | `tests/test_domain_sr.sh` | have | add sample JSON → canonical sudoers lines |
| **TP-SR-08** | `tests/test_domain_sr.sh` | have | remove sample JSON → `# Purpose:` only (skip visudo) |
| **TP-SR-09** | `tests/test_domain_sr.sh` | have | add sample sudoers → JSON |
| **TP-SR-19** | `tests/test_domain_sr.sh` | have | json-to-sudoers `--ownership user:group` → `user\:group`; visudo -cf Pass; unescaped control fails visudo; round-trip JSON has `alice:ops` (portable visudo-legal colon) |
| **TP-SR-20** | `tests/test_domain_sr.sh` | have | json-to-sudoers `--ownership *` keeps star operand; visudo -cf Pass (portable visudo-legal star) |
| **TP-SR-21** | `tests/test_domain_sr.sh` | have | visudo reject says “visudo rejected”; quotes syntax; Next json-to-sudoers; no “host validation” (operator-readable visudo-fail) |
| **TP-SR-HOOK-08** | `tests/test_domain_sr.sh` | have | `json-to-sudoers` of `kind=login-hook-elev` emits `/usr/local/bin/sudoer-review-hook` even when inbound JSON still names the sibling product binary |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `requirement-domain-sudoer-approval.md` | Convert/submit/dest catalog; canonical line + samples; **points here** |
| `requirement-three-layer-privilege-model.md` | F6 Table A visudo (JOB-VISUDO); Type 1 dest path; F6 grants `sudoer-review-hook` |
| `requirement-login-interactive-review-hook.md` | Live doorbell name `sudoer-review-hook` |
| `requirement-incorrect-json-format.md` | JSON-format Fence (not this file) |
| `requirement-well-known-sudoer-binary-fence.md` | Cmnd **path** trust (not arg escape) |
| `requirement-privilege-prevention-set.md` | **PREV-JSON-VISUDO** |
| `requirement-shell-temp-file-system.md` | `mktemp` visudo leaves |
| `requirement-shell-cli-interface` | Dual mention of convert verbs |
| `requirement-shell-output-requirements` | Printer `out_die`; operator-readable fatal slots |
| `src/sudoer-cli` | Ship unit |

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-26 | Active 1.0.0 | Independent REQ: grant sudoers text dual, Cmnd arg escape (`\:`), visudo -cf, visudo-fail copy. Extracted from domain **2.32.0** body. **TP-SR-19..21**. |
| 2026-08-26 | Active 1.1.0 | Aligned to portable sudoer-file text dual: stay-honest sibling grants (not own-binary-only); re-encode fidelity; visudo-legal; operator-readable visudo-fail slots. |
| 2026-09-13 | Active 1.3.0 | `login-hook-elev` convert / dest-write **MUST** emit `/usr/local/bin/sudoer-review-hook`. Heal old `login-review-hook`. **TP-SR-HOOK-08**. |
| 2026-09-13 | Active 1.2.0 | `login-hook-elev` convert / dest-write **MUST** emit `/usr/local/bin/login-review-hook`. **TP-SR-HOOK-08**. |

**Last Updated**: 2026-09-13  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
