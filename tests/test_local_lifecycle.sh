# =============================================================================
# tests/test_local_lifecycle.sh — channel install / self-uninstall / 0755
# =============================================================================
# Primary REQs: requirement-shell-self-management, requirement-shell-cli-zero-arguments,
# requirement-shell-idempotency, requirement-shell-interactive-vs-noninteractive
# TP family: TP-LC-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_local_lifecycle() {
    t_header "Install lifecycle (TP-LC / TP-CSUM, local channel)"

    require_cmd sh
    require_cmd curl
    require_cmd python3
    require_cmd sha256sum

    # --- TP-LC-18 / TP-INST-MAYBE-01: helper itself under JSON/QUIET ---
    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi
    ci_source_ship_unit
    EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)
    export EFFECTIVE_STORAGE_DIR TMPDIR="${EFFECTIVE_STORAGE_DIR}"
    SCRIPT_URL="${CI_SCRIPT_URL}"
    TTY=0
    FORCE_REINSTALL=0

    JSON=1
    QUIET=1
    inst_maybe_install >/dev/null 2>"${CI_HOME}/maybe-json.err"
    _ec=$?
    assert_eq "TP-LC-18 JSON helper not-installed exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-18 JSON helper placed binary" "${CI_USER_BIN}/${APP_NAME}"

    rm -f "${CI_USER_BIN}/${APP_NAME}"
    JSON=0
    QUIET=1
    inst_maybe_install >/dev/null 2>"${CI_HOME}/maybe-quiet.err"
    _ec=$?
    assert_eq "TP-LC-18 QUIET helper not-installed exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-18 QUIET helper placed binary" "${CI_USER_BIN}/${APP_NAME}"

    JSON=0
    QUIET=0
    rm -f "${CI_USER_BIN}/${APP_NAME}"
    ci_stop_channel
    ci_cleanup_env

    ci_isolated_env
    ci_source_ship_unit
    EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)
    export EFFECTIVE_STORAGE_DIR TMPDIR="${EFFECTIVE_STORAGE_DIR}"
    SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-unreachable"
    JSON=1
    QUIET=1
    TTY=0
    FORCE_REINSTALL=0
    inst_maybe_install >/dev/null 2>"${CI_HOME}/maybe-fail.err"
    _ec=$?
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-LC-18 JSON helper bad channel exits non-zero"
    else
        t_fail "TP-LC-18 JSON helper bad channel expected non-zero (fake success skip)"
    fi
    assert_file_missing "TP-LC-18 JSON helper bad channel left no binary" "${CI_USER_BIN}/${APP_NAME}"
    JSON=0
    QUIET=0
    ci_cleanup_env

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi

    _run() {
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
            SCRIPT_URL="${CI_SCRIPT_URL}" sh "${SCRIPT}" "$@"
    }
    _app_bin="${CI_USER_BIN}/${APP_NAME}"
    _errf="${CI_HOME}/lc-err.txt"

    # TP-LC-01 install places binary under USER_BIN from the channel
    _out=$(_run --json install 2>&1)
    _ec=$?
    assert_eq "TP-LC-01 install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-01 binary at USER_BIN" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-01 install success" "${_out}" "successfully installed"

    # TP-LC-02 installed version works
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        sh "${CI_USER_BIN}/${APP_NAME}" version 2>/dev/null)
    assert_eq "TP-LC-02 installed version exit 0" 0 "$?"
    assert_contains "TP-LC-02 installed version" "$_out" "${PRODUCT_VERSION}"

    # TP-LC-03 idempotent reinstall without force
    _out=$(_run --json install 2>&1)
    _ec=$?
    assert_eq "TP-LC-03 reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-03 already installed" "${_out}" "already installed"

    # TP-LC-04 about reports installed (where-is-me dropped; about owns paths)
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" sh "${CI_USER_BIN}/${APP_NAME}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-LC-04 about exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 json installed true" "${_out}" '"installed":"true"'
    assert_contains "TP-LC-04 json script_url" "${_out}" "script_url"

    # TP-LC-05 self-uninstall --json without force fails closed
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        sh "${CI_USER_BIN}/${APP_NAME}" --json self-uninstall 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-LC-05 self-uninstall json no-force exit 1" 1 "$_ec"
    assert_file_exists "TP-LC-05 binary remains" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-05 confirm_required" "${_err}" "confirm_required"

    # TP-LC-06 self-uninstall --force removes
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        sh "${CI_USER_BIN}/${APP_NAME}" self-uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-06 self-uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-06 binary removed" "${CI_USER_BIN}/${APP_NAME}"

    # TP-LC-07 self-uninstall when absent is success no-op
    _out=$(_run self-uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-07 self-uninstall absent exit 0" 0 "$_ec"
    assert_contains "TP-LC-07 nothing to uninstall" "${_out}" "not installed"

    # TP-LC-08 about after install shows installed
    _run --json install >/dev/null 2>&1
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" sh "${CI_USER_BIN}/${APP_NAME}" --json about 2>/dev/null)
    assert_contains "TP-LC-08 about installed true" "${_out}" '"installed":"true"'

    # TP-LC-09 managed binary mode must be 0755
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-09 install mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-09 install mode 0755" "0755" "${_mode}" ;;
    esac
    if [ -r "${CI_USER_BIN}/${APP_NAME}" ] && [ -x "${CI_USER_BIN}/${APP_NAME}" ]; then
        assert_eq "TP-LC-09 readable+executable" "1" "1"
    else
        assert_eq "TP-LC-09 readable+executable" "1" "0"
    fi

    # TP-LC-10 re-install without --force heals broken mode (0711 trap)
    chmod 0711 "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || chmod 711 "${CI_USER_BIN}/${APP_NAME}"
    _out=$(_run install 2>&1)
    _ec=$?
    assert_eq "TP-LC-10 heal reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-10 already installed path" "${_out}" "already installed"
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-10 healed mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-10 healed mode 0755" "0755" "${_mode}" ;;
    esac

    # Type O empty argv when installed is ensure, not help
    _out=$(_run </dev/null 2>&1)
    _ec=$?
    assert_eq "TP-LC-11 empty argv installed exit 0" 0 "$_ec"
    assert_contains "TP-LC-11 empty argv already installed" "${_out}" "already installed"
    assert_not_contains "TP-LC-11 empty argv not help" "${_out}" "Global Options"

    # TP-LC-12 version-check against local channel
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_app_bin}" --json version-check 2>"${_errf}")
    _ec=$?
    assert_eq "TP-LC-12 version-check --json exit 0" 0 "$_ec"
    assert_contains "TP-LC-12 version-check --json type" "$_out" '"type":"ver_check"'
    assert_contains "TP-LC-12 version-check --json local_version" "$_out" "\"local_version\":\"${PRODUCT_VERSION}\""
    assert_contains "TP-LC-12 version-check --json remote_version" "$_out" "\"remote_version\":\"${PRODUCT_VERSION}\""
    assert_contains "TP-LC-12 version-check --json is_latest true" "$_out" '"is_latest":"true"'
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_app_bin}" version-check 2>/dev/null)
    _ec=$?
    assert_eq "TP-LC-12 version-check human exit 0" 0 "$_ec"
    assert_contains "TP-LC-12 version-check human local" "$_out" "Local version"
    assert_contains "TP-LC-12 version-check human remote" "$_out" "Latest version"

    # TP-LC-13 self-update already-latest
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_app_bin}" --json self-update 2>"${_errf}")
    _ec=$?
    assert_eq "TP-LC-13 self-update already-latest exit 0" 0 "$_ec"
    assert_contains "TP-LC-13 self-update already-latest success" "$_out" '"type":"out_success"'
    assert_contains "TP-LC-13 self-update already-latest message" "$_out" "Already running the latest version"

    # TP-CSUM-02 human --force install transparency
    _out=$(_run --force install 2>"${_errf}")
    _ec=$?
    assert_eq "TP-CSUM-02 human --force install exit 0" 0 "$_ec"
    assert_contains "TP-CSUM-02 companion link" "$_out" "Companion link:"
    assert_contains "TP-CSUM-02 expected digest" "$_out" "Expected SHA-256:"
    assert_contains "TP-CSUM-02 actual digest" "$_out" "Actual SHA-256:"
    assert_contains "TP-CSUM-02 PASS result" "$_out" "Automatic checksum result: PASS"
    assert_contains "TP-CSUM-02 verified flag" "$_out" "cryptographically verified"

    # TP-LC-15 Case C: empty argv when global path present
    _global_bin="${CI_HOME}/global-bin-case-c"
    mkdir -p "${_global_bin}"
    cp "${SCRIPT}" "${_global_bin}/${APP_NAME}"
    chmod +x "${_global_bin}/${APP_NAME}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${_global_bin}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" sh "${SCRIPT}" </dev/null 2>"${_errf}")
    _ec=$?
    assert_eq "TP-LC-15 empty argv when installed (global) exit 0" 0 "$_ec"
    assert_contains "TP-LC-15 empty argv global already installed" "$_out" "already installed"
    assert_not_contains "TP-LC-15 empty argv global not help" "$_out" "Global Options"
    rm -f "${_global_bin}/${APP_NAME}"

    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        sh "${_app_bin}" self-uninstall --force >/dev/null 2>&1 || true

    # TP-LC-14 first empty argv (not installed) places binary
    _out=$(_run </dev/null 2>"${_errf}")
    _ec=$?
    assert_eq "TP-LC-14 empty argv first install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-14 empty argv first install binary" "${_app_bin}"
    assert_not_contains "TP-LC-14 empty argv first install not help" "$_out" "Global Options"

    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        sh "${_app_bin}" self-uninstall --force >/dev/null 2>&1 || true

    # TP-CSUM-01 publisher companion matches ship unit
    _repo_hex=$(awk '{print $1; exit}' "${REPO_ROOT}/src/${APP_NAME}.sha256" 2>/dev/null || true)
    _live_hex=$(sha256sum "${SCRIPT}" | awk '{print $1}')
    assert_eq "TP-CSUM-01 repo sidecar matches ship unit" "${_live_hex}" "${_repo_hex}"

    # TP-CSUM-03 strict CHECKSUM pin mismatch aborts
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        CHECKSUM="0000000000000000000000000000000000000000000000000000000000000000" \
        sh "${SCRIPT}" --json install 2>"${_errf}")
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-CSUM-03 CHECKSUM mismatch aborts (non-zero)" 1 "$_ec"
    assert_contains "TP-CSUM-03 checksum_mismatch code" "$_err" "checksum_mismatch"
    assert_contains "TP-CSUM-03 mismatch human" "$_err" "does not match"
    assert_file_missing "TP-CSUM-03 no install after bad CHECKSUM" "${_app_bin}"

    # TP-CSUM-04 strict CHECKSUM pin match succeeds
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" CHECKSUM="${_live_hex}" \
        sh "${SCRIPT}" --json install 2>"${_errf}")
    _ec=$?
    assert_eq "TP-CSUM-04 CHECKSUM match install exit 0" 0 "$_ec"
    assert_file_exists "TP-CSUM-04 install with good CHECKSUM" "${_app_bin}"

    # TP-LC-16 / TP-LC-17 downgrade refuse without --force; allow with --force
    _older="${CI_CHANNEL_DIR}/src/${APP_NAME}"
    # shellcheck disable=SC2016
    sed "s/^VERSION=\"${PRODUCT_VERSION}\"/VERSION=\"0.9.0\"/" "${SCRIPT}" > "${_older}"
    printf '%s\n' "$(sha256sum "${_older}" | awk '{print $1}')" > "${CI_CHANNEL_DIR}/src/${APP_NAME}.sha256"
    assert_file_exists "TP-LC-16 local binary present for downgrade" "${_app_bin}"

    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_app_bin}" --json self-update 2>"${_errf}")
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-LC-16 self-update downgrade without --force exit 1" 1 "$_ec"
    assert_contains "TP-LC-16 downgrade_blocked code" "$_err" "downgrade_blocked"
    assert_contains "TP-LC-16 downgrade human" "$_err" "use --force"
    _loc=$(grep '^VERSION="' "${_app_bin}" | cut -d'"' -f2)
    assert_eq "TP-LC-16 local version unchanged after refused downgrade" "${PRODUCT_VERSION}" "$_loc"

    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_app_bin}" --json --force self-update 2>"${_errf}")
    _ec=$?
    assert_eq "TP-LC-17 self-update --force downgrade exit 0" 0 "$_ec"
    _loc=$(grep '^VERSION="' "${_app_bin}" | cut -d'"' -f2)
    assert_eq "TP-LC-17 local version after forced downgrade" "0.9.0" "$_loc"

    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_app_bin}" self-uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env
}
