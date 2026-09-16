# Sedaia Portfolio

The static portfolio website for Sedaia Designs, built with SolidJS 2, TypeScript,
Vite, and Sass.

The site presents Sedaia Designs' background, software projects, and professional
work in a responsive, component-based interface. It is a client-only application:
there is no router, server runtime, or SolidStart layer. Source code lives in
`src/`, static assets in `public/`, and the production output is generated in
`dist/client`.

## Development

```sh
pnpm install
pnpm dev
```

Run `pnpm build` to create the production site in `dist/client`, or `pnpm serve`
to preview the production build locally.

### Available commands

- `pnpm dev` — start the Vite development server.
- `pnpm build` — type-check and build the deployable static site.
- `pnpm serve` — preview the production build locally.

The repository uses `pnpm-lock.yaml` to keep dependency installation reproducible.

## Vercel deployment

The repository includes `vercel.json` configured for Vercel's static deployment
workflow. Import the repository into Vercel without changing the detected root
directory; Vercel will install dependencies with the checked-in lockfile, run
`pnpm build`, and publish `dist/client`.
