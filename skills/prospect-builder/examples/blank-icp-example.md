# Example: thin ICP input

Sometimes the input is barely an ICP: "SaaS companies with a sales team, mid-size." No CRM,
no size precision, no exclusions. This shows the thin-input path: name the gaps, ask at most
one or two sharp questions, and build a plan that is honest about what it is guessing.

## Input

- **ICP description**: "B2B SaaS companies with a sales team, mid-size."
- No CRM named, no size precision, no exclusions.
- Offer: the offering in config/offering.md (Recap AI).

## Do not pad the gaps

A thin ICP has two missing dimensions that change the pool a lot: what counts as "mid-size,"
and which CRM the target runs (Recap AI integrates with HubSpot and Salesforce, so the CRM is
a real qualifier). The buyer persona is not a gap here, because config/personas.md already
defines the buying committee for this offer. Guessing the size and CRM silently produces a
confident but wrong audience. Two moves instead:

1. Name the gaps in the plan.
2. Ask one or two questions that most change the pool, then proceed.

### The one or two questions worth asking

- **CRM**: "Do your best-fit customers run HubSpot or Salesforce, or does it not matter for you?" Reason: the offer's integration depth makes CRM a qualifier, not a nice-to-have.
- **Size precision**: "Mid-size can mean 50 to 200 or 200 to 1000. Which end?" Reason: it swings the pool size by an order of magnitude.

Do not ask about exclusions up front; those refine, they do not block. The buyer persona comes
from config/personas.md, so it does not need a question. Build without exclusions and note they
would sharpen the result.

## The plan (built with gaps named)

### 1. Firmographic filters (Clay Search, `--source-type companies`)

    {
      "industries": ["Software Development", "Technology, Information and Internet"],
      "minimum_member_count": 50,
      "maximum_member_count": 500,
      "country_names": ["United States", "Canada"]
    }

- `industries`: the B2B SaaS lane for the offer. Reason: right lane; confirm the exact allowed values against the fields output.
- `minimum_member_count: 50` / `maximum_member_count: 500`: a placeholder for "mid-size," flagged as a guess pending the size question. Reason: gap named, not hidden.
- `country_names: United States, Canada`: the offer's default geography for English-primary sales conversations. Reason: sensible default, stated as one.

### 2. Signal filters

None specified in the input, but the offer defines its buying signals in config/offering.md. Default to the two cheapest that map to a scaling sales team, and note they are defaults:

- Recent funding -> **Clay Routine**: Company Latest Funding.
- Hiring for sales roles -> **Clay Routine**: Company Job Openings.

State that confirming CRM and outbound motion would sharpen the pool once the CRM question is answered.

### 3. Persona scope

Not a gap. Use the buying committee in config/personas.md (VP Sales, CRO, Head of RevOps, and the rest of the priority list). Reason: the offer's buyer is defined in config, so the people search does not need a question here, unlike the size and CRM gaps.

### 4. Exclusion filters

None given. Note that without exclusions the pool will include agencies, inbound-only companies, and companies already running an entrenched rev intel tool, which the offer's ICP excludes. Offer to add `industries_exclude` and the post-source sales-motion check once the user confirms the CRM and size answers.

### 5. Data source map

| Layer | Primitive | Why |
| --- | --- | --- |
| Industry, geo, size | Clay Search | Native filters |
| Funding, hiring | Clay Routine (Company Latest Funding, Company Job Openings) | Not Search filters |
| CRM confirmation | Clay Routine (Website Technology Stack) | Pending the CRM answer; not a Search filter |
| Buyer contacts | Clay Search people | Persona from config/personas.md |

If the industry enum proves too coarse, note Apollo MCP as a fallback for a tighter cut, and say why in the map.

### 6. Estimated pool size

Plan mode: method only. Flag that with `sizes` and the CRM unresolved, any pool estimate is provisional until those two answers land.

### 7. Enrichment order (cheapest-first)

1. Firmographics on the Search rows (free) -> pre-filter obvious non-fits.
2. Enrich Company, Company Employee Count (cheap) -> confirm size and sales-team size.
3. Company Latest Funding, Company Job Openings, Website Technology Stack (signals) -> qualified rows only; the tech stack routine also answers the CRM question.
4. Find People at Company -> qualified companies only, scoped to the config personas.
5. Contact and email routines -> last, qualified people only.

### 8. Refresh cadence

- Firmographics: quarterly.
- Funding and hiring: weekly.
- Contacts: re-verify near send.

Same decay logic as any pool; nothing about the thin input changes how fast the data ages.

### 9. Ownership map

Prefix `ab_`: `ab_source`, `ab_pool` = `saas_sales_teams_midsize`, `ab_signal_funding`, `ab_signal_hiring`, `ab_enriched_at`.

## What this example demonstrates

The plan is buildable from a thin ICP, but it is honest: the size band and CRM are flagged as
unresolved, and the missing exclusions are named as things that would sharpen the result. The
buyer persona is not a gap, because config/personas.md already defines it, which is exactly the
point of keeping the ICP content in config rather than in the input. A confident plan over a
thin input is worse than a plan that shows its gaps.
