# Phase 05 - R2 Asset Supply Chain

## Goal

Build a controlled asset supply chain from source artifact through quarantine, validation, approval, immutable storage, metadata linkage, retention, and independent recovery.

## Scope

R2 accounts/buckets, credentials/bindings, object keys, metadata, multipart uploads, validation, scanning, signing/notarization, publication states, replacement/deprecation/deletion, lifecycle, inventory, and independent backup.

## Prerequisites

Phases 01–02 complete, schema conventions from Phase 04 stable enough for artifact linkage, approved account/bucket and backup decisions.

## Decisions before execution

Approve bucket names/environment separation, jurisdiction, authoritative external archive, key grammar, upload actors, scanner, maximum object size, allowed MIME/extensions, signing policy, retention/legal hold, lifecycle tiers, and emergency withdrawal policy.

## Repository areas and hosted systems

`apps/cdn`, `apps/sql`, API publication services, Cloudflare R2/Workers configuration, CI/release repositories, malware scanner, platform signing/notarization, independent backup/archive.

## Ordered steps

- [ ] Define key grammar such as `products/{product-id}/releases/{version}/{platform}/{sha256-prefix}/{filename}` with normalized allowlisted segments; keys are immutable and never reused.
- [ ] Define object metadata: SHA-256, exact byte length, detected and declared MIME, safe ASCII/UTF-8 filename policy, product/release/platform/architecture, source commit/build provenance, signature/notarization status, scan result/version/time, uploader, and retention class.
- [ ] Provision isolated staging/quarantine, production-public, and production-private buckets; disable public `r2.dev` access and direct listing; grant narrow per-environment tokens/bindings.
- [ ] Implement an idempotent upload workflow that streams checksum calculation, rejects traversal/control characters and mismatches, validates size/type, and writes quarantine only.
- [ ] Run malware scanning and required signing/notarization verification before approval; define fail-closed behavior, scanner outage handling, false-positive review, and re-scan triggers.
- [ ] Copy approved bytes to a new immutable production key, verify HEAD/size/checksum metadata, then transactionally register or advance the database record; a failed metadata transaction leaves an unreferenced object for controlled cleanup, not public metadata.
- [ ] Define replacement as a new version/key and metadata transition; never overwrite published bytes. Deprecation preserves history; withdrawal removes discovery and may deny delivery while evidence remains.
- [ ] Configure lifecycle only for temporary/quarantine/multipart data until independent backup and retention proof exists; exclude active releases and legal holds.
- [ ] Create signed inventory manifests and replicate every authoritative binary to the independent archive/source; reconcile bucket/database/archive inventories on schedule.
- [ ] Perform a restore of representative large/signed artifacts from the independent source into a clean test bucket and verify SHA-256, metadata, and delivery readiness.

## Security and operational considerations

Upload credentials never reach browsers unless a separately approved constrained direct-upload design exists. Treat content-type as untrusted and use safe disposition. Prevent public access to private/staging buckets through every alternate hostname. Separate approval from upload where staffing permits.

## Test strategy

Test valid/invalid/oversized/truncated/mislabeled/malicious/duplicate/concurrent uploads, checksum mismatch, scanner failure, signing failure, metadata failure, orphan reconciliation, attempted overwrite, private access denial, lifecycle exclusions, inventory drift, and independent restore.

## Acceptance criteria

Every publishable object is immutable, checksum-addressable, scanned as approved, provenance-linked, backed up independently, and represented by consistent database metadata; no private/staging object has an unauthenticated route.

## Evidence to retain

Bucket IDs/policies, token/binding scopes, key specification, sample manifests, scan/sign/notarization reports, object/database/archive reconciliation, lifecycle config, restore results, costs, and owner approvals.

## Rollback or recovery

Withdraw metadata or revert Worker policy without overwriting objects. Restore missing/corrupt bytes to the identical key only after checksum/provenance validation and cache incident analysis; otherwise publish a new key/version. Recover from the independent archive, not the serving bucket alone.

## Dependencies

Depends on Phases 01–02 and coordinates with Phase 04. Blocks Phases 06–07 publication flows.

## Exit criterion

A representative release artifact can move from quarantine to approved immutable storage and database linkage, then be independently restored with byte-identical checksum and complete evidence.
