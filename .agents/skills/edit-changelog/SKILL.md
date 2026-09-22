---
name: edit-changelog
description: Create, edit, curate, or review changelog entries and release notes for the Sedaia Web Platform monorepo or one of its applications and packages. Use for Unreleased or version sections, release deltas, or validating user-visible notes.
---

# Edit a Changelog

Write release notes from final observable behavior, not commit subjects.

1. Identify the affected applications and packages, then read their instructions, release metadata, existing changelog conventions, and matching tags.
2. Establish the target release and predecessor; ask only when the boundary cannot be established safely.
3. Inspect the complete predecessor-to-current diff, including relevant uncommitted work for `Unreleased`.
4. Separate platform-wide changes from independently versioned application or package changes. Avoid duplicating one change across changelogs unless each audience needs it.
5. Reconcile external Sedaia repositories when they are explicitly in scope while keeping histories and release notes distinct.
6. Exclude reverted work, temporary defects, formatting churn, and implementation-only noise.

Describe outcomes for users, API clients, operators, or contributors. Call out breaking changes, deprecations, removals, security changes, migrations, and meaningful fixes. Do not invent compatibility, motivation, deployment status, or impact.

Follow an existing format. If creating a changelog is explicitly required and none exists, use Keep a Changelog headings with `Unreleased` first and dates in `YYYY-MM-DD` form. Verify every entry against final state, ordering, links, and related metadata; review the changelog diff separately and run `git diff --check`.
