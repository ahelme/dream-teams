---
category: '{ [ ADAPT: this project''s ADR categories, e.g. meta | core | ops | team ] }'
status: '{proposed | accepted | rejected | superseded by [title](YYYY-MM-DD-…md) | deprecated}'
date: {YYYY-MM-DD}
deciders: '{who owns/approved this — e.g. [ FOUNDER NAME ] + [ AGENT NAME ] (workstream)}'
---

# {verb-phrase title — the decision, not the problem}

## Context
{Why now? What broke, changed, or is about to break? What constraints shape
this? Enough that a future agent with no prior context gets it without asking.}

## Decision
{What we're choosing to do — specific and scoped. Include non-goals: what this
is explicitly NOT doing.}

## Consequences
- Good, because {…}
- Cost, because {what gets harder / the maintenance or perf price}

## Implementation notes
- **Affected paths**: {real files/dirs}
- **Follow**: {existing pattern to match}
- **Avoid**: {what NOT to do}

### Verification
- [ ] {a check an agent could actually run}
- [ ] {another}

## Revisit-when
{The trip-wire that should reopen this decision. We move fast — name the
condition. If none, write "stable — supersede only on a measured regression".}

<!-- Optional — delete if unused -->
## Alternatives considered
- {Alternative}: {why rejected, one line}

<!-- Optional — delete if unused -->
## More
{Related ADRs, issues (`[ ORG/REPO ]#N`), commits, experiment notes.
`Supersedes:` / `Superseded by:` links go here.}
