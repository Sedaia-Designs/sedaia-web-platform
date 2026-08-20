# Sedaia Portfolio guidelines

## Project

This project is the static professional portfolio. It uses SolidJS 2,
TypeScript, Vite, and Sass without SolidStart, a router, or server runtime.
`vite build` emits the deployable static site in `dist/client`.

Dynamic public content may be fetched from sibling project
`../sedaia-central-api`. Do not connect this frontend directly to
`sedaia-main-db`, add server-only behavior, or introduce SolidStart unless the
deployment architecture is intentionally reconsidered across the workspace.

Do not edit generated output such as `dist/`, `.vite/`, or dependency folders.

## Conventions

- Use `.tsx` for JSX and `.ts` otherwise; keep useful strict types.
- Follow SolidJS 2 patterns, not React patterns. Use `class` for JSX classes;
  never use React's `className`. Use Solid primitives, accessors, and
  fine-grained reactivity.
- Keep `src/App.tsx` focused on page composition; put reusable UI in
  `src/components` and nonvisual behavior in `src/lib`.
- Use semantic HTML and accessible loading, error, empty, navigation, and form
  states.
- Guard browser-only globals when code can run while the document shell is
  generated.
- Use `.scss` or `.module.scss` for authored styles. Prefer semantic tokens and
  `hsl()` or `oklch()` colors over hexadecimal, RGB, or named literals.

## Commands

Use pnpm and the checked-in lockfile:

```sh
pnpm install
pnpm dev
pnpm build
pnpm serve
```

Run focused tests when present, then `pnpm build` and `git diff --check` for
behavior or configuration changes as applicable.

## Skills

- Use `.agents/skills/code-style` for SolidJS, TypeScript/TSX, Sass, Vite, or
  frontend configuration changes and reviews.
- Use `.agents/skills/ui-accessibility` for components, interactions, or layout
  accessibility.
- Use `.agents/skills/integrate-brand-icons` when adding or normalizing brand
  SVGs. Confirm the current asset/component paths before following it because
  this project is still evolving from its starter template.

Shared Git, changelog, release, and cross-site workflows live in
`../.agents/skills`.

Do not commit, push, tag, release, deploy, or modify remote services without
explicit authorization.
