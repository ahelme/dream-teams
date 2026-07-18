---
name: deploy-test
description: >
  Deploy the testing branch to the testing environment ([ TESTING URL ]).
  Claude executes the deploy steps, confirming before each destructive
  step. Use when: the testing branch has been updated and it's time to
  deploy/redeploy the testing stack.
user-invocable: true
version: 1.0.0
---

# /deploy-test — Deploy to Testing

You (Claude) execute the deploy steps, confirming before each destructive step.

## Environment

[ TESTING ENVIRONMENT DETAILS REQUIRED HERE — testing URL, host (local or
`ssh [ SSH COMMAND ]`), app dir, TLS/proxy arrangement, port map (note any
host ports already taken on a shared box), and any remote pieces plus the
env vars that bind them to this stack. ]

## Steps

### 1. Preflight
- `git branch --show-current` — expect the testing branch ([ TESTING BRANCH ]); confirm with user if other.
- `git pull` (fast-forward only; stop on conflicts).
- `.env` exists with all required vars non-empty ([ ADAPT: list the
  must-have vars; where secrets are sourced from ]).
- Disk: `df -h` — enough free space on the Docker data-root for the build.
- TLS/proxy prerequisites in place ([ ADAPT: host nginx site + cert paths ]).
- [ ADAPT: firewall/port checks for any externally-reachable services ].

### 2. Generate derived compose files (if any)
```bash
[ ADAPT: e.g. ./scripts/generate-user-compose.sh — reads scale + version from .env ]
```
Confirm scale/sizing with the user if the box is shared or memory-tight.

### 3. Build images (only what changed — retag rules)

Images are tagged with the full release tag (see `/create-release`).
Non-stable releases (alpha/beta/rc/hotfix): only images **rebuilt this
deploy** get the new tag — unchanged services keep the tag from the release
where their code last changed (audit at a glance). Stable releases: retag
ALL images with the new stable version.

```bash
[ ADAPT: build commands, e.g.
docker build -t [ IMAGE PREFIX ]-frontend:<version>-$(git rev-parse --short HEAD) -f <Dockerfile> .
docker compose build <services> ]
```

### 4. Deploy
```bash
docker compose up -d
```
- Check for stale `docker-compose.override.yml` files before a full-stack deploy — old workarounds can re-expose services.
- `.env` changed since last up? Use `docker compose up -d --force-recreate` (**`restart` does NOT re-read .env**).

### 5. Verify (in order — each step gates the next)
1. `docker compose ps` — all healthy (some services may start in batches).
2. `curl -s [ TESTING URL ]/[ HEALTH ENDPOINT ]` — through the full proxy chain.
3. [ ADAPT: auth-armed check — an internal API should return 401 without credentials, not 200/503 ].
4. [ APP-SPECIFIC VERIFICATION — e.g. open the app at [ TESTING URL ] and confirm it authenticates (credentials per `.env`) ].
5. [ ADAPT: verify any remote workers registered/heartbeating ].
6. End-to-end: exercise one real user flow; watch it complete.

## Gotchas

[ ADAPT: project-specific deploy gotchas — e.g. pre-create bind-mount dirs
with the right owner BEFORE `compose up` (Docker auto-creates missing dirs
as root, breaking non-root writers); architecture mismatches when some
images must be built on a different arch; shared-box etiquette (never prune
others' images; if space is short, STOP and ask). ]
