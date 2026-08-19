# Report: dest Fence + OPEN-BEHALF — sudoer-cli 1.8.1

**Date:** 2026-08-19  
**Mode:** local review then implement  
**Status:** closed  
**Suite:** PASS=299 FAIL=0 SKIP=2

## Summary

Local review of uncommitted 1.7.0–1.8.1 work found dest-fence law Active but unwired (`interactive` prompted first; `reject` skipped JSON; action mismatch dropped), `remove-sudoer-request` still bound the subject to `id -un`, and version SSOT split (ship 1.8.1 vs law/SECURITY 1.7.1). Those bugs are fixed in this release. Approve-path actor lock removal and LPU rc `chown` remain.

## Issues

### Issue 1 -- Severity: bug
- File: src/sudoer-cli (sr_interactive / sr_reject / sr_approve)
- Description: Dest Fence not applied before yes/no.
- Suggestion: `sr_dest_fence_or_die` on approve/reject/interactive; action `field_mismatch`; username/service not a fence.
- Lesson: (new) dest Fence first
- Test: TP-SR-FENCE-01..04
- Status: closed

### Issue 2 -- Severity: bug
- File: src/sudoer-cli (sr_submit remove / sr_json_encode_request)
- Description: Remove rewrote subject to the invoker.
- Suggestion: Keep JSON username/service; purpose-only means no commands.
- Lesson: L-ID-SPLIT-01 / OPEN-BEHALF
- Test: TP-SR-17 / TP-SR-18
- Status: closed

### Issue 3 -- Severity: bug
- File: docs/requirements/requirement-domain-sudoer-approval.md
- Description: Identity-match row still taught basename username/service win.
- Suggestion: JSON user/service SSOT; only basename action must match.
- Status: closed
