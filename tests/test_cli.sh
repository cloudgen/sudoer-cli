# =============================================================================
# tests/test_cli.sh — CLI surface (online-installable Type O)
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-zero-arguments,
# requirement-shell-cli-default-interaction, requirement-shell-cli-language,
# requirement-shell-output-requirements, requirement-shell-cli-storage
# TP family: TP-CLI-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface (TP-CLI)"

    require_cmd sh
    require_cmd grep

    # TP-CLI-01 syntax
    sh -n "${SCRIPT}"
    assert_eq "TP-CLI-01 sh -n ship unit" 0 "$?"

    # TP-CLI-02 version human
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version mentions app" "$_out" "${APP_NAME}"
    assert_contains "TP-CLI-02 version mentions VERSION" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-03 version json
    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 type version" "$_out" '"type":"version"'
    assert_contains "TP-CLI-03 app field" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "TP-CLI-03 version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # TP-CLI-04 help lists online lifecycle; not trimmed parent domain
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help self-update" "$_out" "self-update"
    assert_contains "TP-CLI-04 help self-uninstall" "$_out" "self-uninstall"
    assert_contains "TP-CLI-04 help version-check" "$_out" "version-check"
    assert_contains "TP-CLI-04 help menu" "$_out" "menu / main"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_not_contains "TP-CLI-04 no backup verb" "$_out" "backup <"
    assert_not_contains "TP-CLI-04 no restore verb" "$_out" "restore <"
    assert_contains "TP-CLI-04 help sudoers-to-json" "$_out" "sudoers-to-json"
    assert_contains "TP-CLI-04 help json-to-sudoers" "$_out" "json-to-sudoers"
    assert_contains "TP-CLI-04 help test-json-format" "$_out" "test-json-format"
    assert_contains "TP-CLI-04 help test-well-known-binary" "$_out" "test-well-known-binary"
    assert_contains "TP-CLI-04 help fence-test" "$_out" "fence-test"
    assert_contains "TP-CLI-04 help rc-test" "$_out" "rc-test"
    assert_contains "TP-CLI-04 help lists BASHRC" "$_out" "BASHRC"
    assert_contains "TP-CLI-04 help unit test heading" "$_out" "Unit tests (local test folder; does not queue):"
    assert_not_contains "TP-CLI-04 rc-test not under install-only" "$_out" "  rc-test              Place"
    assert_contains "TP-CLI-04 help operational heading" "$_out" "Convert, queue, and list requests:"
    assert_not_contains "TP-CLI-04 help headings not Type-N lead" "$_out" "Type 0 —"
    assert_not_contains "TP-CLI-04 help print-sudoers not F6 lead" "$_out" "Emit F6 Table A"
    assert_contains "TP-CLI-04 help add-sudoer-request" "$_out" "add-sudoer-request"
    assert_contains "TP-CLI-04 help update-sudoer-request" "$_out" "update-sudoer-request"
    assert_contains "TP-CLI-04 help remove-sudoer-request" "$_out" "remove-sudoer-request"
    assert_contains "TP-CLI-04 help print-sudoers" "$_out" "print-sudoers"
    assert_contains "TP-CLI-04 help print-sudoers-install-script" "$_out" "print-sudoers-install-script"
    assert_contains "TP-CLI-04 help list-approved" "$_out" "list-approved"
    assert_contains "TP-CLI-04 help list-rejected" "$_out" "list-rejected"
    assert_contains "TP-CLI-04 help SCRIPT_URL" "$_out" "SCRIPT_URL"
    assert_not_contains "TP-CLI-04 no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-04 no where-is-me" "$_out" "where-is-me"
    assert_not_contains "TP-CLI-04 no bare uninstall row" "$_out" "  uninstall            "

    # TP-CLI-05 help json
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    assert_eq "TP-CLI-05 help --json exit 0" 0 "$?"
    assert_contains "TP-CLI-05 help json success" "$_out" '"type":"success"'

    # TP-CLI-06 about json storage, no channel, no domain backup fields
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-06 type about" "$_out" '"type":"about"'
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
    assert_not_contains "TP-CLI-06 no backup_notation" "$_out" '"backup_notation"'
    assert_not_contains "TP-CLI-06 no deposit_dir" "$_out" '"deposit_dir"'
    assert_not_contains "TP-CLI-06 no restore_host_default" "$_out" '"restore_host_default"'
    assert_not_contains "TP-CLI-06 no CHECKSUM" "$_out" "CHECKSUM"
    assert_contains "TP-CLI-06 json script_url" "$_out" '"script_url"'
    assert_not_contains "TP-CLI-06 no CHECKSUM key" "$_out" '"checksum"'

    # TP-CLI-07 empty argv is Type O install-ensure, not help
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/sudoer-cli-unreachable" sh "${SCRIPT}" </dev/null 2>/dev/null)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-CLI-07 empty argv dead channel exits non-zero"
    else
        t_fail "TP-CLI-07 empty argv dead channel expected non-zero"
    fi
    assert_not_contains "TP-CLI-07 empty argv is not help" "${_out}" "Usage:"
    ci_cleanup_env

    # TP-CLI-08 unknown command fail-closed
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown error text" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" --json no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown --json type" "$_err" '"type":"out_error"'

    # TP-CLI-09 quiet suppresses version info
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-09 quiet version exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-09 quiet suppresses human version"
    else
        t_fail "TP-CLI-09 quiet expected empty stdout, got '$(_trunc "$_out")'"
    fi

    # TP-CLI-10 online verbs are routed (not unknown)
    ci_isolated_env
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/sudoer-cli-unreachable" sh "${SCRIPT}" self-update 2>&1 >/dev/null)
    assert_not_contains "TP-CLI-10 self-update not unknown" "${_err}" "Unknown command"
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/sudoer-cli-unreachable" sh "${SCRIPT}" version-check 2>&1 >/dev/null)
    assert_not_contains "TP-CLI-10 version-check not unknown" "${_err}" "Unknown command"
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        sh "${SCRIPT}" self-uninstall --force 2>&1 >/dev/null)
    assert_not_contains "TP-CLI-10 self-uninstall not unknown" "${_err}" "Unknown command"
    ci_cleanup_env

    # TP-CLI-11 set -u HOME unset still works for version
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-11 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-11 env -u HOME version text" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-12 storage isolation under temp HOME
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in storage" "$_out" "${APP_NAME}"
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-12 effective_storage directory exists"
    else
        t_fail "TP-CLI-12 effective_storage missing: '${_eff:-empty}'"
    fi
    ci_cleanup_env

    # TP-CLI-13 trimmed parent (non-product) verbs fail closed
    for _verb in backup restore remove-project-sudoers; do
        _err=$(sh "${SCRIPT}" "${_verb}" 2>&1 >/dev/null)
        _ec=$?
        assert_eq "TP-CLI-13 ${_verb} exit 1" 1 "$_ec"
        assert_contains "TP-CLI-13 ${_verb} unknown" "$_err" "Unknown command"
    done

    # TP-CLI-14 unrouted leftover names stay unknown; routed domain verbs are known
    _err=$(sh "${SCRIPT}" not-a-sudoer-verb 2>&1 >/dev/null)
    assert_eq "TP-CLI-14 unknown domain-like exit 1" 1 "$?"
    assert_contains "TP-CLI-14 unknown" "$_err" "Unknown command"
    _err=$(sh "${SCRIPT}" sudoers-to-json 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-14 sudoers-to-json routed (xor fail not unknown)" 1 "$_ec"
    assert_not_contains "TP-CLI-14 sudoers-to-json not unknown" "$_err" "Unknown command"
    _err=$(sh "${SCRIPT}" test-json-format 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-14 test-json-format routed (xor fail not unknown)" 1 "$_ec"
    assert_not_contains "TP-CLI-14 test-json-format not unknown" "$_err" "Unknown command"
    _err=$(sh "${SCRIPT}" test-well-known-binary 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-15 test-well-known-binary routed (xor fail not unknown)" 1 "$_ec"
    assert_not_contains "TP-CLI-15 test-well-known-binary not unknown" "$_err" "Unknown command"
    _err=$(sh "${SCRIPT}" fence-test 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-16 fence-test routed (xor fail not unknown)" 1 "$_ec"
    assert_not_contains "TP-CLI-16 fence-test not unknown" "$_err" "Unknown command"

    # TP-CLI-17 default-cli-main-menu-style printers (claimed menu uses them)
    _th=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.menu.XXXXXX")
    _runner="${_th}/run-style.sh"
    {
        sed -n '/^out_text()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'out_menu_choice() { out_text menu_choice "" "${1-}" "${2-}" "${3-}"; }'
        sed -n '/^util_app_ident()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'APP_NAME=sudoer-cli'
        printf '%s\n' 'APP_LANG=en'
        printf '%s\n' "VERSION='${PRODUCT_VERSION}'"
        printf '%s\n' 'JSON=0; QUIET=0'
        printf '%s\n' 'TTY=0'
        printf '%s\n' 'printf "OFFIDENT:%s\n" "$(util_app_ident)"'
        printf '%s\n' 'printf "OFFROW:"'
        printf '%s\n' 'out_menu_choice 1 convert "Turn sudoers text into JSON"'
        printf '%s\n' 'TTY=1'
        printf '%s\n' 'printf "ONIDENT:%s\n" "$(util_app_ident)"'
        printf '%s\n' 'printf "ONROW:"'
        printf '%s\n' 'out_menu_choice 1 convert "Turn sudoers text into JSON"'
    } >"${_runner}"
    _out=$(sh "${_runner}")
    assert_contains "TP-CLI-17 off-TTY ident is APP_NAME(VERSION)" "${_out}" "OFFIDENT:sudoer-cli(${PRODUCT_VERSION})"
    assert_not_contains "TP-CLI-17 off-TTY ident has no CSI" "${_out}" "$(printf 'OFFIDENT:\033')"
    assert_contains "TP-CLI-17 off-TTY row is plain" "${_out}" "OFFROW:1. convert: Turn sudoers text into JSON"
    assert_contains "TP-CLI-17 TTY ident bold SGR" "${_out}" "$(printf 'ONIDENT:\033[1msudoer-cli\033[0m(\033[3m%s\033[0m)' "${PRODUCT_VERSION}")"
    assert_contains "TP-CLI-17 TTY row gray italic explain" "${_out}" "$(printf '\033[3;37mTurn sudoers text into JSON\033[0m')"
    assert_contains "TP-CLI-17 TTY row keeps unstyled name" "${_out}" "ONROW:1. convert: "
    rm -rf "${_th}"

    # TP-CLI-18: menu / main routed; empty argv is Type O (not help)
    _out=$(sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-18 menu off-TTY exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-18 menu off-TTY is help" "${_out}" "Usage:"
    assert_not_contains "TP-CLI-18 menu off-TTY not unknown" "${_out}" "Unknown command"
    _out=$(sh "${SCRIPT}" main 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-18 main off-TTY exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-18 main off-TTY is help" "${_out}" "Usage:"
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/sudoer-cli-unreachable" sh "${SCRIPT}" </dev/null 2>/dev/null)
    assert_not_contains "TP-CLI-18 empty argv not help" "${_out}" "Usage:"
    assert_not_contains "TP-CLI-18 empty argv not Choice prompt" "${_out}" "Choice:"
    ci_cleanup_env

    # TP-CLI-19: off-TTY menu follows json; --quiet must not swallow help
    _out=$(sh "${SCRIPT}" --json menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-19 menu --json off-TTY exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-19 menu --json is JSON help" "${_out}" '"type":"success"'
    assert_not_contains "TP-CLI-19 menu --json not numbered header" "${_out}" "numbered list of live commands"
    _out=$(sh "${SCRIPT}" --quiet menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-19 menu --quiet off-TTY exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-19 menu --quiet still prints help" "${_out}" "Usage:"

    # TP-CLI-20: membership + Exit 99 (N=16; Exit text lives in app_menu_text)
    _fn=$(sed -n '/^app_main_menu_print()/,/^}/p' "${SCRIPT}")
    _cat=$(sed -n '/^app_menu_text()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CLI-20 row sudoers-to-json" "${_fn}" "sudoers-to-json"
    assert_contains "TP-CLI-20 row interactive" "${_fn}" "interactive"
    assert_contains "TP-CLI-20 row languages" "${_fn}" "app_menu_text cat_languages"
    assert_contains "TP-CLI-20 print calls Exit key" "${_fn}" "app_menu_text line_exit"
    assert_contains "TP-CLI-20 Exit 99" "${_cat}" '*) _mt_out="99. Exit"'
    assert_not_contains "TP-CLI-20 no 16. Exit" "${_fn}${_cat}" "16. Exit"
    assert_not_contains "TP-CLI-20 no 17. Exit" "${_fn}${_cat}" "17. Exit"
    assert_not_contains "TP-CLI-20 no help row" "${_fn}" 'out_menu_choice 'help
    if printf '%s\n' "${_fn}" | grep -E 'out_menu_choice [0-9]+ install ' >/dev/null; then
        t_fail "TP-CLI-20 install must not be a numbered choice"
    else
        t_pass "TP-CLI-20 no install choice"
    fi
    assert_not_contains "TP-CLI-20 no setup choice" "${_fn}" 'out_menu_choice 12 setup'
    assert_not_contains "TP-CLI-20 no version choice" "${_fn}" "out_menu_choice"version
    assert_not_contains "TP-CLI-20 no about as choice name" "${_fn}" 'out_menu_choice '*' about '
    assert_not_contains "TP-CLI-20 no test-json-format" "${_fn}" "test-json-format"
    assert_not_contains "TP-CLI-20 no test-well-known-binary" "${_fn}" "test-well-known-binary"
    assert_not_contains "TP-CLI-20 no fence-test" "${_fn}" "fence-test"
    assert_not_contains "TP-CLI-20 no rc-test" "${_fn}" "rc-test"
    assert_not_contains "TP-CLI-20 no menu as choice" "${_fn}" 'out_menu_choice '*' menu '
    assert_contains "TP-CLI-20 remove-lpu is a row" "${_fn}" "remove-lpu"
    assert_not_contains "TP-CLI-20 print-sudoers label not F6" "${_fn}" "F6 Table A"
    assert_not_contains "TP-CLI-20 remove-lpu label not LPU jargon" "${_fn}" "Teardown LPU"
    assert_not_contains "TP-CLI-20 interactive label not TTY-loop jargon" "${_fn}" "TTY review loop"

    # TP-CLI-21: interactive menu ignores --json (draw list, not JSON help)
    _th=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.menu21.XXXXXX")
    _runner="${_th}/run-menu.sh"
    {
        printf '%s\n' 'set -u'
        sed -n '/^out_text()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'out_info() { out_text out_info "$*"; }'
        printf '%s\n' 'out_plain() { out_text plain "$*"; }'
        printf '%s\n' 'out_menu_choice() { out_text menu_choice "" "${1-}" "${2-}" "${3-}"; }'
        printf '%s\n' 'out_die() { printf "DIE:%s\n" "$*"; exit 1; }'
        printf '%s\n' 'out_error() { printf "ERROR:%s\n" "$*"; }'
        sed -n '/^util_app_ident()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_menu_text()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu_print()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'APP_NAME=sudoer-cli'
        printf '%s\n' 'APP_LANG=en'
        printf '%s\n' "VERSION='${PRODUCT_VERSION}'"
        printf '%s\n' 'prompt_ask() { PROMPT_ASK_VALUE=99; }'
        printf '%s\n' 'app_help() { printf "%s\n" HELPPATH; }'
        printf '%s\n' 'app_run_command() { printf "%s\n" RAN; }'
        printf '%s\n' 'TTY=1; JSON=1; QUIET=1; PROMPT_ASK_VALUE='
        printf '%s\n' 'app_main_menu'
    } >"${_runner}"
    _out=$(sh "${_runner}")
    _ec=$?
    assert_eq "TP-CLI-21 interactive menu --json exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-21 interactive menu --json draws list" "${_out}" "numbered list of live commands"
    assert_not_contains "TP-CLI-21 interactive menu --json not help path" "${_out}" "HELPPATH"
    assert_contains "TP-CLI-21 interactive menu --json Exit 99" "${_out}" "99. Exit"
    rm -rf "${_th}"

    # TP-CLI-22: invalid choice retries this layer (portable TP-CLI-19 already names off-TTY menu help)
    _th=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.menu22.XXXXXX")
    _runner="${_th}/run-retry.sh"
    {
        printf '%s\n' 'set -u'
        sed -n '/^out_text()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'out_info() { out_text out_info "$*"; }'
        printf '%s\n' 'out_plain() { out_text plain "$*"; }'
        printf '%s\n' 'out_menu_choice() { out_text menu_choice "" "${1-}" "${2-}" "${3-}"; }'
        printf '%s\n' 'out_die() { printf "DIE:%s\n" "$*"; exit 1; }'
        printf '%s\n' 'out_error() { printf "ERROR:%s\n" "$*"; }'
        sed -n '/^util_app_ident()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_menu_text()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu_print()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'APP_NAME=sudoer-cli'
        printf '%s\n' 'APP_LANG=en'
        printf '%s\n' "VERSION='${PRODUCT_VERSION}'"
        printf '%s\n' '_asks=0'
        printf '%s\n' 'prompt_ask() {'
        printf '%s\n' '  _asks=$((_asks + 1))'
        printf '%s\n' '  if [ "${_asks}" -eq 1 ]; then PROMPT_ASK_VALUE=17; else PROMPT_ASK_VALUE=99; fi'
        printf '%s\n' '}'
        printf '%s\n' 'app_help() { printf "%s\n" HELPPATH; }'
        printf '%s\n' 'app_run_command() { printf "%s\n" RAN; }'
        printf '%s\n' 'TTY=1; JSON=0; QUIET=0; PROMPT_ASK_VALUE='
        printf '%s\n' 'app_main_menu'
    } >"${_runner}"
    _out=$(sh "${_runner}")
    _ec=$?
    assert_eq "TP-CLI-22 unused 17 exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-22 unused 17 is ERROR" "${_out}" "ERROR:Unknown menu choice '17'"
    assert_contains "TP-CLI-22 unused 17 says not on this list" "${_out}" "not on this list"
    assert_not_contains "TP-CLI-22 unused 17 is not DIE" "${_out}" "DIE:"
    assert_not_contains "TP-CLI-22 unused 17 is not unknown argv" "${_out}" "Unknown command"
    assert_not_contains "TP-CLI-22 unused 17 did not run a handler" "${_out}" "RAN"
    _exit_n=$(printf '%s' "${_out}" | grep -c "99. Exit" || true)
    if [ "${_exit_n}" -ge 2 ]; then
        t_pass "TP-CLI-22 unused 17 reprints this layer (${_exit_n} Exit rows)"
    else
        t_fail "TP-CLI-22 unused 17 reprints this layer (Exit rows=${_exit_n}, want >=2)"
    fi
    {
        printf '%s\n' 'set -u'
        sed -n '/^out_text()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'out_info() { out_text out_info "$*"; }'
        printf '%s\n' 'out_plain() { out_text plain "$*"; }'
        printf '%s\n' 'out_menu_choice() { out_text menu_choice "" "${1-}" "${2-}" "${3-}"; }'
        printf '%s\n' 'out_die() { printf "DIE:%s\n" "$*"; exit 1; }'
        printf '%s\n' 'out_error() { printf "ERROR:%s\n" "$*"; }'
        sed -n '/^util_app_ident()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_menu_text()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu_print()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'APP_NAME=sudoer-cli'
        printf '%s\n' 'APP_LANG=en'
        printf '%s\n' "VERSION='${PRODUCT_VERSION}'"
        printf '%s\n' '_asks=0'
        printf '%s\n' 'prompt_ask() {'
        printf '%s\n' '  _asks=$((_asks + 1))'
        printf '%s\n' '  if [ "${_asks}" -eq 1 ]; then PROMPT_ASK_VALUE=not-a-command; else PROMPT_ASK_VALUE=99; fi'
        printf '%s\n' '}'
        printf '%s\n' 'app_help() { printf "%s\n" HELPPATH; }'
        printf '%s\n' 'app_run_command() { printf "%s\n" RAN; }'
        printf '%s\n' 'TTY=1; JSON=0; QUIET=0; PROMPT_ASK_VALUE='
        printf '%s\n' 'app_main_menu'
    } >"${_runner}"
    _out=$(sh "${_runner}")
    _ec=$?
    assert_eq "TP-CLI-22 unknown name exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-22 unknown name is ERROR" "${_out}" "ERROR:Unknown menu choice 'not-a-command'"
    assert_not_contains "TP-CLI-22 unknown name is not DIE" "${_out}" "DIE:"
    assert_not_contains "TP-CLI-22 unknown name did not run a handler" "${_out}" "RAN"
    _exit_n2=$(printf '%s' "${_out}" | grep -c "99. Exit" || true)
    if [ "${_exit_n2}" -ge 2 ]; then
        t_pass "TP-CLI-22 unknown name reprints this layer (${_exit_n2} Exit rows)"
    else
        t_fail "TP-CLI-22 unknown name reprints this layer (Exit rows=${_exit_n2}, want >=2)"
    fi
    {
        printf '%s\n' 'set -u'
        sed -n '/^out_text()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'out_info() { out_text out_info "$*"; }'
        printf '%s\n' 'out_plain() { out_text plain "$*"; }'
        printf '%s\n' 'out_menu_choice() { out_text menu_choice "" "${1-}" "${2-}" "${3-}"; }'
        printf '%s\n' 'out_die() { printf "DIE:%s\n" "$*"; exit 1; }'
        printf '%s\n' 'out_error() { printf "ERROR:%s\n" "$*"; }'
        sed -n '/^util_app_ident()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_menu_text()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu_print()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'APP_NAME=sudoer-cli'
        printf '%s\n' 'APP_LANG=en'
        printf '%s\n' "VERSION='${PRODUCT_VERSION}'"
        printf '%s\n' '_asks=0'
        printf '%s\n' 'prompt_ask() {'
        printf '%s\n' '  _asks=$((_asks + 1))'
        printf '%s\n' '  if [ "${_asks}" -eq 1 ]; then PROMPT_ASK_VALUE=17; else PROMPT_ASK_VALUE=1; fi'
        printf '%s\n' '}'
        printf '%s\n' 'app_help() { printf "%s\n" HELPPATH; }'
        printf '%s\n' 'app_run_command() { printf "%s\n" RAN:"${COMMAND}"; }'
        printf '%s\n' 'TTY=1; JSON=0; QUIET=0; PROMPT_ASK_VALUE=; COMMAND='
        printf '%s\n' 'app_main_menu'
    } >"${_runner}"
    _out=$(sh "${_runner}")
    _ec=$?
    assert_eq "TP-CLI-22 retry then listed 1 exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-22 retry then listed 1 still ERROR first" "${_out}" "ERROR:Unknown menu choice '17'"
    assert_contains "TP-CLI-22 retry then listed 1 runs handler" "${_out}" "RAN:sudoers-to-json"
    assert_not_contains "TP-CLI-22 retry then listed 1 is not DIE" "${_out}" "DIE:"
    rm -rf "${_th}"

    _menu=$(sed -n '/^app_main_menu()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CLI-22 menu invalid uses out_error" "${_menu}" 'out_error "$(app_menu_text unknown_front'
    assert_not_contains "TP-CLI-22 menu invalid does not out_die" "${_menu}" 'out_die "Unknown choice'
    assert_contains "TP-CLI-22 menu layer retry loop" "${_menu}" "Invalid choice retries this layer"
    assert_contains "TP-CLI-22 nested layer comment present" "${_menu}" "Nested numbered submenu"

    # TP-ELEV-10: do-not-capture-read (portable TP-CLI-16 hosted here; product TP-CLI-16 is fence-test)
    _menu=$(sed -n '/^app_main_menu()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-ELEV-10 menu calls prompt_ask" "${_menu}" 'prompt_ask "$(app_menu_text choice_label)"'
    assert_contains "TP-ELEV-10 menu reads PROMPT_ASK_VALUE" "${_menu}" 'PROMPT_ASK_VALUE'
    _langm=$(sed -n '/^app_cmd_menu_language()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-ELEV-10 language menu calls prompt_ask" "${_langm}" 'prompt_ask "$(app_menu_text choice_label)"'
    _menu_live=$(printf '%s\n' "${_menu}" | grep -v '^[[:space:]]*#' || true)
    if printf '%s\n' "${_menu_live}" | grep -E '\$\(prompt_|`prompt_' >/dev/null; then
        t_fail "TP-ELEV-10 app_main_menu must not \$() prompt_ask"
    else
        t_pass "TP-ELEV-10 app_main_menu no \$() of prompt_ask"
    fi
    _cap_bad=0
    while IFS= read -r _cl; do
        [ -n "${_cl}" ] || continue
        case "${_cl}" in
            *'#'*) continue ;;
            *) _cap_bad=1 ;;
        esac
    done <<EOF
$(grep -n '$(prompt_\|`prompt_' "${SCRIPT}" || true)
EOF
    if [ "${_cap_bad}" -eq 0 ]; then
        t_pass "TP-ELEV-10 ship unit has no live \$() of prompt_"
    else
        t_fail "TP-ELEV-10 live \$() of prompt_ still present"
    fi
    _pask=$(sed -n '/^prompt_ask()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-ELEV-10 prompt_ask assigns PROMPT_ASK_VALUE" "${_pask}" "PROMPT_ASK_VALUE="

    # TP-CLI-24: menu 5 languages. prompt_ask is stubbed so the runner does not read /dev/tty.
    _th=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.menu24.XXXXXX")
    _runner="${_th}/run-lang.sh"
    {
        printf '%s\n' 'set -u'
        sed -n '/^out_text()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'out_info() { out_text out_info "$*"; }'
        printf '%s\n' 'out_plain() { out_text plain "$*"; }'
        printf '%s\n' 'out_warn() { out_text out_warn "$*"; }'
        printf '%s\n' 'out_menu_choice() { out_text menu_choice "" "${1-}" "${2-}" "${3-}"; }'
        printf '%s\n' 'out_die() { printf "DIE:%s\n" "$*"; exit 1; }'
        printf '%s\n' 'out_error() { printf "ERROR:%s\n" "$*"; }'
        sed -n '/^util_app_ident()/,/^}/p' "${SCRIPT}"
        sed -n '/^util_persistent_storage_dir()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_lang_load()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_lang_save()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_menu_text()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_cmd_menu_language()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu_print()/,/^}/p' "${SCRIPT}"
        sed -n '/^app_main_menu()/,/^}/p' "${SCRIPT}"
        printf '%s\n' "APP_NAME=${APP_NAME}"
        printf '%s\n' "VERSION='${PRODUCT_VERSION}'"
        printf '%s\n' 'app_run_command() { printf "RAN:%s\n" "${COMMAND}"; }'
        printf '%s\n' 'app_help() { printf "%s\n" HELPPATH; }'
        printf '%s\n' 'prompt_ask() { IFS= read -r PROMPT_ASK_VALUE || PROMPT_ASK_VALUE=; }'
        printf '%s\n' 'TTY=1; JSON=0; QUIET=0; PROMPT_ASK_VALUE=; COMMAND='
        printf '%s\n' 'app_lang_load'
        printf '%s\n' 'app_main_menu'
    } >"${_runner}"
    _lhome="${_th}/home"
    mkdir -p "${_lhome}"
    _lfile="${_lhome}/.local/${APP_NAME}/language"
    _out=$(printf '%s\n' '5' '0' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    _ec=$?
    assert_eq "TP-CLI-24 open language then Back exit 0" 0 "${_ec}"
    assert_contains "TP-CLI-24 front language long" "${_out}" "display language for this menu"
    assert_contains "TP-CLI-24 language row 51" "${_out}" "51."
    assert_contains "TP-CLI-24 language English" "${_out}" "English"
    assert_contains "TP-CLI-24 language row 52" "${_out}" "52."
    assert_contains "TP-CLI-24 language Simplified Chinese" "${_out}" "简体中文"
    assert_contains "TP-CLI-24 language Simplified Chinese long" "${_out}" "use Simplified Chinese for this menu"
    assert_contains "TP-CLI-24 language row 53" "${_out}" "53."
    assert_contains "TP-CLI-24 language Traditional Chinese" "${_out}" "繁體中文"
    assert_contains "TP-CLI-24 language Traditional Chinese long" "${_out}" "use Traditional Chinese for this menu"
    assert_contains "TP-CLI-24 language row 54" "${_out}" "54."
    assert_contains "TP-CLI-24 language Spanish" "${_out}" "Español"
    assert_contains "TP-CLI-24 language row 55" "${_out}" "55."
    assert_contains "TP-CLI-24 language Arabic" "${_out}" "العربية"
    assert_contains "TP-CLI-24 language row 56" "${_out}" "56."
    assert_contains "TP-CLI-24 language French" "${_out}" "Français"
    assert_contains "TP-CLI-24 language row 57" "${_out}" "57."
    assert_contains "TP-CLI-24 language Portuguese" "${_out}" "Português"
    assert_contains "TP-CLI-24 language row 58" "${_out}" "58."
    assert_contains "TP-CLI-24 language Russian" "${_out}" "Русский"
    assert_contains "TP-CLI-24 language row 59" "${_out}" "59."
    assert_contains "TP-CLI-24 language German" "${_out}" "Deutsch"
    assert_contains "TP-CLI-24 language row 60" "${_out}" "60."
    assert_contains "TP-CLI-24 language Japanese" "${_out}" "日本語"
    assert_contains "TP-CLI-24 language row 61" "${_out}" "61."
    assert_contains "TP-CLI-24 language Korean" "${_out}" "한국어"
    assert_contains "TP-CLI-24 language row 62" "${_out}" "62."
    assert_contains "TP-CLI-24 language Dutch" "${_out}" "Nederlands"
    assert_contains "TP-CLI-24 language row 63" "${_out}" "63."
    assert_contains "TP-CLI-24 language Greek" "${_out}" "Ελληνικά"
    assert_contains "TP-CLI-24 front language row 5" "${_out}" "5."
    assert_not_contains "TP-CLI-24 no reserved row 50" "${_out}" "50."
    assert_not_contains "TP-CLI-24 no reserved row 64" "${_out}" "64."
    assert_not_contains "TP-CLI-24 no reserved row 69" "${_out}" "69."
    assert_contains "TP-CLI-24 language Back" "${_out}" "0. Back"
    assert_file_missing "TP-CLI-24 Back does not write language" "${_lfile}"
    _out=$(printf '%s\n' '5' '50' '0' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 reserved 50 warns" "${_out}" "Unknown menu choice '50'"
    assert_file_missing "TP-CLI-24 reserved 50 does not write language" "${_lfile}"
    _out=$(printf '%s\n' '5' '64' '0' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 reserved 64 warns" "${_out}" "Unknown menu choice '64'"
    assert_file_missing "TP-CLI-24 reserved 64 does not write language" "${_lfile}"
    _out=$(printf '%s\n' '5' '69' '0' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 reserved 69 warns" "${_out}" "Unknown menu choice '69'"
    assert_file_missing "TP-CLI-24 reserved 69 does not write language" "${_lfile}"
    _out=$(printf '%s\n' '6' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 front 6 runs add-sudoer-request" "${_out}" "RAN:add-sudoer-request"
    assert_not_contains "TP-CLI-24 front 6 does not open language rows" "${_out}" "51."
    assert_file_missing "TP-CLI-24 front 6 does not write language" "${_lfile}"
    _out=$(printf '%s\n' '51' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 front 51 is not a language save" "${_out}" "Unknown menu choice '51'"
    assert_not_contains "TP-CLI-24 front 51 did not run a handler" "${_out}" "RAN:"
    assert_file_missing "TP-CLI-24 front 51 does not write language" "${_lfile}"
    _out=$(printf '%s\n' 'languages' '0' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 name languages opens the board" "${_out}" "0. Back"
    assert_file_missing "TP-CLI-24 name languages Back does not write" "${_lfile}"
    _out=$(printf '%s\n' '5' '' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 empty on language board is Back" "${_out}" "0. Back"
    assert_not_contains "TP-CLI-24 empty Back did not save" "${_out}" "Menu language is"
    assert_file_missing "TP-CLI-24 empty Back does not write language" "${_lfile}"
    while IFS='|' read -r _num _code _saved _lexit; do
        [ -n "${_num}" ] || continue
        _out=$(printf '%s\n' '5' "${_num}" '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
        _ec=$?
        assert_eq "TP-CLI-24 choose ${_code} exit 0" 0 "${_ec}"
        assert_contains "TP-CLI-24 ${_code} saved" "${_out}" "${_saved}"
        assert_contains "TP-CLI-24 ${_code} Exit" "${_out}" "${_lexit}"
        _got=$(head -n 1 "${_lfile}" | tr -d '\r')
        assert_eq "TP-CLI-24 file is ${_code}" "${_code}" "${_got}"
    done <<'EOF'
51|en|Menu language is English|99. Exit
52|zh-Hans|菜单语言是简体中文|99. 离开
53|zh-Hant|選單語言是繁體中文|99. 離開
54|es|El idioma del menú es español|99. Salir
55|ar|لغة القائمة هي العربية|99. خروج
56|fr|La langue du menu est le français|99. Quitter
57|pt|O idioma do menu é português|99. Sair
58|ru|Язык меню — русский|99. Выход
59|de|Die Menüsprache ist Deutsch|99. Beenden
60|ja|メニューの言語は日本語|99. 終了
61|ko|메뉴 언어는 한국어|99. 종료
62|nl|De menutaal is Nederlands|99. Afsluiten
63|el|Η γλώσσα του μενού είναι ελληνικά|99. Έξοδος
EOF
    _mode=$(stat -c '%a' "${_lfile}" 2>/dev/null || stat -f '%OLp' "${_lfile}")
    assert_eq "TP-CLI-24 language file mode 600" "600" "${_mode}"
    _out=$(printf '%s\n' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 next run stays Greek" "${_out}" "99. Έξοδος"
    assert_not_contains "TP-CLI-24 next run is not the English header" "${_out}" "numbered list of live commands"
    printf '%s\n' 'nope' > "${_lfile}"
    _out=$(printf '%s\n' '99' | env -u SUDOER_CLI_LANG HOME="${_lhome}" sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 unrecognized file is English" "${_out}" "numbered list of live commands"
    _got=$(head -n 1 "${_lfile}" | tr -d '\r')
    assert_eq "TP-CLI-24 unrecognized file is left as written" "nope" "${_got}"
    printf '%s\n' 'en' > "${_lfile}"
    _out=$(printf '%s\n' '99' | HOME="${_lhome}" SUDOER_CLI_LANG=ja sh "${_runner}" 2>&1)
    assert_contains "TP-CLI-24 SUDOER_CLI_LANG overrides the file" "${_out}" "99. 終了"
    _got=$(head -n 1 "${_lfile}" | tr -d '\r')
    assert_eq "TP-CLI-24 SUDOER_CLI_LANG does not rewrite the file" "en" "${_got}"
    rm -rf "${_th}"

    _h24=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.help24.XXXXXX")
    _out=$(env -u SUDOER_CLI_LANG HOME="${_h24}" SUDOER_CLI_LANG=ja sh "${SCRIPT}" help 2>&1)
    assert_contains "TP-CLI-24 Japanese help heading" "${_out}" "使い方:"
    assert_not_contains "TP-CLI-24 Japanese help is not Usage" "${_out}" "Usage:"
    assert_contains "TP-CLI-24 Japanese help keeps install" "${_out}" "install"
    assert_file_missing "TP-CLI-24 help does not create the language file" "${_h24}/.local/${APP_NAME}/language"
    _out=$(env -u SUDOER_CLI_LANG HOME="${_h24}" SUDOER_CLI_LANG=ko sh "${SCRIPT}" help 2>&1)
    assert_contains "TP-CLI-24 Korean help heading" "${_out}" "사용법:"
    assert_not_contains "TP-CLI-24 Korean help is not Usage" "${_out}" "Usage:"
    _out=$(env -u SUDOER_CLI_LANG HOME="${_h24}" SUDOER_CLI_LANG=ja sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-24 Japanese about title" "${_out}" "概要 / 診断"
    assert_contains "TP-CLI-24 Japanese about storage" "${_out}" "使用中のストレージ"
    assert_not_contains "TP-CLI-24 Japanese about is not About / Diagnostics" "${_out}" "About / Diagnostics"
    _out=$(env -u SUDOER_CLI_LANG HOME="${_h24}" SUDOER_CLI_LANG=ko sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-24 Korean about title" "${_out}" "개요 / 진단"
    assert_not_contains "TP-CLI-24 Korean about is not About / Diagnostics" "${_out}" "About / Diagnostics"
    _out=$(env -u SUDOER_CLI_LANG HOME="${_h24}" SUDOER_CLI_LANG=en sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-CLI-24 English help still says Usage" "${_out}" "Usage:"
    assert_contains "TP-CLI-24 English help still says Global Options" "${_out}" "Global Options"
    assert_contains "TP-CLI-24 English help names Japanese" "${_out}" "60 Japanese"
    assert_contains "TP-CLI-24 English help names Korean" "${_out}" "61 Korean"
    assert_contains "TP-CLI-24 English help names Simplified Chinese" "${_out}" "52 Simplified Chinese"
    _out=$(env -u SUDOER_CLI_LANG HOME="${_h24}" SUDOER_CLI_LANG=ja sh "${SCRIPT}" version 2>/dev/null)
    assert_contains "TP-CLI-24 Japanese version stays the English one-liner" "${_out}" "${PRODUCT_VERSION}"
    assert_not_contains "TP-CLI-24 Japanese version is not a help heading" "${_out}" "使い方:"
    assert_file_missing "TP-CLI-24 version does not create the language file" "${_h24}/.local/${APP_NAME}/language"
    rm -rf "${_h24}"
    unset _out _ec _lhome _lfile _runner _got _mode _num _code _saved _lexit _h24

    # TP-ELEV-07: only top-level measure + sr_read_input data-source may use [ -t 0/1 ]
    # Specified exception: the login-hook *snippet* (rc policy, not CLI TTY SSOT).
    _t_hits=$(grep -n '\[ -t [01] \]' "${SCRIPT}" | grep -v '^[[:space:]]*#' || true)
    _t_bad=0
    while IFS= read -r _tl; do
        [ -n "${_tl}" ] || continue
        case "${_tl}" in
            *"[ -t 0 ] && [ -t 1 ] && TTY=1"*) ;;
            *"sr_read_input"*|*"if [ -t 0 ]; then"*) ;;
            *lpu-hook-rc*) ;;
            *) _t_bad=1 ;;
        esac
    done <<EOF
${_t_hits}
EOF
    if [ "${_t_bad}" -eq 0 ]; then
        t_pass "TP-ELEV-07 [ -t ] only at entry + sr_read_input"
    else
        t_fail "TP-ELEV-07 unexpected [ -t ] policy retest"
    fi

    # TP-ELEV-08: sudo escalation check (T1-BOOTSTRAP-N + T1-N-POLLUTE)
    # Default: do not invoke sudo -n. Mention it only where law specifies (F6 hook).
    _sudo_n_exec=0
    while IFS= read -r _sl; do
        [ -n "${_sl}" ] || continue
        case "${_sl}" in
            *'#'*) continue ;;
            *out_plain*|*out_info*|*out_die*|*out_warn*|*sr_die*) continue ;;
            *_mt_out*) continue ;;
            *lpu-hook-rc*) continue ;;
            *) _sudo_n_exec=1 ;;
        esac
    done <<EOF
$(grep -n 'sudo -n' "${SCRIPT}" || true)
EOF
    if [ "${_sudo_n_exec}" -eq 0 ]; then
        t_pass "TP-ELEV-08 no sudo -n command invocation"
    else
        t_fail "TP-ELEV-08 ship unit must not invoke sudo -n (avoid -n unless specified)"
    fi
    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-ELEV-08 help sudo setup" "${_help}" "sudo ${APP_NAME} setup"
    assert_not_contains "TP-ELEV-08 help not sudo -n setup" "${_help}" "sudo -n ${APP_NAME} setup"
    assert_not_contains "TP-ELEV-08 help not sudo -n install" "${_help}" "sudo -n ${APP_NAME} install"
    assert_contains "TP-ELEV-08 help password sudo OK" "${_help}" "password sudo OK"
    case "${_help}" in
        *'sudo -n'*)
            case "${_help}" in
                *[Ff]6*|*[Hh]ook*)
                    t_pass "TP-ELEV-08 help sudo -n only with specified F6/hook"
                    ;;
                *)
                    t_fail "TP-ELEV-08 help mentions sudo -n without F6/hook (T1-N-POLLUTE)"
                    ;;
            esac
            ;;
        *)
            t_pass "TP-ELEV-08 help has no sudo -n (default avoid)"
            ;;
    esac
    _err=$(sh "${SCRIPT}" setup 2>&1 >/dev/null)
    assert_contains "TP-ELEV-08 setup refuse tells sudo (not -n)" "${_err}" "sudo "
    assert_contains "TP-ELEV-08 setup refuse Next" "${_err}" "Next:"
    assert_contains "TP-ELEV-08 setup refuse names setup" "${_err}" "setup"
    assert_not_contains "TP-ELEV-08 setup refuse not sudo -n" "${_err}" "sudo -n"
    assert_not_contains "TP-ELEV-08 setup refuse no euid" "${_err}" "euid"

    # TP-TMP-01: no predictable sr-*.$$ scratch paths
    if grep -E 'sr-[A-Za-z0-9_.]+\$\$|/tmp/sr-' "${SCRIPT}" >/dev/null 2>&1; then
        t_fail "TP-TMP-01 predictable sr-\$\$, scratch still present"
    else
        t_pass "TP-TMP-01 no sr-\$\$, scratch paths"
    fi

    # TP-SUDO-*: sudo-wrapping function + check before sudo (chmod example)
    if grep -q '^util_sudo()' "${SCRIPT}" && grep -q '^util_chmod()' "${SCRIPT}"; then
        t_pass "TP-SUDO-01 util_sudo and util_chmod defined"
    else
        t_fail "TP-SUDO-01 missing util_sudo / util_chmod"
    fi
    _sudo_at_n=$(grep -cE '^[[:space:]]+sudo "\$@"' "${SCRIPT}" || true)
    if [ "${_sudo_at_n}" -eq 1 ]; then
        t_pass "TP-SUDO-02 sudo \"\$@\" only once (util_sudo)"
    else
        t_fail "TP-SUDO-02 expected one sudo \"\$@\" (got ${_sudo_at_n})"
    fi
    if grep -E '^[[:space:]]+sudo[[:space:]]+chmod' "${SCRIPT}" >/dev/null 2>&1; then
        t_fail "TP-SUDO-03 raw sudo chmod still present"
    else
        t_pass "TP-SUDO-03 no raw sudo chmod"
    fi
    if grep -q 'util_sudo "$@"' "${SCRIPT}"; then
        t_pass "TP-SUDO-04 lpu_sudo / callers use util_sudo"
    else
        t_fail "TP-SUDO-04 no util_sudo \"\$@\" caller"
    fi

    # TP-SUDO-05..07: runtime check before sudo (chmod example + already-root)
    _sd=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.sudo.XXXXXX")
    _sf="${_sd}/owned"
    : >"${_sf}"
    chmod 0600 "${_sf}"
    _runner="${_sd}/run-chmod.sh"
    {
        printf '%s\n' 'set -u'
        sed -n '/^util_sudo()/,/^}/p' "${SCRIPT}"
        sed -n '/^util_chmod()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'sudo() { printf "%s\n" SUDO_CALLED >&2; return 1; }'
        printf '%s\n' "util_chmod 0640 '${_sf}'"
    } >"${_runner}"
    _err=$(sh "${_runner}" 2>&1)
    _ec=$?
    assert_eq "TP-SUDO-05 owned file util_chmod exit 0" 0 "${_ec}"
    assert_not_contains "TP-SUDO-05 owned file no sudo" "${_err}" "SUDO_CALLED"
    _ls=$(ls -l "${_sf}")
    assert_contains "TP-SUDO-05 owned file mode 0640" "${_ls}" "rw-r-----"

    _runner="${_sd}/run-missing.sh"
    {
        printf '%s\n' 'set -u'
        sed -n '/^util_sudo()/,/^}/p' "${SCRIPT}"
        sed -n '/^util_chmod()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'sudo() { printf "%s\n" SUDO_CALLED >&2; return 1; }'
        printf '%s\n' "util_chmod 0640 '${_sd}/missing'"
    } >"${_runner}"
    _err=$(sh "${_runner}" 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-SUDO-06 missing path util_chmod nonzero"
    else
        t_fail "TP-SUDO-06 missing path util_chmod expected nonzero"
    fi
    assert_not_contains "TP-SUDO-06 missing path no sudo" "${_err}" "SUDO_CALLED"

    _runner="${_sd}/run-root.sh"
    {
        printf '%s\n' 'set -u'
        sed -n '/^util_sudo()/,/^}/p' "${SCRIPT}"
        printf '%s\n' 'id() { if [ "${1:-}" = "-u" ]; then printf "%s\n" 0; else command id "$@"; fi; }'
        printf '%s\n' 'sudo() { printf "%s\n" SUDO_CALLED >&2; return 1; }'
        printf '%s\n' 'util_sudo true'
    } >"${_runner}"
    _err=$(sh "${_runner}" 2>&1)
    _ec=$?
    assert_eq "TP-SUDO-07 already-root util_sudo skips sudo" 0 "${_ec}"
    assert_not_contains "TP-SUDO-07 already-root no sudo" "${_err}" "SUDO_CALLED"
    rm -rf "${_sd}"
}
