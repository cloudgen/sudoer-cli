**file**: docs/requirements/requirement-shell-cli-language.md
**Status**: Active (Version 1.2.0)
**Area**: shell
**Key**: `requirement-shell-cli-language`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the product law for **menu language** on sudoer-cli: thirteen codes, the saved file, and the words the numbered menu, human `help`, and human `about` print.

The front board (row **1** approval features, row **5** languages, row **7** sudoers, Exit **99**) stays owned by `requirement-shell-cli-default-interaction`. This file owns the language codes, the `language` leaf, and the menu copy. Rows **51–63** use the same names and order as the sibling grok-cli language board. **50** and **64–69** stay unprinted. The scratch resolver stays owned by `requirement-shell-cli-storage`.

### 1.1 Human-facing

**In one sentence:** Menu **5** chooses English, 简体中文, 繁體中文, Español, العربية, Français, Português, Русский, Deutsch, 日本語, 한국어, Nederlands, or Ελληνικά for the numbered menu, for `help`, and for `about`, and the next run — including a bare `sudoer-cli` at a real terminal — opens in that language.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Pick a language on the menu | `5` then **51** through **63** |
| The other role | A script that must not wait | `sudoer-cli help` |
| Not this file | What `approve` prints, argv `version`, JSON about | Those stay English |

| Includes | Excludes |
|----------|----------|
| Codes `en`, `zh-Hans`, `zh-Hant`, `es`, `ar`, `fr`, `pt`, `ru`, `de`, `ja`, `ko`, `nl`, and `el`; front **5** / block **50–69** (assigned **51–63**); human `help` and human `about` | Translating command output, flag names, paths, argv `version`, or JSON about fields |
| File `${HOME}/.local/${APP_NAME}/language` | Putting that file in the scratch/cache resolver, or creating the directory on `help` / `version` |

## 2. Core Rules / Requirements (Mandatory)

**Claimed:** yes. Default language is English so an existing menu test keeps matching English words. The other twelve codes are the operator’s choice, stored for the next run. Order on the board: English, Simplified Chinese, Traditional Chinese, then the remaining codes by native-speaker count.

### 2.1 Languages

| Code | Name on the language board | Number | Default |
|------|----------------------------|--------|---------|
| `en` | English | **51** | yes |
| `zh-Hans` | 简体中文 | **52** | no |
| `zh-Hant` | 繁體中文 | **53** | no |
| `es` | Español | **54** | no |
| `ar` | العربية | **55** | no |
| `fr` | Français | **56** | no |
| `pt` | Português | **57** | no |
| `ru` | Русский | **58** | no |
| `de` | Deutsch | **59** | no |
| `ja` | 日本語 | **60** | no |
| `ko` | 한국어 | **61** | no |
| `nl` | Nederlands | **62** | no |
| `el` | Ελληνικά | **63** | no |

**MUST** accept only these thirteen codes in this version. The language board uses only numbers **50** through **69**. That block is twenty numbers, so this menu has **not more than 20 languages**. This version assigns thirteen: **51** through **63**. **50** and **64** through **69** are reserved and are not printed. A pick of one of those reserved numbers warns, reprints this board, and does not write the file. **MUST NOT** assign a language row outside **50–69**. **MUST NOT** assign more than twenty language rows. **MUST** treat a missing file, an empty file, or any other first line as English for this process. **MUST NOT** rewrite a file whose first line is not one of these codes. **MUST NOT** add a fourteenth code without a new revision of this file.

The short names on the language board are the same words in every language (each language’s own name).

### 2.2 Where the choice is stored

1. The leaf is `${HOME}/.local/${APP_NAME}/language`. **MUST NOT** put it in the scratch/cache path from `util_resolve_storage`. **MUST NOT** put it under `/var/sudoer-cli`.
2. The file is one line, one of `en`, `zh-Hans`, `zh-Hant`, `es`, `ar`, `fr`, `pt`, `ru`, `de`, `ja`, `ko`, `nl`, or `el`, then a newline. Mode **0600**. A trailing CR is ignored. Only the first line is read.
3. `util_persistent_storage_dir` only prints `${HOME}/.local/${APP_NAME}`. It does **not** create the directory.
4. `app_lang_load` sets `APP_LANG` once, inside `app_main`, after storage resolve and flag parse, including TTY empty argv and `--json` with no command. Off-TTY empty argv may load too; the load is read-only and **MUST NOT** create `~/.local/${APP_NAME}`. Human `help`, human `about`, and the numbered menu in that process see the loaded value. TTY empty argv and TTY `--debug` with no command **MUST** show the front board in `APP_LANG`. **MUST NOT** call `app_lang_load` again in that same process: a later call would let `SUDOER_CLI_LANG` cover a pick just saved.
5. When `SUDOER_CLI_LANG` is one of those thirteen codes, that value wins over the file for this process. It does not write the file. A menu pick still writes the file and sets `APP_LANG` for the rest of that process.
6. `app_lang_save` creates the directory, writes the line, sets mode **0600**, and sets `APP_LANG` only after the write succeeds. A code outside the thirteen returns failure and leaves `APP_LANG` unchanged. A failed `mkdir` or write returns failure, warns (`lang_save_fail`), and does **not** `out_die`. The front board still redisplays.

### 2.3 Menu numbers

Front **5** opens `app_cmd_menu_language`. The English short token is **`languages`**. Typed `language` and the translated shorts also open it: `語言`, `语言`, `idiomas`, `idioma`, `langues`, `langue`, `Sprachen`, `Sprache`, `言語`, `언어`, `لغات`, `لغة`, `языки`, `язык`, `talen`, `taal`, `γλώσσες`, `γλώσσα`.

**51** saves `en`. **52** saves `zh-Hans`. **53** saves `zh-Hant`. **54** saves `es`. **55** saves `ar`. **56** saves `fr`. **57** saves `pt`. **58** saves `ru`. **59** saves `de`. **60** saves `ja`. **61** saves `ko`. **62** saves `nl`. **63** saves `el`. Each successful save prints an info line in the new language, then the front board redisplays in that language. **0** / empty / EOF on the language board is Back and does not write the file. An invalid choice on that board warns and reprints **that** board.

The language board accepts:

| Row | Typed tokens |
|-----|----------------|
| **51** | `english`, `en`, `English` |
| **52** | `simplified-chinese`, `zh-hans`, `zh-Hans`, `简体中文` |
| **53** | `traditional-chinese`, `zh-hant`, `zh-Hant`, `繁體中文` |
| **54** | `spanish`, `es`, `Español`, `español` |
| **55** | `arabic`, `ar`, `العربية`, `عربي` |
| **56** | `french`, `fr`, `Français`, `français` |
| **57** | `portuguese`, `pt`, `Português`, `português`, `portugues` |
| **58** | `russian`, `ru`, `Русский`, `русский` |
| **59** | `german`, `de`, `Deutsch`, `deutsch` |
| **60** | `japanese`, `ja`, `日本語` |
| **61** | `korean`, `ko`, `한국어` |
| **62** | `dutch`, `nl`, `Nederlands`, `nederlands` |
| **63** | `greek`, `el`, `Ελληνικά`, `ελληνικά` |

`language` and `languages` are not argv verbs. Picking **51** on the **front** board is an invalid front choice. The operator enters **5** first. Front **6** is `add-sudoer-request`. It does not open the language board.

The choice on both boards **MUST** be current-shell `prompt_ask "$(app_menu_text choice_label)" ""` then `${PROMPT_ASK_VALUE}`. English `choice_label` is `Choice`, so the visible prompt is `Choice: `. **MUST NOT** capture `prompt_ask` with `$()` or backticks.

Row **5** is numbered on every host, including Termux, Git Bash, and Windows cmd. It is not a hide cause. Exit on the front board stays **99**.

### 2.4 What follows the saved language

**MUST** follow `APP_LANG` on the front board and the language board: header, row longs, Back, Exit, the choice label, and the unknown-choice line.

**MUST** keep each operational command token as the Latin verb in every language (`sudoers-to-json`, `add-sudoer-request`, `interactive`, and the other row tokens). The languages short follows `APP_LANG` (`languages` in English). The approval-family short follows `APP_LANG` (`approval features` in English). The sudoers-family short stays the Latin token `sudoers` in every language.

**MUST** follow `APP_LANG` on human `help` and human `about`. Section headings and the words after each command token follow the code. The command token, the flag, the path, and the env name stay the Latin spelling (`install`, `--json`, `SCRIPT_URL`, `SUDOER_CLI_LANG`). English `help` still prints `Usage:` and `Global Options:`. The English menu sentence in `help` names **51** English through **63** Greek, and names front **5**. The other codes use their own usage heading: `用法：`, `Uso:`, `Utilisation :`, `Verwendung:`, `الاستخدام:`, `Использование:`, `Gebruik:`, `Χρήση:`, `使い方:`, `사용법:`. English `about` still prints `About / Diagnostics`. Japanese about prints `概要 / 診断` and `使用中のストレージ`. Korean about prints `개요 / 진단`.

`app_menu_text` prints the chosen string. Its body **MUST** stay free of the four letters r, e, a, d in a row, so a command substitution of that function stays legal. Callers pass the string to `out_menu_choice`, `out_info`, `out_warn`, `out_plain`, `out_success`, or `out_error`.

**Stays English in this version:** argv `version` (`app_version`), operational command output, JSON about keys and values, flag glosses under Global Options, environment notes, and example command lines. Headings of those sections follow `APP_LANG`.

After a successful save the info line is printed after `APP_LANG` has changed:

| Code | Saved |
|------|--------|
| `en` | `Menu language is English` |
| `zh-Hans` | `菜单语言是简体中文` |
| `zh-Hant` | `選單語言是繁體中文` |
| `es` | `El idioma del menú es español` |
| `ar` | `لغة القائمة هي العربية` |
| `fr` | `La langue du menu est le français` |
| `pt` | `O idioma do menu é português` |
| `ru` | `Язык меню — русский` |
| `de` | `Die Menüsprache ist Deutsch` |
| `ja` | `メニューの言語は日本語` |
| `ko` | `메뉴 언어는 한국어` |
| `nl` | `De menutaal is Nederlands` |
| `el` | `Η γλώσσα του μενού είναι ελληνικά` |

A failed write warns in the language that was current before the failed write and leaves `APP_LANG` unchanged. English text: `Could not save the menu language`.

Back and Exit:

| Code | Back | Exit |
|------|------|------|
| `en` | `0. Back` | `99. Exit` |
| `zh-Hans` | `0. 返回` | `99. 离开` |
| `zh-Hant` | `0. 返回` | `99. 離開` |
| `es` | `0. Atrás` | `99. Salir` |
| `ar` | `0. رجوع` | `99. خروج` |
| `fr` | `0. Retour` | `99. Quitter` |
| `pt` | `0. Voltar` | `99. Sair` |
| `ru` | `0. Назад` | `99. Выход` |
| `de` | `0. Zurück` | `99. Beenden` |
| `ja` | `0. 戻る` | `99. 終了` |
| `ko` | `0. 뒤로` | `99. 종료` |
| `nl` | `0. Terug` | `99. Afsluiten` |
| `el` | `0. Πίσω` | `99. Έξοδος` |

### 2.5 Worked sample (English)

Plain text of the front board, then the language board. The version token is the live `VERSION`. Choice prompt ends with the colon-space from `prompt_ask`.

```text
[INFO] sudoer-cli(1.31.0) — numbered list of live commands
1. approval features: Queue, list, show, and decide requests
5. languages: display language for this menu
7. sudoers: Convert and print sudoers text
99. Exit
Choice:
```

Row **1** then lists `add-sudoer-request`, `update-sudoer-request`, `remove-sudoer-request`, `list-approving`, `list-approved`, `list-rejected`, `show`, `remove-lpu`, `approve`, `reject`, and `interactive`, plus `0. Back` and `99. Exit`. Row **7** then lists `sudoers-to-json`, `json-to-sudoers`, `print-sudoers`, and `print-sudoers-install-script`, plus `0. Back` and `99. Exit`.

```text
[INFO] sudoer-cli(1.31.0) — languages
51. English: use English for this menu
52. 简体中文: use Simplified Chinese for this menu
53. 繁體中文: use Traditional Chinese for this menu
54. Español: use Spanish for this menu
55. العربية: use Arabic for this menu
56. Français: use French for this menu
57. Português: use Portuguese for this menu
58. Русский: use Russian for this menu
59. Deutsch: use German for this menu
60. 日本語: use Japanese for this menu
61. 한국어: use Korean for this menu
62. Nederlands: use Dutch for this menu
63. Ελληνικά: use Greek for this menu
0. Back
Choice:
```

Ship-unit functions: `util_persistent_storage_dir`, `app_lang_load`, `app_lang_save`, `app_menu_text`, `app_cmd_menu_language`. Proof **TP-CLI-24**.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows cmd, or the same class (no root login on that shell):

| MUST | MUST NOT |
|------|----------|
| Keep **normal user privilege** only | Turn on **admin privilege** or **dedicated system user privilege** |
| Offer row **5** and write the language file under this login’s `HOME` | Require root to change the menu language |

**This requirement:** the language file is this login’s file. It MUST NOT write `/etc` or a dedicated-account home.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Missing or garbage language file stays English and is not rewritten.
- **Intentional**: One code, one file, thirteen names.
- **Anti-fragile**: A failed save warns and returns to the front board.
- **Over-protect**: `help` and `version` do not create `~/.local/sudoer-cli`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Add a fourteenth language code without a new revision of this file.
2. Number a language outside **50–69**, or print **50** or **64–69**.
3. Put the language file in the scratch resolver or under `/var/sudoer-cli`.
4. Create `~/.local/${APP_NAME}` on `help`, `version`, or `about`.
5. Call `app_lang_load` again after a menu pick in the same process.
6. Capture `prompt_ask` with `$()` or backticks.
7. Put the four letters r, e, a, d in a row inside `app_menu_text`.
8. Translate argv `version`, JSON about fields, or operational command output in this version.
9. Treat front **6** as the language board, or treat **51** on the front board as a language save. Front **6** is not a command row.

**Violating this rule is a critical menu-language regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Front **5** opens rows **51–63** and `0. Back`; **50** and **64–69** are not printed |
| AC-2 | A listed language writes `${HOME}/.local/${APP_NAME}/language` mode **0600** and redisplays the front board in that language |
| AC-3 | **0** / empty on the language board does not write the file |
| AC-4 | Reserved **50** / **64** / **69** warn and do not write the file |
| AC-5 | An unrecognized first line stays English and is not rewritten |
| AC-6 | `SUDOER_CLI_LANG` wins for that process and does not rewrite the file |
| AC-7 | Japanese and Korean `help` / `about` follow the code; English `help` still prints `Usage:` and `Global Options:` |
| AC-8 | `help` does not create the language file |
| AC-9 | TTY empty argv and TTY `--debug` with `SUDOER_CLI_LANG=ja` show `99. 終了` and do not write the language file |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-default-interaction` | Front row **5**, Exit **99**, invalid-choice retry; TTY empty argv uses this copy |
| `requirement-shell-cli-zero-arguments` | TTY empty argv opens the translated front board; off-TTY stays Type O |
| `requirement-shell-cli-storage` | Persistence leaf vs scratch resolver |
| `requirement-shell-prompt` | `prompt_ask` / `PROMPT_ASK_VALUE` |
| `requirement-shell-cli-interface` | Human `help` / `about`; argv `version` stays English |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-24** | `tests/test_cli.sh` | have | Rows 51–63, save, Back, reserved, env override, ja/ko help and about |
| **TP-CLI-29** | `tests/test_cli.sh` | have | TTY empty argv and TTY `--debug` with `SUDOER_CLI_LANG=ja` show `99. 終了` and do not write the language file |
| **TP-CLI-20** | `tests/test_cli.sh` | have | Exit **99** lives in `app_menu_text` `line_exit` |
| **TP-CLI-22** | `tests/test_cli.sh` | have | Unused front integer **17** reprints the front board (Exit **99**) |
| **TP-ELEV-10** | `tests/test_cli.sh` | have | Both boards call `prompt_ask "$(app_menu_text choice_label)"` |

**Matrix:** `reviews/requirement-test-matrix.md`
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-10-04 | Active 1.2.0 | Rows **51–63** stay the sibling grok-cli names and order. **50** and **64–69** stay unprinted. Front **1** and **7** are families, not language rows. Ship unit **1.31.0**. |
| 2026-10-04 | Active 1.1.0 | `app_lang_load` runs for TTY empty argv and for `--json` with no command. TTY `--debug` shows the front board in `APP_LANG`. Proof **TP-CLI-29**. Ship unit **1.30.0**. |
| 2026-10-02 | Active 1.0.0 | Menu **5** languages; block **50–69** assigned **51–63**; `SUDOER_CLI_LANG`; proof **TP-CLI-24**. Ship unit **1.29.0**. |

---

**Last Updated**: 2026-10-04
**Owner**: project maintainers
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
