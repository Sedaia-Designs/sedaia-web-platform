# Phase 02 - Complete Shared Packages

**Status: Pending demonstrated consumers.**

1. Decide whether the OpenAPI package should generate a TypeScript client or
   only validate the public contract.
2. Generate and test the client if runtime consumers require it.
3. Introduce design tokens or shared configuration only when at least two
   applications need the same behavior.
4. Keep package builds and contract-drift checks independently runnable.

Exit criterion: required shared packages exist, have real consumers, and do
not contain speculative utilities.
