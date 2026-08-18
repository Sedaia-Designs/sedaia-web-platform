---
name: integrate-brand-icons
description: Retrieve, normalize, add, or refine SVG brand marks for Sedaia Portfolio. Use for company or service logos, theme-aware currentColor conversion, icon scaling, SVG transform cleanup, tonal opacity layers, or brand-icon troubleshooting.
---

# Integrate brand icons

1. Read `../../../../AGENTS.md`; locate the current icon component, vector
   directory, naming convention, and every caller. Do not assume starter or
   Central paths apply here.
2. Prefer the brand owner's official press kit and an official SVG logomark.
   Confirm provenance and preserve required attribution.
3. Preserve the official silhouette. Remove editor metadata, fixed dimensions,
   embedded styles, masks, unnecessary groups, and fixed colors when safe.
4. Follow the repository's filename, root ID, viewBox, and component mapping
   contract exactly.
5. Use `fill="currentColor"` for theme-aware monochrome marks. Preserve
   meaningful multicolor layers with a small number of opacity tiers instead of
   hard-coded replacement colors.
6. Flatten transforms when reliable tooling is available and tightly crop the
   viewBox while retaining intentional whitespace.
7. Compare perceived scale and contrast with adjacent icons on light and dark
   backgrounds.

Validate SVG XML, identifiers and mappings; search for unintended transforms,
styles, fixed colors, and dimensions. Run `pnpm build` and `git diff --check`
after integration, and inspect real hover/focus states when a browser is
practical.
