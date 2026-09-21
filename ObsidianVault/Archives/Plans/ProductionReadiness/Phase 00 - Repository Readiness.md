# Phase 00 - Repository Readiness

**Status: Complete in repository; hosted validation pending elsewhere.**

The repository contains:

- the canonical `https://api.sedaia-designs.org` OpenAPI server;
- explicit CORS support for the Portfolio production origins;
- readiness, JSON-response, and Portfolio-origin CORS verification;
- immutable release-manifest generation and provenance validation;
- serialized deployment and rollback workflows;
- explicit Cloud Run port, identity, ingress, scaling, CPU, memory,
  concurrency, and timeout settings; and
- cleanup and monitoring configuration scripts.

Exit criterion: repository controls required by later phases are checked in and
their local validation passes.
