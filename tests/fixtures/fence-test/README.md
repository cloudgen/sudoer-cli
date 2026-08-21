# fence-test corpus

**Test-purpose** corpus: prove dest fence functions against a JSON **file location** in this **local test folder**. **No sudo** except wrap chmod/chown of this folder. **No sudoers file.** Does **not** queue.

One file:

```sh
sh src/sudoer-cli fence-test --file tests/fixtures/fence-test/pass/login-hook-elev-dns-adm.json
```

A folder of cases:

```sh
sh src/sudoer-cli fence-test --dir tests/fixtures/fence-test/pass
sh src/sudoer-cli fence-test --dir tests/fixtures/fence-test/match --expect-match
```

| Folder | Meaning |
|--------|---------|
| `pass/` | Every dest fence must **clear** (well-formed + well-known system binary). |
| `match/` | Every file must **match** a dest fence (bad JSON, home-tree path, interpreter, …). |

Regular `*.json` only. No symlinks. Do **not** add `expect_fence` keys to the grant body (unknown key is itself a JSON-format Fence).
