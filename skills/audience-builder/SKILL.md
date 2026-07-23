---
name: audience-builder
description: Use when turning an ICP definition into an actual account and contact list. Sits upstream of icp-scoring: audience-builder produces the pool, icp-scoring ranks it. Sources TAM and enriches it with the Clay Agent Plugin (Search, Routines, Tables), falls back to Apollo MCP, then WebSearch. Runs in plan mode by default and only touches Clay data when invoked with --execute.
---

# Audience builder

Turn an ICP definition into a real, enriched list of accounts and contacts. Given an ICP description (and optionally a few closed-won examples, exclusions, and an offer description), this skill produces a Clay-grounded audience plan, and on request executes it against Clay to return the pool with real data.

## Where this sits

This is the front of the funnel. [icp-scoring](../icp-scoring/SKILL.md) scores accounts you already have; audience-builder produces the accounts in the first place. The two share a contract: audience-builder emits accounts with the firmographic and signal fields icp-scoring reads (stage, headcount, motion, buyer, stack, signal, reachability), so a pool built here can flow straight into scoring without a reshape. Build the pool wide and cheap here; let icp-scoring do the ranking and the skip gate.

## Primary tool: the Clay Agent Plugin

Clay is the primary source for both sourcing and enrichment. Reach the plugin through the `clay` CLI (JSON output). The three primitives this skill uses:

- **Search** (`clay search filters-mode ...`): pull TAM from Clay's companies and people dataset using structured filters.
- **Routines** (`clay routines ...`): run Clay-managed functions and any custom functions or workflows in the workspace for enrichment (emails, phones, firmographic depth, funding, news, hiring).
- **Tables** (`clay tables ...` and the `table` MCP tool): read from existing audience tables. Note the write limitation below.

Method and function names are grounded in [docs/patterns/clay-integration.md](../../docs/patterns/clay-integration.md). Read it before writing any Clay call.

### Never invent Clay function names

The routines in a workspace vary. Before naming or running any function, list what actually exists:

```bash
clay routines list
```

Match the user's intent to a real routine from that output. Reference routines by their real name, and resolve the `function:<id>` at runtime from the list (IDs are workspace-specific, names are stable for Clay-managed functions). If no routine covers what you need, say so and use a fallback rather than inventing a name.

## Inputs

- **ICP description** (required): industry, size range, geography, buying stage. Prose is fine; parse it into filter dimensions.
- **Closed-won examples** (optional, 3 to 5): named customers to expand from as a lookalike seed. See [examples/lookalike-example.md](examples/lookalike-example.md).
- **Exclusion criteria** (optional): industries, sizes, regions, named accounts, or attributes to keep out.
- **Offer / product description** (optional): informs which signals matter, so signal weighting is grounded in what you sell rather than generic intent.

If the ICP is thin, do not pad it with guesses. Ask one or two sharp questions, or build the plan with the gaps named explicitly. See [examples/blank-icp-example.md](examples/blank-icp-example.md) for the thin-input path.

## Modes

- **Plan mode (default)**: produce the full audience plan below. Do not run Search, do not run Routines, do not spend credits. The user reviews the plan first. Every filter and enrichment step names its reasoning and its cost.
- **Execute mode (`--execute`)**: run the plan against Clay and return the audience with real data. Check credits before spending (see the credit discipline section). Persist per the persistence section.

Default to plan mode. Only execute when the flag is present.

## Output structure (the plan)

Produce these nine layers, in order. Each filter carries a one-line reason. Each enrichment step carries a credit-cost note.

1. **Firmographic filters**, translated to Clay Search parameters. Give the actual `--source-type companies` filter JSON, and a reason per filter. Name any ICP attribute that is not a native Clay Search filter and route it to a routine or Apollo instead (see the coverage section).

2. **Signal filters**, each tagged with its source: `Clay native` (a Search filter), `Clay Routine` (a named function like Company Latest Funding, Company News, or Company Job Openings), or `manual` (no Clay coverage; describe the manual or WebSearch step). Weight signals by the offer description if one was given.

3. **Persona scope**: title keywords and seniority for the Clay people search, drawn from the buyer described in the ICP. This is the input to a `--source-type people` search or to Find People at Company.

4. **Exclusion filters**: the exclude-side Search parameters (for example `industries_exclude`, `location_states_exclude`, `include_company_identifiers` used as a suppression list) plus any exclusion that has to be applied post-hoc because Search cannot express it.

5. **Data source map**: for each layer above, which Clay primitive covers it (Search, a named Routine, or a Table read), and why that primitive. Where Clay does not cover it, name the fallback (Apollo MCP or WebSearch) and the reason.

6. **Estimated pool size**: in execute mode, sample the first few pages of the Search and extrapolate. Report it as an approximate floor, for example "~1,200+ (sampled 3 pages, hasMore=true)", with a note that Clay Search has no count endpoint and an exact number requires a full page-through. In plan mode, state the method rather than a number.

7. **Enrichment routine order**: the waterfall, cheapest-first. Firmographics already returned by Search cost nothing extra, so use them before calling any routine. Gate the expensive person and email routines behind firmographic and signal qualification, so email credits are spent only on rows likely to survive icp-scoring. See the waterfall section.

8. **Refresh cadence**: how often to rebuild each layer, keyed to how fast that data decays (firmographics slow, funding and news fast, contact emails fastest).

9. **Ownership map**: the namespace prefix pattern for any field this skill writes toward a CRM, so provenance is legible and fields do not collide. See the ownership section.

Close the plan with a compact machine-readable summary:

    {
      "source_type": "companies",
      "firmographic_filters": { "<clay_filter>": ["<value>"] },
      "exclusion_filters": { "<clay_filter>": ["<value>"] },
      "signal_filters": [
        { "signal": "<name>", "source": "Clay native | Clay Routine | manual", "routine": "<real routine name or null>" }
      ],
      "persona_scope": { "job_title_keywords": ["<title>"], "seniority": ["<level>"] },
      "enrichment_order": ["<routine name in cheapest-first order>"],
      "data_source_map": [ { "layer": "<layer>", "primitive": "Search | Routine | Table | Apollo | WebSearch", "why": "<reason>" } ],
      "estimated_pool": "<approx floor or 'plan mode: method only'>",
      "refresh_cadence": { "firmographics": "<interval>", "signals": "<interval>", "contacts": "<interval>" },
      "ownership_prefix": "<prefix>",
      "fallbacks_used": ["<attribute -> Apollo | WebSearch, and why>"]
    }

## Firmographic to Clay Search translation

Discover the real filter names first, never assume them:

```bash
clay search filters-mode fields --source-type companies
clay search filters-mode fields --source-type people
```

Common mappings (confirm against the live `fields` output, which is authoritative):

- Industry -> `industries` (enum; pick from the allowed values the `fields` command returns).
- Geography -> `location_cities_include`, `location_states_include`, `country_names`, plus `location_headquarters_only` to restrict to HQ.
- Size -> `sizes`, or `minimum_member_count` / `maximum_member_count` for a custom band.
- Revenue -> `annual_revenues` (enum ranges).
- Keywords -> `description_keywords` to narrow to a niche the industry enum is too coarse for.

### What Clay Search does not filter natively

Some ICP attributes are not Search filters. Do not force them into an existing filter or invent one. Split the request: get a candidate set from the closest native filters, then enrich or verify the missing attribute with a routine or a fallback.

- **Funding stage (Series A, B, C)**: not native. Clay Search has `funding_amounts` (total-raised ranges) only. Approximate the stage with a `funding_amounts` band, then confirm the actual round with the **Company Latest Funding** routine on the candidate set.
- **Tech in use as a hard filter**: `Website Technology Stack` is a routine, not a Search filter. Source the candidates, then run the routine and filter its output.
- **Recent hiring / news as a hard filter**: `Company Job Openings` and `Company News` are routines. Source, then enrich, then filter.

Always state in the data source map when an attribute is handled this way, and why.

## Enrichment waterfall (cheapest-first)

Order enrichment so cheap, high-coverage lookups qualify rows before expensive person-level and email lookups run. Confirm the exact per-item cost with `clay routines get <id>` before each step; the tiers below are the ordering principle, not fixed prices.

1. **Free**: firmographics already on the Search rows (name, domain, size, industry, location, funding range). Use these to pre-filter before spending anything.
2. **Cheap company lookups**: Company Domain, Company Industry, Company Employee Count, Enrich Company. Fill firmographic gaps.
3. **Signal routines**: Company Latest Funding, Company News, Company Job Openings. Run only on rows that passed the firmographic gate.
4. **People discovery**: Find People at Company (scoped to the persona titles and seniority from layer 3 of the plan).
5. **Contact detail and email**: Enrich Person and Find Contact Details, Work Email. Most expensive per item, run last and only on qualified people. Treat email as decaying data, so re-verify near send time rather than trusting a months-old result.

The gate matters: a row that will score `skip` in icp-scoring should never reach step 5. Spend email credits on the pool that survives qualification, not the raw TAM.

## Persistence (execute mode)

The Clay plugin cannot write rows into a Clay table (the table surface is read-only via CLI, MCP, and the Public API). So audience-builder persists like this:

- **Default: CSV.** Write the enriched audience to a local CSV and tell the user how to import it in the Clay app (New table, then CSV import) if they want it in Clay.
- **Optional: webhook write-back.** If the user passes `--webhook-url <url>` for a Clay table configured with an inbound webhook source, POST the rows to that URL as well. This is the one supported write path into a Clay table, and it requires the user to have set up the webhook-source column in the Clay app first.

Reading from existing audience tables is fully supported (`clay tables` and the `table` MCP tool); only writing is constrained. State this limitation in the output rather than implying a write happened when it did not.

## Ownership map

Namespace every field this skill contributes toward a CRM with a stable prefix, so provenance is legible and audience-builder fields never collide with native CRM or other-tool fields. Default prefix: `ab_`.

- `ab_source` (which Clay primitive or fallback produced the row)
- `ab_pool` (the audience/pool label this row belongs to)
- `ab_signal_*` (one field per signal, for example `ab_signal_funding`, `ab_signal_hiring`)
- `ab_enriched_at` (date of last enrichment, for the refresh cadence)

This is a naming convention for output, not a CRM write. Consistent with the stack's CRM doctrine, audience-builder never writes to a CRM automatically; it produces a labeled package the user reviews and loads.

## Fallbacks

Clay first. When Clay does not cover a firmographic filter or an enrichment well:

1. **Apollo MCP** for firmographic filters Clay Search lacks (some intent and technographic cuts, certain size or revenue slices). Note in the data source map that Apollo produced the layer and why.
2. **WebSearch** only as a last resort, for a niche attribute neither Clay nor Apollo has. Every fact WebSearch produces about a company carries its source, per the stack's citation rule.

Name every fallback in `fallbacks_used`. Silent substitution hides where the data came from.

## Credit discipline (execute mode)

Before spending, check cost and balance:

```bash
clay routines get <id>          # read estimatedCreditCost.perRun
clay credits                    # read balance
```

Multiply per-item cost by the number of rows the step will run on. If the estimated total exceeds the balance, stop and report it rather than starting a run that only partially completes. Prefer running expensive routines on the qualified subset, not the raw pool.

## Quality rules

- No em dashes. No clichés, no marketing jargon (no "unlock", "leverage", "seamless", "best-in-class", "AI-powered", and the rest of the banned list in CLAUDE.md).
- Every filter recommendation includes its reasoning.
- Every enrichment step includes a credit-cost consideration.
- Never invent a Clay function name. Run `clay routines list` and match a real one.
- Note explicitly, in the data source map, when Clay cannot cover a layer and Apollo or WebSearch is standing in, and why.
