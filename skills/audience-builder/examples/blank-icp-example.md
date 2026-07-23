# Example: thin ICP input

Sometimes the input is barely an ICP: "fintech companies in New York, mid-size." No stage, no buyer, no exclusions, no offer. This shows the thin-input path: name the gaps, ask at most one or two sharp questions, and build a plan that is honest about what it is guessing.

## Input

- **ICP description**: "fintech companies in NYC, mid-size."
- No closed-won seed, no exclusions, no offer.

## Do not pad the gaps

A thin ICP has three missing dimensions that change the pool a lot: buying stage, the buyer persona, and what counts as "mid-size." Guessing them silently produces a confident but wrong audience. Two moves instead:

1. Name the gaps in the plan.
2. Ask one or two questions that most change the pool, then proceed.

### The one or two questions worth asking

- **Buyer persona**: "Who are you selling to at these companies (founder, VP Sales, Head of Growth, RevOps)?" Reason: this sets the entire people-search scope, and there is no safe default.
- **Stage or size precision**: "Mid-size can mean 50 to 200 or 200 to 1000. Which end?" Reason: it swings the pool size by an order of magnitude.

Do not ask about exclusions or offer up front; those refine, they do not block. Build without them and note they would sharpen the result.

## The plan (built with gaps named)

### 1. Firmographic filters (Clay Search, `--source-type companies`)

    {
      "industries": ["Financial Services"],
      "location_cities_include": ["New York"],
      "location_headquarters_only": true,
      "description_keywords": ["fintech"],
      "sizes": ["51-200", "201-500"]
    }

- `industries: Financial Services`: Clay has no literal "Fintech" industry, so this is the closest enum. Reason: coarse but the right lane. Confirm the fields output for the exact allowed value.
- `description_keywords: fintech`: narrows Financial Services (which includes banks and insurers) toward actual fintech. Reason: the enum alone is too broad.
- `location_cities_include: New York` + `location_headquarters_only`: NYC-HQ only. Reason: geography.
- `sizes: 51-200, 201-500`: a placeholder for "mid-size", flagged as a guess pending the size question. Reason: gap named, not hidden.

### 2. Signal filters

None specified in the input. Default to two broad, cheap signals so the pool is not blind, and note they are defaults:

- Recent funding -> **Clay Routine**: Company Latest Funding.
- Recent news -> **Clay Routine**: Company News.

No offer was given, so signals are unweighted. State that a provided offer would let the skill rank signals.

### 3. Persona scope

Blocked pending the buyer question. Do not guess a persona; the people search is only as good as this input. If the user declines to answer, default to founder and head-of-revenue titles and label the scope as assumed.

### 4. Exclusion filters

None given. Note that without exclusions, the pool will include incumbents and non-target subsectors (payments infra, crypto, insurtech) that the user may not want. Offer to add `description_keywords_exclude` or `industries_exclude` once they name what to drop.

### 5. Data source map

| Layer | Primitive | Why |
| --- | --- | --- |
| Industry, geo, size | Clay Search | Native filters |
| Fintech narrowing | Clay Search (`description_keywords`) | No native fintech industry value |
| Funding, news | Clay Routine (Company Latest Funding, Company News) | Not search filters |
| Buyer contacts | Clay Search people | Pending persona answer |

If Financial Services proves too coarse even with the keyword, note Apollo MCP as a fallback for a tighter fintech cut, and say why in the map.

### 6. Estimated pool size

Plan mode: method only. Flag that with `sizes` and persona unresolved, any pool estimate is provisional until those two answers land.

### 7. Enrichment order (cheapest-first)

1. Firmographics on the Search rows (free) -> pre-filter obvious non-fintech.
2. Enrich Company, Company Industry (cheap) -> confirm the fintech classification the keyword only approximates.
3. Company Latest Funding, Company News (signals) -> qualified rows only.
4. Find People at Company -> blocked until the persona is set.
5. Contact and email routines -> last, qualified people only.

### 8. Refresh cadence

- Firmographics: quarterly.
- Funding and news: weekly.
- Contacts: re-verify near send.

Same decay logic as any pool; nothing about the thin input changes how fast the data ages.

### 9. Ownership map

Prefix `ab_`: `ab_source`, `ab_pool` = `nyc_fintech_midsize`, `ab_signal_funding`, `ab_signal_news`, `ab_enriched_at`.

## What this example demonstrates

The plan is buildable from a thin ICP, but it is honest: the size band and persona are flagged as unresolved, the fintech industry mapping is flagged as approximate, and the missing offer and exclusions are named as things that would sharpen the result. A confident plan over a thin input is worse than a plan that shows its gaps.
