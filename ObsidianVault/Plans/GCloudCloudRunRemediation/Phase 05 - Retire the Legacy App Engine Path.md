# Phase 05 - Retire the Legacy App Engine Path

## Goal

End the App Engine fallback deliberately after Cloud Run has proven safe deployment, recovery, and monitoring, while preserving the evidence needed to understand or reconstruct the former state.

## Preconditions

- [ ] Phases 00–04 are complete with links to evidence.
- [ ] The production owner accepts the Cloud Run observation window and records the decision, date, residual risks, and rollback authority.
- [ ] Public and authoritative DNS resolve `api.sedaia-designs.org` only to the Google load balancer, the managed certificate is active, and no App Engine domain mapping or frontend configuration is still required for API traffic.
- [ ] At least two current known-good Cloud Run revisions and immutable digests remain recoverable under the tested rollback procedure.

## Work

- [ ] Export the final App Engine service, version, traffic, domain-mapping, IAM-relevant, and log-retention state. Record version `20260918t095626`, its source/build provenance where available, and the fact that the default service itself cannot be deleted.
- [ ] Search repository automation, documentation, secrets, scheduled jobs, external CI/CD integrations, and operator runbooks for App Engine deployment or rollback entry points. Disable or remove only those confirmed obsolete; preserve historical notes as historical evidence.
- [ ] Confirm the default App Engine hostname and any old mapped hostname are absent from frontend environment configuration, health checks, monitors, webhooks, and external integrations.
- [ ] Stop the serving App Engine version with `gcloud app versions stop --service=default 20260918t095626 --project=sedaia-web-platform-api-508804` only after the preconditions pass. Do not attempt to delete the App Engine `default` service.
- [ ] Verify the version reports stopped, Cloud Run remains healthy at both endpoints, DNS and TLS remain correct, alerts remain enabled, and no unexpected requests appear in App Engine logs during the agreed follow-up window.
- [ ] Remove obsolete App Engine credentials and IAM bindings only after confirming they are unused. Preserve final evidence for the agreed audit period.
- [ ] Update all orchestration and status notes to state that Cloud Run is production and App Engine is retired, including the recovery implications of a stopped legacy version.

## Failure handling

If a previously unknown dependency still calls App Engine, record it and decide whether to migrate the dependency or temporarily restart the retained version. Restarting App Engine is an incident/change action, not the normal Cloud Run rollback path. Do not delete the retained version during this plan.

## Exit criterion

The App Engine version is stopped, no production dependency or automation targets it, Cloud Run and monitoring remain healthy through the accepted follow-up window, and the final legacy evidence and reactivation limitations are documented.
