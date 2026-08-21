# =============================================================================
# tests/test_domain_sr.sh — sudoers-request domain (TP-SR-*, TP-SR-PRIV-01..04, TP-SR-HOOK-01..04, TP-SR-FENCE-01..12, TP-SR-INT-01..06)
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
{"schema_version":1,"purpose":"Allow this user to reload nginx and read the nginx unit journal.","username":"${_u}","service":"webservice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/systemctl","args":["reload","nginx"]},{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/journalctl","args":["-u","nginx"]},{"runas":"root","tags":["NOPASSWD"],"path":"/usr/sbin/nginx","args":["-t"]}]}
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
  "submit_app": "dns-cli",
  "submit_version": "1.12.0",
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
  "submit_app": "dns-cli",
  "submit_version": "1.12.0",
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
    assert_contains "TP-SR-02 submit_app" "${_js}" '"submit_app":"sudoer-cli"'
    assert_contains "TP-SR-02 submit_version" "${_js}" '"submit_version":"'

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
    printf '%s\n' '{"schema_version":1,"purpose":"broken","username":"'"${_u}"'","service":"webservice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/systemctl","args":["reload","nginx"],"path":"/usr/sbin/nginx"}]}' >"${CI_HOME}/dup-path.json"
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

    # TP-SR-17 OPEN-BEHALF: JSON username B (hyphenated service+user) — dest uses B, not last-hyphen adm
    printf '%s\n' '{"schema_version":1,"purpose":"DNS grant for colleague.","username":"dns-adm","service":"dns-cli","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/local/bin/dns-cli","args":["reload"]}]}' >"${CI_HOME}/behalf.json"
    _outb=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" add-sudoer-request --file "${CI_HOME}/behalf.json" 2>/dev/null)
    assert_eq "TP-SR-17 behalf submit exit 0" 0 "$?"
    assert_contains "TP-SR-17 request_id uses B" "${_outb}" "dns-cli-dns-adm-add-"
    assert_contains "TP-SR-17 dest uses JSON subject" "${_outb}" '"dest":"/etc/sudoers.d/dns-cli-dns-adm"'
    assert_not_contains "TP-SR-17 dest is not last-hyphen adm" "${_outb}" "dns-cli-adm\""

    # TP-SR-18 remove for B: JSON username survives encode
    printf '%s\n' '{"purpose":"Revoke colleague DNS grant.","username":"dns-adm","service":"dns-cli","action":"remove"}' >"${CI_HOME}/rm-b.json"
    _outrm=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" remove-sudoer-request --service dns-cli --file "${CI_HOME}/rm-b.json" 2>/dev/null)
    assert_eq "TP-SR-18 remove-for-B exit 0" 0 "$?"
    assert_contains "TP-SR-18 remove request_id uses B" "${_outrm}" "dns-cli-dns-adm-remove-"
    assert_contains "TP-SR-18 remove dest uses B" "${_outrm}" '"dest":"/etc/sudoers.d/dns-cli-dns-adm"'
    _ridrm=$(printf '%s' "${_outrm}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    assert_file_exists "TP-SR-18 remove queued" "${_q}/sudoer-request/${_ridrm}"
    _rmbody=$(cat "${_q}/sudoer-request/${_ridrm}")
    assert_contains "TP-SR-18 inbound keeps username B" "${_rmbody}" '"username":"dns-adm"'
    assert_contains "TP-SR-18 inbound keeps service" "${_rmbody}" '"service":"dns-cli"'
    assert_contains "TP-SR-18 inbound keeps action remove" "${_rmbody}" '"action":"remove"'

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
                *sr_require_type1_bootstrap*) t_fail "TP-SR-PRIV-02 approve must keep euid-0 gate" ;;
                *) t_pass "TP-SR-PRIV-02 approve keeps sr_require_type1 (euid 0)" ;;
            esac
            ;;
        *) t_fail "TP-SR-PRIV-02 approve must call sr_require_type1" ;;
    esac
    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-SR-PRIV-02 help bootstrap sudo setup" "${_help}" "sudo ${APP_NAME} setup"
    assert_contains "TP-SR-PRIV-02 help password sudo OK" "${_help}" "password sudo OK"
    assert_contains "TP-SR-PRIV-02 help not limited to sudoer-adm" "${_help}" "Not limited to sudoer-adm"

    # TP-SR-PRIV-04 / TP-PREV-03 / TP-ELEV-09: no second actor lock after elev
    _t1=$(sed -n '/^sr_require_type1()/,/^}/p' "${SCRIPT}")
    case "${_t1}" in
        *'!= "sudoer-adm"'*|*"!= 'sudoer-adm'"*|*"Only sudoer-adm"*)
            t_fail "TP-SR-PRIV-04 approve gate must not require SUDO_USER==sudoer-adm"
            ;;
        *) t_pass "TP-SR-PRIV-04 approve gate has no exclusive-LPU actor lock" ;;
    esac
    t_pass "TP-PREV-03 alias of TP-SR-PRIV-04"
    t_pass "TP-ELEV-09 alias of TP-SR-PRIV-04"
    assert_not_contains "TP-SR-PRIV-04 help not only-sudoer-adm approve" "${_help}" "after F6; sudoer-adm or real root"
    assert_contains "TP-SR-PRIV-04 help password sudo may approve" "${_help}" "password sudo"
    _setup_body=$(sed -n '/^lpu_setup()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-04 setup helps submit" "${_setup_body}" "add-sudoer-request"
    assert_contains "TP-SR-PRIV-04 setup Next names interactive" "${_setup_body}" "interactive"
    _sub=$(sed -n '/^sr_submit()/,/^}/p' "${SCRIPT}")
    assert_not_contains "TP-SR-PRIV-04 Type 0 submit never useradd" "${_sub}" "useradd"
    case "${_t1}" in
        *'_su='*|*'${SUDO_USER'*|*'SUDO_USER-'*)
            t_fail "TP-SR-PRIV-04 sr_require_type1 must not read SUDO_USER after euid 0"
            ;;
        *) t_pass "TP-SR-PRIV-04 sr_require_type1 has no SUDO_USER actor check" ;;
    esac
    _prevf="${REPO_ROOT}/docs/requirements/requirement-privilege-prevention-set.md"
    if [ -f "${_prevf}" ]; then
        _prev=$(cat "${_prevf}")
        assert_contains "TP-PREV-03 law OPEN-SUDOER-APPR" "${_prev}" "OPEN-SUDOER-APPR"
        _block=$(sed -n '/^#### 2.2.1/,/^#### 2.2.2/p' "${_prevf}")
        case "${_block}" in
            *PREV-APPR-ACTOR*) t_fail "TP-PREV-03 §2.2.1 must not republish PREV-APPR-ACTOR as a block" ;;
            *) t_pass "TP-PREV-03 §2.2.1 has no PREV-APPR-ACTOR block row" ;;
        esac
    else
        t_fail "TP-PREV-03 prevention-set file missing"
    fi

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
    _hookfn=$(sed -n '/^lpu_install_hook()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-HOOK-01 install_hook checks/creates .profile" "${_hookfn}" "lpu_ensure_profile"
    _ens=$(sed -n '/^lpu_ensure_profile()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-HOOK-01 ensure tests .profile" "${_ens}" '.profile'
    assert_contains "TP-SR-HOOK-01 ensure leaves existing file" "${_ens}" '[ -f "${_pr}" ]'
    _own=$(sed -n '/^lpu_own_user_rc()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-HOOK-04 own_user_rc chowns LPU" "${_own}" 'chown "${LPU_USER}:${LPU_USER}"'
    assert_contains "TP-SR-HOOK-04 own_user_rc fail-closed chown" "${_own}" 'sr_die "cannot chown'
    assert_not_contains "TP-SR-HOOK-04 own_user_rc does not swallow chown" "${_own}" '|| true'
    _apply=$(sed -n '/^lpu_hook_apply()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-HOOK-04 apply calls own_user_rc" "${_apply}" "lpu_own_user_rc"
    assert_contains "TP-SR-HOOK-04 ensure calls own_user_rc" "${_ens}" "lpu_own_user_rc"
    _gbin=$(sed -n '/^lpu_ensure_global_bin()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-PRIV-03 global bin heals VERSION mismatch" "${_gbin}" '_have'
    assert_contains "TP-SR-PRIV-03 global bin compares VERSION" "${_gbin}" '_want'
    _ptxt=$(sed -n '/^lpu_profile_text()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-HOOK-03 profile text sources bashrc" "${_ptxt}" '. \"\${HOME}/.bashrc\"'
    assert_contains "TP-SR-HOOK-03 profile text BEGIN marker" "${_ptxt}" "BEGIN sudoer-cli profile source-bashrc"

    # Isolated heal (no host useradd): missing .profile is created; existing is not replaced.
    _th=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.hook.XXXXXX")
    _runner="${_th}/run-hook.sh"
    {
        printf '%s\n' 'sr_die() { printf "%s\n" "$*" >&2; exit 1; }'
        printf '%s\n' 'getent() { return 1; }'
        sed -n '/^util_sudo()/,/^}/p' "${SCRIPT}"
        sed -n '/^util_chmod()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_defaults()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_own_user_rc()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_hook_text()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_hook_strip()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_hook_apply()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_profile_sources_bashrc()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_profile_text()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_ensure_profile()/,/^}/p' "${SCRIPT}"
        sed -n '/^lpu_install_hook()/,/^}/p' "${SCRIPT}"
        printf '%s\n' "LPU_HOME='${_th}/home'"
        printf '%s\n' "LPU_USER=sudoer-adm"
        printf '%s\n' "APP_NAME=sudoer-cli"
        printf '%s\n' "GLOBAL_BIN=/usr/local/bin"
        printf '%s\n' 'mkdir -p "${LPU_HOME}"'
        printf '%s\n' "lpu_install_hook"
    } >"${_runner}"
    sh "${_runner}"
    assert_file_exists "TP-SR-HOOK-01 missing .profile created" "${_th}/home/.profile"
    assert_file_exists "TP-SR-HOOK-01 .bashrc created" "${_th}/home/.bashrc"
    _prf=$(cat "${_th}/home/.profile")
    assert_contains "TP-SR-HOOK-03 created sources bashrc" "${_prf}" '. "${HOME}/.bashrc"'
    assert_contains "TP-SR-HOOK-03 created BEGIN marker" "${_prf}" "# BEGIN sudoer-cli profile source-bashrc"
    printf '%s\n' "# keep-me" >"${_th}/home/.profile"
    sh "${_runner}"
    _prf2=$(cat "${_th}/home/.profile")
    assert_contains "TP-SR-HOOK-02 existing .profile body kept" "${_prf2}" "# keep-me"
    assert_not_contains "TP-SR-HOOK-02 existing not replaced by create sample" "${_prf2}" "BEGIN sudoer-cli profile source-bashrc"
    rm -rf "${_th}"
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
    assert_not_contains "TP-SR-Q-02 approve has no owner_mismatch wall" "${_aprbody2}" "owner_mismatch"
    _rejbody=$(sed -n '/^sr_reject()/,/^}/p' "${SCRIPT}")
    assert_not_contains "TP-SR-Q-02 reject has no owner_mismatch wall" "${_rejbody}" "owner_mismatch"
    assert_not_contains "TP-SR-Q-02 reject has no self-scope wall" "${_rejbody}" "self_scope"
    _subfn=$(sed -n '/^sr_submit()/,/^}/p' "${SCRIPT}")
    assert_not_contains "TP-SR-Q-02 submit has no self-scope wall" "${_subfn}" "self-scope"
    _j2s=$(sed -n '/^sr_json_to_sudoers()/,/^}/p' "${SCRIPT}")
    assert_not_contains "TP-SR-Q-02 json-to-sudoers has no self-scope wall" "${_j2s}" "self-scope"
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
    _int_pyn_n=$(printf '%s\n' "${_int}" | grep -c 'prompt_yes_no "' || true)
    assert_eq "TP-SR-INT-06 one prompt_yes_no in review loop" "1" "${_int_pyn_n}"
    assert_not_contains "TP-SR-INT-06 no Reject y/N" "${_int}" 'prompt_yes_no "Reject'
    assert_not_contains "TP-SR-INT-06 no Quit y/N" "${_int}" "Quit review"
    assert_not_contains "TP-SR-INT-06 no skip branch" "${_int}" "skipped"
    assert_contains "TP-SR-INT-06 else is reject" "${_int}" "sr_reject"
    assert_contains "TP-SR-INT-06 Approve this request" "${_int}" 'prompt_yes_no "Approve this request"'
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
        printf '%s\n' '{"schema_version":1,"purpose":"int-06 one-off reject","username":"'"${_u}"'","service":"webservice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/true","args":[]}]}' \
            >"${_pq}/sudoer-request/${_rid}"
        _err=$(printf 'n\n' | HOME="${CI_HOME}" TTY=1 SUDOER_CLI_ALLOW_TEST_ROOTS=1 \
            sh "${SCRIPT}" --queue-root "${_pq}" interactive 2>&1)
        assert_eq "TP-SR-INT-06 live no-exit 0" 0 "$?"
        assert_contains "TP-SR-INT-06 live rejected note" "${_err}" "rejected"
        assert_not_contains "TP-SR-INT-06 live no skip" "${_err}" "skipped"
        assert_not_contains "TP-SR-INT-06 live no quit" "${_err}" "quit; remaining"
        assert_not_contains "TP-SR-INT-06 live no Reject prompt" "${_err}" "Reject "
        assert_file_exists "TP-SR-INT-06 live moved to rejected" "${_pq}/sudoer-rejected/${_rid}"
        assert_file_missing "TP-SR-INT-06 live left inbound" "${_pq}/sudoer-request/${_rid}"
    else
        t_skip "TP-SR-INT-04 empty inbound live needs Type 1"
        t_skip "TP-SR-INT-06 live reject needs Type 1"
    fi

    # TP-SR-FENCE: dest Fence before yes/no; reject re-validates; action mismatch; subject mismatch is not a fence
    _intfn=$(sed -n '/^sr_interactive()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-FENCE-01 interactive calls dest fence" "${_intfn}" "sr_dest_fence_or_die"
    assert_contains "TP-SR-FENCE-12 interactive archives fenced" "${_intfn}" "sr_archive_fenced_rejected"
    _aprfn=$(sed -n '/^sr_approve()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-FENCE-01 approve calls dest fence" "${_aprfn}" "sr_dest_fence_or_die"
    _rejfn=$(sed -n '/^sr_reject()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-FENCE-01 reject calls dest fence" "${_rejfn}" "sr_dest_fence_or_die"
    _int_fence_line=$(printf '%s\n' "${_intfn}" | grep -n 'sr_dest_fence_or_die' | head -n1 | cut -d: -f1)
    _int_prompt_line=$(printf '%s\n' "${_intfn}" | grep -n 'prompt_yes_no "Approve' | head -n1 | cut -d: -f1)
    _int_arch_line=$(printf '%s\n' "${_intfn}" | grep -n 'sr_archive_fenced_rejected' | head -n1 | cut -d: -f1)
    if [ -n "${_int_fence_line}" ] && [ -n "${_int_prompt_line}" ] && [ "${_int_fence_line}" -lt "${_int_prompt_line}" ]; then
        t_pass "TP-SR-FENCE-01 fence runs before Approve prompt"
    else
        t_fail "TP-SR-FENCE-01 fence must run before Approve prompt (fence=${_int_fence_line} prompt=${_int_prompt_line})"
    fi
    if [ -n "${_int_fence_line}" ] && [ -n "${_int_arch_line}" ] && [ "${_int_fence_line}" -lt "${_int_arch_line}" ]; then
        t_pass "TP-SR-FENCE-12 fence display before rejected move"
    else
        t_fail "TP-SR-FENCE-12 fence must run before rejected move (fence=${_int_fence_line} archive=${_int_arch_line})"
    fi

    _tfence=$(mktemp -d "${TMPDIR:-/tmp}/sudoer-cli.fence.XXXXXX")
    _frunner="${_tfence}/run-fence.sh"
    {
        printf '%s\n' 'sr_die() { printf "%s\n" "$1" >&2; printf "CODE:%s\n" "${2:-unknown}" >&2; [ -n "${3-}" ] && printf "Next: %s\n" "$3" >&2; exit 1; }'
        printf '%s\n' 'sr_operator_cmd() { printf "%s" "sudoer-cli"; }'
        printf '%s\n' 'util_mktemp() { mktemp "${TMPDIR:-/tmp}/sudoer-cli.XXXXXX"; }'
        sed -n '/^sr_json_get_str()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_has_key()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_decode_to_fields()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_valid_service_name()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_split_service_user()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_parse_request_id()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_format_fence_die()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_dest_fence_unknown_keys()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_format_fence_or_die()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_path_is_well_known()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_well_known_fence_die()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_cmds_require_well_known()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_dest_fence_or_die()/,/^}/p' "${SCRIPT}"
        printf '%s\n' "id=\"\$1\"; path=\"\$2\""
        printf '%s\n' 'sr_dest_fence_or_die "${path}" "${id}"'
        printf '%s\n' 'printf "FENCE_OK\n"'
    } >"${_frunner}"
    _fid="sudoer-20260819-webservice-alice-add-1.json"
    printf '%s\n' 'not json at all' >"${_tfence}/bad.json"
    _ferr=$(sh "${_frunner}" "${_fid}" "${_tfence}/bad.json" 2>&1)
    assert_eq "TP-SR-FENCE-02 not-json exit 1" 1 "$?"
    assert_contains "TP-SR-FENCE-02 not-json people words" "${_ferr}" "not a grant JSON object"
    assert_contains "TP-SR-FENCE-02 not-json no yes/no" "${_ferr}" "Dest will not ask yes/no"
    assert_contains "TP-SR-FENCE-02 not-json Next" "${_ferr}" "add-sudoer-request"
    printf '%s\n' '{"schema_version":1,"purpose":"x","username":"alice","service":"webservice","action":"remove","commands":[]}' >"${_tfence}/act.json"
    _ferr=$(sh "${_frunner}" "${_fid}" "${_tfence}/act.json" 2>&1)
    assert_eq "TP-SR-FENCE-03 action mismatch exit 1" 1 "$?"
    assert_contains "TP-SR-FENCE-03 action mismatch words" "${_ferr}" "name says add but the JSON action is remove"
    assert_contains "TP-SR-FENCE-03 action code" "${_ferr}" "CODE:field_mismatch"
    # Filename subject alice, JSON username bob — MUST NOT fence
    printf '%s\n' '{"schema_version":1,"purpose":"grant for bob","username":"bob","service":"webservice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/true","args":[]}]}' >"${_tfence}/bob.json"
    _ferr=$(sh "${_frunner}" "${_fid}" "${_tfence}/bob.json" 2>&1)
    assert_eq "TP-SR-FENCE-04 subject mismatch is not a fence" 0 "$?"
    assert_contains "TP-SR-FENCE-04 subject mismatch passes" "${_ferr}" "FENCE_OK"
    rm -rf "${_tfence}"

    # TP-SR-FENCE-05..08: Type 0 test-json-format (no dest elev; fixture need not sit inbound)
    _fx="${TESTS_ROOT}/fixtures/login-hook-elev-dns-adm.json"
    assert_file_exists "TP-SR-FENCE-05 fixture present" "${_fx}"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json test-json-format --file "${_fx}" 2>/dev/null)
    assert_eq "TP-SR-FENCE-05 login-hook-elev fixture exit 0" 0 "$?"
    assert_contains "TP-SR-FENCE-05 well-formed message" "${_out}" "JSON format is well-formed"
    assert_contains "TP-SR-FENCE-05 kind login-hook-elev" "${_out}" '"kind":"login-hook-elev"'
    assert_contains "TP-SR-FENCE-05 username dns-adm" "${_out}" '"username":"dns-adm"'
    assert_contains "TP-SR-FENCE-05 service dns-cli" "${_out}" '"service":"dns-cli"'
    printf '%s\n' 'not json at all' >"${CI_HOME}/not-object.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-json-format --file "${CI_HOME}/not-object.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-FENCE-06 not-json via test-json-format exit 1" 1 "$?"
    assert_contains "TP-SR-FENCE-06 not-json people words" "${_err}" "not a grant JSON object"
    assert_contains "TP-SR-FENCE-06 not-json well-formed sentence" "${_err}" "not a well-formed grant JSON"
    assert_contains "TP-SR-FENCE-06 Next test-json-format" "${_err}" "test-json-format --file"
    printf '%s\n' '{"schema_version":1,"purpose":"x","username":"alice","service":"webservice","action":"add","token":"nope","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/true","args":[]}]}' >"${CI_HOME}/extra-key.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-json-format --file "${CI_HOME}/extra-key.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-FENCE-07 unknown key via test-json-format exit 1" 1 "$?"
    assert_contains "TP-SR-FENCE-07 unknown field token" "${_err}" "unexpected JSON field 'token'"
    _actid="sudoer-20260820-webservice-alice-add-1.json"
    printf '%s\n' '{"schema_version":1,"purpose":"x","username":"alice","service":"webservice","action":"remove"}' >"${CI_HOME}/${_actid}"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-json-format --file "${CI_HOME}/${_actid}" 2>&1 >/dev/null)
    assert_eq "TP-SR-FENCE-08 request-id action mismatch via test-json-format exit 1" 1 "$?"
    assert_contains "TP-SR-FENCE-08 action mismatch words" "${_err}" "name says add but the JSON action is remove"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-json-format 2>&1 >/dev/null)
    assert_eq "TP-SR-FENCE-05 xor without file exit 1" 1 "$?"
    assert_not_contains "TP-SR-FENCE-05 xor not unknown" "${_err}" "Unknown command"
    # TP-SR-FENCE-09: dest-written submit_by is the queue owner converted into JSON
    _maxfx="${TESTS_ROOT}/fixtures/maximal-dest-stamped-login-hook-elev.json"
    assert_file_exists "TP-SR-FENCE-09 maximal dest-stamped fixture present" "${_maxfx}"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json test-json-format --file "${_maxfx}" 2>/dev/null)
    assert_eq "TP-SR-FENCE-09 dest-stamped submit_by exit 0" 0 "$?"
    assert_contains "TP-SR-FENCE-09 submit_by alice" "${_out}" '"submit_by":"alice"'
    assert_contains "TP-SR-FENCE-09 still username dns-adm" "${_out}" '"username":"dns-adm"'
    _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --queue-root "${_q}" add-sudoer-request --file "${_maxfx}" 2>&1 >/dev/null)
    assert_eq "TP-SR-FENCE-10 Type 0 must not plant submit_by exit 1" 1 "$?"
    assert_contains "TP-SR-FENCE-10 Type 0 submit_by words" "${_err}" "submit_by"
    _intfn=$(sed -n '/^sr_interactive()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-FENCE-09 interactive reads owner first" "${_intfn}" "sr_request_owner"
    assert_contains "TP-SR-FENCE-09 interactive stamps submit_by" "${_intfn}" "sr_stamp_submit_by"
    # TP-SR-FENCE-11: dest stamp inserts submit_by only at the first '{'
    _pretty="${CI_HOME}/pretty-stamp.json"
    cat >"${_pretty}" <<'EOF'
{
  "schema_version": 1,
  "purpose": "stamp pretty",
  "username": "alice",
  "service": "webservice",
  "action": "add",
  "submit_app": "dns-cli",
  "submit_version": "1.12.0",
  "commands": [
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/bin/true",
      "args": []
    },
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/bin/false",
      "args": []
    }
  ]
}
EOF
    {
        sed -n '/^util_json_escape()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_has_key()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_stamp_submit_by()/,/^}/p' "${SCRIPT}"
        printf '%s\n' "sr_stamp_submit_by '${_pretty}' bob"
    } >"${CI_HOME}/run-stamp.sh"
    sh "${CI_HOME}/run-stamp.sh"
    assert_eq "TP-SR-FENCE-11 stamp pretty exit 0" 0 "$?"
    _stamped=$(cat "${_pretty}")
    _sb_n=$(printf '%s\n' "${_stamped}" | grep -o '"submit_by"' | wc -l | tr -d ' ')
    assert_eq "TP-SR-FENCE-11 submit_by once" "1" "${_sb_n}"
    assert_contains "TP-SR-FENCE-11 owner bob" "${_stamped}" '"submit_by":"bob"'
    assert_contains "TP-SR-FENCE-11 command path kept" "${_stamped}" '"path": "/bin/true"'
    assert_not_contains "TP-SR-FENCE-11 no nested stamp" "${_stamped}" '{"submit_by":"bob","runas"'

    # TP-SR-FENCE-13..15: submit_app / submit_version dest-owned; sibling name is not a fence
    printf '%s\n' '{"schema_version":1,"purpose":"grant","username":"alice","service":"webservice","action":"add","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/true","args":[]}]}' >"${CI_HOME}/no-submit-app.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-json-format --file "${CI_HOME}/no-submit-app.json" 2>&1)
    assert_eq "TP-SR-FENCE-13 missing submit_app exit 1" 1 "$?"
    assert_contains "TP-SR-FENCE-13 missing submit_app words" "${_err}" "submit_app"
    printf '%s\n' '{"schema_version":1,"purpose":"grant","username":"alice","service":"webservice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/true","args":[]}]}' >"${CI_HOME}/sibling-app.json"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-json-format --file "${CI_HOME}/sibling-app.json" 2>/dev/null)
    assert_eq "TP-SR-FENCE-14 sibling submit_app exit 0" 0 "$?"
    assert_contains "TP-SR-FENCE-14 sibling well-formed" "${_out}" "JSON format is well-formed"
    _encfn=$(sed -n '/^sr_json_encode_request()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-FENCE-15 encoder stamps submit_app" "${_encfn}" "submit_app"
    assert_contains "TP-SR-FENCE-15 encoder stamps submit_version" "${_encfn}" "submit_version"
    _ukfn=$(sed -n '/^sr_dest_fence_unknown_keys()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-FENCE-15 dest allowlist submit_app" "${_ukfn}" "submit_app"
    assert_contains "TP-SR-FENCE-15 dest allowlist submit_version" "${_ukfn}" "submit_version"
    _intfn=$(sed -n '/^sr_interactive()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-SR-FENCE-15 interactive queued by" "${_intfn}" "queued by"

    # TP-SR-FENCE-12: interactive displays a fence match, then moves inbound → rejected
    if [ "$(id -u)" -eq 0 ]; then
        _fq="${CI_HOME}/fenceq"
        mkdir -p "${_fq}/sudoer-request" "${_fq}/sudoer-approved" "${_fq}/sudoer-rejected"
        _frid="sudoer-20260820-fence12test-${_u}-add-1.json"
        printf '%s\n' 'not a grant JSON' >"${_fq}/sudoer-request/${_frid}"
        _ferr=$(HOME="${CI_HOME}" TTY=1 SUDOER_CLI_ALLOW_TEST_ROOTS=1 \
            sh "${SCRIPT}" --queue-root "${_fq}" interactive 2>&1)
        assert_eq "TP-SR-FENCE-12 live exit 0" 0 "$?"
        assert_contains "TP-SR-FENCE-12 live people words" "${_ferr}" "not a grant JSON object"
        assert_contains "TP-SR-FENCE-12 live no yes/no" "${_ferr}" "Dest will not ask yes/no"
        assert_contains "TP-SR-FENCE-12 live rejected note" "${_ferr}" "rejected"
        assert_not_contains "TP-SR-FENCE-12 live no Approve prompt" "${_ferr}" "Approve this request"
        assert_file_exists "TP-SR-FENCE-12 live moved to rejected" "${_fq}/sudoer-rejected/${_frid}"
        assert_file_missing "TP-SR-FENCE-12 live left inbound" "${_fq}/sudoer-request/${_frid}"
    else
        t_skip "TP-SR-FENCE-12 live interactive fence-to-rejected needs Type 1"
    fi

    # TP-SR-WKBIN-01: golden login-hook-elev path is well-known
    _fx="${TESTS_ROOT}/fixtures/login-hook-elev-dns-adm.json"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json test-well-known-binary --file "${_fx}" 2>/dev/null)
    assert_eq "TP-SR-WKBIN-01 login-hook-elev exit 0" 0 "$?"
    assert_contains "TP-SR-WKBIN-01 well-known message" "${_out}" "well-known system binaries"
    assert_contains "TP-SR-WKBIN-01 command name" "${_out}" '"command":"test-well-known-binary"'

    # TP-SR-WKBIN-02: webservice nginx-ctl paths pass
    printf '%s\n' '{"schema_version":1,"purpose":"nginx ctl","username":"alice","service":"webservice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/bin/systemctl","args":["reload","nginx"]},{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/journalctl","args":["-u","nginx"]},{"runas":"root","tags":["NOPASSWD"],"path":"/usr/sbin/nginx","args":["-t"]}]}' >"${CI_HOME}/ngx-ctl.json"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-well-known-binary --file "${CI_HOME}/ngx-ctl.json" 2>&1)
    assert_eq "TP-SR-WKBIN-02 nginx-ctl exit 0" 0 "$?"
    assert_contains "TP-SR-WKBIN-02 nginx-ctl pass" "${_out}" "well-known system binaries"

    # TP-SR-WKBIN-03: nginx-cli managed global binary
    printf '%s\n' '{"schema_version":1,"purpose":"nginx-cli request","username":"alice","service":"nginx-cli","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"nginx-adm","tags":["NOPASSWD"],"path":"/usr/local/bin/nginx-cli","args":["request"]}]}' >"${CI_HOME}/ngx-cli.json"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-well-known-binary --file "${CI_HOME}/ngx-cli.json" 2>&1)
    assert_eq "TP-SR-WKBIN-03 nginx-cli exit 0" 0 "$?"

    # TP-SR-WKBIN-04: packaged certbot wrapper
    printf '%s\n' '{"schema_version":1,"purpose":"certbot","username":"alice","service":"certbot","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/certbot","args":["renew"]}]}' >"${CI_HOME}/certbot.json"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-well-known-binary --file "${CI_HOME}/certbot.json" 2>&1)
    assert_eq "TP-SR-WKBIN-04 certbot exit 0" 0 "$?"

    # TP-SR-WKBIN-05: CI gbin (dns-cli incident path class)
    printf '%s\n' '{"schema_version":1,"kind":"login-hook-elev","purpose":"hook","username":"dns-adm","service":"dns-cli","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/home/leolio/prjs/dns-cli/.ci-homes/home.Nh7l39/gbin/dns-cli","args":["interactive"]}]}' >"${CI_HOME}/ci-gbin.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json test-well-known-binary --file "${CI_HOME}/ci-gbin.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-WKBIN-05 ci-gbin exit 1" 1 "$?"
    assert_contains "TP-SR-WKBIN-05 ci-gbin people words" "${_err}" "not a well-known system binary"
    assert_contains "TP-SR-WKBIN-05 ci-gbin path" "${_err}" ".ci-homes"
    assert_contains "TP-SR-WKBIN-05 ci-gbin code" "${_err}" '"code":"untrusted_path"'

    # TP-SR-WKBIN-06: pip --user / USER_BIN
    printf '%s\n' '{"schema_version":1,"purpose":"user certbot","username":"alice","service":"certbot","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/home/alice/.local/bin/certbot","args":["renew"]}]}' >"${CI_HOME}/user-certbot.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-well-known-binary --file "${CI_HOME}/user-certbot.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-WKBIN-06 user-bin exit 1" 1 "$?"
    assert_contains "TP-SR-WKBIN-06 user-bin words" "${_err}" ".local/bin/certbot"

    # TP-SR-WKBIN-07: python interpreter
    printf '%s\n' '{"schema_version":1,"purpose":"python -m certbot","username":"alice","service":"certbot","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/python3","args":["-m","certbot"]}]}' >"${CI_HOME}/py3.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-well-known-binary --file "${CI_HOME}/py3.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-WKBIN-07 python3 exit 1" 1 "$?"
    assert_contains "TP-SR-WKBIN-07 python3 path" "${_err}" "/usr/bin/python3"

    # TP-SR-WKBIN-08: .. traversal
    printf '%s\n' '{"schema_version":1,"purpose":"dotdot","username":"alice","service":"dns-cli","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/local/bin/../home/alice/evil","args":["interactive"]}]}' >"${CI_HOME}/dotdot.json"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" test-well-known-binary --file "${CI_HOME}/dotdot.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-WKBIN-08 dotdot exit 1" 1 "$?"
    assert_contains "TP-SR-WKBIN-08 dotdot" "${_err}" "not a well-known system binary"

    # TP-SR-WKBIN-09: dest fence runner (JSON format passes, well-known fails)
    _wkrun="${CI_HOME}/wk-runner.sh"
    {
        printf '%s\n' 'sr_die() { printf "%s\n" "$1" >&2; printf "CODE:%s\n" "${2:-unknown}" >&2; [ -n "${3-}" ] && printf "Next: %s\n" "$3" >&2; exit 1; }'
        printf '%s\n' 'sr_operator_cmd() { printf "%s" "sudoer-cli"; }'
        printf '%s\n' 'util_mktemp() { mktemp "${TMPDIR:-/tmp}/sudoer-cli.XXXXXX"; }'
        sed -n '/^sr_json_get_str()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_has_key()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_decode_to_fields()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_valid_service_name()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_split_service_user()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_parse_request_id()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_format_fence_die()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_dest_fence_unknown_keys()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_json_format_fence_or_die()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_path_is_well_known()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_well_known_fence_die()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_cmds_require_well_known()/,/^}/p' "${SCRIPT}"
        sed -n '/^sr_dest_fence_or_die()/,/^}/p' "${SCRIPT}"
        printf '%s\n' "id=\"\$1\"; path=\"\$2\""
        printf '%s\n' 'sr_dest_fence_or_die "${path}" "${id}"'
        printf '%s\n' 'printf "FENCE_OK\n"'
    } >"${_wkrun}"
    _wkid="sudoer-20260821-dns-cli-dns-adm-add-1.json"
    _err=$(sh "${_wkrun}" "${_wkid}" "${CI_HOME}/ci-gbin.json" 2>&1)
    assert_eq "TP-SR-WKBIN-09 dest fence ci-gbin exit 1" 1 "$?"
    assert_contains "TP-SR-WKBIN-09 dest no yes/no" "${_err}" "Dest will not ask yes/no"
    assert_contains "TP-SR-WKBIN-09 dest untrusted" "${_err}" "CODE:untrusted_path"
    _err=$(sh "${_wkrun}" "${_wkid}" "${_fx}" 2>&1)
    assert_eq "TP-SR-WKBIN-09 dest golden exit 0" 0 "$?"
    assert_contains "TP-SR-WKBIN-09 dest golden ok" "${_err}" "FENCE_OK"

    # TP-SR-WKBIN-10: Type 0 submit refuses CI gbin
    _err=$(HOME="${CI_HOME}" SUDOER_CLI_ALLOW_TEST_ROOTS=1 sh "${SCRIPT}" --json --queue-root "${_q}" add-sudoer-request --file "${CI_HOME}/ci-gbin.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-WKBIN-10 submit ci-gbin exit 1" 1 "$?"
    assert_contains "TP-SR-WKBIN-10 submit code" "${_err}" '"code":"untrusted_path"'
    assert_contains "TP-SR-WKBIN-10 submit do not queue" "${_err}" "Do not convert or queue"

    # TP-SR-FT: Type 0 fence-test (closed dest fence list; --file or --dir corpus)
    _ftdir="${TESTS_ROOT}/fixtures/fence-test"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json fence-test --file "${_fx}" 2>/dev/null)
    assert_eq "TP-SR-FT-01 golden --file exit 0" 0 "$?"
    assert_contains "TP-SR-FT-01 no dest fence" "${_out}" "No dest fence matched"
    assert_contains "TP-SR-FT-01 command fence-test" "${_out}" '"command":"fence-test"'
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" fence-test --file "${_ftdir}/match/not-object.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-FT-02 not-object exit 1" 1 "$?"
    assert_contains "TP-SR-FT-02 not-object words" "${_err}" "not a grant JSON object"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json fence-test --file "${_ftdir}/match/ci-homes-gbin.json" 2>&1 >/dev/null)
    assert_eq "TP-SR-FT-03 ci-gbin exit 1" 1 "$?"
    assert_contains "TP-SR-FT-03 ci-gbin code" "${_err}" '"code":"untrusted_path"'
    assert_contains "TP-SR-FT-03 Next running ship unit" "${_err}" "${SCRIPT} fence-test --file"
    assert_not_contains "TP-SR-FT-03 Next not global install" "${_err}" "/usr/local/bin/sudoer-cli"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json fence-test --dir "${_ftdir}/pass" 2>/dev/null)
    assert_eq "TP-SR-FT-04 pass corpus exit 0" 0 "$?"
    assert_contains "TP-SR-FT-04 pass corpus files" "${_out}" '"files":"4"'
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json fence-test --dir "${_ftdir}/match" --expect-match 2>/dev/null)
    assert_eq "TP-SR-FT-05 match corpus --expect-match exit 0" 0 "$?"
    assert_contains "TP-SR-FT-05 all matched" "${_out}" "all matched a dest fence"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" fence-test --dir "${_ftdir}/pass" --file "${_fx}" 2>&1 >/dev/null)
    assert_eq "TP-SR-FT-06 xor --file and --dir exit 1" 1 "$?"
    assert_contains "TP-SR-FT-06 xor words" "${_err}" "not both --file and --dir"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" fence-test --expect-match --file "${_fx}" 2>&1 >/dev/null)
    assert_eq "TP-SR-FT-07 --expect-match needs --dir exit 1" 1 "$?"
    assert_contains "TP-SR-FT-07 expect-match words" "${_err}" "only valid with --dir"

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
{"schema_version":1,"purpose":"Allow this user to deposit folder-backup archives.","username":"${_u}","service":"folder-backup","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/mkdir","args":["-p","/var/backup/folder-backup"]}]}
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
