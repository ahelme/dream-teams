---
name: create-release
description: Create a git tag + GitHub release. Use when shipping a new release (stable, hotfix, alpha, beta, or RC). Enforces a tag convention that embeds the upstream dependency pin — never drop the `v` prefix.
user-invocable: true
version: 1.0.0
---

# /create-release — Release Tagging

This convention is for an app built on top of a pinned upstream project
([ UPSTREAM PROJECT — the framework/app your build wraps; its pinned version
is `UPSTREAM_VERSION` in `.env` ]). The release tag embeds that pin so any
tag maps to the exact upstream + app code it was built against.
[ ADAPT: if your project has no upstream pin, drop the `{UPSTREAM_VERSION}`
component throughout. ]

**Never drop the `v` prefix.** The conventions below are the only ones to use.

## Naming convention

All formats start with `v` and use the **explicit** form (no elision of trailing zeros). Every component is always present.

### Stable Release (no commit)

```
v{UPSTREAM_VERSION}.{app-major}.{app-minor}.0
```
(patch/hotfix component resets to `0` on a stable release.)

### Patch / Hotfix (with commit)

```
v{UPSTREAM_VERSION}.{app-major}.{app-minor}.{patch}.{commit}
```

### Pre-release — alpha, beta, RC (with commit)

```
v{UPSTREAM_VERSION}.{app-major-target}.{app-minor-target}.0.{commit}-{stage}.{stage-number}
```

### Component definitions

- **`UPSTREAM_VERSION`** — exact upstream version pinned (3 parts, e.g. `0.17.4`).
- **`app-major`** — a new stable release with major changes (breaking changes, major new features, architecture shifts). Bumps per major on the same upstream pin. Resets on upstream upgrade. Stable releases do NOT include a commit.
- **`app-minor`** — a new stable release with minor features (and non-urgent bug fixes) on top of a major. Stable releases do NOT include a commit. e.g. `v0.17.4.1.0`.
- **`patch/hotfix`** — current stable is patched (critical bug or security fix). Bumps on subsequent patches. Resets on new minor. Patch/hotfix releases DO include the commit. e.g. `v0.17.4.1.1.1.uw8x4m`.
- **`commit`** — short SHA (7 chars) of tagged commit. Lets anyone map tag → exact code.
- **`stage`** — `alpha` / `beta` / `rc`.
- **`stage-number`** — iteration within the stage (`.1`, `.2`, ...). Increment for each new alpha/beta/rc targeting the same upcoming version.

### Stage definitions

- **Alpha** — pre-release in early development, targeting the next major or minor. e.g. `v0.17.4.2.0.pxu7a-alpha.1` (first alpha targeting `v0.17.4.2.0`).
- **Beta** — pre-release with features believed locked for the target. If new features or bug fixes are added, cut a new beta (`-beta.2`, `-beta.3`, ...).
- **RC (release candidate)** — features fully locked, bugs believed fixed, needs testing. Bumps to `-rc.2` if more bugs found.

## Examples

**Example 1 — starting from a stable minor release `v0.17.2.4.1.0`:**
- Security patch: `v0.17.2.4.1.1.9w3z8o` (patch=1, commit)
- Alpha targeting next minor: `v0.17.2.4.2.0.33iwn3-alpha.1`

**Example 2 — iterating through pre-releases:**
- Previous beta: `v0.17.2.4.2.0.sj9k20-beta.3`
- Next beta adds features + fixes: `v0.17.2.4.2.0.iw10xw-beta.4`
- Stable-looking → cut RC: `v0.17.2.4.2.0.alw93n-rc.1`
- Testing clean → stable minor release: `v0.17.2.4.2.0` (no commit)
- Deploy `v0.17.2.4.2.0` to production.

## Docker image tagging

Tag Docker builds with the same release tag.

**Retag rules:**
- **Non-stable releases (alpha/beta/rc/hotfix):** do NOT retag images that were not rebuilt. Each image keeps the tag from the last release where its code changed — shows at a glance when each service last had changes applied.
- **Stable releases:** DO retag ALL images with the new stable version (no commit). Resets everyone to the same tag.

## Steps

### 1. Decide what kind of release this is

Stable, hotfix, or pre-release (alpha/beta/rc)? Same minor, new minor, or new major? Upstream pin unchanged or upgraded?

### 2. Preflight

- Confirm correct branch ([ ADAPT: main for stable/hotfix; team branch for pre-release ]).
- Working tree clean: `git status`
- Get the upstream pin (from `.env` or source):
  ```bash
  up=$(grep -oP '(?<=UPSTREAM_VERSION=)[^ "]+' .env | tr -d '"v')
  ```
- Get commit SHA: `sha=$(git rev-parse --short=7 HEAD)`
- Find the last tag on this upstream pin to compute next major/minor/patch:
  ```bash
  git tag --sort=-v:refname | grep -E "^v$up\\." | head -5
  ```

### 3. Compose tag name per convention

Pick whichever format matches the release type. **Double-check the `v` prefix is present.**

### 4. Confirm with user

Show: tag name, target branch, target commit, and a release body draft. **Get explicit approval before creating.**

### 5. Create annotated tag + push

```bash
git tag -a "$new_tag" -m "Release $new_tag"
git push origin "$new_tag"
```

### 6. Create GitHub release

**Title format** (all release types):

```
{YYYY-MM-DD} - {full-tag}
```

Date leads so the Releases page is chronologically scannable. Any short description lives in the release body header, not the title.

**Body must start with this dated header block** (required — makes the body self-describing):

```markdown
**Release date:** {YYYY-MM-DD}
**Commit:** [`{short-sha}`](https://github.com/[ ORG/REPO ]/commit/{short-sha})
**Upstream pin:** {UPSTREAM_VERSION}
**Target stable:** {target stable tag}   ← pre-releases only
```

Then the usual release notes (What changed, bullets, related issues, team signature).

**Command:**

```bash
pub_date=$(date -u +%F)
is_pre=""
[[ "$new_tag" == *-alpha.* || "$new_tag" == *-beta.* || "$new_tag" == *-rc.* ]] && is_pre="--prerelease"
# For stable releases, add --latest

gh release create "$new_tag" \
  --repo [ ORG/REPO ] \
  --title "$pub_date - $new_tag" \
  $is_pre \
  --notes "$(cat <<EOF
**Release date:** $pub_date
**Commit:** [\`$sha\`](https://github.com/[ ORG/REPO ]/commit/$sha)
**Upstream pin:** $up
**Target stable:** <target stable tag>

---

## What changed
- <bullet>

## Related issues
- #...

[ TEAM SIGNATURE ]
EOF
)"
```

For stable releases, also pass `--latest` (moves the "Latest" badge).

### 7. Update infrastructure inventory

[ ADAPT: if the team keeps an ops/infrastructure registry, add a row when a
release corresponds to a Docker image push — the image tag IS the release tag. ]

### 8. Announce

- [ ADAPT: team announcement channel, e.g. Slack ]
- If prod release → trigger `/deploy-prod`
- If testing release → `/deploy-test`

## Gotchas

- **`v` prefix is required.** Never drop it.
- **Stable releases do NOT include a commit.** The commit belongs in the release body/linked Docker tag history.
- **Pre-releases and hotfixes MUST include a commit.** No exceptions.
- **Use `-` before stage, `.` before stage-number.** `-beta.1` not `.beta.1`.
- **Annotated tags only** (`git tag -a`). Lightweight tags lose the message and break GH releases metadata.

## See also

- `/deploy-prod`, `/deploy-test` — deploy after a release; image tagging behaviour
