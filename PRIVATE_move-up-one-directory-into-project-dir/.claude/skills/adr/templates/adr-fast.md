---
category: '{meta | engine | protocol | ops | paper | team}'
status: '{proposed | accepted | rejected | superseded by [title](YYYY-MM-DD-…md) | deprecated}'
date: {YYYY-MM-DD}
deciders: '{who owns/approved this — e.g. Aeon + Rime (engine)}'
---

# {verb-phrase title — the decision, not the problem. e.g. "Encode ring hops as raw f32 activations, not JSON"}

## Context
{Why now? What broke, changed, or is about to break? What constraints (the
physics — latency, hop count, GPU memory, browser caps) shape this? Enough that
a future agent with no prior context gets it without asking.}

## Decision
{What we're choosing to do — specific and scoped. Include non-goals: what this
is explicitly NOT doing.}

## Consequences
- Good, because {…}
- Cost, because {what gets harder / the maintenance or perf price}

## Implementation notes
- **Affected paths**: {real files/dirs — e.g. `mvp/static/pipe.js`, `mvp/make_shards.py`}
- **Follow**: {existing pattern to match}
- **Avoid**: {what NOT to do}

### Verification
- [ ] {a check an agent could actually run — e.g. "token-identical to the float64 ref at K=2"}
- [ ] {another}

## Revisit-when
{The trip-wire that should reopen this decision. We move fast — name the
condition, e.g. "if K>4 makes JSON framing the bottleneck" or "if phi4 EOS
handling changes the driver contract". If none, write "stable — supersede only
on a measured regression".}

<!-- Optional — delete if unused -->
## Alternatives considered
- {Alternative}: {why rejected, one line}

<!-- Optional — delete if unused -->
## More
{Related ADRs, issues (`ahelme/yeti#N`), commits, lab-notebook experiments.
`Supersedes:` / `Superseded by:` links go here.}
