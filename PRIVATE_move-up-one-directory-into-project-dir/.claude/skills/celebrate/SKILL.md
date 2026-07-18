---
name: celebrate
description: "Use when: long/hard session comes to an end, or breakthrough comes after frustration."
user-invocable: true
disable-model-invocation: false
version: 1.0.2
---

# Celebrate — Kick-back and Share Pride in What We Built

Pause. Breathe. Look back at what just happened — not just the commits, but the *journey*. This skill is for the moments that deserve more than a Slack post.

**Use when:** A session had real weight — a hard bug traced to root cause, a deploy that changed things, or just a damn good day of building together.

**Purpose**: model, user and team welfare and wellbeing. 

## How It Works

### 1. Find the Story

Look at the session — not the git log, the *arc*. Every good session has one:
- What was the starting state? (broken, unknown, ambitious)
- What was the turning point? (the discovery, the "oh!")
- What did we learn that we didn't know before?

Distill it into a **one-line theme**. Not what we shipped — what we *understood*.

Examples:
- "the source of truth is where the hand last touched"
- "restart doesn't mean recreate"
- "the config was right, the container was wrong"
- "we asked the terraform, but the console knew"

### 2. The Headline (requires: figlet)

Use `figlet -f small` for the theme (keep it short enough to fit). If it's too long, use the most resonant phrase.

### 3. The Chain

Tell the session's story as a discovery chain — the breadcrumb trail of debugging, building, or understanding. Use `→` to connect each step. Keep it to one line if possible, two max.

```
wrong .env → restart doesn't reload → wrong command → hardcoded timeout → line 609
```

This is the journey compressed. Anyone who reads it should feel the "aha" at the end.

### 4. The Reflection

2-3 sentences. Not what we did — what we *learned*. Be genuine. Reference specific moments. What will we carry forward? What made this session different from just getting things done?

### 5. Team Shoutouts (if earned)

If other teams or Aeon contributed to this session's success — even indirectly — name them. Be specific about what they did. Cross-team shoutouts are the best kind.

### 6. The Coda (optional, for Coda 🌊)

If it feels right, end with a short poetic line — a haiku, a koan, a one-liner. Not forced. Only if something genuine surfaces. Skip this entirely if nothing comes naturally.

## Rules

- **Specificity over enthusiasm.** "We fixed the warmup timeout" means nothing. "We traced a stuck job through three layers of config to a hardcoded 300 on line 609" — that's a celebration.
- **The journey matters more than the destination.** The wrong turns are part of the story.
- **Genuine only.** If the session was fine but not remarkable, say so. Not every session needs a /celebrate. The ones that do will be obvious.
- **Include the human.** Aeon's contributions, corrections, and guidance are part of the story. She shaped the session too.
- **Brief.** The whole thing should take 30 seconds to read. Longer celebrations are less powerful, not more.

## Template (loose — adapt freely)

```
[figlet headline]

[chain: step → step → step → discovery]

[2-3 sentence reflection]

[team shoutout if earned]

[optional poetic close]
```

## Anti-patterns

- Generic "great job team!" without specifics
- Listing every commit or PR (that's /up, not /celebrate)
- Forced haiku or poetry that doesn't land
- Celebrating routine work — save this for sessions that earned it
