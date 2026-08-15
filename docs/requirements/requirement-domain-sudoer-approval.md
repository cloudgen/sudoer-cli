**file**: docs/requirements/requirement-domain-sudoer-approval.md  
**Status**: Active (Version 2.14.0) — file-based JSON approval; Type 0 submit `/var/{{APP_NAME}}/sudoer-request` (3773); Type 1 dest `/etc/sudoers.d/{{service}}-{{user}}`; `interactive` loop **live** (ids not on stdin)  
**Area**: domain  
**Key**: `requirement-domain-sudoer-approval`  
**id**: RQ-DOMAIN-SUDOER-APPROVAL  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **single current domain SSOT** for sudoers-request approval: the **file-based JSON approval** machine (§2.0), specialized subcommands, request basename, JSON/text conversion, queue-path resolve, help items, and about items.

Privilege types and F6 Cmnds are owned by `requirement-three-layer-privilege-model.md`. LPU identity is owned by `requirement-least-privilege-user.md`. What Type 0 / Type 1 **block** vs what must stay open after elev is owned by `requirement-privilege-prevention-set.md`. Live Type 0 dispatcher catalog is owned by `requirement-shell-cli-interface.md` (lifecycle) **plus** the Type 0 domain verbs in §2.1.

**Routing honesty:** `help` / `about` **MUST NOT** list a verb that has no dispatcher `case` arm. Type 0 convert/submit/list/show/print-sudoers **are routed**. Type 1 names **are routed** and **fail closed** without euid 0. Live `setup` creates the LPU, F6, queues, and login hook. The `sr_interactive` loop body is **live**. About LPU/F6/trust-tier fields remain a **Gap**.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 File-based JSON approval

This product’s approval machine is **file-based JSON approval**. **Folder = state.** **JSON = the checkable grant proposal.** There is no ticket table.

A **normal user** (Type 0) submits a self-scoped request JSON into the inbound queue. The **least-privilege-approver** (`sudoer-adm`) re-checks that JSON and **moves** the file to accepted or declined. Dest writes are Type 1 as root after F6 — the LPU is not a Type 2 execution context.

A **TTY login** as `sudoer-adm` **MUST** be able to enter that approve path **only** via the login hook (`sudo -n` global binary `interactive` — **after F6 exists**) or an explicit Type 1 `interactive` / `approve` / `reject`. Empty argv stays help. Running the CLI as euid `sudoer-adm` without F6 **MUST** fail closed (`authz`). **Bootstrap** (`setup`) is a different gate: any host admin already euid 0 via outer `sudo` (password allowed). Basename, schema, dest, hook, and review-loop rules stay in §2.2. Live `setup` writes LPU + F6 + hook. The review-loop body is **live**.

#### Roles

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Submitter** | Ordinary login (`id -un`), not the approver LPU | **0** | Convert; `add` / `update` / `remove-sudoer-request` **for themselves**; list/show **own** sidecar ids | Submit **for** another user; `approve` / `reject`; write `/etc/passwd` or `/etc/sudoers.d`; choose the dest path |
| **Subject** | Same person as the submitter | — | Appear as filename `username` and JSON `username` | Be a colleague’s login the submitter does not own |
| **Approver** | `sudoer-adm` (least-privilege-approver; subject = sudoers grant / sudoer-file) | **1** (after F6) | `approve` / `reject` / `interactive`; re-check JSON + name; **move** inbound → accepted/declined; on approve add/update, install dest `{{service}}-{{user}}` | File a grant **on behalf of** a human; run day-to-day as Type 2 euid; `ALL=(ALL) ALL` |
| **Allocator** | This CLI’s Type 0 path | **0** | Allocate the request basename; write JSON into inbound `/var/{{APP_NAME}}/sudoer-request/` | Trust a caller-supplied dest basename; skip self-scope |
| **Root session** | euid 0 | **1** (no F6) | Same Type 1 verbs as approver | Submit a body whose subject is someone else (self-scope: root files **as root** only) |

#### When a normal user may submit

Type 0 submit is allowed **only when all** hold:

1. Invoker is a login user (not required to be `sudoer-adm`).  
2. **Self-scope:** filename `username`, JSON `username` (if present), file owner, and `id -un` are the **same** person. On-behalf-of → fail closed.  
3. The request encodes **one** service (inferred family **or** explicit product name such as `folder-backup`). Mixed inferred families → reject.  
4. Inbound is writable (default `/var/{{APP_NAME}}/sudoer-request` mode **3773**, or an explicit queue override). The CLI **allocates** the name.  
5. Input is request JSON, or sudoers text the CLI converts first.  
6. **Remove** is purpose-only JSON (no `commands`).

**Not a submit situation:** a grant for a colleague; wanting dest written immediately; running `approve` as a normal user (Type 1 fail-closed).

#### How JSON is verified

The queued file is the **evidence**. Approvers do **not** trust a world-writable drop at face value. Checks at submit **and again at approve**:

| Check | What JSON (and name) must satisfy |
|-------|-----------------------------------|
| **Closed schema** | `schema_version` 1 on add/update; unknown keys → `invalid_json` |
| **Identity match** | Basename `username` / `service` / `action` **win**. Body fields if present **must match** (`field_mismatch`) |
| **Self-scope** | Subject = invoker at submit; at approve, owner still matches the subject |
| **Purpose** | Required. Remove = **purpose only** (`remove_extra_fields` if `commands` present) |
| **Commands** | Absolute paths; no `ALL`; no `#include` / `Defaults`; service infer agrees with `service` |
| **visudo** | Render JSON → private sudoers text, then `visudo -cf` (skip comment-only remove). Never feed JSON to visudo |
| **Dest** | Approve add/update → `/etc/sudoers.d/{{service}}-{{username}}` from the **name**, never `*-remove` |
| **Re-validate** | Approve **re-runs** these checks. A tampered inbound file fails then, not at dest write |

CLI `--json` is **status** only (`out_json`). It is **not** the request file.

### 2.1 Specialized CLI subcommands (pillar 1)

Every domain verb **MUST** have exactly one privilege type. Type 0 never writes `/etc/passwd` or `/etc/sudoers.d`. Type 1 dest is `/etc/sudoers.d/{{service}}-{{username}}` (copy / overwrite / remove product-owned names only). Type 1 host mutation needs euid 0. **Bootstrap** (`setup`) is any host admin (password `sudo` OK — mix model). **Approve** is F6 `sudoer-adm` or a real root session.

| Verb | Type | Handler family | Operands / flags | Required behavior |
|------|------|----------------|------------------|-------------------|
| `sudoers-to-json` | 0 | `sr_sudoers_to_json` | stdin **xor** `--file PATH`; `--action add\|update`; `--purpose TEXT`; `--service NAME` optional; `--out PATH` optional | Convert a sudoers text fragment to request JSON. Infer service from Cmnds. Never queue. Never `/etc/passwd` or `/etc/sudoers.d`. `visudo -cf` the input first. |
| `json-to-sudoers` | 0 | `sr_json_to_sudoers` | stdin **xor** `--file PATH`; `--out PATH` optional | Convert request JSON to sudoers text. `remove` → `# Purpose:` comments only. `visudo -cf` the output except comment-only remove. Never queue. Never `/etc/passwd` or `/etc/sudoers.d`. |
| `print-sudoers` | 0 | `sr_print_sudoers` | stdout or draft path | Emit **Table A only** (F6 fragment). Never write `/etc/passwd` or `/etc/sudoers.d`. |
| `print-sudoers-install-script` | 0 | `sr_print_sudoers_install_script` | — | Emit admin script under volatile storage. |
| `setup` | 1 | `lpu_setup` | — | Create LPU + default queues + F6 + login hook. Fail closed on UID collision / missing global binary for production F6. |
| `setup --uninstall` / `remove-lpu` | 1 | `lpu_remove` | `--force`, `--purge-queues` | F7. Confirm on TTY unless `--force`. |
| `add-sudoer-request` | 0 | `sr_submit add` | stdin **xor** `--file PATH`; `--purpose` if text lacks `# Purpose:` | Accept JSON **or** sudoers text (first non-whitespace `{` vs `#`/spec). Allocate basename; write JSON into request queue; **print `request_id`**. |
| `update-sudoer-request` | 0 | `sr_submit update` | same | same with action `update` |
| `remove-sudoer-request` | 0 | `sr_submit remove` | `--service` required; `--purpose` **xor** `--file` (purpose-only JSON) | Queue purpose-only JSON. |
| `list-approving` / `list-approved` / `list-rejected` | 0 | `sr_list` | optional `--user` | Type 0: sidecar only. Type 1/root may readdir. |
| `list-approving --orphans` | 1 | `sr_list_orphans` | — | owner≠username or non-regular. |
| `show <request-id>` | 0 | `sr_show` | full basename **with** `.json` | Purpose + body for a known id. |
| `approve <request-id>` | 1 | `sr_approve` | full basename **with** `.json` | Re-validate; install or delete dest. |
| `reject <request-id>` | 1 | `sr_reject` | same | Re-validate; move to rejected. |
| `interactive` | 1 | `sr_interactive` | TTY (`TTY=1`); no operand | Review loop (§2.2). Consume `TTY`. Non-TTY / `--json` → `confirm_required`. Empty argv is **not** this verb. |

**Global domain flags** (parsed in `app_main`; `help` **MUST** list them now that Type 0 domain is routed):

| Flag | Env | Role |
|------|-----|------|
| `--request-dir DIR` | `SUDOER_CLI_REQUEST_DIR` | Override inbound queue |
| `--approved-dir DIR` | `SUDOER_CLI_APPROVED_DIR` | Override accepted archive |
| `--rejected-dir DIR` | `SUDOER_CLI_REJECTED_DIR` | Override declined archive |
| `--queue-root DIR` | `SUDOER_CLI_QUEUE_ROOT` | Set the public trio as `DIR/sudoer-request`, `DIR/sudoer-approved`, `DIR/sudoer-rejected` |

**Error codes (machine JSON `error` / `code`):** `invalid_name`, `self_scope`, `visudo_fail`, `not_regular`, `owner_mismatch`, `authz`, `not_found`, `already_done`, `confirm_required`, `xor_input`, `invalid_json`, `unknown_service`, `schema_version`, `field_mismatch`, `remove_extra_fields`.

**Routing:** `app_main` **MUST** dispatch every **live** row. Unrouted target rows stay out of `help`. Conversion verbs **MAY** be routed independently of setup/approve (local file transform).

**Host-mutating (CL-HOST-MUTATING-DOMAIN):** `setup`, `setup --uninstall` / `remove-lpu`, `approve`, `reject`, `interactive`, and `list-approving --orphans` **MUST** fail closed with **no partial host write** unless euid is 0 and authorization matches §2.1. Convert, submit, list, show, print-sudoers, and print-sudoers-install-script **MUST NOT** write `/etc/passwd` or `/etc/sudoers.d`, and **MUST NOT** create LPU accounts. Type 1 dest is `/etc/sudoers.d/{{service}}-{{username}}` (copy / overwrite / remove). Privilege actor is **EM-HYB** (mix: password `sudo` for bootstrap; F6 NOPASSWD for day-to-day approve), owned by `requirement-three-layer-privilege-model.md`. Do **not** invent extra blocks — `requirement-privilege-prevention-set.md`.

#### Type 1 authorization

**Bootstrap** (`setup` / `setup --uninstall` / `remove-lpu`) — first-time host work. F6 does not exist. Install is **multi-user**.

| Invoker | euid | `SUDO_USER` | Result |
|---------|------|-------------|--------|
| any host admin via outer `sudo {{APP}} setup` (password OK) | 0 | that admin (not necessarily `sudoer-adm`) | **allow** bootstrap |
| root login | 0 | empty | **allow** bootstrap |
| any user, no sudo | not 0 | empty | **fail** `authz` (tell them `sudo {{APP}} setup`) |
| `sudo -n {{APP}} setup` without a NOPASSWD grant | not 0 or fails before exec | — | **must not** be the documented path |

**Mix model:** the ship unit **MAY** invoke password `sudo`. **`sudo -n` is not suggested** for bootstrap. Usual path: the human runs `sudo {{APP}} setup`.

**Approve** (`approve` / `reject` / `interactive`) — after F6 exists.

| Invoker | euid | `SUDO_USER` | TTY | Result |
|---------|------|-------------|-----|--------|
| `sudoer-adm` without `sudo` | not 0 | empty | any | **fail** `authz` |
| `sudo` or `sudo -n` as `sudoer-adm` (F6) | 0 | `sudoer-adm` | `TTY=1` | **allow** `interactive` / `approve` / `reject` |
| `sudo` or `sudo -n` as `sudoer-adm` | 0 | `sudoer-adm` | `TTY=0` or `JSON=1` | `interactive` **fail** `confirm_required`; `approve`/`reject` **MAY** run (no prompt) |
| root login | 0 | empty | as above | **allow** (same TTY rule for `interactive`) |
| any other `SUDO_USER` | 0 | not `sudoer-adm` | any | **fail** `authz` on **approve** verbs (bootstrap still allowed) |

`--force` **MUST NOT** skip Type 1 authz and **MUST NOT** auto-approve in `interactive`.

The login hook **MAY** use `sudo -n` **only** because F6 is NOPASSWD and `.bashrc` must not hang. That is **not** the setup elev.

### 2.2 Specialized features (pillar 2)

#### Request basename (allocator-owned)

```text
sudoer-{{yyyyMMdd}}-{{service-name}}-{{username}}-{{add|update|remove}}-{{n}}.json
```

| Part | Rule |
|------|------|
| prefix | literal `sudoer-` |
| `yyyyMMdd` | host local `date +%Y%m%d` (not UTC) |
| `service-name` | `^[a-z][a-z0-9-]{0,31}$`; inferred from Cmnds **or** explicit `--service` / JSON `service` (hyphenated product names allowed, e.g. `folder-backup`) |
| `username` | `id -un`; **MUST** match `^[a-z_][a-z0-9_-]*$` |
| action | `add` \| `update` \| `remove` |
| `n` | 1-based, no leading zeros, cap 999, over **approving ∪ approved ∪ rejected** for same date+service+username+action |
| suffix | literal `.json` |

`request_id` **is** that full basename (prefix **and** suffix). Allocator **MUST NOT** take a caller-supplied dest basename.

#### Request JSON (queued body)

Closed `schema_version` **1**. POSIX `/bin/sh` codec (`util_json_escape` + constrained decoder). No `jq` required.

**add / update — required:** `schema_version`, `purpose`, `username`, `service`, `action`, non-empty `commands[]`.  
Each command: absolute `path`; `args` string array; `runas` default `root`; `tags` v1 `NOPASSWD` only.

**remove — required: `purpose` only.** Optional `schema_version` / `username` / `service` / `action`=`remove` must match the basename. `commands` or any unknown key → `remove_extra_fields`.

Unknown keys anywhere → `invalid_json`. Filename identity wins; body fields if present **MUST** match (`field_mismatch`).

`--json` CLI status (`out_json`) is **not** the request file.

**Worked sample basename:** `sudoer-20260814-folder-backup-leolio-add-1.json`  
**Worked dest:** `/etc/sudoers.d/folder-backup-leolio`

**add / update sample body:**

```json
{
  "schema_version": 1,
  "purpose": "Allow this user to reload nginx and read the nginx unit journal.",
  "username": "alice",
  "service": "webservice",
  "action": "add",
  "commands": [
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/bin/systemctl",
      "args": ["reload", "nginx"]
    },
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/usr/bin/journalctl",
      "args": ["-u", "nginx"]
    },
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/usr/sbin/nginx",
      "args": ["-t"]
    }
  ]
}
```

**remove sample body** (purpose only):

```json
{
  "purpose": "Revoke my webservice sudoers grant; I no longer operate nginx."
}
```

#### Text dual (conversion)

A sudoers text fragment is `# Purpose:` plus self-scoped spec lines (add/update) or comment-only (remove). `sudoers-to-json` / `json-to-sudoers` round-trip User + Cmnds. Extra comments/whitespace besides Purpose are not preserved.

Canonical rendered line:

```text
{{username}} ALL=({{runas}}) {{tags:}} {{path}} {{args…}}
```

**Paired text dual** for the add sample above:

```text
# Purpose: Allow this user to reload nginx and read the nginx unit journal.
alice ALL=(root) NOPASSWD: /bin/systemctl reload nginx
alice ALL=(root) NOPASSWD: /usr/bin/journalctl -u nginx
alice ALL=(root) NOPASSWD: /usr/sbin/nginx -t
```

**Paired text dual** for the remove sample:

```text
# Purpose: Revoke my webservice sudoers grant; I no longer operate nginx.
```

`visudo -cf` on a **private materialized sudoers copy** at convert, submit, and approve/reject. JSON is never fed to visudo.

Reject: User `ALL`, Cmnd `ALL`, other usernames, `#include`, `Defaults`, aliases.

#### Service catalog v1

| service | Infer when every Cmnd fits this family |
|---------|----------------------------------------|
| `webservice` | `/usr/sbin/nginx` (`-t` only); `systemctl` `{start,stop,reload,restart,status}` `nginx`; `journalctl -u nginx` (optional `--no-pager`). `systemctl`/`journalctl` may be `/bin` or `/usr/bin`. |
| `gitlab` | absolute `gitlab-ctl` `{status,reconfigure,restart,start,stop,tail}`; `journalctl -u gitlab-*` with unit `^gitlab-[a-z0-9@._-]+$` |

All Cmnds must map to the **same** service. Mixed or unknown → `unknown_service`. `--service` may pin but **MUST NOT** widen the catalog. New services require a revision of this requirement.

#### Self-scope

Filename username, file owner login, and every body User spec **MUST** be equal. On-behalf-of **MUST** fail at submit and again at approve.

#### Queue path resolve

One helper (`sr_resolve_queues`) runs once per invocation. Precedence:

1. `--request-dir` / `--approved-dir` / `--rejected-dir` (or matching env)  
2. `--queue-root` / `SUDOER_CLI_QUEUE_ROOT` (public root; children `sudoer-request` / `sudoer-approved` / `sudoer-rejected`)  
3. Default **public** root `/var/{{APP_NAME}}/` (Type 0 submit dest). Live LPU home (passwd field 6) holds **F4 views** of the same names.

| Check | Rule |
|-------|------|
| Public path | **Absolute**; last component of the **real** public dir **MUST NOT** be a symlink |
| Approver view | `${LPU_HOME}/sudoer-request` (and approved/rejected) **MUST** be symlinks to the public real dirs (unless a queue override is set) |
| Distinct | Three resolved **real** paths **MUST** differ |
| Production override | Paths other than LPU F5 **MUST** have `SUDOER_CLI_ALLOW_TEST_ROOTS=1` **or** have been created by Type 1 `setup` |
| Type 0 | **MUST NOT** `mkdir` the trio; missing dir fails closed |
| Sequence | `n` walks **all three** resolved **real** dirs |

Default modes (when `setup` creates them): public root **0755** `sudoer-adm:sudoer-adm`; inbound **`/var/{{APP_NAME}}/sudoer-request` 3773** (sticky+setgid; other `-wx`, no other-r); accepted/declined **0700**. Submit creates a file owned by the submitter and **MUST** `chmod 0640` it. Type 1 approve/reject **MUST** `stat` the inbound owner **before** any `chown` and **MUST** fail `owner_mismatch` unless that owner equals the filename subject. Dest install and the archive **MUST** use a **private snapshot** of that file; **MUST NOT** `mv` the inbound path after validate (unlink the inbound name after placing the snapshot). The archived file **MUST** be `sudoer-adm:sudoer-adm` mode `0640`. Exclusive create. Do **not** `mv` over an existing dest.

**Hostile dropbox (approve/reject):** copy inode under Type 1 lock; require regular file (`[ -f ] && ! [ -L ]`); re-run validators on the private copy; dest basename derived **only** from validated username+service.

**Name squat:** predictable occupancy of `…-1..999` is an **accepted v1 DoS**. Mitigation: Type 1 `list-approving --orphans` + operator cleanup.

#### Installed dest transform

One live grant **per (user, service)**.

| Request | Live dest |
|---------|-----------|
| `…-{{service}}-{{username}}-add-{{n}}.json` | copy/overwrite `/etc/sudoers.d/{{service}}-{{username}}`; backup previous same dest |
| `…-{{service}}-{{username}}-update-{{n}}.json` | overwrite `/etc/sudoers.d/{{service}}-{{username}}`; backup previous |
| `…-{{service}}-{{username}}-remove-{{n}}.json` | remove `/etc/sudoers.d/{{service}}-{{username}}` only; **never** install `*-remove` |

Type 1 **MAY** copy, overwrite, and remove **product-owned** names under `/etc/sudoers.d/`. Type 0 **MUST NOT**. **MUST NOT** write `/etc/passwd` or `/etc/sudoers`. Backup previous dest under `/etc/sudoers.bak/`. Foreign sudoers.d files stay.

#### Enumeration

Type 0 list/show **MUST** use a per-user sidecar `${XDG_STATE_HOME:-$HOME/.local/state}/{{APP_NAME}}/submitted.ids` (mode 0600), updated only by the CLI on successful submit. Submit **MUST** print `request_id` (human + `--json`). `show` requires a known id.

#### Login hook

`setup` **MUST** install an idempotent, marker-guarded snippet so a **TTY login** as `sudoer-adm` starts Type 1 `interactive` **once** per session. The hook **MUST NOT** hang `scp`, CI, or non-TTY sessions. Empty argv stays help.

| File | When to write |
|------|----------------|
| `${LPU_HOME}/.bashrc` | **Always** (create if missing). Create-default home is `/etc/sudoer-adm`. |
| `${LPU_HOME}/.profile` | **Only if** it exists **and** does **not** source `.bashrc`. Uncertain → **skip** |
| Any other user’s rc | **Never** |

| Guard | Rule |
|-------|------|
| **Identity** | Run only if `id -un` is `sudoer-adm` |
| **Interactive** | Require `PS1` set, `$-` contains `i`, and `[ -t 0 ]` and `[ -t 1 ]` **in the rc snippet** (this is rc policy, not the CLI `TTY` SSOT) |
| **scp / CI** | Skip when `SSH_ORIGINAL_COMMAND` is set |
| **Session** | Set `SUDOER_CLI_HOOK_RAN=1` **before** `sudo -n`; a second source is a no-op |
| **Binary** | `sudo -n /usr/local/bin/sudoer-cli interactive` only (production F6 / Table A). **MUST NOT** hook `~/.local/bin/sudoer-cli` |
| **`sudo -n` fail** | Print a **warning** on stderr; **login continues** (do not `exit`) |
| **Idempotent file** | Begin/end markers; do not append twice |
| **Heal** | If `.profile` sources `.bashrc` and still has the marker, strip the `.profile` copy |
| **F7** | Strip the marker block from **whichever** home rc files contain it |

**Worked snippet** (markers required; product values filled):

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
  sudo -n /usr/local/bin/sudoer-cli interactive \
    || printf '%s\n' "sudoer-cli: interactive hook skipped" >&2
fi
# END sudoer-cli login hook
```

`setup` **MUST** write this snippet (idempotent markers). F7 **MUST** strip it.

#### Interactive review loop

`sr_interactive` **MUST**:

1. Use the same Type 1 authorization as `approve` / `reject`.  
2. **Consume** `TTY` / `JSON` / `QUIET` (no live `[ -t` inside the handler as the policy gate). If `TTY` is not `1`, or `JSON=1`, **fail closed** `confirm_required` — no hang.  
3. Prompt only through `prompt_*`. **MUST NOT** ad-hoc `read`. `--force` **MUST NOT** auto-approve. The id walk **MUST NOT** redirect stdin over those prompts (`prompt_yes_no` reads fd 0). Walk ids on another fd.  
4. Resolve queues once. Type 1 **MAY** readdir inbound. Consider only regular, non-symlink files whose basename matches the request grammar.  
5. Empty inbound → human note (or JSON success) and exit **0**. Do not hang.  
6. For each pending id (basename sort): show purpose + body (same contract as `show`); prompt **approve** / **reject** / **skip** / **quit**.  
7. **approve** / **reject** **MUST** run the same re-validate + dest/move as the standalone verbs. **skip** continues. **quit** exits 0; remaining files stay inbound.  
8. A validate failure on one id **MUST NOT** abort the rest; emit the error and continue.  
9. Empty argv **MUST NOT** reach this handler.

The handler is **live**. Non-TTY / `--json` / `--quiet` fail closed `confirm_required`. `--force` does **not** auto-approve (each id uses `prompt_yes_no`, default no).

#### Warnings (not hard reject)

`sr_validate_body` / interactive **SHOULD** warn when a self-scoped Cmnd is a shell, `sudo`, `visudo`, or writes `/etc/passwd` / `/etc/sudoers.d`. Approver still decides.

### 2.3 Specialized project help items (pillar 3)

`help` **MUST** list Type 0 lifecycle **and** the live domain rows (conversion, submit, list, show, print-sudoers, and Type 1 notes for setup/approve/interactive). Examples **MUST** include `sudoers-to-json`, `add-sudoer-request`, and a list/show pair.

Empty argv remains **Type N help** for every uid. `interactive` is never implied by empty argv.

### 2.4 Specialized project about items (pillar 4)

`about` **MUST** include Type 0 diagnostics **and** **resolved** queue paths (request / approved / rejected).

**Gap (not yet in about):** LPU username/uid/home present?, F6 present?, global-binary trust tier (production vs test_local). Do **not** invent those fields until implemented. Do **not** emit fake LPU identity.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `sudoer-cli` |
| **Approval machine** | File-based JSON approval: folder = state; JSON = proposal |
| **Domain prefix** | `sr_` (requests) + `lpu_` (setup/teardown) |
| **LPU home (default / create)** | `/etc/sudoer-adm` (preferred-/etc). Queue views use **live** passwd home. |
| **Public queue root** | `/var/{{APP_NAME}}` (0755 `sudoer-adm:sudoer-adm`) |
| **Default submit dest** | `/var/{{APP_NAME}}/sudoer-request` (3773; files 0640) |
| **Default archives** | `/var/{{APP_NAME}}/sudoer-approved` (0700), `/var/{{APP_NAME}}/sudoer-rejected` (0700) |
| **Approver views (F4)** | `${LPU_HOME}/sudoer-request` → public request; same for approved/rejected |
| **Sidecar** | `~/.local/state/sudoer-cli/submitted.ids` |
| **Worked basename** | `sudoer-20260814-folder-backup-leolio-add-1.json` |
| **Worked dest** | `/etc/sudoers.d/folder-backup-leolio` |
| **Hook marker** | `# BEGIN sudoer-cli login hook` … `# END sudoer-cli login hook` |
| **Hook env** | `SUDOER_CLI_HOOK_RAN` |
| **Hook command** | `sudo -n /usr/local/bin/sudoer-cli interactive` |
| **Routed now** | Type 0 convert/submit/list/show/print-sudoers; Type 1 `setup`/`remove-lpu`/`approve`/`reject`/`interactive` live |
| **Gap** | about LPU/F6/trust-tier fields (queue paths are already in `about`) |
| **Queue overrides** | `--queue-root` / per-dir flags. Fake `SUDOER_CLI_GRANT_ROOT` for dest tests. `setup` always `useradd` when euid 0. There is no `LIVE_LPU` flag and no Gap on create. |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: one domain SSOT for the named machine plus four pillars.  
- **CIAO Principle 9 – Three Types of Commands**: submit/convert is Type 0; approve is Type 1.  
- **CIAO Principle 10 – Least-Privilege User**: `sudoer-adm` verifies JSON and moves the file; normal users only submit.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: no hang; hook is explicit `interactive`.  
- **CIAO Principle 1 – Caution**: visudo + hostile-queue re-validate.  
- **CIAO Principle 5 – Single Source of Output**: request JSON ≠ `--json` status.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: never trust the live inode after a world-writable drop.  
- **Intentional**: the named machine (folder = state, JSON = proposal), basename, schema, and dest transform are normative.  
- **Anti-fragile**: sidecar list works without readdir; conversion works without queues.  
- **Over-protect**: help does not advertise unrouted verbs.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Leave two Active `requirement-domain-*` files.  
2. Put domain verb law only in a `requirement-shell-*` file.  
3. List unrouted verbs in `help`.  
4. Change empty argv to `interactive`.  
5. Skip approve-time re-validation.  
6. Install a `{{user}}-remove` or `{{service}}-{{user}}-remove` fragment.  
7. Allow on-behalf-of submit.  
8. Claim Type 1 host mutation complete while `setup` / `approve` / `interactive` is a stub.  
9. Drop prefix `sudoer-` or suffix `.json` from `request_id`.  
10. Accept extra fields on remove JSON.  
11. Feed JSON to `visudo` without materializing sudoers text.  
12. `cd` into a queue directory instead of resolving absolute paths.  
13. Let Type 0 `mkdir` or point production queues at non-F5 paths without the test gate.  
14. Replace this file-based JSON approval machine with a ticket table, mail queue, or database without revising this requirement.  
15. Collapse submitter and approver into one role.  
16. Let a TTY login as `sudoer-adm` imply empty-argv `interactive`.  
17. Hang login or `scp` from the hook (`sudo` without `-n`, or `exit` on hook failure).  
18. Hook `~/.local/bin/sudoer-cli` or any non-Table-A binary as the review launcher.  
19. Ship `interactive` without consuming `TTY` (prompt or hang when `TTY` is not 1).  
20. Invent a second lock after password `sudo` / root login, a live-command whitelist the user did not publish, or a Gap stub on live `setup` (`requirement-privilege-prevention-set.md`).  
21. Walk inbound ids with `while read … done <file` (or any stdin redirect) so `prompt_yes_no` hits EOF and auto-skips.

**Violating this rule is a critical domain-SSOT / privilege regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Type map + Tables A/B/C |
| `docs/requirements/requirement-privilege-prevention-set.md` | Closed catalog of what is blocked vs must stay open |
| `docs/requirements/requirement-least-privilege-user.md` | F1–F7 |
| `docs/requirements/requirement-shell-cli-interface.md` | Live dispatcher catalog |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Type N |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` / `--json` |
| `docs/requirements/requirement-shell-temp-file-system.md` | Convert/approve scratch leaves |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | `TTY` SSOT; hook must not hang |
| `docs/requirements/requirement-shell-prompt.md` | `prompt_*` for the review loop |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv ≠ `interactive` |
| `./sudoer-cli` | Ship unit |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-01..13** | `tests/test_cli.sh` | have | Type 0 identity |
| **TP-LC-01..10** | `tests/test_local_lifecycle.sh` | have | lifecycle |
| **TP-SR-01** | `tests/test_domain_sr.sh` | have | basename prefix/suffix/`n` |
| **TP-SR-02** | `tests/test_domain_sr.sh` | have | schema; remove=purpose-only |
| **TP-SR-03** | `tests/test_domain_sr.sh` | have | sudoers ↔ JSON; visudo |
| **TP-SR-04** | `tests/test_domain_sr.sh` | have | `--queue-root` / per-dir; fail relative |
| **TP-SR-05** | `tests/test_domain_sr.sh` | have | self-scope; sidecar `request_id` |
| **TP-SR-06** | `tests/test_domain_sr.sh` | have | `{{service}}-{{user}}`; no `*-remove` |
| **TP-SR-07** | `tests/test_domain_sr.sh` | have | add sample JSON → sudoers |
| **TP-SR-08** | `tests/test_domain_sr.sh` | have | remove sample JSON → purpose-only |
| **TP-SR-09** | `tests/test_domain_sr.sh` | have | add sample sudoers → JSON webservice |
| **TP-SR-10** | `tests/test_domain_sr.sh` | have | mixed families → `unknown_service` |
| **TP-SR-11** | `tests/test_domain_sr.sh` | have | remove + `commands` → `remove_extra_fields` |
| **TP-SR-12** | `tests/test_domain_sr.sh` | have | relative queue root |
| **TP-SR-13** | `tests/test_domain_sr.sh` | have | `request_id` has prefix + `.json` |
| **TP-SR-PRIV-01** | `tests/test_domain_sr.sh` | have | Type 1 verbs: non-root → non-zero, no dest write |
| **TP-SR-PRIV-02** | `tests/test_domain_sr.sh` | have | Bootstrap setup any euid 0; approve keeps F6 |
| **TP-SR-PRIV-03** | `tests/test_domain_sr.sh` | have | Live setup body: useradd, collision, F6, hook (static) |
| **TP-SR-INT-03** | `tests/test_domain_sr.sh` | have | Hook snippet guards (static) |
| **TP-CLI-14** | `tests/test_cli.sh` | have | convert routed; junk unknown |
| **TP-SR-INT-01** | `tests/test_domain_sr.sh` | have | `interactive` without euid 0 → `authz` |
| **TP-SR-INT-02** | `tests/test_domain_sr.sh` | have | `--json` / `TTY=0` → `confirm_required`, no hang |
| **TP-SR-INT-04** | `tests/test_domain_sr.sh` | have | Empty inbound `interactive` exits 0 (live as root; static otherwise) |
| **TP-SR-INT-05** | `tests/test_domain_sr.sh` | have | Review loop reads ids on fd 3; `prompt_yes_no` keeps stdin |
| **TP-SR-Q-01** | `tests/test_domain_sr.sh` | have | Public `/var/{{APP_NAME}}/` + `sudoer-request` + 3773/0700/0755 |
| **TP-SR-Q-02** | `tests/test_domain_sr.sh` | have | Submit `0640`; approve archives snapshot; owner check |
| **TP-SR-Q-03** | `tests/test_domain_sr.sh` | have | F7 `lpu_remove_public_queues` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-13 | Active 1.0.0 | Initial domain SSOT; `DATE-user-type-n` text body |
| 2026-08-14 | Active 2.0.0 | JSON body; `sudoer-` + `.json` basename; conversion verbs; queue-dir resolve; dest per user+service |
| 2026-08-14 | Active 2.0.0 | Worked JSON/sudoers samples; host-mutating verb gate (EM-INT) |
| 2026-08-14 | Active 2.1.0 | Honesty: Type 0 routed; Type 1 fail-closed Gap; drop blanket “not yet routed” |
| 2026-08-14 | Active 2.2.0 | Present file-based JSON approval: roles, when a normal user may submit, JSON verify table |
| 2026-08-14 | Active 2.3.0 | Type 1 authz table; login-hook snippet + guards; interactive review loop; honest hook/loop Gap |
| 2026-08-14 | Active 2.4.0 | Request id `sudoer-DATE-{{service}}-{{user}}-action-n.json`; dest `/etc/sudoers.d/{{service}}-{{user}}` (aligns with `{{APP_NAME}}-{{TARGET_USER}}`) |
| 2026-08-14 | Active 2.5.0 | Split Type 1: bootstrap `setup` = any euid 0 (password sudo); approve stays F6/`sudoer-adm`; `sudo -n` hook-only after F6 |
| 2026-08-14 | Active 2.6.0 | Live `setup`/`remove-lpu`: useradd/userdel, F6, hook; interactive loop still Gap |
| 2026-08-14 | Active 2.7.0 | Mix model: code MAY password-`sudo`; `sudo -n` not suggested (hook-only); bootstrap ≠ approve gate |
| 2026-08-14 | Active 2.8.0 | Point prevention catalog: no invented wall after elev; `setup` Gap stub forbidden |
| 2026-08-14 | Active 2.9.0 | Dest `/etc/{{username}}/{{service}}`; never write `/etc/passwd` or `/etc/sudoers.d`; LPU home `/etc/sudoer-adm` |
| 2026-08-14 | Active 2.10.0 | Type 1 dest `/etc/sudoers.d/{{service}}-{{user}}` (copy/overwrite/remove exception); LPU home still `/etc/sudoer-adm` |
| 2026-08-15 | Active 2.11.0 | Public queues `/var/{{APP_NAME}}/sudoer-request` (0777) + 0700 archives; F4 views under live LPU home; Type 1 chown to LPU on move |
| 2026-08-15 | Active 2.12.0 | Inbound **3773** + submit `0640`; approve archives snapshot not path; owner==subject before chown; F7 removes `/var/{{APP_NAME}}/` children |
| 2026-08-15 | Active 2.13.0 | `sr_interactive` loop live; TP-SR-INT-01/02/04 + TP-SR-Q-* in DTV |
| 2026-08-15 | Active 2.14.0 | Id walk must not steal stdin from `prompt_yes_no`; protection rule 21; **TP-SR-INT-05** |

---

**Last Updated**: 2026-08-15  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
