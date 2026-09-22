# Plans

Active feature and refactor plans live in one subfolder per initiative. Each plan starts with an `Orchestration.md` note that links its phases in execution order. Every phase has its own note, and final verification is always the last phase.

Historical plans are retained under `../Archives/Plans/` for reference and are not active execution plans.

## Active plans

- [[SedaiaPlatformBuildout/Orchestration|Sedaia Platform buildout]] — authoritative five-surface production buildout; execution pending review and approvals
- [[GCloudCloudRunRemediation/Orchestration|Google Cloud Run remediation]]

## Superseded and historical plans

| Plan | Classification | Authority |
| --- | --- | --- |
| [[MonorepoBuildout/Orchestration|Monorepo buildout]] | Superseded; all phases and meaningful checklist items are mapped in the successor audit | [[SedaiaPlatformBuildout/Orchestration]] |
| [[../Archives/Plans/ProductionReadiness/Orchestration|Production readiness]] | Superseded; App Engine deployment evidence is historical | [[GCloudCloudRunRemediation/Orchestration]] |
| [[../Archives/Plans/GitHubActionsMigration/Orchestration|GitHub Actions migration]] | Superseded; GitHub configuration evidence is historical and GitHub deployment is not active | [[GCloudCloudRunRemediation/Orchestration]] |
| [[../Archives/Plans/GCloudCloudRunSetup/Orchestration|Google Cloud Run setup]] | Historical execution record; incomplete gates moved to remediation | [[GCloudCloudRunRemediation/Orchestration]] |

## Archived pre-Obsidian audit

| Historical plan | Classification | Active successor |
| --- | --- | --- |
| `PLAN.md` | Historical source transferred through the superseded Monorepo Buildout plan | [[SedaiaPlatformBuildout/Orchestration]] |
| `DEPLOYMENT_READINESS_PLAN.md` | In progress | [[../Archives/Plans/ProductionReadiness/Orchestration]] and [[../Archives/Plans/GitHubActionsMigration/Orchestration]] |
| `GITHUB_UI_VALIDATION_PLAN.md` | In progress | [[../Archives/Plans/GitHubActionsMigration/Orchestration]] |
| `CLOUD_RUN_CONFIGURATION_PLAN.md` | Repository work complete; remaining operational gates superseded | [[../Archives/Plans/GitHubActionsMigration/Orchestration]] and [[../Archives/Plans/ProductionReadiness/Orchestration]] |

The classifications are based on checked-in repository evidence. Work that requires hosted-service state is considered pending unless the historical note contains explicit evidence of completion.
