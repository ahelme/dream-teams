---
name: create-release
description: Create a git tag + GitHub release for ComfyuMe. Use when shipping a new release (stable, hotfix, alpha, beta, or RC). Enforces the ComfyuMe tag convention — see "Naming convention" below. NEVER use the old v0.17.X.Y format or drop the `v` prefix.
user-invocable: true
version: 1.1.0
---

# /create-release — ComfyuMe Release Tagging

## Quick history

Our old release scheme drifted independently of ComfyUI — we shipped tags up to `v0.17.4.5` while ComfyUI was still on v0.11.0. Those old numbers look like ComfyUI versions but aren't. On 2026-04-20/21 all 10 legacy tags were renamed to carry the ComfyUI pin they were actually built against: `v0.11.0.<old-name>` (e.g. `v0.17.4.5` → `v0.11.0.17.4.5`, `v0.16.0a` → `v0.11.0.16.0a`). They sort naturally before new `v0.17.x+` releases. Treat everything under `v0.11.0.*` as frozen history — do not cut new releases with that prefix.

**Never create a tag in the old `v0.17.X.Y` format. Never drop the `v` prefix.** The conventions below are the only ones to use.

## Naming convention

All formats start with `v` and use the **explicit** form (no elision of trailing zeros). Every component is always present.

### Stable Release (no commit)

```
v{COMFYUI_VERSION}.{comfyume-major}.{comfyume-minor}.0
```
(patch/hotfix component resets to `0` on a stable release.)

### Patch / Hotfix (with commit)

```
v{COMFYUI_VERSION}.{comfyume-major}.{comfyume-minor}.{patch}.{commit}
```

### Pre-release — alpha, beta, RC (with commit)

```
v{COMFYUI_VERSION}.{comfyume-major-target}.{comfyume-minor-target}.0.{commit}-{stage}.{stage-number}
```

### Component definitions

- **`COMFYUI_VERSION`** — exact ComfyUI version we're pinned to (3 parts, e.g. `0.17.4`).
- **`comfyume-major`** — a new stable release with major changes (breaking changes, major new features, architecture shifts). Bumps per major on the same ComfyUI pin. Resets on ComfyUI upgrade. Stable releases do NOT include a commit. e.g. `v0.17.4.0.0.0`.
- **`comfyume-minor`** — a new stable release with minor features (and non-urgent bug fixes) on top of a major. Stable releases do NOT include a commit. e.g. `v0.17.4.1.0`.
- **`patch/hotfix`** — current stable is patched (critical bug or security fix). Bumps on subsequent patches. Resets on new minor. Patch/hotfix releases DO include the commit. e.g. `v0.17.4.1.1.1.uw8x4m`.
- **`commit`** — short SHA (7 chars) of tagged commit. Lets anyone map tag → exact code.
- **`stage`** — `alpha` / `beta` / `rc`.
- **`stage-number`** — iteration within the stage (`.1`, `.2`, ...). Increment for each new alpha/beta/rc targeting the same upcoming version.

### Stage definitions

- **Alpha** — pre-release in early development, targeting the next major or minor. e.g. `v0.17.4.2.0.pxu7a-alpha.1` (first alpha targeting `v0.17.4.2.0`).
- **Beta** — pre-release with features we believe are locked for the target. e.g. `v0.17.4.2.0.co99xt-beta.1` (first beta targeting `v0.17.4.2.0`). If new features or new bug fixes are added, cut a new beta (`-beta.2`, `-beta.3`, ...).
- **RC (release candidate)** — features fully locked, bugs believed fixed, needs testing. e.g. `v0.17.4.2.0.hf83lk-rc.1`. Bumps to `-rc.2` if more bugs found.

## Examples

**Example 1 — starting from a stable minor release `v0.17.2.4.1.0`:**
- Security patch: `v0.17.2.4.1.1.9w3z8o` (patch=1, commit)
- Alpha targeting next minor: `v0.17.2.4.2.0.33iwn3-alpha.1`

**Example 2 — iterating through pre-releases:**
- Previous beta: `v0.17.2.4.2.0.sj9k20-beta.3`
- Next beta adds two minor features + three bug fixes: `v0.17.2.4.2.0.iw10xw-beta.4`
- Stable-looking → cut RC: `v0.17.2.4.2.0.alw93n-rc.1`
- Testing clean → stable minor release: `v0.17.2.4.2.0` (no commit)
- Deploy `v0.17.2.4.2.0` to production.

## Docker image tagging

We tag Docker builds with the same release tag (e.g. `v0.17.2.4.2.0.sj9k20-beta.3`).

**Retag rules:**
- **Non-stable releases (alpha/beta/rc/hotfix):** do NOT retag images that were not rebuilt. Each image keeps the tag from the last release where its code changed. This lets us see at a glance when each service last had changes applied.
- **Stable releases:** DO retag ALL images with the new stable version (no commit). Resets everyone to the same tag.

### Example A — testing (mid-cycle)

`comfyume-frontend` was last rebuilt for `v0.17.2.4.2.0.sj9k20-beta.3`, so it carries that tag.
`queue-manager`, `nginx`, `admin` had more recent changes → rebuilt for `v0.17.2.4.2.0.owxkh1-beta.4` and carry that tag.

### Example B — production (post-stable + hotfix)

`admin` and `nginx` are tagged `v0.17.2.4.1.0` (last stable minor, no commit).
`frontend` and `queue-manager` received a hotfix → tagged `v0.17.2.4.1.1.9w3z8o`.

## Steps

### 1. Decide what kind of release this is

Is it stable, a hotfix, or a pre-release (alpha/beta/rc)? Is it targeting the same minor, a new minor, or a new major? Is ComfyUI the same or upgraded?

### 2. Preflight

- Confirm correct branch (main for stable/hotfix; team/ATT branch for pre-release).
- Working tree clean: `git status`
- Get the ComfyUI pin (from `.env` or source):
  ```bash
  cui=$(grep -oP '(?<=COMFYUI_VERSION=)[^ "]+' .env | tr -d '"v')
  echo "ComfyUI: $cui"
  ```
- Get commit SHA:
  ```bash
  sha=$(git rev-parse --short=7 HEAD)
  ```
- Find the last tag on this ComfyUI pin to compute next major/minor/patch:
  ```bash
  git tag --sort=-v:refname | grep -E "^v$cui\\." | head -5
  ```

### 3. Compose tag name per convention

Pick whichever format matches the release type. Examples above. **Double-check the `v` prefix is present.**

### 4. Confirm with user

Show: tag name, target branch, target commit, and a release body draft. **Get explicit approval before creating.**

### 5. Create annotated tag + push

```bash
git tag -a "$new_tag" -m "Release $new_tag"
git push origin "$new_tag"
```

### 6. Create GitHub release

**Title format** (all release types, from 2026-04-21):

```
{YYYY-MM-DD} - {full-tag}
```

Date leads so the Releases page is chronologically scannable at a glance. Any short description lives in the release body header, not the title.

**Examples:**
- `2026-04-19 - v0.17.2.1.0.0.9fffcf5-alpha.1`
- `2026-04-20 - v0.17.2.1.0.0.055aaa5-beta.1`
- `2026-04-21 - v0.17.2.1.0.0.5b1e8af-rc.1`
- `2026-04-22 - v0.17.2.1.0.0` ← stable (tag has no commit)
- `2026-04-25 - v0.17.2.1.0.1.9w3z8o` ← hotfix

_Historical releases (`v0.11.0.*` legacy + the three `v0.17.2.1.0.0-*` pre-releases) predate this format. Leave them as-is — don't retroactively rewrite._

**Body must start with this dated header block** (required — makes the body self-describing):

```markdown
**Release date:** {YYYY-MM-DD}
**Commit:** [`{short-sha}`](https://github.com/ahelme/comfyume-v1/commit/{short-sha})
**ComfyUI pin:** {COMFYUI_VERSION}
**Target stable:** {target stable tag, e.g. v0.17.2.1.0.0}   ← pre-releases only
**Originally tagged as:** `{old tag name}` (renamed YYYY-MM-DD)   ← rename/backfill only
```

Then the usual release notes (What changed, bullets, related issues, team signature).

**Command:**

```bash
pub_date=$(date -u +%F)
is_pre=""
[[ "$new_tag" == *-alpha.* || "$new_tag" == *-beta.* || "$new_tag" == *-rc.* ]] && is_pre="--prerelease"
# For stable releases, add --latest

gh release create "$new_tag" \
  --repo ahelme/comfyume-v1 \
  --title "$pub_date - $new_tag" \
  $is_pre \
  --notes "$(cat <<EOF
**Release date:** $pub_date
**Commit:** [\`$sha\`](https://github.com/ahelme/comfyume-v1/commit/$sha)
**ComfyUI pin:** $cui
**Target stable:** <e.g. v0.17.2.1.0.0>

---

## What changed
- <bullet>

## Related issues
- #...

🪶 Scripp — Sys Team
EOF
)"
```

For stable releases, also pass `--latest` (moves the "Latest" badge). For pre-releases, `--prerelease` is auto-set above.

### 7. Update [`infrastructure-registry.md`](https://github.com/ahelme/ops/blob/main/infrastructure-registry.md)

Add a row to the worker image table if this release corresponds to a Docker image push. The Docker image tag IS the release tag (e.g. `vccr.io/<project>/comfyume-worker:v0.17.2.4.2.0.sj9k20-beta.3`).

### 8. Announce

- Slack via `/us`
- If prod release → trigger `/deploy-prod` per wiki
- If testing release → `/deploy-test`

## Gotchas

- **`v` prefix is required.** Never drop it.
- **Stable releases do NOT include a commit.** The commit belongs in the release body/linked Docker tag history.
- **Pre-releases and hotfixes MUST include a commit.** No exceptions.
- **Minor does not reset on ComfyUI upgrade** for hotfixes of a prior version; but a new stable _minor_ on a new ComfyUI pin starts at `.0.0` (major=0, minor=0). _(If this changes later, update here.)_
- **Use `-` before stage, `.` before stage-number.** `-beta.1` not `.beta.1`.
- **Annotated tags only** (`git tag -a`). Lightweight tags lose the message and break GH releases metadata.
- **Legacy tags (`v0.11.0.*`) are read-only.** Don't touch them. They're historical.

## See also

- `/deploy-prod`, `/deploy-test` — deploy after a release; also describes image tagging behaviour
- `infrastructure-registry.md` → Image Tagging Convention section
- 2026-04-20/21 legacy rename: 10 tags renamed to `v0.11.0.*` (ops repo commits `cd63525` + `93b1b45`)
