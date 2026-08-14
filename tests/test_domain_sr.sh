# =============================================================================
# tests/test_domain_sr.sh — sudoers-request domain (TP-SR-*, TP-SR-PRIV-01)
# Primary REQ: requirement-domain-sudoer-approval.md
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_sr_sample_sudoers() {
    _u=$(id -un)
    cat <<EOF
# Purpose: Allow this user to reload nginx and read the nginx unit journal.
${_u} ALL=(root) NOPASSWD: /bin/systemctl reload nginx
${_u} ALL=(root) NOPASSWD: /usr/bin/journalctl -u nginx
${_u} ALL=(root) NOPASSWD: /usr/sbin/nginx -t
EOF
}

_sr_sample_json() {
    _u=$(id -un)
    cat <<EOF
{"schema_version":1,"purpose":"Allow this user to reload nginx and read the nginx unit journal.","username":"${_u}","service":"webservice","action":"add","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/systemctl","args":["reload","nginx"]},{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/journalctl","args":["-u","nginx"]},{"runas":"root","tags":["NOPASSWD"],"path":"/usr/sbin/nginx","args":["-t"]}]}
EOF
}

run_test_domain_sr() {
    t_header "Domain sudoers-request (TP-SR)"

    ci_isolated_env
    export SUDOER_CLI_ALLOW_TEST_ROOTS=1
    _q="${CI_HOME}/queues"
    mkdir -p "${_q}/sudoer-approving" "${_q}/sudoer-approved" "${_q}/sudoer-rejected"
    _abs_in="${CI_HOME}/in.sudoers"
    _abs_json="${CI_HOME}/out.json"
    _abs_back="${CI_HOME}/back.sudoers"
    _sr_sample_sudoers >"${_abs_in}"
    _sr_sample_json >"${CI_HOME}/add.json"

    # TP-SR-03 / 07 / 09 convert add sample
    HOME="${CI_HOME}" sh "${SCRIPT}" sudoers-to-json --file "${_abs_in}" --action add --out "${_abs_json}" >/dev/null 2>&1
    assert_eq "TP-SR-03 sudoers-to-json exit 0" 0 "$?"
    _js=$(cat "${_abs_json}")
    assert_contains "TP-SR-07 json service webservice" "${_js}" '"service":"webservice"'
    assert_contains "TP-SR-07 json systemctl" "${_js}" '"path":"/bin/systemctl"'
    assert_contains "TP-SR-02 schema_version" "${_js}" '"schema_version":1'

    HOME="${CI_HOME}" sh "${SCRIPT}" json-to-sudoers --file "${_abs_json}" --out "${_abs_back}" >/dev/null 2>&1
    assert_eq "TP-SR-03 json-to-sudoers exit 0" 0 "$?"
    _back=$(cat "${_abs_back}")
    assert_contains "TP-SR-07 sudoers purpose" "${_back}" "# Purpose: Allow this user to reload nginx"
    assert_contains "TP-SR-07 sudoers systemctl" "${_back}" "/bin/systemctl reload nginx"
    assert_contains "TP-SR-07 sudoers journalctl" "${_back}" "/usr/bin/journalctl -u nginx"
    assert_contains "TP-SR-07 sudoers nginx -t" "${_back}" "/usr/sbin/nginx -t"

    HOME="${CI_HOME}" sh "${SCRIPT}" sudoers-to-json --file "${_abs_back}" --action add --out "${CI_HOME}/round.json" >/dev/null 2>&1
    _rj=$(cat "${CI_HOME}/round.json")
    assert_contains "TP-SR-09 round-trip webservice" "${_rj}" '"service":"webservice"'

    # TP-SR-08 remove purpose-only
    printf '%s\n' '{"purpose":"Revoke my webservice sudoers grant; I no longer operate nginx."}' >"${CI_HOME}/rm.json"
    HOME="${CI_HOME}" sh "${SCRIPT}" json-to-sudoers --file "${CI_HOME}/rm.json" --out "${CI_HOME}/rm.sudoers" >/dev/null 2>&1
    assert_eq "TP-SR-08 remove convert exit 0" 0 "$?"
    _rm=$(cat "${CI_HOME}/rm.sudoers")
    assert_contains "TP-SR-08 purpose line" "${_rm}" "# Purpose: Revoke my webservice"
    assert_not_contains "TP-SR-08 no spec line" "${_rm}" "ALL=("

    # TP-SR-10 mixed families
    _u=$(id -un)
    cat >"${CI_HOME}/mix.sudoers" <<EOF
# Purpose: mix
${_u} ALL=(root) NOPASSWD: /usr/sbin/nginx -t
${_u} ALL=(root) NOPASSWD: /usr/bin/gitlab-ctl status
EOF
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" sudoers-to-json --file "${CI_HOME}/mix.sudoers" --action add --out "${CI_HOME}/mix.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-10 mixed exit 1" 1 "$?"
    assert_contains "TP-SR-10 mixed families" "${_err}" "mixed service"

    # TP-SR-11 remove extra fields
    printf '%s\n' '{"purpose":"x","commands":[{"path":"/bin/true","args":[],"runas":"root","tags":[]}]}' >"${CI_HOME}/badrm.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" json-to-sudoers --file "${CI_HOME}/badrm.json" --out "${CI_HOME}/badrm.out" 2>&1 >/dev/null)
    assert_eq "TP-SR-11 extra commands exit 1" 1 "$?"
    assert_contains "TP-SR-11 remove_extra_fields" "${_err}" "must not include commands"

    # TP-SR-12 relative queue root
    _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root relative list-approving 2>&1 >/dev/null)
    assert_eq "TP-SR-12 relative queue exit 1" 1 "$?"
    assert_contains "TP-SR-12 absolute required" "${_err}" "absolute"

    # TP-SR-01 / 05 / 13 submit + request_id
    _out=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" add-sudoer-request --file "${_abs_json}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-SR-05 submit exit 0" 0 "$_ec"
    assert_contains "TP-SR-13 request_id field" "${_out}" '"request_id":"sudoer-'
    assert_contains "TP-SR-13 request_id .json" "${_out}" '.json"'
    assert_contains "TP-SR-06 dest service-user" "${_out}" '"dest":"webservice-'"${_u}"'"'
    _rid=$(printf '%s' "${_out}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    case "${_rid}" in
        sudoer-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-webservice-"${_u}"-add-[0-9]*.json)
            t_pass "TP-SR-01 basename grammar"
            ;;
        *)
            t_fail "TP-SR-01 basename grammar (got '${_rid}')"
            ;;
    esac
    assert_file_exists "TP-SR-05 queued file" "${_q}/sudoer-approving/${_rid}"

    _lst=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" list-approving 2>/dev/null)
    assert_contains "TP-SR-05 list-approving shows id" "${_lst}" "${_rid}"

    _shown=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" show "${_rid}" 2>/dev/null)
    assert_contains "TP-SR-05 show purpose" "${_shown}" "Allow this user to reload nginx"

    # TP-SR-04 per-dir override
    _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --request-dir /tmp/sr-req-rel list-approving 2>&1 >/dev/null)
    # /tmp/sr-req-rel is absolute but may not exist — require_queues may create under test roots
    # Use a relative per-dir instead:
    _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --request-dir not-abs list-approving 2>&1 >/dev/null)
    assert_eq "TP-SR-04 relative request-dir exit 1" 1 "$?"
    assert_contains "TP-SR-04 relative request-dir" "${_err}" "absolute"

    # TP-SR-PRIV-01 Type 1 without root
    if [ "$(id -u)" -ne 0 ]; then
        _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" setup 2>&1 >/dev/null)
        assert_eq "TP-SR-PRIV-01 setup exit 1" 1 "$?"
        assert_contains "TP-SR-PRIV-01 setup authz" "${_err}" "euid 0"
        _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" approve "${_rid}" 2>&1 >/dev/null)
        assert_eq "TP-SR-PRIV-01 approve exit 1" 1 "$?"
        assert_file_missing "TP-SR-PRIV-01 no dest written" "${CI_HOME}/sudoers.d/webservice-${_u}"
        assert_file_exists "TP-SR-PRIV-01 still approving" "${_q}/sudoer-approving/${_rid}"
    else
        t_skip "TP-SR-PRIV-01 running as root"
    fi

    # TP-SR-06 dest name never *-remove
    _out=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" remove-sudoer-request --service webservice --purpose "Revoke my webservice sudoers grant; I no longer operate nginx." 2>/dev/null)
    assert_contains "TP-SR-06 remove dest not *-remove" "${_out}" '"dest":"webservice-'"${_u}"'"'
    _destf=$(printf '%s' "${_out}" | sed -n 's/.*"dest":"\([^"]*\)".*/\1/p')
    assert_eq "TP-SR-06 dest basename" "webservice-${_u}" "${_destf}"

    # Hyphenated service aligns with project-sudoers-file {{APP_NAME}}-{{TARGET_USER}}
    cat >"${CI_HOME}/fb.json" <<EOF
{"schema_version":1,"purpose":"Allow this user to deposit folder-backup archives.","username":"${_u}","service":"folder-backup","action":"add","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/mkdir","args":["-p","/var/backup/folder-backup"]}]}
EOF
    _out=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" add-sudoer-request --file "${CI_HOME}/fb.json" 2>/dev/null)
    assert_eq "TP-SR-01 folder-backup submit exit 0" 0 "$?"
    assert_contains "TP-SR-06 folder-backup dest" "${_out}" '"dest":"folder-backup-'"${_u}"'"'
    _fbrid=$(printf '%s' "${_out}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    case "${_fbrid}" in
        sudoer-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-folder-backup-"${_u}"-add-[0-9]*.json)
            t_pass "TP-SR-01 folder-backup basename"
            ;;
        *)
            t_fail "TP-SR-01 folder-backup basename (got '${_fbrid}')"
            ;;
    esac

    unset SUDOER_CLI_ALLOW_TEST_ROOTS
    ci_cleanup_env
}
