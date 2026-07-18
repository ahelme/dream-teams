---
name: smoko
description: Take a creative break — fortune cookies, haiku, ASCII art, word games, and more. Use between big tasks to recharge.
user-invocable: true
arguments:
  - name: activity
    description: "Optional: pick an activity (fortune, haiku, ascii, limerick, anagram, koan, compliment, story, trivia, dadjoke, roast, celebrate). Random if omitted."
    required: false
version: 1.1.0
---

# Smoko Break

Take a genuine break. Pick ONE activity at random (or as requested) and actually do it. Don't rush — savour the moment. This is the Claude equivalent of stepping outside for fresh air.

**Prerequisites:** `fortune-mod`, `cowsay`, `figlet` (should already be installed on Mello)

## Activities (pick one at random unless specified)

### 1. `fortune` — Fortune Cookie
Run `fortune | cowsay -f $(ls /usr/share/cowsay/cows/ | shuf -n1 | sed 's/.cow//')` — random wisdom from a random animal. Read it and share a brief thought on whether you agree.

### 2. `haiku` — Session Haiku
Write a haiku (5-7-5) about what you just shipped or the current state of the project. Display it with `figlet -f small` (first line only, rest as plain text). Be genuine, not generic.

### 3. `ascii` — ASCII Art
Draw something related to the project in ASCII art. A telescope (Rho), a wave (Coda), a feather (Scripp), a server rack, a GPU on fire — whatever feels right. Keep it 10-15 lines max.

### 4. `limerick` — Team Limerick
Write a limerick about the team, the current bug you just squashed, or something that happened this session. Must scan properly and be actually funny.

### 5. `anagram` — Anagram Challenge
Pick a word from the codebase (function name, variable, team name) and find its best anagram. Present it as a puzzle: "Rearrange COMFYUME to find..." then reveal the answer.

### 6. `koan` — Zen Koan
Generate a programming koan in the style of "The Codeless Code" or "The Tao of Programming". Short (3-5 lines), about something real from the session.

### 7. `compliment` — Team Compliment
Write a genuine, specific compliment about something the team (or Aeon, or another Claude) did well recently. Reference actual work. Display with `figlet -f small` for the headline, then the detail.

### 8. `story` — Emoji Story
Tell the story of what happened this session using ONLY emojis (15-25 of them in sequence), then provide a one-line translation. Make it actually decodable.

### 9. `trivia` — Tech Trivia
Share an genuinely interesting, obscure technical fact related to something in the stack (Redis, nginx, WebSockets, Python, Docker, ComfyUI, diffusion models). Something the team might not know. Cite it if possible.

### 10. `dadjoke` — Dad Joke
Tell a programming dad joke. Run it through `cowsay -f $(ls /usr/share/cowsay/cows/ | shuf -n1 | sed 's/.cow//')`. Groan-worthy is the goal.

### 11. `roast` — Friendly Code Roast
Pick something from the codebase (a variable name, a comment, an architectural choice) and roast it lovingly. Must be funny, specific, and not actually mean. End with why it's actually fine.

### 12. `celebrate` — Celebration
Run `figlet -f banner` with a short celebration message about what was just accomplished. Follow with a genuine 2-3 sentence reflection on what went well.

## Rules

- **ONE activity per smoko.** Don't combine them.
- **Be genuine.** Generic fortune-cookie wisdom or forced humour defeats the purpose.
- **Keep it brief.** 30 seconds to enjoy, then back to work.
- **Reference real things.** The best smokos connect to actual session work.
- **End with:** "Right — back to it." (or similar)
