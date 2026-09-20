# Phase 06 - Cut Over the API Domain

## Goal

Route `api.sedaia-designs.org` to the verified Cloud Run service with managed TLS and a reversible DNS change.

## Provider and implementation decision

Vercel is the authoritative DNS provider for `sedaia-designs.org` (`ns1.vercel-dns.com` and `ns2.vercel-dns.com`). The production endpoint uses a Google Cloud global external Application Load Balancer with a serverless NEG pointing to `sedaia-api`, a Google-managed certificate, and HTTP-to-HTTPS redirection. Direct Cloud Run domain mapping is not used.

## Provisioned Google Cloud resources

The Google Cloud side was provisioned on 2026-09-20 in project `sedaia-web-platform-api-508804`.

| Resource | Name or value |
| --- | --- |
| Reserved global IPv4 address | `sedaia-api-ip` / `8.233.157.128` |
| Serverless NEG | `sedaia-api-neg` in `us-central1` |
| Backend service | `sedaia-api-backend` |
| HTTPS URL map | `sedaia-api-url-map` |
| Google-managed certificate | `sedaia-api-cert` for `api.sedaia-designs.org` |
| HTTPS target proxy | `sedaia-api-https-proxy` |
| HTTPS forwarding rule | `sedaia-api-https-forwarding-rule` on TCP 443 |
| HTTP redirect URL map | `sedaia-api-http-redirect` |
| HTTP target proxy | `sedaia-api-http-proxy` |
| HTTP forwarding rule | `sedaia-api-http-forwarding-rule` on TCP 80 |

The Cloud Run backend was `sedaia-api-00002-z9z` with 100 percent traffic when these resources were created. Its generated URL returned successfully from `/health/ready` before load-balancer provisioning.

## Recorded pre-cutover DNS state

On 2026-09-20, `api.sedaia-designs.org` had a 1,800-second TTL and resolved to these Vercel addresses:

- `216.150.1.1`
- `216.150.16.193`

These two A records are the rollback record set. Keep them until the observation window and Phase 08 verification are complete.

## Vercel DNS cutover

The Vercel DNS change was completed and verified on 2026-09-20. The user-provided Vercel screenshot showed an `api` A record targeting `8.233.157.128` with a 60-second TTL. Queries against the authoritative path, Cloudflare resolver `1.1.1.1`, and Google resolver `8.8.8.8` all returned only `8.233.157.128`.

The forced-IP HTTP check reached the Google frontend and returned the expected permanent redirect to HTTPS. The previous Vercel response remained visible briefly through a stale local resolver cache, but public resolvers already held the new record.

The Google-managed certificate remained `PROVISIONING` throughout the initial five-minute observation window and subsequently became `ACTIVE` for `api.sedaia-designs.org`. At verification time, Google reported an expiration time of 2026-12-19 14:02:35 PST; renewal is managed by Google.

## Verification after the Vercel change

```sh
dig +noall +answer api.sedaia-designs.org A

gcloud compute ssl-certificates describe sedaia-api-cert \
  --project=sedaia-web-platform-api-508804 \
  --global \
  --format='yaml(managed.status,managed.domainStatus)'

curl --fail --show-error --silent https://api.sedaia-designs.org/health/ready
scripts/verify-api-deployment.sh https://api.sedaia-designs.org
```

## Final verification result

Phase 06 completed successfully on 2026-09-20. DNS resolved only to `8.233.157.128`, the Google-managed certificate and domain status both reported `ACTIVE`, `/health/ready` returned successfully, and `scripts/verify-api-deployment.sh https://api.sedaia-designs.org` passed HTTP 200, JSON validation, and CORS for `https://sakura-sedaia.com`.

## Rollback

If verification fails after the cutover, replace the `api` A record for `8.233.157.128` with the recorded Vercel A records `216.150.1.1` and `216.150.16.193`. Do not delete the Google Cloud load-balancer resources during rollback; retaining them keeps diagnosis and a subsequent retry reversible.

## Exit criterion

Satisfied on 2026-09-20: the canonical HTTPS hostname resolves to `8.233.157.128`, presents the active Google-managed certificate, passes the full API verification, and can be reverted using the recorded prior Vercel DNS state.
