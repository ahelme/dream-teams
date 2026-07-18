---
name: backup-check
description: >
  Verify what's actually backed up vs what's live on mello (post re-home
  2026-07-15) — local tarballs, R2 offsite copies, and the static model
  vault. Read-only, trusts the real bucket over logs. Use before anything
  destructive, after data changes, or when you just want honest
  "am I backed up?" confirmation.
user-invocable: true
arguments:
  - name: domain
    description: "Optional: --configs, --user-data, --vault (default: all)"
    required: false
version: 2.0.0
---

# /backup-check — Honest Backup Verification

**Contract:** this skill answers "am I actually backed up?" honestly. It reads
the authoritative sources (the real backup dir, the real R2 bucket) and reports
drift. It doesn't trust logs or success messages from previous runs.
**Paired with:** "skills must verify, not just execute" (#583).

## What's backed up where (post re-home)

Backups run via `/usr/local/bin/backup-cron.sh` (root cron `comfyume-backup`,
hourly, v1.0 Fable #620). Source of truth for scope = the script itself — read
its header first; this table can lag.

| Domain | Source (live) | Local | Offsite (R2) |
|---|---|---|---|
| configs | testing stack `.env`, creds, compose, host-nginx vhost, letsencrypt lineage | `/mnt/volume-1/backups/comfyume/configs/` (keep 48) | — (local only) |
| user-data | testing stack `data/{user_data,outputs,inputs}` | `/mnt/volume-1/backups/comfyume/user-data/` (keep 24) | `comfyume-user-files-backups/mello-testing/` at 02/06/14/18 UTC, append-only, size-verified |
| model vault | **no live source** — models are R2-only since the SFS deletion | — | `comfyume-model-vault-backups` (252GB, md5-verified against SFS 2026-07-15 pre-deletion) |
| **prod data** | `/mnt/volume-1/comfyume-prod/data` + prod `.env` | **[!] NOT YET COVERED** | **[!] NOT YET COVERED** |

**The prod gap is a known #642 task** — until the backup-cron extension lands,
this skill MUST report prod as unprotected. Do not soften that finding.

Decommission-day salvage (2026-07-15) also lives in R2: `config/<host>/` final
configs + manifests from both Verda boxes, `prod-sfs-final/` (output art, app
images, a Feb Claude's `.claude` home), and the worker image (5GB). Static —
verify existence only if asked.

## Steps

R2 creds: `R2_ENDPOINT` / `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` in the
testing stack `.env` (same creds the cron uses).

### 1. Local tarball freshness

```bash
ls -lt /mnt/volume-1/backups/comfyume/configs/ | head -3
ls -lt /mnt/volume-1/backups/comfyume/user-data/ | head -3
sudo tail -3 /var/log/backup-cron.log
```

- Newest tarball in each dir < 2h old (cron is hourly), non-zero size
- Log's last run ends `done — ok: N ... failed: 0`

### 2. R2 user-data recency + integrity

```bash
cd <testing-stack-dir> && export AWS_ACCESS_KEY_ID=$(grep '^R2_ACCESS_KEY_ID=' .env | cut -d= -f2-) AWS_SECRET_ACCESS_KEY=$(grep '^R2_SECRET_ACCESS_KEY=' .env | cut -d= -f2-) && EP=$(grep '^R2_ENDPOINT=' .env | cut -d= -f2-)
aws --endpoint-url "$EP" s3 ls s3://comfyume-user-files-backups/mello-testing/ | tail -3
```

- Newest object < 8h old (upload slots are 02/06/14/18 UTC)
- Size of newest R2 object == size of the matching local tarball (the cron
  size-verifies at upload; re-check here, don't trust it)

### 3. Model vault (static)

```bash
aws --endpoint-url "$EP" s3 ls s3://comfyume-model-vault-backups --recursive --summarize | tail -3
```

- Object count + total size stable vs `backups-log.md` (Ops Repo) — the vault is
  append-only and has no live source; **any shrinkage is a red alert**.

### 4. Prod data (until the #642 extension lands)

```bash
du -sh /mnt/volume-1/comfyume-prod/data 2>/dev/null
ls /mnt/volume-1/backups/comfyume/ | grep -i prod || echo "NO PROD BACKUPS"
```

Report the size of what exists vs the fact nothing covers it yet.

### 5. Present to user

Per-domain: ✅ OK / ❌ DRIFT / [!] NOT COVERED. Show drift details verbatim —
do not summarise away file lists. Read-only: if drift is found, propose the fix
(`sudo /usr/local/bin/backup-cron.sh --force-r2` for a missed upload; cron
repair for a dead cron) and wait for confirmation.

## Example output

```
mello (post re-home):
  configs:    ✅ OK — newest 14m ago (48 retained)
  user-data:  ✅ OK — local 14m · R2 3h ago, size match
  vault:      ✅ OK — 252GB / 1,204 objects (stable)
  prod data:  [!] NOT COVERED — 2.1G in /mnt/volume-1/comfyume-prod/data, zero backups (#642 task open)

Recommend: prioritise the prod backup extension before workshop data lands.
```

## Gotchas

- R2 ETag for multipart uploads (>8MiB) is composite, not md5 — size match is the
  practical check; note the caveat rather than false-alarming.
- R2 buckets are **append-only by design** — "rotation" (#642 R2 retention task)
  changes this; update this skill when it lands.
- The old per-domain scripts (`backup-models.sh --verify-only` etc.) were
  Verda/SFS-era — only relevant on fair-snow while it exists, and the SFS they
  verified is already gone. Don't run them on mello.
