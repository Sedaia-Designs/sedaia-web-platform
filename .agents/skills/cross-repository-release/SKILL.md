---
name: cross-repository-release
description: Prepare, validate, coordinate, or publish releases spanning the Sedaia Web Platform monorepo and independent Sedaia repositories. Use for cross-project contracts, release notes, builds, tags, artifacts, deployment ordering, or post-deployment verification.
---

# Coordinate a Cross-Repository Release

Treat preparation, commits, tags, pushes, deployments, and remote publication as separate authorization boundaries. Never infer remote-action permission from a request to prepare a release.

## Establish and Validate the Release

1. Identify participating repositories and the affected monorepo applications or packages. Read each repository's instructions, versions, tags, release metadata, and changelog.
2. Inspect each complete delta from its preceding release and preserve unrelated work.
3. Define shared API, schema, content, asset, and artifact contracts. Identify backward compatibility, migrations, and deployment ordering across independently deployable units.
4. Reconcile final behavior with release notes using the repository's changelog skill.
5. Confirm consumer types and behavior match producers, including OpenAPI, Kotlin models, generated clients, and frontend integrations when applicable.
6. Run each affected unit's documented tests and production build independently, exercise relevant integrations, and inspect `git diff --check` and status in every worktree.

## Publish Only When Authorized

Commit, tag, push, deploy, or publish only with explicit permission for that stage. Follow the established deployment order, verify production contracts and artifacts, and report completed and skipped stages.
