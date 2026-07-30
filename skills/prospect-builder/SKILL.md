---
name: prospect-builder
description: Use when turning an ICP definition into an actual account and contact list. prospect-builder orchestrates the top of the funnel: it sources a firmographic pool with Clay Search and enriches buying signals, then delegates tiering to icp-scoring, contact discovery to contact-resolver, and email checks to email-verification. Runs in plan mode by default and only touches Clay data when invoked with --execute.
---

# Audience builder

Turn an ICP definition into a real, enriched, tiered list of accounts and contacts. Given an ICP description (and optionally a few closed-won examples, exclusions, and an offer description), this skill produces a Clay-grounded audience plan, and on request executes it against Clay and the downstream skills to return the pool with real data, a tier per account, and a contact for the accounts worth reaching.

## Where this sits

This is the front of the funnel, and it is an orchestrator, not a monolith. prospect-builder owns the two jobs that are genuinely its own: sourcing a firmographic pool (Clay Search) and enriching each account with buying signals (Clay Routines). Everything downstream is delegated to the skill that already owns that logic, so there is one source of truth per concern:

- **Tiering** is delegated to [icp-scoring](../icp-scoring/SKILL.md). prospect-builder hands it the account plus its signals; it returns a `tier` (A/B/C) and a `recommended_persona`.
- **Contact discovery** is delegated to [contact-resolver](../contact-resolver/SKILL.md). For tier A and B accounts, prospect-builder passes the domain and `recommended_persona`; it returns one primary contact with a confidence label.
- **Email checks** are delegated to [email-verification](../email-verification/SKILL.md). Each resolved contact's email fields go through it for a verdict.

prospect-builder does not re-implement scoring, people search, or email logic. It sources, enriches signals, calls those three skills, and aggregates the results. It still emits the firmographic and signal fields icp-scoring reads (stage, headcount, motion, buyer, stack, signal, reachability), so the hand-off needs no reshape.

## Primary tool: the Clay Agent Plugin

Clay is the primary source for sourcing and signal enrichment. Reach the plugin through the `clay` CLI (JSON output). The three primitives this skill uses:

- **Search** (`clay search filters-mode ...`): pull TAM from Clay's companies and people dataset using structured filters.
- **Routines** (`clay routines ...`): run Clay-managed functions and any custom functions or workflows in the workspace for enrichment (firmographic depth, funding, news, hiring, tech stack).
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
- **Offer / product description** (optional): informs which signals matter. Signal relevance is read from the buying signals in config/offering.md at runtime, so weighting is grounded in what you sell rather than a hardcoded topic list.
- **Motion** (optional, `--motion <name>`): overrides motion assignment, forcing a single motion across the whole run, one of the seven in config/motions/. Useful for a named campaign (for example `--motion abm`). Without the flag, prospect-builder auto-assigns a motion per row from each motion's Tier defaults: Tier A and B rows get signal-based, Tier C rows get nurture. Either way the assigned motion is written to `ab_motion`; prospect-builder tags but does not execute the motion (that is a later skill's job). If `--motion` names a motion that is not a file in config/motions/, reject the run and list the seven valid motions rather than proceeding. Tier decides priority; motion decides treatment.

If the ICP is thin, do not pad it with guesses. Ask one or two sharp questions, or build the plan with the gaps named explicitly. See [examples/blank-icp-example.md](examples/blank-icp-example.md) for the thin-input path.

## Modes

- **Plan mode (default)**: produce the full audience plan below. Do not run Search, do not run Routines, do not call the downstream skills, do not spend credits. The user reviews the plan first. Every filter and enrichment step names its reasoning and its cost.
- **Execute mode (`--execute`)**: run the plan against Clay and the downstream skills, and return the audience with real data. Check credits before spending (see the credit discipline section). Persist per the persistence section.

Default to plan mode. Only execute when the flag is present.

## Output structure (the plan)

Produce these ten layers, in order. Each filter carries a one-line reason. Each enrichment step carries a credit-cost note.

1. **Firmographic filters**, translated to Clay Search parameters. Give the actual `--source-type companies` filter JSON, and a reason per filter. Name any ICP attribute that is not a native Clay Search filter and route it to a routine or Apollo instead (see the coverage section).

2. **Signal enrichment (inputs to scoring, not gates)**. For each account, enrich the buying signals that matter for the offer, each tagged with its source: `Clay Routine` (a named function like Company Latest Funding, Company News, or Company Job Openings) or `manual` (no Clay coverage; describe the WebSearch step). Signals are scoring inputs, not filters: they do not gate any account out of the audience. Every firmographic-qualified account keeps its place in the pool and carries its signal count into icp-scoring, which uses signals to set the tier. Which signals count as relevant is read from the buying signals defined in config/offering.md at runtime, not from a hardcoded topic list.

3. **Persona scope (handed to contact-resolver)**. The buyer titles come from config/personas.md and travel as icp-scoring's `recommended_persona`. prospect-builder does not run its own people search; it delegates contact discovery to contact-resolver, which walks its own waterfall over `recommended_persona`. State which personas the pool targets, and note that the actual contact lookup is delegated.

4. **Exclusion filters**: the exclude-side Search parameters (for example `industries_exclude`, `location_states_exclude`, `include_company_identifiers` used as a suppression list) plus any exclusion that has to be applied post-hoc because Search cannot express it.

5. **Data source map**: for each layer above, which Clay primitive covers it (Search, a named Routine, or a Table read), and why that primitive. Where Clay does not cover it, name the fallback (Apollo MCP or WebSearch) and the reason. For the tiering, contact, and email layers, name the delegated skill (icp-scoring, contact-resolver, email-verification) as the owner.

6. **Estimated pool size (all fit-qualified accounts)**. The pool includes every firmographic-qualified account that icp-scoring tiers A, B, or C, including Tier C accounts with zero active signals, which the previous signal-gated behavior dropped. In execute mode, sample the first few pages of the Search and extrapolate to an approximate floor, for example "~1,200+ (sampled 3 pages, hasMore=true)", noting Clay Search has no count endpoint. The tier split (how many A, B, and C) is only known after icp-scoring runs. In plan mode, state the method rather than a number.

7. **Enrichment routine order (cheapest-first)**. Order the Clay enrichment prospect-builder runs itself so cheap, high-coverage lookups fill firmographics and signals before the delegated calls run. Firmographics already returned by Search cost nothing extra; cheap company lookups fill gaps; signal routines run on every firmographic-qualified row, because signals are scoring inputs and are not gated. Confirm the exact per-item cost with `clay routines get <id>`. The expensive person-level work is not in this list; it is delegated in Layer 8 and gated on the tier icp-scoring returns.

8. **Delegation pipeline (scoring, contacts, email)**. After sourcing and signal enrichment, run each account through the delegated skills in order:
   a. Call **icp-scoring** with the account plus its enriched signals. It returns `tier` (A/B/C, or `skip`) and `recommended_persona`.
   b. **Assign the motion.** With no `--motion` override, read the Tier defaults from config/motions/ and tag `ab_motion` from the tier: Tier A and B get signal-based, Tier C gets nurture. With a `--motion` override (already validated against config/motions/), tag every row with that single motion. Either way this is a tag, not execution.
   c. For accounts tiered **A or B**, call **contact-resolver** with `company_domain` and `recommended_persona`. It returns one primary contact, the layer that landed it, and a confidence label. With `--enrich-all`, run this step for every tier, including Tier C.
   d. For each resolved contact, call **email-verification** with the contact's `email`, `email_status`, `email_domain_catchall`, and `company_domain`. It returns the verdict, confidence, and send recommendation.
   e. **Tier C accounts stay in the pool** with their firmographics, signals, and tier. By default they skip steps c and d (no contact or email spend); with `--enrich-all` they pass through the full pipeline like A and B, producing a fully enriched pool. Their downstream treatment is a motion decision, not a drop. Accounts icp-scoring tiers `skip` are recorded as skip and not advanced.
   prospect-builder passes inputs and aggregates outputs; it does not re-implement any of these three steps.

9. **Refresh cadence**: how often to rebuild each layer, keyed to how fast that data decays (firmographics slow, funding and news fast, contact emails fastest).

10. **Ownership map**: the namespace prefix pattern for any field this skill writes toward a CRM, so provenance is legible and fields do not collide. See the ownership section.

Close the plan with a compact machine-readable summary:

    {
      "source_type": "companies",
      "firmographic_filters": { "<clay_filter>": ["<value>"] },
      "exclusion_filters": { "<clay_filter>": ["<value>"] },
      "signal_filters": [
        { "signal": "<name>", "source": "Clay Routine | manual", "routine": "<real routine name or null>" }
      ],
      "persona_scope": { "job_title_keywords": ["<title>"], "seniority": ["<level>"] },
      "enrichment_order": ["<routine name in cheapest-first order>"],
      "delegated_invocations": {
        "icp_scoring": "<accounts scored, or 'plan mode: not run'>",
        "contact_resolver": "<tier A/B accounts resolved, or 'plan mode: not run'>",
        "email_verification": "<contacts verified, or 'plan mode: not run'>"
      },
      "data_source_map": [ { "layer": "<layer>", "primitive": "Search | Routine | Table | Apollo | WebSearch | icp-scoring | contact-resolver | email-verification", "why": "<reason>" } ],
      "estimated_pool": "<approx floor of fit-qualified accounts, or 'plan mode: method only'>",
      "tier_counts": { "A": "<n>", "B": "<n>", "C": "<n>", "skip": "<n>" },
      "total_pool": "<count of fit-qualified accounts A+B+C, or 'plan mode: method only'>",
      "refresh_cadence": { "firmographics": "<interval>", "signals": "<interval>", "contacts": "<interval>" },
      "ownership_prefix": "<prefix>",
      "fallbacks_used": ["<attribute -> Apollo | WebSearch, and why>"]
    }

In plan mode the `delegated_invocations`, `tier_counts`, and `total_pool` fields state "plan mode: not run"; they carry real counts only after an `--execute` run.

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
- **Tech in use**: `Website Technology Stack` is a routine, not a Search filter. Source the candidates, then run the routine; the result is a signal that feeds scoring, not a filter that drops rows.
- **Recent hiring / news**: `Company Job Openings` and `Company News` are routines. Source, then enrich; these are scoring inputs, not gates.

Always state in the data source map when an attribute is handled this way, and why.

## Execute pipeline (cheapest-first, then delegate)

Order the run so cheap Clay enrichment fills every account before the delegated, per-account calls spend anything. Confirm per-item cost with `clay routines get <id>` before each step; the tiers below are the ordering principle, not fixed prices.

1. **Free**: firmographics already on the Search rows (name, domain, size, industry, location, funding range). Use these to pre-filter obvious non-fits before spending anything.
2. **Cheap company lookups**: Company Domain, Company Industry, Company Employee Count, Enrich Company. Fill firmographic gaps.
3. **Signal routines**: Company Latest Funding, Company News, Company Job Openings, Website Technology Stack. Run on every firmographic-qualified row, because signals are scoring inputs and are not a gate.
4. **Delegate to icp-scoring** (per account): hand it the account plus its signals; record the `tier` and `recommended_persona` it returns.
5. **Delegate to contact-resolver** (tier A and B accounts only): hand it `company_domain` and `recommended_persona`; record the primary contact.
6. **Delegate to email-verification** (each resolved contact): hand it the contact's email fields; record the verdict.
7. **Aggregate** every account into the CSV.

The gate for the expensive person-level work is the tier icp-scoring returns (A or B), not an inline signal or skip computation. Tier C accounts are kept in the pool with firmographics, signals, and tier, and simply skip the contact and email steps. This spends contact and email credits only on the accounts worth reaching now, while keeping the full fit-qualified pool visible for the downstream motion decision.

## Persistence (execute mode)

The Clay plugin cannot write rows into a Clay table (the table surface is read-only via CLI, MCP, and the Public API). So prospect-builder persists like this:

- **Default: CSV.** Write the aggregated audience to a local CSV with columns for firmographics, each signal, the tier from icp-scoring, the intended motion (`ab_motion`), the resolved contact (tier A/B rows), and the email-verification verdict. Tell the user how to import it in the Clay app (New table, then CSV import) if they want it in Clay.
- **Optional: webhook write-back.** If the user passes `--webhook-url <url>` for a Clay table configured with an inbound webhook source, POST the rows to that URL as well. This is the one supported write path into a Clay table, and it requires the user to have set up the webhook-source column in the Clay app first.

Reading from existing audience tables is fully supported (`clay tables` and the `table` MCP tool); only writing is constrained. State this limitation in the output rather than implying a write happened when it did not.

## Ownership map

Namespace every field this skill contributes toward a CRM with a stable prefix, so provenance is legible and prospect-builder fields never collide with native CRM or other-tool fields. Default prefix: `ab_`.

The `ab_` prefix is a legacy artifact of this skill's original name (audience-builder). It is kept unchanged for backwards compatibility with existing CSVs and CRM fields, so the field names below did not change when the skill was renamed.

- `ab_source` (which Clay primitive or fallback produced the row)
- `ab_pool` (the audience/pool label this row belongs to)
- `ab_signal_*` (one field per signal, for example `ab_signal_funding`, `ab_signal_hiring`)
- `ab_tier` (the tier icp-scoring returned: A, B, C, or skip)
- `ab_motion` (the intended outreach motion for the row: the tier-default motion when no override is set, or the `--motion` override when one is)
- `ab_enriched_at` (date of last enrichment, for the refresh cadence)

The resolved contact and the email-verification verdict travel in their own columns, sourced from the delegated skills rather than produced here. This is a naming convention for output, not a CRM write. Consistent with the stack's CRM doctrine, prospect-builder never writes to a CRM automatically; it produces a labeled package the user reviews and loads.

## Fallbacks

Clay first. When Clay does not cover a firmographic filter or a signal enrichment well:

1. **Apollo MCP** for firmographic filters Clay Search lacks (some intent and technographic cuts, certain size or revenue slices). Note in the data source map that Apollo produced the layer and why.
2. **WebSearch** only as a last resort, for a niche attribute neither Clay nor Apollo has. Every fact WebSearch produces about a company carries its source, per the stack's citation rule.

Name every fallback in `fallbacks_used`. Silent substitution hides where the data came from. The tiering, contact, and email layers are delegated, not a fallback: they always route to icp-scoring, contact-resolver, and email-verification, which own their own providers.

## Credit discipline (execute mode)

Before spending, check cost and balance:

```bash
clay routines get <id>          # read estimatedCreditCost.perRun
clay credits                    # read balance
```

Multiply per-item cost by the number of rows the step will run on. If the estimated total exceeds the balance, stop and report it rather than starting a run that only partially completes. Run the signal routines on the firmographic-qualified pool, then let the tier from icp-scoring gate the delegated contact and email work: contact-resolver and email-verification spend on their own providers (Apollo by default), so restricting them to tier A and B accounts keeps that spend on the accounts worth reaching now.

## Quality rules

- No em dashes. No clichés, no marketing jargon (no "unlock", "leverage", "seamless", "best-in-class", "AI-powered", and the rest of the banned list in CLAUDE.md).
- Every filter recommendation includes its reasoning.
- Every enrichment step includes a credit-cost consideration.
- Never invent a Clay function name. Run `clay routines list` and match a real one.
- Do not re-implement scoring, contact discovery, or email logic. Delegate to icp-scoring, contact-resolver, and email-verification.
- Signals are scoring inputs, never gates. Every firmographic-qualified account reaches icp-scoring and gets a tier.
- Note explicitly, in the data source map, when Clay cannot cover a layer and Apollo or WebSearch is standing in, and why.
