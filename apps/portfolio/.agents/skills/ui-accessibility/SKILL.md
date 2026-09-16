---
name: ui-accessibility
description: Apply or review WCAG 2.2 AA accessibility in Sedaia Portfolio navigation, forms, components, loading and error feedback, keyboard behavior, focus, semantics, labels, contrast, responsive layouts, and screen-reader support.
---

# Review UI accessibility

Use WCAG 2.2 AA as the baseline and prefer native HTML semantics before ARIA.

- Preserve logical landmarks and heading hierarchy with one descriptive `h1`.
- Use anchors for navigation/downloads and buttons for actions.
- Give controls visible labels and programmatically associated errors or help.
- Maintain visible focus, logical focus order, keyboard operation, readable
  reflow, sufficient target sizes, and high contrast.
- Do not use color alone for status, errors, freshness, or selection.
- Give informative images useful alt text and decorative images empty alt text.
- Announce important asynchronous state without over-announcing routine updates.
- Check generated markup and Solid transitions for loading, empty, success, and
  error states; avoid duplicate IDs or stranded focus.

Run `pnpm build`. Inspect the changed flow with keyboard-only navigation and a
real browser when practical. Report automated, manual, and unverified
screen-reader or browser coverage separately.
