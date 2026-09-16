---
name: cross-repository-release
description: Prepare, validate, coordinate, or publish releases spanning this project and other independent Sedaia repositories. Use for version preparation, cross-project API compatibility, release notes, production builds, tags, artifacts, deployment ordering, or post-deployment verification.
---

# Coordinate a cross-repository release

Treat preparation, commits, tags, pushes, deployments, and remote publication as
separate authorization boundaries. Never infer remote-action permission from a
request to prepare a release.

## Establish and validate the release

1. Identify every participating repository and read its instructions, versions,
   tags, release metadata, and changelog.
2. Inspect each complete delta from its preceding release and preserve unrelated
   work.
3. Define shared API, schema, content, asset, and artifact contracts. Identify
   backward compatibility, migrations, and deployment ordering.
4. Reconcile final behavior with release notes using `$edit-changelog`.
5. Confirm consumer types and behavior match producers.
6. Run each project's documented tests and production builds independently,
   exercise relevant integrations, and inspect `git diff --check` and status in
   every participating worktree.

## Publish only when authorized

Commit, tag, push, deploy, or publish only with explicit permission for that
stage. Follow the established deployment order, verify production contracts and
artifacts, and report all completed and skipped stages.
