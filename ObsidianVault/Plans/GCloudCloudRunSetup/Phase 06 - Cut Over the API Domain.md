# Phase 06 - Cut Over the API Domain

## Goal

Route `api.sedaia-designs.org` to the verified Cloud Run service with managed
TLS and a reversible DNS change.

## Recommended production path

Use a global external Application Load Balancer with a serverless NEG pointing
to `sedaia-api`, a Google-managed certificate for `api.sedaia-designs.org`, and
an HTTPS forwarding rule. This is Google Cloud's recommended production custom
domain option and supports stronger traffic and TLS controls.

Before implementation, record:

- the current authoritative DNS provider and existing API records;
- the existing App Engine mapping and certificate state;
- the DNS TTL and a rollback record set;
- the reserved global IP, serverless NEG, backend service, URL map, HTTPS proxy,
  certificate, and forwarding-rule names.

Lower the DNS TTL at least one previous-TTL interval before cutover. Create the
load balancer, verify certificate readiness, then change only the API hostname.

## Preview fallback

Direct Cloud Run domain mapping is available in `us-central1`, but Google marks
it Preview and does not recommend it for production. Use it only after recording
explicit acceptance of that limitation:

```sh
gcloud domains list-user-verified

gcloud beta run domain-mappings create \
  --project=sedaia-web-platform-api-508804 \
  --region=us-central1 \
  --service=sedaia-api \
  --domain=api.sedaia-designs.org

gcloud beta run domain-mappings describe \
  --project=sedaia-web-platform-api-508804 \
  --region=us-central1 \
  --domain=api.sedaia-designs.org
```

Apply exactly the returned `resourceRecords` at the DNS provider. If CAA
records are used, allow the certificate authorities required by Google-managed
certificates.

## Verification

```sh
dig api.sedaia-designs.org
curl --fail --show-error --silent https://api.sedaia-designs.org/health/ready
scripts/verify-api-deployment.sh https://api.sedaia-designs.org
```

Keep the previous DNS values and App Engine version until DNS propagation, TLS,
API, CORS, logs, and alerts remain healthy for the agreed observation window.

## Exit criterion

The canonical HTTPS hostname resolves to Cloud Run, presents a valid managed
certificate, passes the full API verification, and can be reverted using the
recorded prior DNS state.
