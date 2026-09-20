# Phase 02 - Establish Release Evidence and Retention

**Status: Partially complete.** The historical audit recorded 30-day Cloud
Logging retention and cleanup configuration in dry-run. Digest comparison,
hosted release artifacts, and safe cleanup activation remain pending.

1. Produce two successful immutable release manifests with verification data.
2. Confirm workflow artifacts remain available for at least 30 days.
3. Compare cleanup candidates with current and previous known-good digests.
4. Enable deletion only after the dry-run proves both rollback candidates and
   the newest ten production images are retained.
5. Record the effective log, artifact, and image retention evidence.

Exit criterion: the full rollback window is covered without rebuilding an old
commit or relying on a mutable tag.
