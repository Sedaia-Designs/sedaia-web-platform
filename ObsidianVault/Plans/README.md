# Plans

Active feature and refactor plans live in one subfolder per initiative. Each
plan starts with an `Orchestration.md` note that links its phases in execution
order. Every phase has its own note, and final verification is always the last
phase.

Historical plans that predate this structure remain in `../Pre-Obsidian/` for
reference and are not active execution plans.

## Active plans

- [[MonorepoBuildout/Orchestration|Monorepo buildout]]
- [[ProductionReadiness/Orchestration|Production readiness]]
- [[GitHubActionsMigration/Orchestration|GitHub Actions migration]]
- [[GCloudCloudRunSetup/Orchestration|Google Cloud Run setup]]
- [[GCloudCloudRunRemediation/Orchestration|Google Cloud Run remediation]]

## Pre-Obsidian audit

| Historical plan | Classification | Active successor |
| --- | --- | --- |
| `PLAN.md` | In progress | [[MonorepoBuildout/Orchestration]] |
| `DEPLOYMENT_READINESS_PLAN.md` | In progress | [[ProductionReadiness/Orchestration]] and [[GitHubActionsMigration/Orchestration]] |
| `GITHUB_UI_VALIDATION_PLAN.md` | In progress | [[GitHubActionsMigration/Orchestration]] |
| `CLOUD_RUN_CONFIGURATION_PLAN.md` | Repository work complete; remaining operational gates superseded | [[GitHubActionsMigration/Orchestration]] and [[ProductionReadiness/Orchestration]] |

The classifications are based on checked-in repository evidence. Work that
requires hosted-service state is considered pending unless the historical note
contains explicit evidence of completion.
