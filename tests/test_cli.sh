# =============================================================================
# tests/test_cli.sh — CLI surface (local-only; no network)
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-zero-arguments,
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

    # TP-CLI-04 help lists local lifecycle; not online; not trimmed parent domain
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-04 help where-is-me" "$_out" "where-is-me"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_not_contains "TP-CLI-04 no backup verb" "$_out" "backup <"
    assert_not_contains "TP-CLI-04 no restore verb" "$_out" "restore <"
    assert_contains "TP-CLI-04 help sudoers-to-json" "$_out" "sudoers-to-json"
    assert_contains "TP-CLI-04 help json-to-sudoers" "$_out" "json-to-sudoers"
    assert_contains "TP-CLI-04 help test-json-format" "$_out" "test-json-format"
    assert_contains "TP-CLI-04 help test-well-known-binary" "$_out" "test-well-known-binary"
    assert_contains "TP-CLI-04 help fence-test" "$_out" "fence-test"
    assert_contains "TP-CLI-04 help unit test heading" "$_out" "Unit test (local test folder; Type 0 — test-purpose):"
    assert_contains "TP-CLI-04 help operational heading" "$_out" "Sudoers requests (Type 0 — operational):"
    assert_contains "TP-CLI-04 help add-sudoer-request" "$_out" "add-sudoer-request"
    assert_contains "TP-CLI-04 help update-sudoer-request" "$_out" "update-sudoer-request"
    assert_contains "TP-CLI-04 help remove-sudoer-request" "$_out" "remove-sudoer-request"
    assert_contains "TP-CLI-04 help print-sudoers" "$_out" "print-sudoers"
    assert_contains "TP-CLI-04 help print-sudoers-install-script" "$_out" "print-sudoers-install-script"
    assert_contains "TP-CLI-04 help list-approved" "$_out" "list-approved"
    assert_contains "TP-CLI-04 help list-rejected" "$_out" "list-rejected"
    assert_not_contains "TP-CLI-04 no self-update" "$_out" "self-update"
    assert_not_contains "TP-CLI-04 no self-uninstall" "$_out" "self-uninstall"
    assert_not_contains "TP-CLI-04 no version-check" "$_out" "version-check"
    assert_not_contains "TP-CLI-04 no SCRIPT_URL channel" "$_out" "SCRIPT_URL"
    assert_not_contains "TP-CLI-04 no CHECKSUM" "$_out" "CHECKSUM"

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
    assert_not_contains "TP-CLI-06 no SCRIPT_URL" "$_out" "SCRIPT_URL"

    # TP-CLI-07 empty argv = Type N help (not install)
    _out=$(sh "${SCRIPT}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 empty argv exit 0" 0 "$_ec"
    assert_contains "TP-CLI-07 empty argv is help" "$_out" "Usage:"
    assert_contains "TP-CLI-07 empty argv mentions Type N or help" "$_out" "help"

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

    # TP-CLI-10 online verbs rejected
    _err=$(sh "${SCRIPT}" self-update 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 self-update exit 1" 1 "$?"
    assert_contains "TP-CLI-10 self-update unknown" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" version-check 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 version-check exit 1" 1 "$?"

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
