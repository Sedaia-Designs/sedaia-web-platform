# Sedaia Portfolio

The static portfolio website for Sedaia Designs, built with SolidJS, TypeScript,
Vite, and Sass.

## Development

```sh
pnpm install
pnpm dev
```

Run `pnpm build` to create the production site in `dist/client`, or `pnpm serve`
to preview the production build locally.

## Vercel deployment

The repository includes `vercel.json` configured for Vercel's static deployment
workflow. Import the repository into Vercel without changing the detected root
directory; Vercel will install dependencies with the checked-in lockfile, run
`pnpm build`, and publish `dist/client`.
