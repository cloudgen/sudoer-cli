# Requirements index

**Product:** sudoer-cli (POSIX `/bin/sh` local self-managed CLI — Type 0 lifecycle **and** Type 0 domain convert/submit live; Type 1 `setup` / `interactive` live)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; historical origin **cli-template** (no live parent ship unit). Online / Type O **absent**.  
**Updated:** 2026-08-15

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, local-only); multi-vault forge push identity §2.0.5a | class | Active (1.5.0) | `requirement-class-software-dev.md` | 2026-08-14 |
| requirement-bootstrap-chain | Historical origin cli-template; this product is sudoer-cli (no live parent ship unit) | architecture | Active (5.1.0) | `requirement-bootstrap-chain.md` | 2026-08-14 |
| requirement-project-folder | Project layout (`src/`), install bins; LPU home / `/etc/{{username}}/` are host paths | architecture | Active (3.1.0) | `requirement-project-folder.md` | 2026-08-14 |
| requirement-shell-cli-interface | Shell CLI interface (Type 0 lifecycle + domain Type 0; Type 1 bootstrap vs F6 approve) | shell | Active (3.3.0) | `requirement-shell-cli-interface.md` | 2026-08-15 |
| requirement-shell-cli-zero-arguments | Empty argv Type N help (interactive ≠ empty argv) | shell | Active (1.1.0) | `requirement-shell-cli-zero-arguments.md` | 2026-08-13 |
| requirement-shell-local-self-management | Local install / uninstall / where-is-me; **mode 0755** multi-user | shell | Active (1.4.0) | `requirement-shell-local-self-management.md` | 2026-08-13 |
| requirement-shell-output-requirements | Central `out_*` output SSOT; colors consume `TTY`; operator fatals include `Next:` | shell | Active (1.1.1) | `requirement-shell-output-requirements.md` | 2026-08-14 |
| requirement-shell-modular-function-design | Single-file modular prefixes; domain `sr_` / `lpu_` reserved; `prompt_*` consume `TTY` | shell | Active (3.1.0) | `requirement-shell-modular-function-design.md` | 2026-08-14 |
| requirement-shell-idempotency | Re-run safety for install / uninstall (setup heal is target law) | shell | Active (1.2.0) | `requirement-shell-idempotency.md` | 2026-08-13 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm policy; TTY measured outside functions; Type 1 `interactive` + hook | shell | Active (1.2.0) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-14 |
| requirement-shell-prompt | `prompt_*` helper bodies; consume `TTY`; worked samples | shell | Active (1.0.0) | `requirement-shell-prompt.md` | 2026-08-14 |
| requirement-shell-cli-storage | Scratch/cache resolve; visudo copies under resolver + pid | shell | Active (1.1.0) | `requirement-shell-cli-storage.md` | 2026-08-13 |
| requirement-shell-temp-file-system | Scratch **leaves**: `mktemp`; no `$$` paths; cleanup | shell | Active (1.0.0) | `requirement-shell-temp-file-system.md` | 2026-08-14 |
| requirement-three-layer-privilege-model | Type 0/1 map; F6 `/etc/sudoers.d/sudoer-adm`; public queues `/var/{{APP_NAME}}/` 3773 inbound | architecture | Active (1.11.0) | `requirement-three-layer-privilege-model.md` | 2026-08-15 |
| requirement-least-privilege-user | sudoer-adm F1–F7; home create `/etc/sudoer-adm`; F5 `/var/{{APP_NAME}}/` 3773 + F4 views | architecture | Active (1.10.0) | `requirement-least-privilege-user.md` | 2026-08-15 |
| requirement-privilege-prevention-set | Closed catalog; OPEN-SUDOERS-D-EX; public `/var/{{APP_NAME}}/` is bound dest | architecture | Active (1.3.0) | `requirement-privilege-prevention-set.md` | 2026-08-15 |
| requirement-domain-sudoer-approval | **Domain SSOT** — submit `/var/{{APP_NAME}}/sudoer-request` (3773); dest `/etc/sudoers.d/{{service}}-{{user}}`; `interactive` **live** | domain | Active (2.13.0) | `requirement-domain-sudoer-approval.md` | 2026-08-15 |

## Intentionally absent

| Surface | Status on sudoer-cli |
|---------|----------------------|
| Online install / `SCRIPT_URL` / Type O empty-argv install-ensure | **Absent** |
| `version-check` / `self-update` / `self-uninstall` | **Absent** |
| Automatic companion `.sha256` channel integrity law | **Absent** |
| Folder archive backup / restore / retention | **Absent** |
| Type 2 execution context (run as LPU euid for `/etc` writes) | **Absent** — sudoer-adm is an authorizer |
| `--purge-grants` on LPU teardown | **Absent** in v1 |

**Install mode:** **local-only** (`install` + `uninstall` + `where-is-me`). Not dual-mode. Global 0755 is the production trust path for F6.

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for sudoer-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only**.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md`.  
7. **Domain SSOT:** exactly one Active `requirement-domain-sudoer-approval.md`. That file **presents** the file-based JSON approval machine (roles, submit-when, JSON verify, Type 1 authz, login hook, interactive loop) plus the four pillars. Help **must not** list a verb with no dispatcher arm. Type 0 domain is **routed**; Type 1 `setup` and `interactive` are **live**.  
8. **Do not reintroduce** online install or Type 2 execution without explicit user order and registry update.  
9. **Prevention set:** `requirement-privilege-prevention-set.md` is the closed catalog of what this product **blocks** and what it **must not block**. Do **not** invent a wall that is not a row in that file.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
