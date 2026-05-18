---
name: publish-nico-prod
description: Prepare and publish sanitized NICO production snapshots from the Bitbucket dev source to an OCI DevOps SCM production branch and PR. Use when asked to push NICO to prod, publish a sanitized OCI snapshot, create a prod handoff branch, create an OCI DevOps PR, or update OCI DevOps main for ies-netops-nico.
---

# Publish NICO Prod

## Contract

Use this skill only for NICO production snapshot publishing.

Core model:
- Bitbucket `main` is the dev source of truth. Never strip, rewrite, force-push, or sanitize Bitbucket `main`.
- OCI DevOps SCM `main` is prod. It must contain only sanitized runtime source.
- Default publish target is an OCI DevOps branch plus PR into OCI `main`, not a direct `main` update.
- Prod repo URL:
  `https://oci.private.devops.scmservice.us-phoenix-1.oci.oracleiaas.com/namespaces/axuxirvibvvo/projects/iesnetworking/repositories/ies-netops-nico`
- After the first prod snapshot, preserve OCI prod linear history: build the new sanitized commit on top of current OCI `main`, not as an unrelated orphan/root commit.
- Do not claim success until local and remote refs are verified after push.

Use PR mode by default: push a sanitized OCI branch and create the OCI DevOps PR if tooling is available. Do not update OCI `main` directly unless the user explicitly says to direct publish, force-update main, or skip PR.

## Safety Rules

Never publish these to OCI:
- dev history
- planning docs
- tests or fixtures
- Jira artifacts
- `nico-memory/data`
- credentials, KeePass databases, secrets, tokens, key material
- `__pycache__`, `.pyc`, build/cache output
- release-evidence files
- local Codex artifacts
- unintended dev-only docs

Push to OCI `main` only in explicit direct-publish mode, only with `--force-with-lease`, and only after verifying the new commit is based on current OCI `main`.

## Required Workflow

1. Verify working tree and branch:
   - Confirm repo is `nico-main`.
   - Confirm current branch and cleanliness.
   - If dirty, stop unless the user clearly asked to include or handle those changes.

2. Verify refs:
   - Fetch Bitbucket dev remote.
   - Fetch OCI prod remote.
   - Record Bitbucket `main` commit.
   - Record OCI `main` commit if it exists.
   - Confirm Bitbucket `main` is unchanged before and after publish.

3. Generate release notes and update the operator runbook on Bitbucket dev `main`:
   - Determine the previous release version: `git describe --tags --abbrev=0` (use `nico-production/main` as the base if no prior tag exists).
   - Run the release-notes generator in the nico-main checkout:

     ```bash
     uv run python scripts/release_notes.py \
         --from <previous-tag-or-base> \
         --to <bitbucket-remote>/main \
         --version <new-version> \
         --write docs/runbooks/nico-install-setup-onboarding.md
     ```

   - Stage and commit the runbook update on Bitbucket dev `main` with message `docs: release notes for <new-version>`.
   - Push the commit to Bitbucket dev `main` so the sanitized snapshot built in the next step includes the up-to-date runbook.
   - If `scripts/release_notes.py` does not exist in the nico-main checkout, stop and report; the skill depends on the generator.

4. Build sanitized snapshot from Bitbucket dev `main`:
   - Use a temporary worktree or temporary directory.
   - Copy only allowed runtime source/config/docs needed for NICO prod operation.
   - Apply the exclude rules above.
   - Preserve executable bits where relevant.
   - Do not copy `.git`, local state, memory data, credentials, or generated artifacts.

5. Create prod commit:
   - If OCI `main` exists, base the snapshot commit on current OCI `main`.
   - If this is first publish and OCI `main` does not exist, create the first sanitized root commit.
   - Commit message should be conventional and concise, e.g. `chore: publish nico prod snapshot YYYY-MM-DD`.

6. Verify sanitized tree:
   - Check `git status --short`.
   - Search for forbidden paths and file types.
   - Search for likely secrets.
   - Confirm tests/planning/dev artifacts are absent.
   - Confirm expected runtime entrypoints and config are present.

7. Publish handoff branch to Bitbucket:
   - Push the sanitized snapshot commit to Bitbucket as `prod/oci-snapshot-YYYY-MM-DD`.
   - Verify Bitbucket remote branch points to the snapshot commit.

8. Publish to OCI:
   - Default PR mode: push an OCI branch such as `prod/oci-snapshot-YYYY-MM-DD` and create the PR if available.
   - Direct publish mode, only when explicitly requested: update OCI `main` to the snapshot commit with `--force-with-lease`.
   - If no OCI PR tool/API is available, push the branch and report the exact branch/ref plus that PR creation was not completed.

9. Tag the published version:
   - Create an annotated tag at the sanitized commit:

     ```bash
     git tag -a <new-version> <snapshot-commit> -m "NICO release <new-version>"
     ```

   - Push the tag to both remotes:

     ```bash
     git push <bitbucket-remote> <new-version>
     git push <oci-remote> <new-version>
     ```

   - Verify the tag is reachable on both remotes via `git ls-remote --tags`.

10. Clean stale OCI tags:
   - List OCI tags.
   - Delete stale OCI tags that point at old history when required by the publish plan.
   - Verify remaining OCI tags.

11. Final verification:
   - Verify OCI PR branch is at the snapshot commit for default PR mode.
   - Verify OCI `refs/heads/main` is at the snapshot commit only in explicit direct-publish mode.
   - Verify Bitbucket handoff branch is at the snapshot commit.
   - Verify Bitbucket dev `main` is still at the original commit.
   - Verify local working tree is clean except intentionally ignored local artifacts.

## Practical Commands

Use actual remote names from the repo; do not assume them. If an OCI remote is missing, add a temporary or named remote only after checking existing remotes.

Useful checks:

```bash
git remote -v
git fetch <bitbucket-remote> main
git fetch <oci-remote> main --tags
git rev-parse <bitbucket-remote>/main
git rev-parse <oci-remote>/main
git merge-base --is-ancestor <oci-main> <snapshot-commit>
git ls-remote <bitbucket-remote> refs/heads/prod/oci-snapshot-YYYY-MM-DD
git ls-remote <oci-remote> refs/heads/main
git ls-remote <oci-remote> refs/heads/prod/oci-snapshot-YYYY-MM-DD
```

For OCI PR branch publish:

```bash
git push <oci-remote> <snapshot-commit>:refs/heads/prod/oci-snapshot-YYYY-MM-DD
```

For explicit OCI direct publish only:

```bash
git push <oci-remote> <snapshot-commit>:refs/heads/main --force-with-lease=refs/heads/main:<oci-main>
```

For Bitbucket handoff:

```bash
git push <bitbucket-remote> <snapshot-commit>:refs/heads/prod/oci-snapshot-YYYY-MM-DD
```

## Sanitization Checks

Run path checks against the sanitized snapshot tree, not the dev repo.

Fail if any of these exist:

```bash
find . -path './.git' -prune -o \( \
  -path './.planning/*' -o \
  -path './docs/tasks/*' -o \
  -path './docs/superpowers/*' -o \
  -path './qa/*' -o \
  -path './tests/*' -o \
  -path './nico-memory/data/*' -o \
  -path './credentials/*' -o \
  -path './.codex-artifacts/*' -o \
  -path './__pycache__/*' -o \
  -name '*.pyc' -o \
  -name '*.kdbx' \
\) -print
```

Search for likely secrets:

```bash
rg -n --hidden --glob '!.git/**' --glob '!uv.lock' \
  '(BEGIN (RSA |OPENSSH |EC |PRIVATE )?KEY|password\s*=|api[_-]?key|secret[_-]?key|token\s*=|ocid1\.user|fingerprint\s*=|passphrase)' .
```

Review matches manually. Some source code identifiers are expected; real values are not.

## Final Response

Keep the final response concise. Include:
- Bitbucket dev `main` before/after commit.
- Release notes version + path to updated runbook.
- OCI `main` before/after commit, or OCI PR branch/PR identifier in PR mode.
- Bitbucket handoff branch and commit.
- Tag name + remotes it was pushed to.
- Sanitization checks run and result.
- Whether stale tags were found/deleted.
- Any cleanup or unresolved blockers.
