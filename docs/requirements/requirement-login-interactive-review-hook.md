**file**: docs/requirements/requirement-login-interactive-review-hook.md  
**Status**: Active (Version 1.2.0) — shared doorbell `/usr/local/bin/login-review-hook`; skip copy names Next:; sudoers **MUST** grant that name  
**Area**: shell  
**Key**: `requirement-login-interactive-review-hook`  
**id**: RQ-LOGIN-INTERACTIVE-REVIEW-HOOK  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **login-time review hook**: the marker-guarded rc snippet, `.profile` create-if-absent, rc owner, and the **shared doorbell** `{{GLOBAL_BIN}}/login-review-hook` (production `/usr/local/bin/login-review-hook`).

Every similar host-mutating CLI **MUST** reuse **one** doorbell filename on the host: `/usr/local/bin/login-review-hook`. `sudoer-cli` plants that name when it is missing. A sibling such as `dns-cli` **MUST** call the same name; **MUST NOT** plant a second per-app doorbell (`sudoer-cli-hook`, `dns-cli-hook`). If the labeled name already exists, **MUST NOT** overwrite it — a host admin **MAY** retarget that doorbell at another similar program. Type 1 `setup` **MUST** rewrite old rc and F6 that still name `{{APP_NAME}}` or `{{APP_NAME}}-hook`.

The dest review **loop** (fence first, YAML body, one-off yes/no) stays on `requirement-domain-sudoer-approval`. F6 Table A still **prints** the hook Cmnd on `requirement-three-layer-privilege-model` and **points here**. The dedicated account home stays on `requirement-least-privilege-user` and **points here**. The `login-hook-elev` JSON body stays on domain / dest JSON law; `commands[].path` **MUST** be this labeled name.

This-login PATH / profile after user-bin install is **not** this file — `requirement-shell-path-and-shell-support`.

### 1.1 Human-facing

**In one sentence:** After first-time setup, a real terminal login as `sudoer-adm` runs review once, by calling the shared doorbell `/usr/local/bin/login-review-hook`, not the day-to-day binary. If that start fails, the line says why and what to type next.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Stay a normal login. Do not plant this hook in your own `.bashrc`. | `sudoer-cli add-sudoer-request --file request.json` |
| The other role | Host admin already using password `sudo` runs setup; later `sudoer-adm` logs in on a TTY | `sudo sudoer-cli setup` then `ssh sudoer-adm@host` |
| Not this file | Waiting-folder walk, dest Fence, F6 Table A rows, Type map | `requirement-domain-sudoer-approval` · `requirement-incorrect-json-format` · `requirement-three-layer-privilege-model` |

| Includes | Excludes |
|----------|----------|
| `.bashrc` snippet; missing `.profile` sample; rc owner; shared `/usr/local/bin/login-review-hook`; Type 1 `setup` **and** `interactive` **review** of `{{APP_NAME}}-adm` rc: old product-binary **and** old `{{APP_NAME}}-hook` **MUST** become `login-review-hook`; skip copy with Next:; skip scp / no TTY | Dest yes/no; YAML review body; dest-write `/etc/sudoers.d` (sudoers REQ rewrites `login-hook-elev` path); Type 2 switch path; empty argv becoming review; overwriting a retargeted hook name; rewriting rc that already uses `login-review-hook`; planting a second per-app `*-hook` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/usr/local/bin/login-review-hook` | shared doorbell symlink | what `.bashrc` `sudo -n`s |
| `/etc/sudoer-adm/.bashrc` | interactive rc | the marked snippet |
| `src/sudoer-cli` | ship unit | `setup` heal + `lpu_ensure_login_hook_symlink` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First global setup | Create the labeled name if it is missing. Plant the snippet in `sudoer-adm` rc. | `sudo sudoer-cli setup` |
| Log in as the approver | One TTY session starts `interactive` through the labeled name. | `ssh sudoer-adm@host` |
| Review without a login hook | Same verb, already root. | `sudo sudoer-cli interactive` |
| Keep a retargeted doorbell | Existing `/usr/local/bin/login-review-hook` stays. Setup does not clobber it. | (leave the name; do not `ln -sf`) |
| Old `.bashrc` still names the product binary or `sudoer-cli-hook` | Type 1 `setup` or `interactive` reviews `sudoer-adm` rc and replaces that line with `login-review-hook`. | `sudo sudoer-cli setup` · `sudo sudoer-cli interactive` |
| Login review did not start | Passwordless grant for the doorbell is missing. Login continues. | From a host admin: `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 Labeled soft link (portable — sibling apps reuse this pattern)

1. **MUST** name the hook executable **`{{GLOBAL_BIN}}/login-review-hook`**. Production typical: `/usr/local/bin/login-review-hook`. This product’s Config token is `COMMON_LOGIN_HOOK_NAME=login-review-hook`.  
2. **MUST** reuse that **same** doorbell on every similar host-mutating CLI. **MUST NOT** plant a per-app second doorbell (`{{APP_NAME}}-hook`, `dns-cli-hook`). **MUST NOT** invent a third alias.  
3. Type 1 `setup` (and a global place of the ship unit), when `{{GLOBAL_BIN}}/{{APP_NAME}}` exists **and** the common name is **absent**: **MUST** `ln -s` the product binary → `login-review-hook`.  
4. **MUST NOT** overwrite an existing file or symlink (any target). A host admin **MAY** retarget the labeled name at another similar program without rewriting `.bashrc` or the F6 hook line.  
5. The rc snippet and `login-hook-elev` `commands[].path` **MUST** use `login-review-hook`. Type 2 switch grants stay `{{GLOBAL_BIN}}/{{APP_NAME}}`.  
6. Heal **MUST** rewrite an old `sudo -n {{GLOBAL_BIN}}/{{APP_NAME}} {{REVIEW_VERB}}` line **and** an old `{{APP_NAME}}-hook` line to `login-review-hook`.  
7. Test-mode **MUST NOT** write live `/usr/local/bin`. **MUST NOT** copy a live `$GLOBAL_BIN` install-isolation path into emit or the snippet.  
8. F7 / `remove-lpu` **MUST NOT** unlink the global hook name.  
9. F6 Table A and dest-written `login-hook-elev` sudoers **MUST** grant `{{GLOBAL_BIN}}/login-review-hook` (owners: `requirement-three-layer-privilege-model` · `requirement-sudoers-file`). Type 1 `setup` **MUST** rewrite F6 that still names `{{APP_NAME}}-hook`. Convert / dest-write of `kind=login-hook-elev` **MUST** emit that doorbell even when inbound JSON still names the product binary or `*-hook`.

### 2.0a Review old product-binary hook on the dedicated account

Type 1 `setup` **and** dest `interactive` **MUST** review the dedicated approver’s login rc (`{{LPU_HOME}}/.bashrc`, and `.profile` when that file contains the hook).

| Finding | MUST |
|---------|------|
| Rc still `sudo -n`s `{{GLOBAL_BIN}}/{{APP_NAME}} {{REVIEW_VERB}}` (old product-binary hook) | Replace with `{{GLOBAL_BIN}}/login-review-hook {{REVIEW_VERB}}` |
| Rc still `sudo -n`s `{{GLOBAL_BIN}}/{{APP_NAME}}-hook {{REVIEW_VERB}}` (old per-app doorbell) | Replace with `{{GLOBAL_BIN}}/login-review-hook {{REVIEW_VERB}}` |
| Rc already `sudo -n`s `{{GLOBAL_BIN}}/login-review-hook {{REVIEW_VERB}}` | **MUST NOT** rewrite |
| `.profile` sources `.bashrc` and still has the old hook | Strip the profile copy; **MUST NOT** plant a second snippet there |
| Dedicated home missing (tests / not yet created) | No-op |
| Any other user’s rc | **MUST NOT** inspect or write |

Old hosts keep working because F6 still grants the product binary; `interactive` started by that old line **MUST** then replace it so the next login uses the labeled name. **MUST NOT** hang. **MUST NOT** `exit` the login shell. Invocation: `sudo {{APP_NAME}} interactive`.

### 2.1 When this requirement applies

The product **claims** login-time review. If it does not, this file is N/A — **MUST NOT** plant a hook.

### 2.2 Install table

| File | When to write |
|------|----------------|
| Interactive rc (`{{LPU_HOME}}/.bashrc`) | **Always** (create if missing). Plant the hook snippet here. |
| Login rc (`{{LPU_HOME}}/.profile`) | **Check.** **Absent:** create the source-bashrc sample. **Present:** **MUST NOT** overwrite the body. If it already sources `.bashrc`, do not also plant the hook in `.profile`. If it exists and does **not** source `.bashrc`, plant the hook in `.profile` so login still reaches review. |
| Any other user’s rc | **Never** |

**Why `.profile` must exist:** a bash login shell (SSH / console) sources `.profile` and does **not** source `.bashrc` unless `.profile` does so. Create-first home plus `useradd -M` copies **no** `/etc/skel` `.profile`. Without that file, the hook in `.bashrc` **never runs**.

### 2.3 Snippet guards

| Guard | Rule |
|-------|------|
| **Identity** | Run only if `id -un` equals the dedicated approver |
| **Interactive** | `PS1` set, `$-` contains `i`, and `[ -t 0 ]` and `[ -t 1 ]` **in the rc snippet** (rc policy, not the CLI `TTY` SSOT) |
| **scp / CI** | Skip when `SSH_ORIGINAL_COMMAND` is set |
| **Session** | Set the session guard **before** `sudo -n`; a second source is a no-op |
| **Binary** | `sudo -n {{GLOBAL_BIN}}/login-review-hook {{REVIEW_VERB}}`. **MUST NOT** hook `{{USER_BIN}}/{{APP_NAME}}`. **MUST NOT** hook `{{APP_NAME}}-hook`. |
| **`sudo -n` fail** | Warning on stderr that fills **what happened / what it means / Next:** (`requirement-shell-output-requirements`). **Login continues** (do not `exit`). **MUST NOT** print only `interactive hook skipped`. |
| **Idempotent file** | Begin/end markers; do not append twice |
| **Empty argv** | Hook **MUST** call the explicit review verb. Empty argv stays help / install-ensure. |
| **Owner** | After create or rewrite: corresponding-user owner, mode **0644**. Fail closed if `chown` fails when the account exists. **MUST NOT** swallow with `\|\| true`. |
| **Heal HOME** | **MUST NOT** write if `HOME` is `/tmp` or under `/dev/shm`. |
| **F7** | Strip the marker block from **whichever** home rc files contain it. **MUST NOT** unlink the global hook name. |

### 2.4 Review verb (compose, do not fork)

This file **starts** the review verb. Fence first, YAML body, two-space indent, one-off yes/no stay on `requirement-domain-sudoer-approval`. Dual mention of `interactive`: this file **and** `requirement-shell-cli-interface`. Invocation the hook runs: `sudo -n /usr/local/bin/login-review-hook interactive`. Direct operator path: `sudo sudoer-cli interactive`.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **Approver** | `sudoer-adm` |
| **Approver home** | `/etc/sudoer-adm` |
| **Review verb** | `interactive` |
| **Session guard** | `SUDOER_CLI_HOOK_RAN` |
| **Global bin** | `/usr/local/bin` |
| **Product binary** | `/usr/local/bin/sudoer-cli` |
| **Labeled hook** | `/usr/local/bin/login-review-hook` → `/usr/local/bin/sudoer-cli` (create when missing; do not overwrite) |
| **Sibling pattern** | `dns-cli` **MUST** call `/usr/local/bin/login-review-hook`; **MUST NOT** plant `dns-cli-hook` |
| **Markers** | `# BEGIN sudoer-cli login hook` … `# END sudoer-cli login hook` |
| **Rc owner / mode** | `sudoer-adm:sudoer-adm` · `0644` |
| **Helpers** | `lpu_ensure_login_hook_symlink` · `lpu_install_hook` · `lpu_ensure_profile` · `lpu_review_old_login_hook` |
| **Test-mode skip** | `SUDOER_CLI_ALLOW_TEST_ROOTS=1` does not `ln` live `/usr/local/bin` |
| **F6 hook Cmnd** | Table A on `requirement-three-layer-privilege-model` **points here** |
| **Grant kind** | `login-hook-elev` path **MUST** be `/usr/local/bin/login-review-hook` (sudoers emit/dest-write rewrite old product-binary / `*-hook`) |

**Worked snippet** (markers required):

```sh
# BEGIN sudoer-cli login hook
if [ -z "${SUDOER_CLI_HOOK_RAN-}" ] \
  && [ -n "${PS1-}" ] \
  && [ -t 0 ] && [ -t 1 ] \
  && case $- in *i*) true ;; *) false ;; esac \
  && [ "$(id -un)" = "sudoer-adm" ] \
  && [ -z "${SSH_ORIGINAL_COMMAND-}" ]; then
  SUDOER_CLI_HOOK_RAN=1
  export SUDOER_CLI_HOOK_RAN
  if ! sudo -n /usr/local/bin/login-review-hook interactive; then
    printf '%s\n' "sudoer-cli: login review did not start. sudoer-adm cannot run the review command without a password (the passwordless grant is not installed yet)." >&2
    printf '%s\n' "You still have a shell. Next: from a host admin, run: sudo sudoer-cli interactive" >&2
  fi
fi
# END sudoer-cli login hook
```

**Complete `.profile` create sample** (only when the file is absent):

```sh
# BEGIN sudoer-cli profile source-bashrc
# Created so a bash login shell sources interactive rc (hook lives in .bashrc).
if [ -n "${BASH_VERSION:-}" ]; then
    if [ -f "${HOME}/.bashrc" ]; then
        . "${HOME}/.bashrc"
    fi
fi
# END sudoer-cli profile source-bashrc
```

`setup` **MUST** write the snippet (idempotent markers) and create the labeled symlink when missing. F7 **MUST** strip the snippet. Session `SUDOER_CLI_HOOK_RAN` **MUST** prevent a second `interactive` if both login and interactive shells source `.bashrc`.

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: one owner for rc heal + labeled hook name; domain SSOT does not re-own the snippet.  
- **CIAO Principle 5 – SSOT**: `/usr/local/bin/login-review-hook` is the one doorbell sibling CLIs copy.  
- **CIAO Principle 10 – Least privilege**: only that dedicated account’s rc; other users never.  
- **CIAO Principle 16 – Interactive**: no hang on scp / CI; `sudo -n` fail continues login.  
- **CIAO Principle 9 – Type 0/1/2**: empty argv is not review; hook calls an explicit verb after admin privilege.

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows cmd, or the same class (no root login on that shell):

**This requirement:** do not plant a login hook, do not create `/usr/local/bin/login-review-hook`, do not recommend `sudo curl | sh`. Type 1 setup / login-time review stay unused on detect.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution** (Principle 1): skip scp; do not `exit` the login shell; do not overwrite a retargeted name.  
- **Intentional** (Principle 2): labeled name is `login-review-hook`; snippet is complete, not a one-liner.  
- **Anti-fragile** (Principle 3): idempotent markers; missing `.profile` created; heal rewrites the old binary line.  
- **Over-protect** (Principle 4 / Principle 20): test-mode never `ln` live `/usr/local/bin`; F7 does not unlink the doorbell.  
- **16 Interactive**: consume TTY in the CLI; rc has its own `[ -t` guards.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Fold this topic back into the domain SSOT as the only owner of the snippet. Domain **points**.  
2. Hijack empty argv as the review verb.  
3. Overwrite an existing `.profile` body.  
4. Plant the hook in another user’s rc.  
5. Hang scp / CI / non-TTY (`sudo` without `-n`, or `exit` on `sudo -n` fail).  
6. Call `{{GLOBAL_BIN}}/{{APP_NAME}}` or `{{APP_NAME}}-hook` from the snippet instead of `login-review-hook`.  
7. Overwrite an existing hook name, or `ln` the live global hook from test-mode.  
8. Plant a per-app second doorbell (`sudoer-cli-hook`, `dns-cli-hook`) so siblings collect N names.  
9. Unlink `/usr/local/bin/login-review-hook` on F7 / `remove-lpu`.  
10. Leave rc owned by writer euid after `mktemp`+`mv`.  
11. Treat rc heal as the `login-hook-elev` grant, or Type 0 submit as this path.  
12. Copy CI `$GLOBAL_BIN` into emit or the snippet.  
13. Claim this file owns dest yes/no or YAML review display.  
14. After Type 1 `setup` or `interactive`, leave `{{APPROVER}}` rc calling `{{GLOBAL_BIN}}/{{APP_NAME}} {{REVIEW_VERB}}` or `{{APP_NAME}}-hook` instead of `login-review-hook`.  
15. Rewrite rc that already uses `login-review-hook`, or inspect another user’s rc.  
16. Print only `interactive hook skipped` when `sudo -n` fails — the skip line **MUST** say what happened, that login continues, and `Next: sudo {{APP_NAME}} interactive`.  
17. Leave F6 or dest-written `login-hook-elev` sudoers granting `{{APP_NAME}}-hook` after setup / dest-write.

**Violating this rule is a critical login-hook / privilege regression.**

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-domain-sudoer-approval.md` | Review loop; **points** here for the snippet |
| `docs/requirements/requirement-least-privilege-user.md` | Approver home; **points** here for rc |
| `docs/requirements/requirement-three-layer-privilege-model.md` | F6 Table A hook Cmnd; **points** here |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of `setup` / `interactive` |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | No hang; consume `TTY` |
| `docs/requirements/requirement-shell-path-and-shell-support.md` | This-login PATH / profile (not approver rc) |
| `src/sudoer-cli` | `lpu_ensure_login_hook_symlink` · `lpu_install_hook` · `lpu_review_old_login_hook` |

## Design-time verification

| TP family / ID | Suite | Status | Intent |
|----------------|-------|--------|--------|
| **TP-SR-HOOK-01** | `tests/test_domain_sr.sh` | have | `setup` checks `.profile`; missing → create source-bashrc sample |
| **TP-SR-HOOK-02** | `tests/test_domain_sr.sh` | have | Existing `.profile` is not overwritten |
| **TP-SR-HOOK-03** | `tests/test_domain_sr.sh` | have | Created `.profile` sources `.bashrc` (markers) |
| **TP-SR-HOOK-04** | `tests/test_domain_sr.sh` | have | After create/rewrite, hook apply/ensure **chown** the LPU (no swallowed `chown`) |
| **TP-SR-HOOK-05** | `tests/test_domain_sr.sh` | have | Shared doorbell: create `${GLOBAL_BIN}/login-review-hook` when missing; heal rewrites old product-binary **and** old `{{APP_NAME}}-hook`; F6 grants `login-review-hook`; test-mode skips live `/usr/local/bin` |
| **TP-SR-HOOK-06** | `tests/test_domain_sr.sh` | have | Type 1 `interactive` reviews `{{APP_NAME}}-adm` rc: old `{{APP_NAME}} interactive` / `{{APP_NAME}}-hook` **MUST** become `login-review-hook`; already-common rc is not rewritten |
| **TP-SR-HOOK-07** | `tests/test_domain_sr.sh` | have | `sudo -n` fail skip copy: happened + login continues + `Next: sudo {{APP_NAME}} interactive`; **MUST NOT** be only `interactive hook skipped` |
| **TP-SR-HOOK-08** | `tests/test_domain_sr.sh` | have | `json-to-sudoers` of `kind=login-hook-elev` emits `/usr/local/bin/login-review-hook` even when inbound JSON still names the sibling product binary |
| **TP-SR-INT-03** | `tests/test_domain_sr.sh` | have | Hook snippet guards (static) |
| **TP-SR-PRIV-03** | `tests/test_domain_sr.sh` | have | Live setup body includes hook markers (static) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-13 | Active 1.2.0 | Shared doorbell `/usr/local/bin/login-review-hook` (not per-app `{{APP_NAME}}-hook`). Skip copy fills happened / Next:. F6 and `login-hook-elev` sudoers **MUST** grant that name. **TP-SR-HOOK-05..08**. |
| 2026-09-08 | Active 1.1.0 | Type 1 `setup` **and** `interactive` **MUST** review `{{APP_NAME}}-adm` rc and replace an old product-binary hook with `{{APP_NAME}}-hook`. **TP-SR-HOOK-06**. |
| 2026-09-08 | Active 1.0.0 | Split from domain SSOT. Labeled `/usr/local/bin/{{APP_NAME}}-hook` so sibling CLIs reuse the same symlink pattern. **TP-SR-HOOK-01..05**. |

---

**Last Updated**: 2026-09-13  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
