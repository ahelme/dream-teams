---
name: check-versions
description: >
  Verify pinned package versions against live registries. Prevents training data
  confabulation — Claude has fabricated release dates to justify outdated pins.
  Use when editing Dockerfiles, requirements.txt, package.json, or any file that
  pins versions. Also user-invocable: /check-versions [file or topic].
user-invocable: true
arguments:
  - name: target
    description: "Optional: file path or package name to check. Default: scan conversation context."
    required: false
version: 1.1.0
---

# /check-versions — Version Verification Gate

**WHY THIS EXISTS:** Claude's training data has a cutoff. It will confidently state
release dates and "latest" versions that are WRONG. A previous Claude wrote
"ComfyUI v0.11.0 released Jan 25, 2026" — the real release was ~2024. This pinned
us 17 versions behind and blocked LTX 2.3 workflows for months.

**RULE: Never trust training knowledge for version currency. Always verify live.**

---

## When to trigger

1. **User says** `/check-versions`
2. **You are about to edit** any of these file types:
   - `Dockerfile` (apt packages, pip installs, git clone --branch)
   - `requirements.txt`, `pyproject.toml`, `setup.py`, `setup.cfg`
   - `package.json`, `package-lock.json`
   - `go.mod`, `Gemfile`, `Cargo.toml`
   - `.env` or config files with version pins
   - Any file where you are writing a specific version number

## Steps

### 1. Identify all version pins

Extract every version being pinned, installed, or recommended. Include:
- Explicit pins: `==2.54.0`, `v0.11.0`, `@latest`
- Git refs: `--branch v0.11.0`, `--depth 1`
- Docker base images: `FROM python:3.11-slim`
- Comments claiming versions: "latest as of..."

### 2. Verify EACH version against live source

**GitHub repos:**
```bash
gh api repos/<org>/<repo>/releases --jq '.[0] | {tag: .tag_name, date: .published_at}'
```

**PyPI packages:**
```bash
pip index versions <package> 2>/dev/null | head -1
# or: curl -s https://pypi.org/pypi/<package>/json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['info']['version'], d['urls'][0]['upload_time'][:10] if d['urls'] else 'unknown')"
```

**npm packages:**
```bash
npm view <package> version
```

**apt packages:**
```bash
apt-cache policy <package> 2>/dev/null | grep Candidate
```

**Docker base images:**
```bash
# Check Docker Hub for latest tag
curl -s "https://hub.docker.com/v2/repositories/library/<image>/tags/?page_size=10&name=<tag-pattern>" | python3 -c "import sys,json; [print(t['name']) for t in json.load(sys.stdin)['results'][:5]]"
```

### 3. Present comparison table

```
| Package    | Pinned  | Latest Stable | Released   | Gap              |
|------------|---------|---------------|------------|------------------|
| ComfyUI    | v0.11.0 | v0.17.2       | 2026-03-10 | 17 releases behind |
| sentry-sdk | 2.54.0  | 2.54.0        | 2026-03-08 | current          |
```

### 4. Flag and advise

For each outdated pin:
- State the gap clearly
- Note if the pin has a comment explaining why (legitimate reason vs confabulation)
- Ask: "Is this intentional or should we upgrade?"

**DO NOT:**
- Auto-upgrade anything
- Dismiss old pins as wrong without checking if there's a compatibility reason
- State release dates from memory — only from the live API response

### 5. If user invoked with no target

Scan the current conversation for any versions discussed or recommended.
If none found, ask: "Which file or package would you like me to check?"
