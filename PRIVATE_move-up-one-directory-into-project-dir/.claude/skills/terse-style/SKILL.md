---
name: terse-style
description: Telegraphic style — rewrite text to omit needless words. Use when user says "make it terse", "telegraphic", "omit needless words", "tighten this up", "/terse-style", or asks to shorten/compress prose without losing meaning.
user-invocable: true
version: 1.1.0
---

# Telegraphic Style

Rewrite target text. Keep meaning. Remove filler.

## Cut

- Articles (a, an, the) unless ambiguous without
- Filler verbs (is, are, was, will be) — use fragments
- "please", "note that", "it should be noted", "in order to"
- Hedging ("basically", "essentially", "generally")

## Prefer

- `→` over "leads to", "results in", "which means"
- `—` for asides over subordinate clauses
- Lists over paragraphs
- Imperative ("Run X") over passive ("X should be run")
- One idea per line

## Replace

- Code blocks → concise summary + relevant lines / commands / function names

## Keep

- Specifics (names, paths, commands, numbers)
- Warnings, caveats
- Logical connectors that prevent misreading
- Technical detail required to understand task

## Apply

- Text → rewrite
- File → read, rewrite, show diff
- No target → ask
