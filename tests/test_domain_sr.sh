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

# Pretty-printed (newlines/spaces between objects). INC-20260817-001: },{ splitter drops these.
_sr_sample_json_pretty() {
    _u=$(id -un)
    cat <<EOF
{
  "schema_version": 1,
  "purpose": "Allow this user to reload nginx and read the nginx unit journal.",
  "username": "${_u}",
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
EOF
}

_sr_sample_folder_backup_pretty() {
    _u=$(id -un)
    cat <<EOF
{
  "schema_version": 1,
  "purpose": "Allow ${_u} to run folder-backup backup and restore as root.",
  "username": "${_u}",
  "service": "folder-backup",
  "action": "add",
  "commands": [
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/folder-backup",
      "args": ["backup"]
    },
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/folder-backup",
      "args": ["restore"]
    }
  ]
}
EOF
}

run_test_domain_sr() {
    t_header "Domain sudoers-request (TP-SR)"

    ci_isolated_env
    export SUDOER_CLI_ALLOW_TEST_ROOTS=1
    _q="${CI_HOME}/queues"
    mkdir -p "${_q}/sudoer-request" "${_q}/sudoer-approved" "${_q}/sudoer-rejected"
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

    # TP-SR-14 pretty add-sample JSON → all three Cmnd lines
    _sr_sample_json_pretty >"${CI_HOME}/add-pretty.json"
    HOME="${CI_HOME}" sh "${SCRIPT}" json-to-sudoers --file "${CI_HOME}/add-pretty.json" --out "${CI_HOME}/pretty-back.sudoers" >/dev/null 2>&1
    assert_eq "TP-SR-14 pretty json-to-sudoers exit 0" 0 "$?"
    _pback=$(cat "${CI_HOME}/pretty-back.sudoers")
    assert_contains "TP-SR-14 pretty systemctl" "${_pback}" "/bin/systemctl reload nginx"
    assert_contains "TP-SR-14 pretty journalctl" "${_pback}" "/usr/bin/journalctl -u nginx"
    assert_contains "TP-SR-14 pretty nginx -t" "${_pback}" "/usr/sbin/nginx -t"

    # TP-SR-16 pretty folder-backup backup+restore
    _sr_sample_folder_backup_pretty >"${CI_HOME}/fb-pretty.json"
    HOME="${CI_HOME}" sh "${SCRIPT}" json-to-sudoers --file "${CI_HOME}/fb-pretty.json" --out "${CI_HOME}/fb-pretty.sudoers" >/dev/null 2>&1
    assert_eq "TP-SR-16 pretty folder-backup convert exit 0" 0 "$?"
    _fbback=$(cat "${CI_HOME}/fb-pretty.sudoers")
    assert_contains "TP-SR-16 pretty backup verb" "${_fbback}" "folder-backup backup"
    assert_contains "TP-SR-16 pretty restore verb" "${_fbback}" "folder-backup restore"

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
    assert_contains "TP-SR-10 mixed families" "${_err}" "more than one service"
    assert_contains "TP-SR-10 mixed Next" "${_err}" "Next:"
    assert_contains "TP-SR-10 mixed no jargon-only" "${_err}" "one service per request"

    # Infer fail: unclassified Cmnd — operator text + Next: --service
    cat >"${CI_HOME}/unk.sudoers" <<EOF
# Purpose: unknown tool
${_u} ALL=(root) NOPASSWD: /bin/true
EOF
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" sudoers-to-json --file "${CI_HOME}/unk.sudoers" --action add --out "${CI_HOME}/unk.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-10 infer exit 1" 1 "$?"
    assert_contains "TP-SR-10 infer human" "${_err}" "Cannot tell which service"
    assert_contains "TP-SR-10 infer Next" "${_err}" "Next:"
    assert_contains "TP-SR-10 infer --service" "${_err}" "--service"

    # Decode count mismatch: two "path" keys in one object — do not approve
    printf '%s\n' '{"schema_version":1,"purpose":"broken","username":"'"${_u}"'","service":"webservice","action":"add","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/systemctl","args":["reload","nginx"],"path":"/usr/sbin/nginx"}]}' >"${CI_HOME}/dup-path.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" json-to-sudoers --file "${CI_HOME}/dup-path.json" --out "${CI_HOME}/dup-path.out" 2>&1 >/dev/null)
    assert_eq "TP-SR-10 decode-lost exit 1" 1 "$?"
    assert_contains "TP-SR-10 decode-lost incomplete" "${_err}" "incomplete"
    assert_contains "TP-SR-10 decode-lost do not approve" "${_err}" "Do not approve"
    assert_contains "TP-SR-10 decode-lost Next" "${_err}" "Next:"
    assert_not_contains "TP-SR-10 decode-lost no codec jargon" "${_err}" "lost objects"

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
    assert_contains "TP-SR-06 dest service-user" "${_out}" '"dest":"/etc/sudoers.d/webservice-'"${_u}"'"'
    _rid=$(printf '%s' "${_out}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    case "${_rid}" in
        sudoer-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-webservice-"${_u}"-add-[0-9]*.json)
            t_pass "TP-SR-01 basename grammar"
            ;;
        *)
            t_fail "TP-SR-01 basename grammar (got '${_rid}')"
            ;;
    esac
    assert_file_exists "TP-SR-05 queued file" "${_q}/sudoer-request/${_rid}"
    _qm=$(stat -c '%a' "${_q}/sudoer-request/${_rid}")
    assert_eq "TP-SR-Q-02 submitted file mode 0640" "640" "${_qm}"

    _lst=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" list-approving 2>/dev/null)
    assert_contains "TP-SR-05 list-approving shows id" "${_lst}" "${_rid}"

    _shown=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" show "${_rid}" 2>/dev/null)
    assert_contains "TP-SR-05 show purpose" "${_shown}" "Allow this user to reload nginx"

    # TP-SR-15 pretty add-sample submit inbound keeps all three paths
    _q15="${CI_HOME}/queues15"
    mkdir -p "${_q15}/sudoer-request" "${_q15}/sudoer-approved" "${_q15}/sudoer-rejected"
    _out15=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q15}" add-sudoer-request --file "${CI_HOME}/add-pretty.json" 2>/dev/null)
    assert_eq "TP-SR-15 pretty submit exit 0" 0 "$?"
    _rid15=$(printf '%s' "${_out15}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    assert_file_exists "TP-SR-15 pretty queued file" "${_q15}/sudoer-request/${_rid15}"
    _ibody15=$(cat "${_q15}/sudoer-request/${_rid15}")
    assert_contains "TP-SR-15 inbound systemctl" "${_ibody15}" "/bin/systemctl"
    assert_contains "TP-SR-15 inbound journalctl" "${_ibody15}" "/usr/bin/journalctl"
    assert_contains "TP-SR-15 inbound nginx" "${_ibody15}" "/usr/sbin/nginx"

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
        assert_contains "TP-SR-PRIV-01 setup says root" "${_err}" "must run as root"
        assert_contains "TP-SR-PRIV-01 setup has Next" "${_err}" "Next:"
        assert_contains "TP-SR-PRIV-01 setup Next is sudo … setup" "${_err}" "sudo "
        assert_contains "TP-SR-PRIV-01 setup Next names setup" "${_err}" "setup"
        assert_not_contains "TP-SR-PRIV-01 setup not sudo -n" "${_err}" "sudo -n"
        assert_not_contains "TP-SR-PRIV-01 setup no euid jargon" "${_err}" "euid"
        assert_not_contains "TP-SR-PRIV-01 setup no Type 1 jargon" "${_err}" "Type 1"
        _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" approve "${_rid}" 2>&1 >/dev/null)
        assert_eq "TP-SR-PRIV-01 approve exit 1" 1 "$?"
        assert_contains "TP-SR-PRIV-01 approve says why" "${_err}" "must run as root"
        assert_contains "TP-SR-PRIV-01 approve has Next" "${_err}" "Next:"
        assert_not_contains "TP-SR-PRIV-01 approve no authorization-failed" "${_err}" "authorization failed"
        assert_file_missing "TP-SR-PRIV-01 no dest written" "/etc/sudoers.d/webservice-${_u}"
        assert_file_exists "TP-SR-PRIV-01 still inbound" "${_q}/sudoer-request/${_rid}"
        _err=$(TTY=1 HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" interactive 2>&1 >/dev/null)
        assert_eq "TP-SR-INT-01 interactive non-root exit 1" 1 "$?"
        assert_contains "TP-SR-INT-01 interactive says root" "${_err}" "must run as root"
        assert_contains "TP-SR-INT-01 interactive has Next" "${_err}" "Next:"
        _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" interactive 2>&1 >/dev/null)
        assert_eq "TP-SR-INT-02 --json interactive exit 1" 1 "$?"
        assert_contains "TP-SR-INT-02 --json confirm_required" "${_err}" "confirm_required"
        _err=$(TTY=0 HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" interactive 2>&1 >/dev/null)
        assert_eq "TP-SR-INT-02 TTY=0 interactive exit 1" 1 "$?"
        assert_contains "TP-SR-INT-02 TTY=0 says TTY" "${_err}" "TTY"
    else
        t_skip "TP-SR-PRIV-01 running as root"
    fi

    # TP-SR-PRIV-02 bootstrap vs F6: setup must not require sudoer-adm / sudo -n
    _lpu=$(sed -n '/^lpu_setup()/,/^}/p' "${SCRIPT}")
    case "${_lpu}" in
        *sr_require_type1_bootstrap*) t_pass "TP-SR-PRIV-02 lpu_setup uses bootstrap gate" ;;
        *) t_fail "TP-SR-PRIV-02 lpu_setup must call sr_require_type1_bootstrap" ;;
    esac
    case "${_lpu}" in
        *sr_require_type1$'\n'*|*sr_require_type1\;*) t_fail "TP-SR-PRIV-02 lpu_setup must not use approver gate" ;;
        *) t_pass "TP-SR-PRIV-02 lpu_setup does not use sr_require_type1" ;;
    esac
    _boot=$(sed -n '/^sr_require_type1_bootstrap()/,/^}/p' "${SCRIPT}")
    case "${_boot}" in
        *sudoer-adm*) t_fail "TP-SR-PRIV-02 bootstrap gate must not name sudoer-adm" ;;
        *) t_pass "TP-SR-PRIV-02 bootstrap gate not limited to sudoer-adm" ;;
    esac
    case "${_boot}" in
        *'sudo -n'*) t_fail "TP-SR-PRIV-02 bootstrap gate must not invoke sudo -n" ;;
        *) t_pass "TP-SR-PRIV-02 bootstrap gate does not use sudo -n" ;;
    esac
    _apr=$(sed -n '/^sr_approve()/,/^}/p' "${SCRIPT}")
    case "${_apr}" in
        *sr_require_type1$'\n'*|*sr_require_type1\;*|*sr_require_type1*)
            case "${_apr}" in
                *sr_require_type1_bootstrap*) t_fail "TP-SR-PRIV-02 approve must keep F6 gate" ;;
                *) t_pass "TP-SR-PRIV-02 approve keeps F6/sr_require_type1" ;;
            esac
            ;;
        *) t_fail "TP-SR-PRIV-02 approve must call sr_require_type1" ;;
    esac
    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-SR-PRIV-02 help bootstrap sudo setup" "${_help}" "sudo ${APP_NAME} setup"
    assert_contains "TP-SR-PRIV-02 help password sudo OK" "${_help}" "password sudo OK"
    assert_contains "TP-SR-PRIV-02 help not limited to sudoer-adm" "${_help}" "Not limited to sudoer-adm"

    # TP-SR-PRIV-03 live setup body (static: non-root CI does not useradd)
    _setup=$(sed -n '/^lpu_setup()/,/^}/p' "${SCRIPT}")
    assert_not_contains "TP-SR-PRIV-03 setup is not a Gap stub" "${_setup}" "not enabled"
    assert_not_contains "TP-SR-PRIV-03 no live-host skip" "${_setup}" "lpu_live_host"
    _src=$(cat "${SCRIPT}")
    assert_not_contains "TP-SR-PRIV-03 no LIVE_LPU flag" "${_src}" "SUDOER_CLI_LIVE_LPU_TEST"
    _create=$(sed -n '/^lpu_create_account()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 create calls useradd" "${_create}" "useradd"
    assert_contains "TP-SR-PRIV-03 create uses lpu_sudo" "${_create}" "lpu_sudo"
    assert_contains "TP-SR-PRIV-03 create uses F1 UID" "${_create}" "LPU_UID"
    assert_contains "TP-SR-PRIV-03 create mkdir home first" "${_create}" "mkdir -p"
    assert_contains "TP-SR-PRIV-03 useradd -M (home already made)" "${_create}" " -M "
    _sudow=$(sed -n '/^lpu_sudo()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 lpu_sudo runs direct when root" "${_sudow}" 'id -u'
    _f6txt=$(sed -n '/^lpu_f6_text()/,/^}/p' "${SCRIPT}")
    assert_not_contains "TP-SR-PRIV-03 F6 has no useradd" "${_f6txt}" "useradd"
    _coll=$(sed -n '/^lpu_collision_check()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 collision probes passwd UID" "${_coll}" 'getent passwd "${LPU_UID}"'
    _defs=$(sed -n '/^lpu_defaults()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 LPU home is /etc/sudoer-adm" "${_defs}" 'LPU_HOME:=/etc/sudoer-adm'
    assert_not_contains "TP-SR-PRIV-03 LPU home is not /home/sudoer-adm" "${_defs}" '/home/sudoer-adm'
    assert_contains "TP-SR-PRIV-03 hook BEGIN marker" "${_defs}" "BEGIN sudoer-cli login hook"
    assert_contains "TP-SR-PRIV-03 hook END marker" "${_defs}" "END sudoer-cli login hook"
    _hook=$(sed -n '/^lpu_hook_text()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 hook sudo -n global interactive" "${_hook}" "sudo -n"
    assert_contains "TP-SR-PRIV-03 hook interactive verb" "${_hook}" "interactive"
    assert_contains "TP-SR-INT-03 hook skips SSH_ORIGINAL_COMMAND" "${_hook}" "SSH_ORIGINAL_COMMAND"
    assert_contains "TP-SR-INT-03 hook requires PS1" "${_hook}" 'PS1-'
    assert_not_contains "TP-SR-INT-03 hook does not exit" "${_hook}" "exit"
    _f6fn=$(sed -n '/^lpu_f6_text()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 F6 Table A NOPASSWD" "${_f6fn}" "NOPASSWD:"
    assert_contains "TP-SR-PRIV-03 F6 global bin" "${_f6fn}" 'GLOBAL_BIN'
    _f6p=$(sed -n '/^lpu_f6_path()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 F6 path uses sudoers.d dir" "${_f6p}" 'sr_sudoers_d_dir'
    assert_contains "TP-SR-PRIV-03 F6 basename is LPU_USER" "${_f6p}" 'LPU_USER'
    _aprbody=$(sed -n '/^sr_approve()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 approve dest helper" "${_aprbody}" 'sr_grant_dest'
    assert_contains "TP-SR-PRIV-03 approve product sudoers.d check" "${_aprbody}" 'sr_require_product_sudoers_d'
    _rm=$(sed -n '/^lpu_remove()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 remove userdel -r" "${_rm}" "userdel"
    assert_contains "TP-SR-PRIV-03 remove --force confirm" "${_rm}" "confirm_required"
    assert_contains "TP-SR-PRIV-03 help no Gap on setup" "${_help}" "Create/teardown LPU"
    assert_not_contains "TP-SR-PRIV-03 help not Gap stub" "${_help}" "Live useradd is a Gap"
    _mkdirf5=$(sed -n '/^lpu_mkdir_f5()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-Q-01 public sudoer-request" "${_mkdirf5}" "sudoer-request"
    assert_contains "TP-SR-Q-01 inbound mode 3773" "${_mkdirf5}" "3773"
    assert_not_contains "TP-SR-Q-01 inbound not 0777" "${_mkdirf5}" "0777"
    assert_contains "TP-SR-Q-01 archive mode 0700" "${_mkdirf5}" "0700"
    assert_contains "TP-SR-Q-01 public root 0755" "${_mkdirf5}" "0755"
    _resq=$(sed -n '/^sr_resolve_queues()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-Q-01 default public /var/APP" "${_resq}" 'sr_default_public_queue_root'
    assert_contains "TP-SR-Q-01 inbound basename sudoer-request" "${_resq}" "sudoer-request"
    assert_not_contains "TP-SR-Q-01 no default sudoer-approving" "${_resq}" "sudoer-approving"
    _aprbody2=$(sed -n '/^sr_approve()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-Q-01 approve uses home view" "${_aprbody2}" "sr_approver_dir"
    assert_contains "TP-SR-Q-02 approve archives snapshot" "${_aprbody2}" "sr_archive_validated"
    assert_contains "TP-SR-Q-02 approve owner check" "${_aprbody2}" "owner_mismatch"
    assert_not_contains "TP-SR-Q-02 approve does not mv inbound path" "${_aprbody2}" 'mv "${_path}"'
    _archfn=$(sed -n '/^sr_archive_validated()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-Q-02 archive copies snapshot" "${_archfn}" 'cp "${_snap}"'
    assert_contains "TP-SR-Q-02 archive unlinks inbound" "${_archfn}" 'rm -f "${_inb}"'
    assert_contains "TP-SR-Q-02 archive chowns dest" "${_archfn}" 'chown "${LPU_USER}:${LPU_USER}"'
    _rmfn=$(sed -n '/^lpu_remove_public_queues()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-Q-03 F7 removes sudoer-request" "${_rmfn}" "sudoer-request"
    assert_contains "TP-SR-Q-03 F7 rmdir public root" "${_rmfn}" "rmdir"
    _rmbody=$(sed -n '/^lpu_remove()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-Q-03 remove calls public teardown" "${_rmbody}" "lpu_remove_public_queues"
    _about=$(HOME="${CI_HOME}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-SR-Q-01 about default submit dest" "${_about}" "/var/sudoer-cli/sudoer-request"
    _int=$(sed -n '/^sr_interactive()/,/^}/p' "${SCRIPT}")
    assert_not_contains "TP-SR-INT-04 loop is not a stub" "${_int}" "not implemented yet"
    assert_contains "TP-SR-INT-04 empty inbound note" "${_int}" "no pending requests"
    assert_contains "TP-SR-INT-04 uses prompt_yes_no" "${_int}" "prompt_yes_no"
    assert_not_contains "TP-SR-INT-05 loop is not a heredoc" "${_int}" 'done <<'
    assert_contains "TP-SR-INT-05 loop reads ids on fd 3" "${_int}" '3<"${_sorted}"'
    assert_contains "TP-SR-INT-05 read from fd 3" "${_int}" 'read -r _bn <&3'
    _int_stripped=$(printf '%s\n' "${_int}" | sed 's/3<"${_sorted}"//g')
    case "${_int_stripped}" in
        *'<"${_sorted}"'*|*'< "${_sorted}"'*)
            t_fail "TP-SR-INT-05 leftover fd-0 redirect of _sorted"
            ;;
        *)
            t_pass "TP-SR-INT-05 no leftover fd-0 redirect of _sorted"
            ;;
    esac
    _pyn=$(sed -n '/^prompt_yes_no()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-INT-05 prompt_yes_no reads fd 0" "${_pyn}" 'read -r answer'
    assert_not_contains "TP-SR-INT-05 prompt_yes_no not a second family" "${_pyn}" "prompt_confirm"
    _tf=$(mktemp "${CI_HOME}/sr-int-class.XXXXXX")
    printf '%s\n' "only-id" >"${_tf}"
    _steal=$(
        printf 'n\nn\ny\n' | {
            while IFS= read -r _id; do
                read -r _a1 || true
                read -r _a2 || true
                read -r _a3 || true
                printf '%s|%s|%s' "${_a1}" "${_a2}" "${_a3}"
            done <"${_tf}"
        }
    )
    assert_eq "TP-SR-INT-05 class steal is empty answers" "||" "${_steal}"
    _keep=$(
        printf 'n\nn\ny\n' | {
            while IFS= read -r _id <&3; do
                read -r _a1 || true
                read -r _a2 || true
                read -r _a3 || true
                printf '%s|%s|%s' "${_a1}" "${_a2}" "${_a3}"
            done 3<"${_tf}"
        }
    )
    assert_eq "TP-SR-INT-05 class fd3 consumes answers" "n|n|y" "${_keep}"
    rm -f "${_tf}"
    if [ "$(id -u)" -eq 0 ]; then
        _eq="${CI_HOME}/emptyq"
        mkdir -p "${_eq}/sudoer-request" "${_eq}/sudoer-approved" "${_eq}/sudoer-rejected"
        HOME="${CI_HOME}" TTY=1 SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_eq}" interactive >/dev/null 2>&1
        assert_eq "TP-SR-INT-04 empty inbound exit 0" 0 "$?"
        _pq="${CI_HOME}/pendingq"
        mkdir -p "${_pq}/sudoer-request" "${_pq}/sudoer-approved" "${_pq}/sudoer-rejected"
        _rid="sudoer-20260815-webservice-${_u}-add-1.json"
        printf '%s\n' '{"schema_version":1,"purpose":"int-05 quit","username":"'"${_u}"'","service":"webservice","action":"add","commands":[]}' \
            >"${_pq}/sudoer-request/${_rid}"
        _err=$(printf 'n\nn\ny\n' | HOME="${CI_HOME}" TTY=1 SUDOER_CLI_ALLOW_TEST_ROOTS=1 \
            sh "${SCRIPT}" --queue-root "${_pq}" interactive 2>&1)
        assert_eq "TP-SR-INT-05 live quit exit 0" 0 "$?"
        assert_contains "TP-SR-INT-05 live quit note" "${_err}" "quit; remaining requests stay inbound"
        assert_not_contains "TP-SR-INT-05 live not skipped" "${_err}" "skipped"
        assert_file_exists "TP-SR-INT-05 live left inbound" "${_pq}/sudoer-request/${_rid}"
    else
        t_skip "TP-SR-INT-04 empty inbound live needs Type 1"
        t_skip "TP-SR-INT-05 live quit needs Type 1"
    fi

    # TP-SR-06 dest name never *-remove
    _out=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" remove-sudoer-request --service webservice --purpose "Revoke my webservice sudoers grant; I no longer operate nginx." 2>/dev/null)
    assert_contains "TP-SR-06 remove dest not *-remove" "${_out}" '"dest":"/etc/sudoers.d/webservice-'"${_u}"'"'
    _destf=$(printf '%s' "${_out}" | sed -n 's/.*"dest":"\([^"]*\)".*/\1/p')
    assert_eq "TP-SR-06 dest path" "/etc/sudoers.d/webservice-${_u}" "${_destf}"
    case "${_destf}" in
        *-remove) t_fail "TP-SR-06 dest must not end in -remove" ;;
        *) t_pass "TP-SR-06 dest is /etc/sudoers.d/<service>-<user>" ;;
    esac

    # Hyphenated service aligns with project-sudoers-file {{APP_NAME}}-{{TARGET_USER}}
    cat >"${CI_HOME}/fb.json" <<EOF
{"schema_version":1,"purpose":"Allow this user to deposit folder-backup archives.","username":"${_u}","service":"folder-backup","action":"add","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/mkdir","args":["-p","/var/backup/folder-backup"]}]}
EOF
    _out=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" add-sudoer-request --file "${CI_HOME}/fb.json" 2>/dev/null)
    assert_eq "TP-SR-01 folder-backup submit exit 0" 0 "$?"
    assert_contains "TP-SR-06 folder-backup dest" "${_out}" '"dest":"/etc/sudoers.d/folder-backup-'"${_u}"'"'
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
