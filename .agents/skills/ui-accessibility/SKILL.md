---
name: ui-accessibility
description: Apply or review WCAG 2.2 AA accessibility across Sedaia Web Platform frontends, including navigation, forms, components, asynchronous feedback, keyboard behavior, focus, semantics, contrast, responsive layouts, and screen-reader support.
---

# Review UI Accessibility

Read the target application's `AGENTS.md`. Use WCAG 2.2 AA as the baseline and prefer native HTML semantics before ARIA.

- Preserve logical landmarks and heading hierarchy with one descriptive `h1` per document.
- Use anchors for navigation and downloads, and buttons for actions.
- Give controls visible labels and programmatically associated errors or help.
- Maintain visible focus, logical focus order, keyboard operation, readable reflow, sufficient target sizes, and adequate contrast.
- Do not use color alone for status, errors, freshness, or selection.
- Give informative images useful alternative text and decorative images empty alternative text.
- Announce important asynchronous state without over-announcing routine updates.
- Check generated markup and Solid transitions for loading, empty, success, and error states; avoid duplicate IDs and stranded focus.

Run the target package's tests and build. Inspect the changed flow with keyboard-only navigation when practical, and distinguish automated, manual, and unverified browser or screen-reader coverage in the result.
