# Tests — sudoer-cli

## Run

```sh
./tests/run.sh
# or
sh tests/run.sh
```

Exit **0** when all assertions pass; **1** on failure; **2** if ship unit missing.

## Layout

| File | Focus | TP families |
|------|--------|-------------|
| `run.sh` | Entrypoint | — |
| `helpers.sh` | Asserts + isolated HOME | — |
| `test_cli.sh` | CLI surface, Type N, trimmed verbs, routed convert / `test-json-format`, TTY/temps static, sudo wrappers | **TP-CLI-01..14**, **TP-ELEV-07**, **TP-ELEV-08**, **TP-TMP-01**, **TP-SUDO-01..07** |
| `test_local_lifecycle.sh` | install / uninstall / where-is-me | **TP-LC-*** |
| `test_domain_sr.sh` | Convert, JSON samples, queues, submit, Type 1 gate, dest Fence, Type 0 `test-json-format`, dest-written `submit_by`, live setup body; dest one-off yes/no | **TP-SR-01..18**, **TP-SR-PRIV-01..04**, **TP-SR-INT-01..06**, **TP-SR-HOOK-***, **TP-SR-FENCE-01..11**, **TP-SR-Q-*** |
| `fixtures/login-hook-elev-dns-adm.json` | Type 0 drop login-hook-elev grant JSON (`dns-adm` / `dns-cli` / `interactive`; no `submit_by`) | **TP-SR-FENCE-05** |
| `fixtures/maximal-dest-stamped-login-hook-elev.json` | Dest-stamped maximal grant JSON (all closed-schema keys including `submit_by`) | **TP-SR-FENCE-09** |

## Isolation

- Temp `HOME` + `USER_BIN` + redirected `GLOBAL_BIN` for install tests  
- **No** public network  
- **No** write to `/etc` or `/var/backup`

## Ship unit under test

`src/sudoer-cli`

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
