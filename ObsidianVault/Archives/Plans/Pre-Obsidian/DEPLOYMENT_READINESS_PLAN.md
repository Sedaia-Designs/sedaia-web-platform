## Remaining deployment readiness plan

> [!NOTE]
> Archived pre-Obsidian plan. Remaining work is split between
> `../ProductionReadiness/Orchestration.md` and
> `../GitHubActionsMigration/Orchestration.md`.

### 7. Connect the Portfolio to the API

Implementation status: repository configuration is ready. Ktor explicitly
allows the production Portfolio origins, the OpenAPI contract identifies
`https://api.sedaia-designs.org`, and the deployment smoke test validates the
Portfolio origin's CORS access. `VITE_API_BASE_URL` still needs to be set in the
Vercel production environment. Runtime calls are intentionally deferred to the
Portfolio's asynchronous helper so the static site remains independent of API
availability.

The deployed Portfolio does not currently call the Ktor API, so the backend
can be released independently. Before adding browser-side API requests:

1. Choose the stable production endpoint: either the generated Cloud Run URL
   or `https://api.sedaia-designs.org` after its DNS and certificate are ready.
2. Add `VITE_API_BASE_URL` to the Portfolio's production environment in
   Vercel. Do not check deployment-specific URLs into the frontend source.
3. Configure Ktor CORS for the actual Portfolio origin,
   `https://sakura-sedaia.com`, and any explicitly required preview origins.
   Do not use a wildcard origin if credentials or private endpoints are added.
4. Update the OpenAPI `servers` entry to match the selected public endpoint.
5. Add an integration check that calls `/v1/portfolio/` from the deployed
   Portfolio origin and verifies a successful JSON response.

This step is complete when the production Portfolio can reach the API without
mixed-content or CORS errors and the configured endpoint matches the OpenAPI
contract.

### 8. Establish rollback and observability

Implementation status: the GitLab repository automation is complete. The first
GitHub Actions port now covers CI validation, manual deployment, retained
release manifests, provenance-checked manual rollback, environment protection,
OIDC authentication, and production concurrency. It must still be configured
and exercised in GitHub before GitHub becomes the only deployment source. The
manual settings, negative tests, evidence register, stability window, and
cutover gates are defined in `GITHUB_UI_VALIDATION_PLAN.md`. The production
audit on 2026-09-16 confirmed 30-day `_Default` log retention, an empty
Artifact Registry repository with no cleanup policy, and no deployed
`sedaia-api` Cloud Run service, uptime check, or alert policies. The checked-in
operations script applies cleanup in dry-run and creates monitoring after an
operator supplies a tested notification channel. Deployment/rollback manifests
and the protected rollback workflow will become exercisable after the first two
production releases. The completion criteria therefore remain operationally
pending; see `operations/ROLLBACK_AND_OBSERVABILITY.md` for the evidence table.

#### Goal

Make every production API release identifiable, observable, and recoverable
without rebuilding source. A release must leave enough durable evidence to
select a known-good revision or immutable image digest after the deployment job
has finished.

#### 8.1 Record an immutable release manifest

Extend `deploy-api` so a successful deployment writes a machine-readable
release manifest containing:

- deployment timestamp and GitHub Actions workflow-run/job URLs;
- Git commit SHA;
- Artifact Registry image URI, commit tag, and resolved `sha256` digest;
- Cloud Run service and revision names;
- production service URL and configured public API URL;
- readiness, portfolio JSON, and Portfolio-origin CORS check results; and
- the revision receiving production traffic after verification.

Publish the manifest as a GitHub Actions artifact with an explicit retention period
that is at least as long as the rollback window. Also print a concise summary in
the job log. The digest-qualified image reference, not only its mutable tag,
must be present. Failed smoke tests must fail the deployment and must not mark
the new revision as known-good.

Use a revision label or annotation for the commit SHA and pipeline ID so Cloud
Run can be correlated with the manifest and source without relying on revision
ordering. Do not include credentials, identity tokens, or environment secrets
in the artifact.

#### 8.2 Define the rollback window and retention

Choose and document one rollback window before adding cleanup automation. The
initial target is 30 days, with at least the 10 most recent production images
retained even if deployment frequency would otherwise age them out.

1. Inspect the `_Default` Cloud Logging bucket and record its actual retention
   period. Increase it or create a dedicated bucket only if it is shorter than
   the rollback and incident-review window.
2. Add an Artifact Registry cleanup policy that deletes unneeded images older
   than 30 days while preserving the most recent 10 production images and every
   image still referenced by a rollback candidate.
3. Preview or dry-run the cleanup policy and verify the known-good and previous
   known-good digests are retained before enabling deletion.
4. Keep GitHub Actions release-manifest artifacts for at least 30 days. If repository
   artifact retention cannot guarantee that period, copy manifests to a
   durable, access-controlled release-history location.

The cleanup policy must operate on deployed artifacts only; it must never make
rollback depend on rebuilding an old commit.

#### 8.3 Configure production monitoring

Manage alert policies as reviewed, reproducible configuration rather than only
as console state. Scope every policy to the `sedaia-api` Cloud Run service in
`us-central1`, and attach a tested notification channel owned by the operator.

Create these initial alerts, then tune them after real traffic establishes a
baseline:

1. **Availability:** an HTTPS uptime check against `/health/ready` on the
   production API endpoint, alerting after two consecutive failures.
2. **HTTP 5xx rate:** alert when 5xx responses exceed 5% for five minutes, with
   a minimum request-volume guard so isolated low-traffic errors do not create
   a misleading percentage alert. Add a separate notification for repeated 5xx
   responses at low traffic if needed.
3. **Latency:** alert when p95 request latency exceeds two seconds for ten
   minutes. Keep the threshold below the configured 30-second request timeout.
4. **Container startup failures:** create a narrowly filtered logs-based metric
   for Cloud Run revision startup failures and alert on any occurrence. Exclude
   routine scale-to-zero shutdown messages.

Alert documentation must state the symptom, dashboard/log link, first checks,
rollback decision point, and notification owner. Send test notifications and
record that each policy is enabled and reaches the intended channel.

#### 8.4 Add an explicit rollback workflow

Add a manual, serialized production rollback job or script that requires an
operator to provide a release manifest, revision name, or digest-qualified
image reference. Before changing traffic it must:

1. confirm the project, region, service, and target revision or image;
2. prove the target exists and matches a previously successful release
   manifest;
3. show the currently serving revision and proposed target; and
4. require an explicit manual action in the protected production environment.

Prefer routing 100% of traffic to an existing previous known-good revision. If
that revision is no longer available, redeploy its recorded digest-qualified
image with the same checked-in Cloud Run configuration. Never rebuild the old
commit, use a floating tag, or automatically select a target solely because it
is the immediately preceding revision.

After rollback, run the same readiness, portfolio JSON, and CORS verification
used after deployment. Emit a rollback manifest containing the initiating
pipeline, reason, source revision, restored revision and digest, start/end
timestamps, verification results, and final traffic allocation. A failed
verification must stop the workflow and provide recovery instructions; it must
not silently switch forward again.

#### 8.5 Perform a controlled rollback drill

After two known-good revisions exist, schedule a low-traffic production drill:

1. record the current and previous known-good release manifests;
2. route traffic to the previous known-good revision using the rollback
   workflow;
3. run the production verification suite and confirm monitoring remains
   functional;
4. measure recovery time from rollback initiation to successful verification;
5. restore the intended current revision using the same immutable process; and
6. record both traffic changes, verification evidence, observed alerts, and any
   runbook corrections.

Do not manufacture an application failure in production for this drill. A
controlled revision traffic change is sufficient to validate the mechanism.

#### Completion criteria

Step 8 is complete when:

- a successful deployment produces a retained release manifest with an image
  digest and verification evidence;
- log and artifact retention cover the documented rollback window;
- availability, 5xx, latency, and startup-failure alerts are enabled and their
  notification path has been tested;
- the protected rollback workflow restores only a verified revision or digest
  and reruns production checks; and
- a rollback drill has restored a previous known-good revision and then the
  intended current revision, with recovery time and results documented.
