---
description: Turn an ICP definition into a Clay-grounded audience of accounts and contacts. Produces a reviewable plan by default (firmographic filters, signals, persona scope, exclusions, data source map, pool estimate, enrichment order, refresh cadence, ownership map). Sources and enriches against Clay only when run with --execute. Sits upstream of icp-scoring.
argument-hint: <ICP description> [seed: closed-won examples] [exclude: criteria] [offer: description] [--execute] [--webhook-url <url>]
model: opus
---

Run the `audience-builder` skill on the ICP in $ARGUMENTS.

Parse the arguments:

- The ICP description is the main text (industry, size, geography, buying stage).
- `seed:` (optional) lists 3 to 5 closed-won customers for lookalike expansion.
- `exclude:` (optional) lists exclusion criteria.
- `offer:` (optional) describes the product or service, used to weight signals.
- `--execute` (optional) switches from plan mode to execute mode.
- `--webhook-url <url>` (optional) is a Clay table inbound-webhook URL to POST the audience to, in addition to the default CSV.

Default to **plan mode**: produce the nine-layer audience plan and its machine-readable summary. Do not run Clay Search, do not run Routines, do not spend credits. The user reviews the plan first.

Only when `--execute` is present, run the plan against Clay:

1. Discover real routines with `clay routines list` before naming any function. Never invent a function name.
2. Check `clay credits` and per-routine `estimatedCreditCost` before spending. If the estimate exceeds the balance, stop and report it.
3. Source the pool with `clay search filters-mode`, sample the first pages to estimate pool size (Search has no count endpoint, so report an approximate floor), then run the enrichment waterfall cheapest-first, gating expensive person and email routines behind firmographic and signal qualification.
4. Persist: write the audience to a local CSV by default, and if `--webhook-url` was given, also POST rows to that Clay table webhook source. The Clay plugin cannot write rows to a table directly, so state which persistence path ran.

Voice and quality rules from CLAUDE.md apply: no em dashes, no clichés or marketing jargon, every filter carries its reasoning, every enrichment step carries a credit-cost note, and every fallback to Apollo MCP or WebSearch is named with its reason in the data source map.

The output feeds [icp-scoring](../skills/icp-scoring/SKILL.md): build the pool wide and cheap here, let scoring rank it and apply the skip gate.
