# Monorepo Buildout

> [!warning] Superseded on 2026-09-21
> This plan is retained as historical evidence and must not be executed. Every phase and meaningful checklist item is dispositioned in [[../SedaiaPlatformBuildout/Phase 00 - Audit and Authority Reconciliation|Sedaia Platform Buildout Phase 00]]. Continue platform buildout work in [[../SedaiaPlatformBuildout/Orchestration|Sedaia Platform Buildout]]. API runtime remediation remains separately authoritative in [[../GCloudCloudRunRemediation/Orchestration|Google Cloud Run Remediation]].

## Summary

Complete the independently buildable Sedaia Designs platform described by the
historical monorepo plan. The core workspace, Ktor API, business site,
portfolio, and OpenAPI contract exist. Documentation, blog, shared-package,
CDN, hosted integration, and production acceptance work remains.

## Source and scope decisions

- Historical source: `../../Archives/Plans/Pre-Obsidian/PLAN.md`.
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

**Superseded.** The 2026-09-18 App Engine deployment is historical evidence, not current authority. Cloud Run is the intended API runtime and its active gates live in [[../GCloudCloudRunRemediation/Orchestration|Google Cloud Run Remediation]]. The five-surface buildout, including SQL, R2/CDN, both frontends, API integration, operations, and final production acceptance, is owned by [[../SedaiaPlatformBuildout/Orchestration|Sedaia Platform Buildout]].
