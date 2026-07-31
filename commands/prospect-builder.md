---
description: Turn an ICP definition into a Clay-grounded, tiered audience of accounts and contacts. Produces a reviewable plan by default (firmographic filters, signals, persona scope, exclusions, data source map, pool estimate, enrichment order, delegation pipeline, refresh cadence, ownership map). Sources (Clay Search by default, or Apollo MCP with --source apollo) and enriches only when run with --execute, then delegates tiering to icp-scoring, contacts to contact-resolver, and email checks to email-verification.
argument-hint: <ICP description> [seed: closed-won examples] [exclude: criteria] [offer: description] [--source <name>] [--motion <name>] [--enrich-all] [--max-companies <n>] [--execute] [--webhook-url <url>]
model: opus
---

Run the `prospect-builder` skill on the ICP in $ARGUMENTS.

Parse the arguments:

- The ICP description is the main text (industry, size, geography, buying stage).
- `seed:` (optional) lists 3 to 5 closed-won customers for lookalike expansion.
- `exclude:` (optional) lists exclusion criteria.
- `offer:` (optional) describes the product or service, used to weight signals.
- `--source <name>` (optional) selects where the firmographic pool comes from: `clay` (default) uses Clay Search, `apollo` uses Apollo MCP company search (`apollo_mixed_companies_search`) for firmographic and technographic sourcing. Only sourcing changes; signal enrichment and the icp-scoring, contact-resolver, and email-verification delegations run identically. If `--source` is an unrecognized value, reject the run and list the valid values (clay, apollo). If `--source apollo` is set but the Apollo MCP is not authenticated, stop with a clear error; do not silently fall back to Clay.
- `--motion <name>` (optional) overrides motion assignment, forcing a single motion across the whole run, one of the seven in config/motions/ (cold-outbound, signal-based, abm, nurture, inbound-followup, expansion, wake-the-dead). Useful for a named campaign. Without it, prospect-builder auto-assigns a motion per row from the deterministic routing table in the skill's Layer 8b, keyed on the tier and the fresh-signal count together: A or B with a live signal to signal-based, A or B with none to cold-outbound, C with a live signal to cold-outbound, C with none to nurture. If `--motion` is passed with a name that is not a file in config/motions/, reject the run with an error listing the seven valid motions; do not proceed. Either way the assigned motion is written to `ab_motion`; the skill does not execute the motion.
- `--enrich-all` (optional) overrides the default cost gate and runs contact-resolver and email-verification on Tier C accounts too, producing a fully enriched pool. By default only Tier A and B accounts get contact and email enrichment; Tier C stays firmographic, signal, tier, and motion only. Use `--enrich-all` when you want contacts for the whole pool immediately, for example to feed a nurture motion that sends to Tier C.
- `--max-companies <n>` (optional) caps how many companies `--execute` sources. Defaults to 25 (test scale). Raise for production: 500 to 1500 for a weekly refresh, 3000+ for a full TAM sweep. Cost scales with the count at sourcing and further with contact/email on Tier A/B; Tier C never incurs contact/email spend, so cost stays bounded at scale.
- `--execute` (optional) switches from plan mode to execute mode.
- `--webhook-url <url>` (optional) is a Clay table inbound-webhook URL to POST the audience to, in addition to the default CSV.

Default to **plan mode**: produce the ten-layer audience plan and its machine-readable summary. Do not run Clay Search, do not run Routines, do not call the downstream skills, do not spend credits. The user reviews the plan first.

Only when `--execute` is present, run the plan against Clay and the downstream skills:

1. Discover real routines with `clay routines list` before naming any function. Never invent a function name.
2. Check `clay credits` and per-routine `estimatedCreditCost` before spending. If the estimate exceeds the balance, stop and report it.
3. Source the pool per `--source` (default `clay`). For `clay`, use `clay search filters-mode`. For `apollo`, translate the config/icp.md filters to `apollo_mixed_companies_search` parameters (see the skill's Sourcing section for the real parameter mapping) and page it. Sample the first pages to estimate pool size (report an approximate floor), and tag each row's `ab_pool_source` (`clay-search` or `apollo-mcp`). The steps below are identical regardless of source.
4. Enrich buying signals on every firmographic-qualified row with the signal routines (Company Latest Funding, Company News, Company Job Openings, Website Technology Stack). Signals are scoring inputs, not gates, so no account is dropped here.
5. Delegate, do not duplicate. Call `icp-scoring` per account for the tier (A/B/C) and `recommended_persona`. Assign `ab_motion` per row from the deterministic routing table in the skill's Layer 8b, keyed on tier plus fresh-signal count, unless a valid `--motion` overrides it for the whole run. Call `contact-resolver` to resolve one contact for tier A and B accounts, or for every tier when `--enrich-all` is set. Call `email-verification` on each resolved contact for a verdict. By default Tier C accounts stay in the pool without contact or email spend; with `--enrich-all` they pass through the full pipeline too.
6. Persist: write the audience to a local CSV by default, with an `ab_pool_source` column (`clay-search` or `apollo-mcp`), an `ab_tier` column, an `ab_motion` column (the routed motion from the tier plus fresh-signal table, or the `--motion` override), and a row for every fit-qualified account (A, B, and C). If `--webhook-url` was given, also POST rows to that Clay table webhook source. The Clay plugin cannot write rows to a table directly, so state which persistence path ran.

Voice and quality rules from CLAUDE.md apply: no em dashes, no clichés or marketing jargon, every filter carries its reasoning, every enrichment step carries a credit-cost note, and every fallback to Apollo MCP or WebSearch is named with its reason in the data source map.

In execute mode, prospect-builder delegates tiering to [icp-scoring](../skills/icp-scoring/SKILL.md), contact discovery to [contact-resolver](../skills/contact-resolver/SKILL.md), and email checks to [email-verification](../skills/email-verification/SKILL.md), then aggregates the tiered pool. Build wide and cheap at sourcing; let the delegated skills score, resolve, and verify.
