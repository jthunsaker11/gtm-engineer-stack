# Clay integration pattern

How this stack uses the Clay Agent Plugin: the primitives, when to reach for each, and the real method and function names. The `prospect-builder` skill is the primary consumer; this doc is the reference it points to.

Everything here is grounded in the plugin's own skill docs and a live `clay routines list` / `clay search filters-mode fields` against the workspace. Do not add a method or function name to this doc that you have not confirmed against the CLI.

## The three primitives

Clay exposes three things this stack uses. Pick by what you are doing.

| Primitive | Use it to | Surface |
| --- | --- | --- |
| **Search** | Find accounts and people from Clay's dataset using structured filters (source TAM) | `clay search filters-mode ...` |
| **Routines** | Run a saved function or workflow to enrich or act on records (emails, phones, firmographics, funding, news, hiring) | `clay routines ...` |
| **Tables** | Read data out of an existing Clay table | `clay tables ...`, `table` MCP tool |

Search finds. Routines enrich. Tables hold. A normal audience build is Search, then Routines on the results, then a Table read if a persistent list already exists.

## Two Clay MCP surfaces: do not mix them

The environment can show two Clay connections. They are different products.

- **The plugin** (`plugin:clay`, the `clay` CLI plus MCP tools like `table`, `read`, `edit_node`): the full-access surface for building and running Clay from a coding agent. This is what the stack uses.
- **The reps product** (a separate connection providing `list_subroutines`, `run_subroutine`, `find-and-enrich-contacts-at-company`, and similar): built for reps prospecting in a chat UI. Not part of the plugin.

Use the plugin. For discovery, that means `clay routines list`, not the reps product's `list_subroutines`. The two share a workspace but are not interchangeable, and mixing them is a documented mistake.

## Search: sourcing TAM

A search is a forward-only iterator: discover filters, create the search, then page.

```bash
# 1. Discover the real filters for the source type (authoritative; do not assume filter names)
clay search filters-mode fields --source-type companies
clay search filters-mode fields --source-type people

# 2. Create a search from structured filters; returns { "searchId": "search_..." }
clay search filters-mode create --source-type companies \
  --filters '{"industries":["Software Development"],"country_names":["United States"]}'

# 3. Page. Repeat the run call while the page reports "hasMore": true
clay search filters-mode run search_abc123 --limit 50
```

Two constraints that shape every plan:

- **No count endpoint.** There is no "how many match" call. Estimate pool size by sampling the first pages and reporting an approximate floor with `hasMore`, or page fully for an exact number. The stack default is sample-and-extrapolate with an explicit "approximate" note.
- **Filters are a fixed set.** Only the fields from `filters-mode fields` work. Anything outside that set (funding stage, tech in use, recent hiring) is not a search filter. Source on the closest native filter, then enrich for the real attribute with a routine.

### Attributes that are not native Search filters

| ICP attribute | Native filter? | Handle it with |
| --- | --- | --- |
| Funding stage (Series A/B/C) | No | `funding_amounts` band to approximate. No Clay routine confirms the round: **Company Latest Funding** returns an amount only. For the exact round use Apollo `apollo_organizations_enrich`, whose `latest_funding_stage` carries it (1 Apollo credit per account). |
| Tech in use | No | **Website Technology Stack** routine on the candidate set |
| Recent hiring | No | **Company Job Openings** routine |
| Recent news / events | No | **Company News** routine |
| Exact revenue | Range only (`annual_revenues`) | **Company Revenue (Exact)** routine for a precise figure |

## Routines: enrichment and actions

A routine is a runnable saved function or workflow. Discover before you run; never assume an id or invent a name.

```bash
clay routines list                 # every routine in the workspace, with id, name, source
clay routines get <id>             # input schema and estimatedCreditCost
clay routines runs start <id>      # start an async run over 1 to 100 items (see --help)
clay routines runs get <run-id>    # poll for results
```

Function routine ids look like `function:<tableId>` and are workspace-specific. Reference routines by name in prompts and skills, and resolve the id at runtime from `clay routines list`. This keeps the stack portable across cloned workspaces, where the ids differ but the Clay-managed function names are stable.

### Clay-managed functions available in this workspace

Confirmed via `clay routines list`. All are `source: managed` (Clay defaults, present in any workspace). A cloned workspace may also have `custom` functions and workflows; always re-run `list` to pick those up.

**Company-level**

- Company Domain (name to website domain; the prerequisite for most company enrichments)
- Company Industry
- Company Address
- Company Employee Count
- Company Job Openings (hiring signal)
- Company News (news and events signal)
- Company Latest Funding (amount only: returns a single `Latest Funding` value, no round type and no date, so it cannot confirm a stage)
- Company Revenue (Exact)
- Enrich Company (firmographic bundle from domain or LinkedIn)
- Website Technology Stack
- Website Traffic

**Person-level**

- Find People at Company (persona-scoped people discovery)
- Enrich Person
- Person Job Title
- Person Full Name
- Person Location
- Enrich Person and Find Contact Details (verified contact data)
- Work Email

### Cost before you run

Two budgets: data credits (`balance`) and, on some plans, action executions (`actionExecutionBalance`).

```bash
clay routines get <id>   # read estimatedCreditCost.perRun
clay credits             # read balance and actionExecutionBalance
```

Multiply per-item cost by row count. If the total exceeds the matching balance, stop rather than starting a run that half-completes. This is why the audience waterfall runs cheapest-first and gates expensive person and email routines behind qualification: you spend email credits only on rows that will survive `icp-scoring`.

## Tables: read-only through the plugin

The plugin can read tables but cannot write them. This is a hard limitation to design around, not a bug.

- **Supported**: list tables, read schema, query, export to CSV. Surfaces: `clay tables list | get | rows | query` and the `table` MCP tool (`mode: "schema"` and `mode: "query"`).
- **Not supported**: creating a table, inserting rows, updating cells. Not via the CLI, the MCP tool, or the Public API. Rows enter a table only through the Clay app (CSV import, or a source column such as an inbound webhook).

```bash
clay tables list                       # ids, names, queryEnabled flag
clay tables update <id> --query-enabled true   # enable querying (Enterprise; toggles read, not write)
```

`clay tables query` needs API table sync (Enterprise). Without it, use the `table` MCP tool for reads, which works on any accessible table.

### Persisting an audience

Because there is no table write API, `prospect-builder` persists two ways:

1. **CSV (default)**: write the enriched audience locally, and give the user the Clay-app import steps if they want it in a table.
2. **Webhook write-back (optional)**: if the user has configured a Clay table with an inbound webhook source and passes its URL, POST the rows to that URL. This is the one supported path into a Clay table, and it depends on app-side setup the user does first.

State which path ran. Do not imply a table write happened when only a CSV was produced.

## Fallback order

Clay is primary. When it does not cover a layer:

1. **Apollo MCP** for firmographic or technographic filters Clay Search lacks. Note it in the data source map.
2. **WebSearch** only as a last resort, for a niche attribute neither Clay nor Apollo has. Every company fact from WebSearch carries its source, per the stack citation rule in CLAUDE.md.

Name every fallback and the reason. Silent substitution hides provenance, which the ownership map is meant to preserve.

## Authoritative references

- Plugin skill docs: `clay/skills/{search,routines,tables}/SKILL.md` in the plugin cache.
- CLI help is a machine-readable spec: `clay <command> --help`.
- Clay developer docs: https://developers.clay.com/llms.txt
