# Phase 11 - Final Verification

**Status: Pending.** Run last, after the cutover decision.

Perform the final cross-check after the cutover decision:

1. Confirm required checks and the `production` environment remain enforced.
2. Confirm OIDC trust still matches only the canonical repository and
   production environment.
3. Confirm the latest release and rollback evidence is complete and retained.
4. Confirm production traffic serves the intended immutable App Engine
   version and that its workflow evidence identifies the source commit.
5. Confirm the operational fallback and incident instructions match the final
   system of record.
6. Review repository changes for credentials, unrelated edits, broken links,
   and stale references to the former deployment source.

Exit criterion: every check passes, evidence locations are recorded, and no
required migration work remains open.
