**file**: docs/requirements/requirement-domain-sudoer-approval.md  
**Status**: Active (Version 2.24.0) — dest review asks one-off yes/no (approval-question)  
**Area**: domain  
**Key**: `requirement-domain-sudoer-approval`  
**id**: RQ-DOMAIN-SUDOER-APPROVAL  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **single current domain SSOT** for sudoers-request approval: the **file-based JSON approval** machine (§2.0), specialized subcommands, request basename, JSON/text conversion, queue-path resolve, help items, and about items.

Privilege types and F6 Cmnds are owned by `requirement-three-layer-privilege-model.md`. LPU identity is owned by `requirement-least-privilege-user.md`. What Type 0 / Type 1 **block** vs what must stay open after elev is owned by `requirement-privilege-prevention-set.md`. Live Type 0 dispatcher catalog is owned by `requirement-shell-cli-interface.md` (lifecycle) **plus** the Type 0 domain verbs in §2.1.

**Routing honesty:** `help` / `about` **MUST NOT** list a verb that has no dispatcher `case` arm. Convert/submit/list/show/print-sudoers/`test-json-format` **are routed**. Setup and review **are routed** and **fail closed** unless the invoker is already root. Live `setup` creates the dedicated account, the extra sudoers fragment, queues, and login hook. The review-loop body is **live**. About LPU/trust-tier fields remain a **Gap**.

### 1.1 Human-facing

**In one sentence:** You drop a JSON grant file in the waiting folder; a host admin who already used password `sudo` moves it. Folders are the state.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Convert and queue a grant for yourself or another login | `sudoer-cli add-sudoer-request --file request.json` |
| The other role | Host admin already root, or `sudoer-adm` after setup | `sudo sudoer-cli interactive` |
| Not this file | Type map, prevention catalog, dest Fence body | `requirement-three-layer-privilege-model` · `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Roles, submit-when, verify table, dest fence table, verbs, basename, hook, review loop | Ticket DB; inventing a dest fence; `SUDO_USER` must be `sudoer-adm` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/sudoer-cli/sudoer-request` | waiting folder | inbound JSON |
| `src/sudoer-cli` | ship unit | convert / submit / review |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Convert | Turn sudoers text into JSON. Nothing is queued yet. | `sudoer-cli sudoers-to-json --file draft.sudoers --action add --purpose "…"` |
| Submit | This program names the file and writes it into the waiting folder. | `sudoer-cli add-sudoer-request --file request.json` |
| Decide | If the JSON is broken, dest says so and does not ask. If it is valid, **one** yes/no: yes accepts, no (or Enter) declines. No skip or quit. | `sudo sudoer-cli interactive` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 File-based JSON approval

This product’s approval machine is **file-based JSON approval**. **Folder = state.** **JSON = the checkable grant proposal.** There is no ticket table.

A **normal user** (Type 0) submits request JSON into the inbound queue. **User A may submit on behalf of user B**; the allocated filename uses **B**. The **least-privilege-approver** (`sudoer-adm`) or an already-elevated host admin re-checks that JSON and **moves** the file. Dest writes are Type 1 as root after F6 — the LPU is not a Type 2 execution context. Dest uses **B**.

A **TTY login** as `sudoer-adm` **MUST** be able to enter that approve path via the login hook (`sudo -n` global binary `interactive` — **after F6 exists**) or an explicit Type 1 `interactive` / `approve` / `reject`. Empty argv stays help. Running the CLI as euid `sudoer-adm` without F6 **MUST** fail closed (`authz`). **Bootstrap** (`setup`) and **approve** share the same elev: any host admin already euid 0 via outer `sudo` (password allowed). F6 is an extra day-to-day path, not the exclusive approver. Basename, schema, dest, hook, and review-loop rules stay in §2.2. Live `setup` writes LPU + F6 + hook and **helps** the installing sudoer submit (prints the submit next-step). The review-loop body is **live**. Type 0 / an LSU **MUST NOT** `useradd`.

#### Roles

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Submitter (A)** | Ordinary login (`id -un`) | **0** | Convert; `add` / `update` / `remove-sudoer-request` **for B** (or for themselves); list/show own sidecar ids | `approve` / `reject`; write `/etc/passwd` or `/etc/sudoers.d`; choose the dest path |
| **Subject (B)** | Grant login — **may** differ from A | — | Appear as filename `username` and JSON `username` | Be invented by last-hyphen parse when JSON names B |
| **Approver** | Host admin who already elevated (password `sudo`, any `SUDO_USER`); **or** `sudoer-adm` via F6; **or** a real root login | **1** (euid 0) | `approve` / `reject` / `interactive`; re-check JSON + name; **move** inbound → accepted/declined; dest `/etc/sudoers.d/{{service}}-{{B}}` | Steal the decision (actor/owner/submitter walls); Type 2 dest-write; `ALL=(ALL) ALL` |
| **Allocator** | This CLI’s Type 0 path | **0** | Allocate `sudoer-{{date}}-{{service}}-{{B}}-{{action}}-{{n}}.json` | Trust a caller dest basename; force the name to A when JSON says B |
| **Root session** | euid 0 | **1** (no F6) | Same Type 1 verbs as approver | Invent a second lock after elev |

#### When a normal user may submit

Type 0 submit is allowed **only when all** hold:

1. Invoker is a login user (not required to be `sudoer-adm`).  
2. The request encodes **one** service (inferred family **or** explicit product name such as `folder-backup`). Mixed inferred families → reject.  
3. Inbound is writable (default `/var/{{APP_NAME}}/sudoer-request` mode **3773**, or an explicit queue override). The CLI **allocates** the name.  
4. Input is request JSON, or sudoers text the CLI converts first.  
5. **Remove** is purpose-only JSON (no `commands`). JSON `username` (or the sudoers User spec) **MAY** differ from `id -un`. The allocator uses that subject.

**Not a submit situation:** wanting dest written immediately; running `approve` as a normal user (Type 1 fail-closed).

**Human decides:** accept / decline of a **valid inbound** request is a **person**. Dest review asks the **approval question** (term `approval-question`): one-off yes/no. Helpful checks review the **file** (schema, visudo, hostile inode, User `ALL` / alias). Extra actor locks after elev, unpublished auto-reject heuristics, forcing A=B, skip / quit / maybe on that question, and hiding inbound files are **blockage**, not an approval system.

#### How JSON is verified

The queued file is the **evidence**. Approvers do **not** trust a world-writable drop at face value. Checks at submit **and again at approve**:

| Check | What JSON (and name) must satisfy |
|-------|-----------------------------------|
| **Closed schema** | `schema_version` 1 on add/update; unknown keys → `invalid_json` |
| **Identity match** | User/service SSOT is JSON `username` / `service` when present, else the name. Basename **action** must match JSON `action` when JSON has `action` (`field_mismatch`). Filename subject token ≠ JSON `username` is **not** a fail |
| **Not an actor lock** | After euid 0, do **not** require `SUDO_USER==sudoer-adm`, file owner == subject, or JSON username == invoker. Those checks are blockage. Dest uses JSON `username` / `service` when present |
| **Purpose** | Required. Remove = **purpose only** (`remove_extra_fields` if `commands` present) |
| **Commands** | Absolute paths; no `ALL`; no `#include` / `Defaults`; service infer agrees with `service` |
| **visudo** | Render JSON → private sudoers text, then `visudo -cf` (skip comment-only remove). Never feed JSON to visudo |
| **Dest** | Approve add/update → `/etc/sudoers.d/{{service}}-{{username}}` from JSON `service`/`username` when present, else the name. Never `*-remove` |
| **Re-validate** | Approve **re-runs** these checks. A tampered inbound file fails then, not at dest write |

CLI `--json` is **status** only (`out_json`). It is **not** the request file.

#### Dest approval fencing conditions (closed)

Dest `approve` / `reject` / `interactive` **MUST** run this list **before** the approval question. When a **Fence** matches: display the match in people/folder words; **MUST NOT** ask the approval question for that file. Each dest **Fence** row **MUST** point at an independent REQ.

| Condition | Dest approve / reject / interactive |
|-----------|--------------------------------------|
| Incorrect JSON format | **Fence** — fail closed. Independent REQ: `requirement-incorrect-json-format` |
| File-ownership | **MUST NOT** fence — dest takes ownership as `sudoer-adm` |
| Who submitted / dest self-scope (A≠B) | **MUST NOT** fence |
| JSON `username` ≠ `sudoer-adm` | **MUST NOT** fence |
| Filename subject token ≠ JSON `username` | **MUST NOT** fence — user SSOT is the JSON field |
| Dest-written `submit_by` / missing `submit_by` | **MUST NOT** fence |

**MUST NOT** add a dest inbound fence that is not on this table.

### 2.1 Specialized CLI subcommands (pillar 1)

Every domain verb **MUST** have exactly one privilege type. Type 0 never writes `/etc/passwd` or `/etc/sudoers.d`. Type 1 dest is `/etc/sudoers.d/{{service}}-{{username}}` (copy / overwrite / remove product-owned names only). Type 1 host mutation needs euid 0. **Bootstrap** (`setup`) is any host admin (password `sudo` OK — mix model). **Approve** is any already euid-0 host admin (password `sudo`), or F6 `sudoer-adm`, or a real root session.

| Verb | Type | Handler family | Operands / flags | Required behavior |
|------|------|----------------|------------------|-------------------|
| `sudoers-to-json` | 0 | `sr_sudoers_to_json` | stdin **xor** `--file PATH`; `--action add\|update`; `--purpose TEXT`; `--service NAME` optional; `--out PATH` optional | Convert a sudoers text fragment to request JSON. Infer service from Cmnds. Never queue. Never `/etc/passwd` or `/etc/sudoers.d`. `visudo -cf` the input first. |
| `json-to-sudoers` | 0 | `sr_json_to_sudoers` | stdin **xor** `--file PATH`; `--out PATH` optional | Convert request JSON to sudoers text. `remove` → `# Purpose:` comments only. `visudo -cf` the output except comment-only remove. Never queue. Never `/etc/passwd` or `/etc/sudoers.d`. |
| `test-json-format` | 0 | `sr_test_json_format` | stdin **xor** `--file PATH` | Test a grant JSON file against `requirement-incorrect-json-format` without dest elev and without the waiting folder. Basename grammar / action match only when the input basename already matches request-id grammar. Never queue. Never `/etc/passwd` or `/etc/sudoers.d`. |
| `print-sudoers` | 0 | `sr_print_sudoers` | stdout or draft path | Emit **Table A only** (F6 fragment). Never write `/etc/passwd` or `/etc/sudoers.d`. |
| `print-sudoers-install-script` | 0 | `sr_print_sudoers_install_script` | — | Emit admin script under volatile storage. |
| `setup` | 1 | `lpu_setup` | — | Create LPU + default queues + F6 + login hook. Fail closed on UID collision / missing global binary for production F6. Any host admin (password `sudo`). Type 0 / LSU **MUST NOT** `useradd`. After success, **help submit**: print the `add-sudoer-request` next-step for the invoking sudoer (subject **may** be B). |
| `setup --uninstall` / `remove-lpu` | 1 | `lpu_remove` | `--force`, `--purge-queues` | F7. Confirm on TTY unless `--force`. |
| `add-sudoer-request` | 0 | `sr_submit add` | stdin **xor** `--file PATH`; `--purpose` if text lacks `# Purpose:` | Accept JSON **or** sudoers text (first non-whitespace `{` vs `#`/spec). Allocate basename; write JSON into request queue; **print `request_id`**. |
| `update-sudoer-request` | 0 | `sr_submit update` | same | same with action `update` |
| `remove-sudoer-request` | 0 | `sr_submit remove` | `--service` required; `--purpose` **xor** `--file` (purpose-only JSON) | Queue purpose-only JSON (no `commands`). Allocator uses JSON `username` when present (A may name B). |
| `list-approving` / `list-approved` / `list-rejected` | 0 | `sr_list` | optional `--user` | Type 0: sidecar only. Type 1/root may readdir. |
| `list-approving --orphans` | 1 | `sr_list_orphans` | — | Non-regular inbound only (symlink / missing). File owner is not an orphan wall. |
| `show <request-id>` | 0 | `sr_show` | full basename **with** `.json` | Purpose + body for a known id. |
| `approve <request-id>` | 1 | `sr_approve` | full basename **with** `.json` | Re-validate; install or delete dest. |
| `reject <request-id>` | 1 | `sr_reject` | same | Re-validate; move to rejected. |
| `interactive` | 1 | `sr_interactive` | TTY (`TTY=1`); no operand | Review loop (§2.2). Consume `TTY`. One-off yes/no per unfenced file (approval-question). Non-TTY / `--json` → `confirm_required`. Empty argv is **not** this verb. |

**Global domain flags** (parsed in `app_main`; `help` **MUST** list them now that Type 0 domain is routed):

| Flag | Env | Role |
|------|-----|------|
| `--request-dir DIR` | `SUDOER_CLI_REQUEST_DIR` | Override inbound queue |
| `--approved-dir DIR` | `SUDOER_CLI_APPROVED_DIR` | Override accepted archive |
| `--rejected-dir DIR` | `SUDOER_CLI_REJECTED_DIR` | Override declined archive |
| `--queue-root DIR` | `SUDOER_CLI_QUEUE_ROOT` | Set the public trio as `DIR/sudoer-request`, `DIR/sudoer-approved`, `DIR/sudoer-rejected` |

**Error codes (machine JSON `error` / `code`):** `invalid_name`, `self_scope`, `visudo_fail`, `not_regular`, `owner_mismatch`, `authz`, `not_found`, `already_done`, `confirm_required`, `xor_input`, `invalid_json`, `unknown_service`, `schema_version`, `field_mismatch`, `remove_extra_fields`.

**Routing:** `app_main` **MUST** dispatch every **live** row. Unrouted target rows stay out of `help`. Conversion verbs **MAY** be routed independently of setup/approve (local file transform).

**Host-mutating (CL-HOST-MUTATING-DOMAIN):** `setup`, `setup --uninstall` / `remove-lpu`, `approve`, `reject`, `interactive`, and `list-approving --orphans` **MUST** fail closed with **no partial host write** unless euid is 0 and authorization matches §2.1. Convert, `test-json-format`, submit, list, show, print-sudoers, and print-sudoers-install-script **MUST NOT** write `/etc/passwd` or `/etc/sudoers.d`, and **MUST NOT** create LPU accounts. Type 1 dest is `/etc/sudoers.d/{{service}}-{{username}}` (copy / overwrite / remove). Privilege actor is **EM-HYB** (mix: password `sudo` for bootstrap; F6 NOPASSWD for day-to-day approve), owned by `requirement-three-layer-privilege-model.md`. Do **not** invent extra blocks — `requirement-privilege-prevention-set.md`.

#### Type 1 authorization

**Bootstrap** (`setup` / `setup --uninstall` / `remove-lpu`) — first-time host work. F6 does not exist. Install is **multi-user**.

| Invoker | euid | `SUDO_USER` | Result |
|---------|------|-------------|--------|
| any host admin via outer `sudo {{APP}} setup` (password OK) | 0 | that admin (not necessarily `sudoer-adm`) | **allow** bootstrap |
| root login | 0 | empty | **allow** bootstrap |
| any user, no sudo | not 0 | empty | **fail** `authz` (tell them `sudo {{APP}} setup`) |
| `sudo -n {{APP}} setup` without a NOPASSWD grant | not 0 or fails before exec | — | **must not** be the documented path |

**Mix model:** the ship unit **MAY** invoke password `sudo`. **`sudo -n` is not suggested** for bootstrap. Usual path: the human runs `sudo {{APP}} setup`.

**Approve** (`approve` / `reject` / `interactive`) — same elev as bootstrap. F6 is extra, not exclusive.

| Invoker | euid | `SUDO_USER` | TTY | Result |
|---------|------|-------------|-----|--------|
| `sudoer-adm` without `sudo` | not 0 | empty | any | **fail** `authz` |
| any host admin via outer `sudo` (password OK) | 0 | that admin (not necessarily `sudoer-adm`) | `TTY=1` | **allow** `interactive` / `approve` / `reject` |
| any host admin via outer `sudo` | 0 | that admin | `TTY=0` or `JSON=1` | `interactive` **fail** `confirm_required`; `approve`/`reject` **MAY** run (no prompt) |
| `sudo` or `sudo -n` as `sudoer-adm` (F6) | 0 | `sudoer-adm` | as above | **allow** (same TTY rule) |
| root login | 0 | empty | as above | **allow** (same TTY rule) |

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
| `username` | Subject **B** (JSON `username` / sudoers User spec; **may** differ from `id -un`). **MUST** match `^[a-z_][a-z0-9_-]*$` |
| action | `add` \| `update` \| `remove` |
| `n` | 1-based, no leading zeros, cap 999, over **approving ∪ approved ∪ rejected** for same date+service+username+action |
| suffix | literal `.json` |

`request_id` **is** that full basename (prefix **and** suffix). Allocator **MUST NOT** take a caller-supplied dest basename.

#### Request JSON (queued body)

Closed `schema_version` **1**. POSIX `/bin/sh` codec (`util_json_escape` + constrained decoder). No `jq` required.

**add / update — required:** `schema_version`, `purpose`, `username`, `service`, `action`, non-empty `commands[]`.  
Each command: absolute `path`; `args` string array; `runas` default `root`; `tags` v1 `NOPASSWD` only.  
**Optional `kind`:** `type-2-switch` or `login-hook-elev`. Unknown `kind` → `invalid_json`.

**Dest-written `submit_by`:** original Unix owner of the waiting file **before** dest took ownership. Dest `interactive` **MUST** read that owner first, take ownership as `sudoer-adm`, format-check, and **if** the JSON is well-formed **MUST** write `submit_by` to that owner. Type 0 submit **MUST NOT** include `submit_by`. Dest **MUST NOT** fence if `submit_by` is present or missing. User SSOT stays JSON `username`.

**remove — required: `purpose` only.** Optional `schema_version` / `username` / `service` / `action`=`remove` / `kind` / `submit_by` must match the basename when present. `commands` or any unknown key → `remove_extra_fields`.

Unknown keys anywhere → `invalid_json`. Closed-schema allowlist: `schema_version`, `purpose`, `username`, `service`, `action`, `commands`, `kind`, `submit_by`. Basename **action** must match JSON `action` when present (`field_mismatch`). User/service SSOT is JSON when present.

`--json` CLI status (`out_json`) is **not** the request file.

**Codec fidelity (sacred):** Pretty-printed and compact JSON are the same grant. `sr_json_decode_to_fields` / convert / submit re-encode **MUST** keep every `commands[]` object (`path`, `args`, `runas`, `tags`). A splitter that only matches the token `},{` is non-compliant (`}, {` and `},\n{` are legal). After decode, object count **MUST** equal input `"path"` count; mismatch → `invalid_json`. Silent last-`args`-wins is forbidden. `purpose` and `[OK] request_id=` are **not** completeness. Suites **MUST** include a pretty multi-command fixture, not only encoder output (INC-20260817-001).

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

**Dest-stamped maximal body** (queue Unix owner converted to JSON `submit_by` after dest format check; Type 0 **MUST NOT** queue this key). On-disk proof: `tests/fixtures/maximal-dest-stamped-login-hook-elev.json`. `test-json-format` **MUST** accept it.

```json
{
  "schema_version": 1,
  "kind": "login-hook-elev",
  "purpose": "Allow dns-adm login hook to run dns-cli interactive.",
  "username": "dns-adm",
  "service": "dns-cli",
  "action": "add",
  "submit_by": "alice",
  "commands": [
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/dns-cli",
      "args": ["interactive"]
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

A sudoers text fragment is `# Purpose:` plus User-spec lines (add/update) or comment-only (remove). `sudoers-to-json` / `json-to-sudoers` round-trip User + Cmnds. Extra comments/whitespace besides Purpose are not preserved. **JSON whitespace inside `commands[]` is not semantics** — pretty input **MUST** round-trip the same Cmnd set as compact input.

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

Default modes (when `setup` creates them): public root **0755** `sudoer-adm:sudoer-adm`; inbound **`/var/{{APP_NAME}}/sudoer-request` 3773** (sticky+setgid; other `-wx`, no other-r); accepted/declined **0700**. Submit creates a file owned by the submitter and **MUST** `chmod 0640` it. Type 1 approve/reject **MUST NOT** fail `owner_mismatch` or `self_scope`. Dest install uses JSON `username` / `service` when present. Dest install and the archive **MUST** use a **private snapshot** of that file; **MUST NOT** `mv` the inbound path after validate (unlink the inbound name after placing the snapshot). The archived file **MUST** be `sudoer-adm:sudoer-adm` mode `0640`. Exclusive create. Do **not** `mv` over an existing dest.

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

**Why `${LPU_HOME}/.profile` must exist:** a bash **login** shell (SSH / console) sources `.profile` (or `.bash_profile` / `.bash_login`) and does **not** source `.bashrc` unless `.profile` does so. Create-first home plus `useradd -M` copies **no** `/etc/skel` `.profile`. Without that file, the hook in `.bashrc` **never runs**.

| File | When to write |
|------|----------------|
| `${LPU_HOME}/.bashrc` | **Always** (create if missing). Create-default home is `/etc/sudoer-adm`. Plant the hook snippet here. After create or rewrite (`mktemp`+`mv`): **owner `sudoer-adm:sudoer-adm`**, mode **0644**. |
| `${LPU_HOME}/.profile` | **Check.** **Absent:** **create** it with the complete source-bashrc sample below. **Present:** **MUST NOT** overwrite the body. If it already sources `.bashrc`, do not also plant the hook in `.profile`. If it exists and does **not** source `.bashrc`, plant the hook in `.profile` so login still reaches review. After create or rewrite, **and** on heal of an existing unreadable file: **owner `sudoer-adm:sudoer-adm`**, mode **0644**. |
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
| **`.profile` check** | `setup` **MUST** test whether `${LPU_HOME}/.profile` exists before deciding create vs leave |
| **`.profile` create** | Missing → write the complete sample below (bash login sources `.bashrc`). Existing → leave the body unchanged |
| **Owner** | After create or rewrite of `.bashrc` / `.profile`: `chown sudoer-adm:sudoer-adm` and `chmod 0644`. When the LPU account exists, **fail closed** if `chown` fails. **MUST NOT** swallow with `\|\| true`. Existence is not enough if the LPU cannot read the file |
| **Heal** | If `.profile` sources `.bashrc` and still has the hook marker, strip the `.profile` copy, then re-apply owner/mode. Heal an existing unreadable `.profile` without replacing its body |
| **F7** | Strip the hook marker block from **whichever** home rc files contain it |

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

Session `SUDOER_CLI_HOOK_RAN` **MUST** prevent a second `interactive` if both login and interactive shells source `.bashrc`.

#### Interactive review loop

`sr_interactive` **MUST**:

1. Use the same Type 1 authorization as `approve` / `reject`.  
2. **Consume** `TTY` / `JSON` / `QUIET` (no live `[ -t` inside the handler as the policy gate). If `TTY` is not `1`, or `JSON=1`, **fail closed** `confirm_required` — no hang.  
3. Prompt only through `prompt_*`. **MUST NOT** ad-hoc `read`. `--force` **MUST NOT** auto-approve. The id walk **MUST NOT** redirect stdin over those prompts (`prompt_yes_no` reads fd 0). Walk ids on another fd.  
4. Resolve queues once. Type 1 **MAY** readdir inbound. Consider only regular, non-symlink files whose basename matches the request grammar.  
5. Empty inbound → human note (or JSON success) and exit **0**. Do not hang.  
6. For each pending id (basename sort): **fence first** (`requirement-incorrect-json-format`). If a fence **matches**: display the match in people/folder words; **MUST NOT** ask the approval question; continue to the next file. If **no** fence: show purpose + body (same contract as `show`); ask the **approval question** (term `approval-question`): **one-off yes/no** via **one** `prompt_yes_no`. **Yes** = approve. **No** (including Enter) = reject. **MUST NOT** offer skip / quit / maybe. **MUST NOT** chain Approve then Reject then Quit as three `(y/N)` questions.  
7. **yes** / **no** **MUST** run the same re-validate + dest/move as the standalone `approve` / `reject` verbs. Remaining inbound files stay in this loop (no quit). Direct `approve` / `reject` with a request id stay **non-interactive**.  
8. A validate failure on one id **MUST NOT** abort the rest; emit the error and continue.  
9. Empty argv **MUST NOT** reach this handler.

The handler is **live**. Non-TTY / `--json` / `--quiet` fail closed `confirm_required`. `--force` does **not** auto-approve. Each unfenced id uses **one** `prompt_yes_no` (default no = reject).

#### Warnings (not hard reject)

`sr_validate_body` / interactive **SHOULD** warn when a request Cmnd is a shell, `sudo`, `visudo`, or writes `/etc/passwd` / `/etc/sudoers.d`. Approver still decides.

### 2.3 Specialized project help items (pillar 3)

`help` **MUST** list Type 0 lifecycle **and** the live domain rows (conversion, `test-json-format`, submit, list, show, print-sudoers, and Type 1 notes for setup/approve/interactive). Examples **MUST** include `sudoers-to-json`, `test-json-format`, `add-sudoer-request`, and a list/show pair.

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
| **Approval question** | One-off yes/no (`prompt_yes_no "Approve this request"`). Yes = approve. No / Enter = reject. No skip / quit / maybe. Term `approval-question`. |
| **`.profile` create** | Missing → write source-bashrc sample (`# BEGIN sudoer-cli profile source-bashrc`). Existing never overwritten. |
| **Routed now** | Type 0 convert/`test-json-format`/submit/list/show/print-sudoers; Type 1 `setup`/`remove-lpu`/`approve`/`reject`/`interactive` live |
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
7. Re-add `owner_mismatch` or `self_scope` (invoker / file owner / parsed subject) as a Type 1 or convert/submit wall. That is blockage.  
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
20. Invent a second lock after password `sudo` / root login — including `SUDO_USER` must be `sudoer-adm` on approve — a live-command whitelist the user did not publish, or a Gap stub on live `setup` (`requirement-privilege-prevention-set.md`).  
21. Walk inbound ids with `while read … done <file` (or any stdin redirect) so `prompt_yes_no` hits EOF and auto-answers no (reject).  
22. Silently drop `commands[]` objects on decode/re-encode (pretty JSON last-`args` wins). Compact-only fixtures do **not** prove fidelity.  
23. Skip the `${LPU_HOME}/.profile` existence check, or skip auto-create when it is missing (a login shell then never sources `.bashrc`, so the hook never fires).  
24. Overwrite an existing `.profile`.  
25. Leave `${LPU_HOME}/.profile` or `.bashrc` as `root:root` / unreadable after create or rewrite (`mktemp`+`mv`). The corresponding user **must** own those files. Swallowing `chown` is forbidden.  
26. Offer skip / quit / maybe on dest review, or chain Approve then Reject then Quit as three `(y/N)` questions. The approval question is one-off yes/no.

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
| `docs/requirements/requirement-shell-prompt.md` | `prompt_yes_no` body for the one-off approval question |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv ≠ `interactive` |
| `docs/requirements/requirement-actor-role-subject-approver.md` | Five-column consider catalog |
| `docs/requirements/requirement-incorrect-json-format.md` | Dest Fence body |
| `src/sudoer-cli` | Ship unit |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-01..13** | `tests/test_cli.sh` | have | Type 0 identity |
| **TP-LC-01..10** | `tests/test_local_lifecycle.sh` | have | lifecycle |
| **TP-SR-01** | `tests/test_domain_sr.sh` | have | basename prefix/suffix/`n` |
| **TP-SR-02** | `tests/test_domain_sr.sh` | have | schema; remove=purpose-only |
| **TP-SR-03** | `tests/test_domain_sr.sh` | have | sudoers ↔ JSON; visudo |
| **TP-SR-04** | `tests/test_domain_sr.sh` | have | `--queue-root` / per-dir; fail relative |
| **TP-SR-05** | `tests/test_domain_sr.sh` | have | submit (A may name B); sidecar `request_id` |
| **TP-SR-06** | `tests/test_domain_sr.sh` | have | `{{service}}-{{user}}`; no `*-remove` |
| **TP-SR-07** | `tests/test_domain_sr.sh` | have | add sample JSON → sudoers |
| **TP-SR-08** | `tests/test_domain_sr.sh` | have | remove sample JSON → purpose-only |
| **TP-SR-09** | `tests/test_domain_sr.sh` | have | add sample sudoers → JSON webservice |
| **TP-SR-10** | `tests/test_domain_sr.sh` | have | mixed families → `unknown_service` |
| **TP-SR-11** | `tests/test_domain_sr.sh` | have | remove + `commands` → `remove_extra_fields` |
| **TP-SR-12** | `tests/test_domain_sr.sh` | have | relative queue root |
| **TP-SR-13** | `tests/test_domain_sr.sh` | have | `request_id` has prefix + `.json` |
| **TP-SR-PRIV-01** | `tests/test_domain_sr.sh` | have | Type 1 verbs: non-root → non-zero, no dest write |
| **TP-SR-PRIV-02** | `tests/test_domain_sr.sh` | have | Bootstrap setup any euid 0; not `sudo -n` |
| **TP-SR-PRIV-04** | `tests/test_domain_sr.sh` | have | Approve gate: no exclusive-`sudoer-adm` actor lock |
| **TP-SR-PRIV-03** | `tests/test_domain_sr.sh` | have | Live setup body: useradd, collision, F6, hook (static) |
| **TP-SR-INT-03** | `tests/test_domain_sr.sh` | have | Hook snippet guards (static) |
| **TP-SR-HOOK-01** | `tests/test_domain_sr.sh` | have | `setup` checks `.profile`; missing → create source-bashrc sample |
| **TP-SR-HOOK-02** | `tests/test_domain_sr.sh` | have | Existing `.profile` is not overwritten |
| **TP-SR-HOOK-03** | `tests/test_domain_sr.sh` | have | Created `.profile` sources `.bashrc` (markers) |
| **TP-SR-HOOK-04** | `tests/test_domain_sr.sh` | have | After create/rewrite, hook apply/ensure **chown** the LPU (no swallowed `chown`) |
| **TP-CLI-14** | `tests/test_cli.sh` | have | convert routed; junk unknown |
| **TP-SR-INT-01** | `tests/test_domain_sr.sh` | have | `interactive` without euid 0 → `authz` |
| **TP-SR-INT-02** | `tests/test_domain_sr.sh` | have | `--json` / `TTY=0` → `confirm_required`, no hang |
| **TP-SR-INT-04** | `tests/test_domain_sr.sh` | have | Empty inbound `interactive` exits 0 (live as root; static otherwise) |
| **TP-SR-INT-05** | `tests/test_domain_sr.sh` | have | Review loop reads ids on fd 3; `prompt_yes_no` keeps stdin |
| **TP-SR-INT-06** | `tests/test_domain_sr.sh` | have | One-off approval question: one `prompt_yes_no`; yes=approve; no/Enter=reject; no skip/quit |
| **TP-SR-Q-01** | `tests/test_domain_sr.sh` | have | Public `/var/{{APP_NAME}}/` + `sudoer-request` + 3773/0700/0755 |
| **TP-SR-Q-02** | `tests/test_domain_sr.sh` | have | Submit `0640`; approve archives snapshot; **no** owner_mismatch / self-scope wall |
| **TP-SR-Q-03** | `tests/test_domain_sr.sh` | have | F7 `lpu_remove_public_queues` |
| **TP-SR-14** | `tests/test_domain_sr.sh` | have | pretty add-sample JSON → all three Cmnd lines |
| **TP-SR-15** | `tests/test_domain_sr.sh` | have | pretty add-sample submit inbound keeps all three `path`s |
| **TP-SR-16** | `tests/test_domain_sr.sh` | have | pretty folder-backup `backup`+`restore` JSON keeps both verbs |
| **TP-SR-FENCE-01..04** | `tests/test_domain_sr.sh` | have | dest Fence before yes/no; isolated dest checks |
| **TP-SR-FENCE-05..08** | `tests/test_domain_sr.sh` | have | Type 0 `test-json-format` + login-hook-elev fixture |
| **TP-SR-FENCE-11** | `tests/test_domain_sr.sh` | have | Dest `submit_by` stamp first `{` only |
| **TP-SR-FENCE-09..10** | `tests/test_domain_sr.sh` | have | dest-written `submit_by` accepted; Type 0 must not plant it |

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
| 2026-08-17 | Active 2.15.0 | Pretty `commands[]` fidelity; fail closed on object-count mismatch; **TP-SR-14/15/16**; INC-20260817-001 |
| 2026-08-18 | Active 2.16.0 | Elevated sudoer **may** approve (OPEN-SUDOER-APPR). Setup helps submit. LSU never `useradd`. **TP-SR-PRIV-04** |
| 2026-08-18 | Active 2.17.0 | Login hook: **check** LPU `~/.profile`; **create** source-bashrc sample when missing; never overwrite. **TP-SR-HOOK-01..03** |
| 2026-08-18 | Active 2.18.0 | **Human decides** valid inbound (blockage forbidden). Drop owner/submitter walls: no `owner_mismatch` / `self_scope` on convert, submit, approve, reject. Dest from JSON identity. **OPEN-DECIDE** |
| 2026-08-18 | Active 2.19.0 | Role table: user A submits on behalf of B; allocated name uses B |
| 2026-08-18 | Active 2.20.0 | Login rc owner: `.profile` / `.bashrc` **MUST** be `sudoer-adm:sudoer-adm` after create/rewrite. **TP-SR-HOOK-04** |
| 2026-08-19 | Active 2.21.0 | Dest fence table; independent `requirement-incorrect-json-format`; interactive fence-first; §1.1 Human-facing |
| 2026-08-20 | Active 2.22.0 | Type 0 `test-json-format`; optional `kind`; **TP-SR-FENCE-05..08** |
| 2026-08-20 | Active 2.23.0 | Dest-written `submit_by` = original queue Unix owner; Type 0 must not plant; **TP-SR-FENCE-09..10** |
| 2026-08-20 | Active 2.24.0 | Dest review asks the **approval question** (one-off yes/no; yes=approve, no/Enter=reject). No skip / quit / maybe. Protection rule 26; **TP-SR-INT-06** |

---

**Last Updated**: 2026-08-20  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
