# Phase 02 - Make Deployment Pre-Traffic Safe

## Goal

Verify the exact candidate revision before production traffic moves, promote only that named revision, and preserve deterministic recovery and evidence for every failure stage.

## Work

- [ ] Capture the pre-deploy serving revision, immutable image digest, traffic allocation, generated URL, and canonical-host verification result before creating a candidate.
- [ ] Change the deploy step to create a zero-traffic candidate with a unique, DNS-safe traffic tag derived from the build ID. Do not use `--to-latest` as the promotion target because “latest” can change under concurrent or break-glass activity.
- [ ] Resolve the candidate revision by its build label and verify its image digest, readiness condition, runtime identity, probes, resources, scaling, and zero production traffic before calling its tagged URL.
- [ ] Run the strengthened Phase 01 verification against the tagged candidate URL. A failure must leave the prior production traffic allocation unchanged.
- [ ] Promote the exact candidate revision to 100 percent only after candidate verification passes. Serialize all deployment and rollback entry points using one enforceable lock or policy, not merely documentation.
- [ ] Verify both the generated service URL and canonical hostname after promotion. If either post-promotion check fails, restore the captured prior revision and verify recovery; retain evidence of the candidate failure, promotion attempt, rollback, and final traffic state.
- [ ] Remove the temporary traffic tag after successful verification or rollback so stale tags do not accumulate or impede revision cleanup.
- [ ] Make `CI_COMMIT_SHA` and repository identity mandatory and format-validated. Never mark a release `known-good` when either value is missing or `unavailable`.
- [ ] Upload staged evidence even on failure. Separate candidate evidence, promotion evidence, canonical verification, recovery evidence, and final state. Ensure a failed evidence upload does not erase local diagnostic output from the build log.
- [ ] Make the rollback workflow consume the same retained Cloud Storage release schema produced by routine automatic builds, or generate an equivalent signed/provenance-checked artifact that the workflow can retrieve without depending on an unrelated manual deployment run.
- [ ] Add build-level tests or a dry-run harness that proves ordering: deploy at zero traffic → candidate verify → named promotion → canonical verify → evidence finalization, with rollback after any post-promotion failure.

## Controlled validation

Use a harmless reviewed API change merged through protected `main`. Confirm exactly one build for the commit, zero candidate traffic during preflight, successful tagged-URL verification, promotion of the named revision, 100 percent final traffic, canonical verification, retained evidence, and removal of the temporary tag. Then run a controlled negative drill using a candidate that fails contract verification but becomes technically ready; prove it receives zero production traffic. Test post-promotion recovery only with a safe reversible method approved by the operator and never manufacture a customer-visible outage.

## Exit criterion

A good candidate is verified before receiving traffic and promoted by immutable revision name; a bad candidate remains at zero percent; a failed post-promotion check restores the captured prior revision; every outcome retains source, digest, revision, traffic, verification, and recovery evidence.
