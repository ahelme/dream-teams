---
name: backup-check
description: >
  Honest backup verification — checks what's actually backed up vs what's
  live by reading the authoritative sources (real backup dirs, real
  offsite bucket), not logs or past success messages. Read-only. Use
  before anything destructive, after data changes, or for an
  "am I backed up?" confirmation.
user-invocable: true
arguments:
  - name: domain
    description: "Optional: restrict to one backup domain (default: all)"
    required: false
version: 1.0.0
---

# /backup-check — Honest Backup Verification

**Contract:** this skill answers "am I actually backed up?" honestly. It reads
the authoritative sources (the real backup dir, the real offsite bucket) and
reports drift. It doesn't trust logs or success messages from previous runs.
Skills must verify, not just execute.

## What's backed up where

[ BACKUP SYSTEM DETAILS REQUIRED HERE — for each backup domain (configs,
user data, databases, static archives): live source path, local backup dir
+ retention count, offsite destination + upload schedule, and the
cron/script that runs it. Source of truth for scope = the backup script
itself — read its header first; any table here can lag. ]

If any domain is known to be NOT yet covered, list it here and **report it
as unprotected on every run. Do not soften that finding.**

## Steps

Offsite credentials: [ ADAPT: where offsite/object-storage creds live,
e.g. env vars in the stack `.env` — same creds the backup cron uses ].

### 1. Local backup freshness

```bash
ls -lt [ LOCAL BACKUP DIR ] | head -3
sudo tail -3 [ BACKUP CRON LOG ]
```

- Newest artifact in each dir younger than the cron interval, non-zero size
- Log's last run ends with the script's success marker (e.g. `failed: 0`)

### 2. Offsite recency + integrity

```bash
[ ADAPT: list newest objects in the offsite bucket, e.g.
aws --endpoint-url "$EP" s3 ls s3://[ BUCKET ]/[ PREFIX ]/ | tail -3 ]
```

- Newest object no older than the upload schedule allows
- Size of newest offsite object == size of the matching local artifact
  (re-check even if the cron claims it verified at upload — don't trust it)

### 3. Static / append-only archives (if any)

- Object count + total size stable vs the last recorded inventory. For an
  append-only archive with no live source, **any shrinkage is a red alert**.

### 4. Known-uncovered domains

```bash
du -sh [ UNCOVERED DATA DIR ] 2>/dev/null
```

Report the size of what exists live vs the fact nothing covers it yet.

### 5. Present to user

Per-domain: ✅ OK / ❌ DRIFT / [!] NOT COVERED. Show drift details verbatim —
do not summarise away file lists. Read-only: if drift is found, propose the
fix (forced re-upload, cron repair) and wait for confirmation.

## Gotchas

- S3-compatible ETags for multipart uploads are composite, not md5 — size
  match is the practical check; note the caveat rather than false-alarming.
- If the offsite bucket is append-only by design, any retention/rotation
  policy change should be reflected here when it lands.
