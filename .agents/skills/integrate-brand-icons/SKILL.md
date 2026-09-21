---
name: integrate-brand-icons
description: Retrieve, normalize, add, or refine SVG brand marks in Sedaia Web Platform frontends. Use for company or service logos, theme-aware currentColor conversion, icon scaling, SVG cleanup, tonal layers, or brand-icon troubleshooting.
---

# Integrate Brand Icons

1. Read the repository and target-app instructions; locate the current icon component, vector directory, naming convention, and every caller. Do not assume paths or mappings are shared between applications.
2. Prefer the brand owner's official press kit and an official SVG logomark. Confirm provenance and preserve required attribution.
3. Preserve the official silhouette. Remove editor metadata, fixed dimensions, embedded styles, masks, unnecessary groups, and fixed colors only when safe.
4. Follow the owning application's filename, root ID, `viewBox`, and component mapping contract exactly. Share an icon through `packages/` only when multiple applications demonstrably use the same contract.
5. Use `fill="currentColor"` for theme-aware monochrome marks. Preserve meaningful multicolor layers with a small number of opacity tiers instead of arbitrary replacement colors.
6. Flatten transforms when reliable tooling is available and tightly crop the `viewBox` while retaining intentional whitespace.
7. Compare perceived scale, contrast, hover, and focus behavior with adjacent icons on light and dark backgrounds.

Validate SVG XML, identifiers, imports, and mappings. Search for unintended transforms, styles, fixed colors, and dimensions. Run the owning package's build and `git diff --check`.
