---
name: edit-changelog
description: Create, edit, curate, or review changelog entries and release notes for this Sedaia project. Use for Unreleased or version sections, deriving notable changes since a release, or checking that notes describe the final user-visible delta.
---

# Edit a changelog

Write release notes from final observable behavior, not commit subjects.

1. Read project instructions, release metadata, existing changelog conventions,
   and matching tags.
2. Identify the target release and predecessor; ask only if the boundary cannot
   be established safely.
3. Inspect the complete predecessor-to-current diff, including relevant
   uncommitted work for `Unreleased`.
4. Reconcile changes across affected repositories while keeping their release
   notes and histories distinct.
5. Exclude reverted work, temporary defects, formatting churn, and
   implementation-only noise.

Describe outcomes for users, API clients, operators, or contributors. Call out
breaking changes, deprecations, removals, security changes, and meaningful
fixes. Do not invent compatibility, motivation, deployment status, or impact.

Follow an existing format. If creating a changelog is explicitly required and
none exists, use Keep a Changelog headings: `Added`, `Changed`, `Deprecated`,
`Removed`, `Fixed`, and `Security`; keep `Unreleased` first and dates in
`YYYY-MM-DD` form.

Verify each entry against final state, version ordering, links, and related
metadata. Review the changelog diff separately and run `git diff --check`.
