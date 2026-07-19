#!/usr/bin/env bash
# read-mattermost.sh — Read recent messages from the team Mattermost channel.
# Usage: read-mattermost.sh [limit]   (default 10, newest last)
# Env: MATTERMOST_URL, MATTERMOST_TOKEN, MATTERMOST_CHANNEL_ID (see post-mattermost.sh)

set -euo pipefail

: "${MATTERMOST_URL:?set MATTERMOST_URL}"
: "${MATTERMOST_TOKEN:?set MATTERMOST_TOKEN}"
: "${MATTERMOST_CHANNEL_ID:?set MATTERMOST_CHANNEL_ID}"

LIMIT="${1:-10}"

python3 - "$LIMIT" <<'EOF'
import json, os, sys, urllib.request

url = os.environ["MATTERMOST_URL"]
tok = os.environ["MATTERMOST_TOKEN"]
chan = os.environ["MATTERMOST_CHANNEL_ID"]
limit = int(sys.argv[1])

def get(path):
    req = urllib.request.Request(url + path, headers={"Authorization": "Bearer " + tok})
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.load(r)

def post(path, payload):
    req = urllib.request.Request(url + path, data=json.dumps(payload).encode(),
        headers={"Authorization": "Bearer " + tok, "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.load(r)

data = get(f"/api/v4/channels/{chan}/posts?per_page={limit}")
order = data.get("order", [])[:limit]
posts = data.get("posts", {})
user_ids = list({posts[p]["user_id"] for p in order if p in posts})
names = {}
if user_ids:
    try:
        for u in post("/api/v4/users/ids", user_ids):
            names[u["id"]] = u.get("username", u["id"])
    except Exception:
        pass
for pid in reversed(order):  # oldest first
    p = posts.get(pid)
    if p:
        who = names.get(p["user_id"], p["user_id"][:8])
        print(f"{who}: {p.get('message','')}")
EOF
