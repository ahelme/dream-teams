# Graph engineering — field notes (2026-08)

Why the configurator is a graph editor and not a form, in five findings from
a quick survey of where "graph engineering" landed in 2026.

1. **The term means declared topology.** Graph engineering is the practice of
   representing an AI application as an executable graph — agents,
   deterministic functions, routers, human checkpoints as nodes; permitted
   transitions as edges — rather than one autonomous loop. The framing is
   emerging, not settled, but the shape is consistent across sources.
2. **Deterministic backbone, LLM at the nodes.** The production pattern that
   survived: a deterministic orchestrator owns the flow (defined states,
   transitions, terminal conditions); model intelligence is invoked
   intentionally at specific nodes and control returns to the backbone.
   Dream Teams matches this: hooks, CI stitching, `team-graph` scaffolding,
   and branch policy are the backbone; agents are the nodes.
3. **Org graphs vs. work graphs.** The 2026 layer-cake distinguishes the
   *org graph* (who exists, what they may touch — stable, committed) from
   *work graphs* (how a task flows — dynamic, per-task). `team.yaml` is
   deliberately only the org graph. Work-graph tooling (task routing,
   handoffs) stays in skills and chat, where it can change per task.
4. **Topology follows task shape, not org charts.** Supervisor/worker and
   explicit graph topologies are the two multi-agent patterns that earn
   their production cost. Our coach + flat-agents + deployer shape is
   supervisor-ish on purpose; the configurator makes changing that shape a
   one-file edit.
5. **Graph-grounded context is the bet.** Gartner's line: >50% of agent
   systems will use graph-based context by 2028, with ~30% accuracy gains
   from graph-grounded context engineering. The kit's graphify hook rides
   the same bet at the code level; `team.yaml` rides it at the team level.

Design consequences baked into the configurator:

- The drawn graph, the form, and the YAML are three projections of one
  declaration — none is the "real" one, so all three stay in sync live.
- The YAML embeds its own topology as an ASCII comment header, so a PR diff
  of `team.yaml` shows the *shape* of the team changing during review.
- Validation runs at declaration time (browser and CLI both), because a
  topology error caught at runtime is a multi-agent incident, not a typo.

Sources:
[Graph Engineering: Wire Multi-Agent Orgs After Loops (explainx)](https://www.explainx.ai/blog/graph-engineering-ai-agents-multi-agent-organizations-2026) ·
[Graph Engineering for Multi-Agent Systems (TrueFoundry)](https://www.truefoundry.com/blog/graph-engineering-enterprise-guide) ·
[Graph-Based Agent Workflow Orchestration in Production (Zylos)](https://zylos.ai/research/2026-04-14-graph-based-agent-workflow-orchestration-production/) ·
[Graph Engineering in LangGraph (Analytics Vidhya)](https://www.analyticsvidhya.com/blog/2026/07/graph-engineering/) ·
[Knowledge Graphs for AI Agents (Atlan)](https://atlan.com/know/ai-agent/knowledge-graph-for-ai-agents/) ·
[Agent Architecture Patterns Taxonomy (Digital Applied)](https://www.digitalapplied.com/blog/agent-architecture-patterns-taxonomy-2026) ·
[Assemble Your Crew: topology design via graph generation (arXiv 2507.18224)](https://arxiv.org/pdf/2507.18224)
