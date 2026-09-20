# Phase 02 - Actions Policy

**Status: Pending hosted verification.** Organization policy controls part of
the settings; record the effective settings and retention rather than assuming
the repository can override them.

Configure allowed Actions, workflow token permissions, fork pull-request
behavior, and artifact/log retention. Keep default permissions least-privileged
and grant elevated permissions only in the jobs that require them.

Exit criterion: Actions can run the checked-in workflows without exposing
production credentials to untrusted changes.
