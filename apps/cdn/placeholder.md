# Sedaia Designs Shared Asset Delivery Placeholder

## Current Status

This directory reserves the future shared CDN or object-storage application. It is not currently a deployable application, and `cdn.sedaia-designs.org` has no implementation in this repository. Assets used by only one frontend remain in that frontend's `public` directory and deployment.

## Intended Responsibility

The shared asset service will publish public assets needed by more than one application, such as portfolio render images and other reusable media referenced by the API. It must not store private or user-specific content.

## Implementation Requirements

- Select the storage and delivery provider only after the first shared-asset use case defines retention, cache, cost, and publication requirements.
- Publish assets at immutable content-hashed or explicitly versioned paths.
- Apply long-lived cache headers to immutable files.
- Document publication, ownership, invalidation, rollback, and recovery procedures.
- Keep application-specific assets with their owning application unless sharing provides a concrete benefit.

## Activation Criterion

Replace this placeholder when a shared asset is required and a reproducible, reviewed publication workflow has been selected and implemented.
