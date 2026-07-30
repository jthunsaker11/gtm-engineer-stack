# Claygent column: sales-motion buying-signal check

A step-by-step guide to building the Claygent web-research column that `prospect-builder` uses to confirm a company runs an outbound sales motion worth prospecting. This is the one piece of `prospect-builder --execute` that lives in the Clay app rather than the CLI, so it has to be set up by hand once per workspace.

## Why this column exists

The [prospect-builder](../../skills/prospect-builder/SKILL.md) skill sources a wide, cheap pool of B2B SaaS companies from Clay Search, then qualifies each account against the signals that matter for the offer. Its single most important qualifier, "runs a real outbound sales motion we can sell into," has no native Clay Search filter and no CLI-runnable routine. Clay Search filters on firmographics; the managed routines cover funding, news, hiring, and contact data, but none of them read a company's careers page or sales-tooling footprint to judge whether there is a staffed sales team on a CRM we integrate with.

Claygent is Clay's AI web-research agent. It runs as a column type inside a Clay table, visits the pages you point it at, and returns a structured answer. That is exactly the shape of this check: read the careers page, the team page, and public sales-tooling signals, decide whether there is evidence of an outbound sales motion on HubSpot or Salesforce, and write the verdict back to the row.

Because Claygent is a table column and the Clay plugin cannot write rows into a table from the CLI, `prospect-builder` reaches it through the one supported write path: an inbound webhook source column. The skill POSTs the qualified pool to the webhook, Claygent runs on each new row app-side, and the skill reads the verdicts back with `clay tables`.

## Plan requirements: this column is a Growth+ upgrade, not a baseline

Inbound webhook sources require Clay's **Growth plan or higher**. Claygent web-research columns sit behind the same paid tier. So the entire app-side path this guide describes (webhook source, Claygent column, POST-and-read-back) is only available once your workspace is on Growth or above.

**You do not need any of that to run `prospect-builder --execute`.** The `--execute` path works out of the box on the **Launch plan** by using the WebSearch fallback for the buying-signal check. WebSearch runs the same qualification logic from the CLI, one account at a time, and reports its verdict in the run output with a citation. No webhook, no Claygent, no table write. This is the default path when you run `--execute` without `--webhook-url`.

Position this Claygent column as the **upgrade path**: once you are on Growth or higher, the app-side column runs the buying-signal check on the whole pool in parallel, persists each verdict in a Clay table, and lets you read the results back with `clay tables`. It is faster and it keeps the verdict in Clay. The trade-offs against the built-in WebSearch fallback:

| | WebSearch fallback (Launch plan, out of the box) | Claygent column (Growth+ upgrade) |
| --- | --- | --- |
| Plan needed | Launch | Growth or higher (webhook + Claygent) |
| Setup | None | This guide, once per workspace |
| Speed | One account at a time, from the CLI | Whole pool in parallel, app-side |
| Verdict persisted in Clay | No | Yes, in the table |
| Read back with `clay tables` | Not applicable | Yes |

Plan mode needs none of this; the setup here is only required before you run `--execute` on Growth+ and want the app-side check instead of the WebSearch fallback.

## Prerequisites

- A Clay workspace, with the `clay` CLI and the Clay Agent Plugin installed and authenticated in Claude Code. Confirm with `clay whoami`.
- A Clay plan that includes **Claygent** and **webhook sources**. Both require the **Growth plan or higher** (see [Plan requirements](#plan-requirements-this-column-is-a-growth-upgrade-not-a-baseline) above). On the Launch plan, skip this whole guide and use the built-in WebSearch fallback, which `prospect-builder --execute` uses by default. Check your plan in the Clay app under Settings, Billing.
- To read verdicts back with `clay tables query`, a plan with **API table sync** (Enterprise). Without it, read back with the `table` MCP tool or a CSV export instead. Both alternatives are covered below.
- Claygent consumes credits per run. Confirm your credit balance with `clay credits` before running it across a pool.

## Step by step (Clay app)

### 1. Create the table

1. In the Clay app, click **New table**, then **Start from scratch** (an empty table, not a Search or import).
2. Name it something legible and stable, for example `audience-sales-motion`. `prospect-builder` does not depend on the table name; you pass the webhook URL, not the name.

### 2. Add the inbound webhook source column

This is how rows enter the table. It must exist before `prospect-builder` can POST to it.

1. Click **Add source** (or the **+** at the top of the table), then choose **Webhook** (listed under "Import" or "Monitor for new data," depending on your Clay version).
2. Clay generates a unique **webhook URL** for this table. Copy it and keep it safe; it is the value you pass as `--webhook-url`.
3. Clay asks for a sample payload so it can create one column per field. Paste the sample payload from the [webhook payload schema](#webhook-payload-schema) section below. Clay reads the keys and creates matching columns (`company_name`, `company_domain`, and the rest).
4. Save the source. The table now has a column for every field in the payload. The one Claygent needs is `company_domain`.

If your Clay version does not accept a pasted sample, send one test row first with the `curl` command in [Testing](#testing), then map the fields Clay detects.

### 3. Add the Claygent column

1. Click **Add column**, then choose **Claygent** (sometimes shown as "AI Web Research" or "Use AI").
2. Pick the **Navigator** variant if your workspace offers named Claygent tiers. Navigator is the web-browsing agent that can visit and read pages, which is what this check needs. If you only see a single Claygent option, use it.
3. Name the column `ab_signal_sales_motion` so it matches the ownership-map field `prospect-builder` expects to read back.
4. Paste the [Claygent prompt](#claygent-prompt) below into the column's prompt box.
5. In the prompt, reference the domain column with Clay's `/` field-insert. Type `/` and pick `company_domain` so the prompt receives the row's real domain at run time.
6. Set the output to **structured** if the option is offered, with fields `verdict`, `evidence`, and `source_url` (see the prompt). If only free text is available, the prompt still instructs Claygent to return those three as labeled lines.
7. Set the column to run automatically on new rows (the default for a Claygent column fed by a source). This is what makes it fire when the webhook adds a row.

### 4. Confirm the run gate

Open the Claygent column settings and check that its run condition is "run on new rows" or unconditional. If it is gated on another column being non-empty, make sure that column is present in the webhook payload, or the column will never fire. The common failure is a run gate pointing at a field the payload does not send.

## Claygent prompt

Paste this into the Claygent column. Replace the `/company_domain` token by inserting the real field with Clay's `/` picker so the domain is substituted per row.

```
You are researching whether the company at /company_domain runs an outbound B2B sales
motion with a real, staffed sales team, the kind of company that buys conversation-
intelligence software.

Check these sources in order and stop once you have a confident answer:
1. The company careers or jobs page (try careers, jobs, <domain>/careers,
   <domain>/jobs, and their LinkedIn Jobs). Look for open or recent roles like
   Account Executive, SDR/BDR, Sales Manager, VP Sales, or Head of RevOps. Several
   sales reqs at once is strong evidence of a scaling sales team.
2. The company team, about, or leadership page. Look for a named VP Sales, CRO,
   Head of Revenue, or Head of RevOps, and any sign of a sales org versus a purely
   self-serve or founder-led motion.
3. Public sales-tooling and CRM signals (job descriptions that name the CRM,
   integration marketplaces, case studies). Look for HubSpot or Salesforce as the
   CRM, and for any existing rev-intel tool already in place (Gong, Chorus, Fathom,
   Fireflies) and how long it has been deployed.

Weigh an active outbound motion over an inbound-only one. A staffed sales team on
HubSpot or Salesforce with open AE or SDR roles counts as qualified. A purely
self-serve product with no sales reqs, a single-founder pre-revenue shop, or a company
already running an entrenched rev-intel tool for more than a year does not.

Return exactly three labeled lines:
verdict: one of qualified, entrenched, no_sales_motion, unclear
evidence: one sentence naming the specific thing you found
source_url: the single URL that best supports the verdict, or none

Do not guess. If you cannot find evidence after checking the three sources, return
verdict: unclear with source_url: none. Every verdict except unclear must carry a real
source_url that a person can open and verify.
```

The `verdict` values map cleanly onto the audience gate: `qualified` proceeds, `entrenched` (a rev-intel tool already deployed over 12 months) and `no_sales_motion` (inbound-only or no sales team) disqualify per the ICP exclusions, and `unclear` routes to a manual WebSearch double-check.

## Webhook payload schema

`prospect-builder --execute` POSTs one JSON object per qualified account to the webhook URL. This is the contract the webhook source column must accept. Field names use the `ab_` ownership prefix for fields the skill contributes, and plain names for firmographics that came straight off the Clay Search row.

Sample payload (paste this into Clay's webhook sample box in step 2):

```json
{
  "company_name": "Example SaaS Inc",
  "company_domain": "example.com",
  "company_linkedin_url": "https://www.linkedin.com/company/example",
  "ab_pool": "b2b-saas-sales-teams-2026q3",
  "ab_source": "clay-search",
  "ab_lookalike_path": "clay-dna",
  "employee_count": 180,
  "industry": "Software Development",
  "country": "United States",
  "ab_signal_hiring": "4 open AE reqs and 1 Head of RevOps role",
  "ab_signal_funding": "Series B, 2025-11, $30M",
  "ab_signal_news": "Announced entry into the enterprise segment, 2026-05",
  "ab_sales_team_size_est": 45,
  "ab_crm": "HubSpot",
  "ab_enriched_at": "2026-07-23"
}
```

Field reference:

| Field | Type | Source | Why it is in the payload |
| --- | --- | --- | --- |
| `company_name` | string | Clay Search | Human-readable label. |
| `company_domain` | string | Clay Search | The input Claygent researches. Required. |
| `company_linkedin_url` | string | Clay Search | Secondary identifier and dedup key. |
| `ab_pool` | string | prospect-builder | The pool label this row belongs to. |
| `ab_source` | string | prospect-builder | Which primitive produced the row (`clay-search`, `apollo`). |
| `ab_lookalike_path` | string | prospect-builder | `clay-dna` or `apollo`, the lookalike path that surfaced the row. |
| `employee_count` | number | Clay Search or Company Employee Count | Firmographic context for the reviewer. |
| `industry` | string | Clay Search | Firmographic context. |
| `country` | string | Clay Search | Firmographic context. |
| `ab_signal_hiring` | string | Company Job Openings | The hiring signal that qualified this row (open sales reqs). |
| `ab_signal_funding` | string | Company Latest Funding | The funding signal. |
| `ab_signal_news` | string | Company News | The news signal. |
| `ab_sales_team_size_est` | number | Company Employee Count + Job Openings | Estimated sales-team size, the real 10-to-100-reps bar. |
| `ab_crm` | string | Website Technology Stack or careers-page signal | Which CRM the company runs (HubSpot or Salesforce qualifies). |
| `ab_enriched_at` | string (date) | prospect-builder | Last enrichment date, for refresh cadence. |

Only `company_domain` is strictly required for Claygent to run. The rest travel so the verdict lands on a row that already carries its qualifying context, which is what you read back.

Claygent writes its result into `ab_signal_sales_motion` (and, if you configured structured output, the `verdict`, `evidence`, and `source_url` subfields). `prospect-builder` does not send that field; Claygent produces it.

## Get the webhook URL and pass it to prospect-builder

1. The webhook URL is the one Clay generated in step 2. To find it again later, open the table, click the webhook source column header, and copy the URL from its settings.
2. Pass it on the execute invocation:

```
/prospect-builder <your ICP> --execute --webhook-url https://api.clay.com/v3/sources/webhook/pull-in-data-from-a-webhook-xxxxxxxx
```

`prospect-builder` sources and enriches the pool, then POSTs each qualified account to that URL. It reports how many rows it posted and reminds you that Claygent runs app-side, so verdicts appear in the table a short time after the POST, not instantly.

## Read Claygent results back

After Claygent has run on the posted rows, read the verdicts back with the CLI.

```bash
# 1. Find the table id
clay tables list

# 2a. If you have API table sync (Enterprise), enable query once, then query
clay tables update <tableId> --query-enabled true
clay tables query <tableId> --filter '{"ab_signal_sales_motion":{"verdict":"qualified"}}'
```

If you do not have API table sync, read back one of these two ways instead:

- **`table` MCP tool**: call it with `mode: "query"` on the table id. This works on any accessible table without the Enterprise sync toggle.
- **CSV export**: in the Clay app, export the table to CSV and hand the file to `prospect-builder` or load it directly.

Filter the read-back to `verdict: qualified` to get the accounts that cleared the sales-motion gate. Those are the rows that proceed to people discovery and email enrichment in the audience waterfall. Everything else (`entrenched`, `no_sales_motion`) stops before you spend contact and email credits on it, and `unclear` gets a manual WebSearch check.

## Testing

Before running a full pool through the webhook, prove the path end to end with one row.

1. **Post a test row.** Replace the URL with your webhook URL:

```bash
curl -X POST 'https://api.clay.com/v3/sources/webhook/pull-in-data-from-a-webhook-xxxxxxxx' \
  -H 'Content-Type: application/json' \
  -d '{
    "company_name": "LaunchDarkly",
    "company_domain": "launchdarkly.com",
    "company_linkedin_url": "https://www.linkedin.com/company/launchdarkly",
    "ab_pool": "test",
    "ab_source": "manual-test",
    "ab_sales_team_size_est": 0,
    "ab_enriched_at": "2026-07-23"
  }'
```

2. **Verify the row landed.** Open the table in the Clay app. A new row with `company_domain: launchdarkly.com` should appear within a few seconds.
3. **Verify Claygent ran.** Watch the `ab_signal_sales_motion` column on that row. It moves from empty to running to a verdict. For a company with a large, public sales org you expect a clear `qualified` verdict with a real `source_url`, which confirms the prompt and the field wiring both work.
4. **Verify read-back.** Run `clay tables list`, find the table id, then read the row back with `clay tables query` (or the `table` MCP tool). Confirm the verdict you saw in the app is what the CLI returns. Once this round-trip works, the path is ready for a real pool.

Use a domain you know runs a large outbound sales team for the test so a `qualified` verdict is the expected, checkable outcome.

## Troubleshooting

**The Claygent column does not fire on new rows.**
The run gate is the usual cause. Open the column settings and confirm it runs on new rows unconditionally, or that any field its run condition points at is present in the webhook payload. A gate on a field the payload does not send leaves the column permanently empty. Also confirm you have Claygent credits (`clay credits`); a zero balance stops runs silently.

**The webhook returns an error or the row never appears.**
Check three things. First, the URL is exact and complete, including the token at the end. Second, the request sets `Content-Type: application/json` and the body is valid JSON (run it through a JSON validator). Third, the payload keys match the columns Clay created from the sample; a key the table has no column for is dropped, and a completely unrecognized payload can be rejected. Re-send the sample payload to Clay's webhook config if the schema drifted.

**Rows land but results do not write back to the column.**
The verdict lives in the table, but your CLI read is not seeing it. If `clay tables query` errors on sync, you do not have API table sync enabled; enable it with `clay tables update <id> --query-enabled true` on Enterprise, or fall back to the `table` MCP tool or a CSV export. Also confirm you are querying the right table id from `clay tables list`, not the id of a different table.

**Claygent returns `unclear` on most rows.**
Either the prompt is not receiving the domain (confirm you inserted `company_domain` with the `/` picker rather than typing the literal text `/company_domain`), or the companies genuinely lack public evidence. Spot-check one row's domain by hand. If the domain is arriving correctly and the company has a known sales org, tighten the prompt's source list to the specific careers or team path that company uses.

**Everything works in the app but prospect-builder posted zero rows.**
That is an prospect-builder qualification result, not a webhook problem. It means no account cleared the firmographic and signal gates that run before the POST. Widen the Layer 1 filters or lower the `minimum_member_count` floor and re-run, or run in plan mode to inspect the pool size first.
