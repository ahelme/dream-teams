---
name: dry
description: Dry — Docker TUI for managing containers on a remote host. Reminds the user how to launch it and gives non-interactive equivalents Claude can run.
user-invocable: true
version: 1.0.0
---

Dry — Docker TUI for managing containers on the Docker host.

**Server:** [ SSH COMMAND / HOST, e.g. `user@host` — or run locally if Docker is on this box ]
**Docs:** https://moncho.github.io/dry/
**Launch:** `ssh -t [ SSH HOST ] "dry"` (needs -t for TTY)

NOTE: Dry is a TUI (terminal UI) — it requires an interactive terminal.
Claude cannot interact with it directly. Use this skill to:
1. Remind the user how to launch it
2. Suggest non-interactive alternatives for the same info

## Keybindings

| Key | Action |
|-----|--------|
| `F1` | Sort containers |
| `F2` | Toggle show all containers |
| `F5` | Refresh |
| `Enter` | Show container details |
| `l` | Show container logs |
| `s` | Show container stats |
| `i` | Inspect container |
| `r` | Restart container |
| `q` | Quit |

## Non-Interactive Alternatives (for Claude)

Container names below assume a common prefix, e.g. `[ CONTAINER PREFIX ]-<name>`.

```bash
# Container list (like dry main screen)
ssh [ SSH HOST ] "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | sort"

# Container stats (like dry 's' key)
ssh [ SSH HOST ] "docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}' | sort"

# Container inspect (like dry 'Enter')
ssh [ SSH HOST ] "docker inspect [ CONTAINER PREFIX ]-$ARGUMENTS 2>/dev/null | python3 -m json.tool | head -50"

# Container logs (like dry 'l')
ssh [ SSH HOST ] "docker logs [ CONTAINER PREFIX ]-$ARGUMENTS --tail 30 2>&1"
```

If $ARGUMENTS provided, run the non-interactive equivalent for that container.
Otherwise tell the user to run `ssh -t [ SSH HOST ] "dry"`.
