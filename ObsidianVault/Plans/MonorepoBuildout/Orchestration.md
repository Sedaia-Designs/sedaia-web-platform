# Monorepo Buildout

## Summary

Complete the independently buildable Sedaia Designs platform described by the
historical monorepo plan. The core workspace, Ktor API, business site,
portfolio, and OpenAPI contract exist. Documentation, blog, shared-package,
CDN, hosted integration, and production acceptance work remains.

## Source and scope decisions

- Historical source: `../../Pre-Obsidian/PLAN.md`.
- Existing architecture decisions remain reference material; this plan tracks
  only unfinished implementation and verification.
- Database, authentication, CMS, and a shared CDN provider remain deferred
  until requirements exist. Deferred choices are not active implementation.
- GitHub migration and production operations are tracked in their own plans.

## Recommended order

1. [[Phase 00 - Baseline Audit]]
2. [[Phase 01 - Complete Application Surfaces]]
3. [[Phase 02 - Complete Shared Packages]]
4. [[Phase 03 - Integrate Portfolio API]]
5. [[Phase 04 - Establish Shared Asset Delivery]]
6. [[Phase 05 - Validate Independent Delivery]]
7. [[Phase 06 - Final Verification]]

## Current status

**In progress.** Phase 00 is complete from repository inspection. Phase 05 now
contains dated evidence of independent API staging and deployment to App Engine
on 2026-09-18; the other delivery boundaries and the hosting-target decision
remain pending or requirements-gated. Production-specific evidence belongs in
[[../ProductionReadiness/Orchestration|Production readiness]].
