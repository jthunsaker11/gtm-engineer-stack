# Example: lookalike expansion from closed-won customers

This walks the skill through a full input with a lookalike seed. Plan mode, so no Clay calls run; the plan is what the user reviews before executing.

## Input

- **ICP description**: B2B SaaS companies, Series B, 50 to 300 employees, US-based, running an outbound sales motion.
- **Closed-won examples (seed)**: Apollo, Clay, Outreach, Gong.
- **Exclusions**: no agencies, no companies under 50 employees, no APAC HQ.
- **Offer**: GTM engineering, agentic outbound and lifecycle systems for revenue teams.

## How the seed is used

The four named customers are a lookalike seed, not filters. Two ways to expand from them in Clay:

- Enrich each seed with **Enrich Company** to read its real firmographics (industry label, size, funding, tech), then set the Search filters to the center of that cluster rather than to the ICP prose. The seed grounds the numbers.
- Feed the seed domains into Clay Search as an include-identifier reference where the workspace supports lookalike sourcing, and treat the ICP prose as the guardrail.

Reason: closed-won firmographics are a sharper target than a written ICP, because they are where the offer already landed.

## The plan

### 1. Firmographic filters (Clay Search, `--source-type companies`)

    {
      "industries": ["Software Development"],
      "sizes": ["51-200", "201-500"],
      "country_names": ["United States"],
      "location_headquarters_only": true,
      "funding_amounts": ["25m_50m", "50m_100m"]
    }

- `industries: Software Development`: the seed companies all classify here; keeps the pool in B2B SaaS. Reason: matches the closed-won cluster.
- `sizes: 51-200, 201-500`: brackets the 50 to 300 headcount band the enum can express. Reason: ICP size range.
- `country_names: United States` + `location_headquarters_only`: US HQ only, so subsidiaries of foreign parents do not slip in. Reason: geography plus the APAC exclusion.
- `funding_amounts: 25m_50m, 50m_100m`: Series B is not a native filter, so this total-raised band approximates it. Reason: stage proxy, confirmed later by a routine.

### 2. Signal filters

- Recent Series B round -> **Clay Routine**: Company Latest Funding. Confirms the stage the funding band only approximates, and dates the round for recency.
- Hiring for SDR / RevOps / GTM roles -> **Clay Routine**: Company Job Openings. Weighted up because the offer is outbound systems, so an active outbound build is a strong buying signal.
- Outbound tooling in the stack -> **Clay Routine**: Website Technology Stack. Presence of a sequencer or CRM signals the motion the offer plugs into.

Signals are weighted by the offer: hiring for outbound roles ranks above generic news because it maps directly to what is being sold.

### 3. Persona scope (Clay Search, `--source-type people`, or Find People at Company)

    {
      "job_title_keywords": ["VP Sales", "Head of Sales", "RevOps", "Revenue Operations", "GTM", "Head of Growth"],
      "seniority": ["director", "vp", "head", "c_suite"]
    }

Reason: the buyer for GTM engineering is the revenue or RevOps leader, not the practitioner.

### 4. Exclusion filters

    {
      "industries_exclude": ["Advertising Services", "Marketing Services"],
      "maximum_member_count_note": "drop rows under 50 post-source; sizes enum floor is coarse"
    }

- `industries_exclude`: keeps agencies out. Reason: stated exclusion.
- Under-50 headcount: the `sizes` enum starts at 51-200, so the floor is mostly handled, but confirm with Company Employee Count and drop any stragglers post-source. Reason: exclusion Search cannot express exactly.
- APAC HQ: handled by the US-only include, so no separate exclude needed.

### 5. Data source map

| Layer | Primitive | Why |
| --- | --- | --- |
| Industry, size, geo, funding band | Clay Search | Native filters cover all four |
| Series B confirmation | Clay Routine (Company Latest Funding) | Stage is not a Search filter |
| Hiring signal | Clay Routine (Company Job Openings) | Not a Search filter |
| Tech stack | Clay Routine (Website Technology Stack) | Not a Search filter |
| Buyer contacts | Clay Search people, or Find People at Company | Native people search |
| Emails, phones | Clay Routine (Enrich Person and Find Contact Details, Work Email) | Enrichment, not search |

No Apollo or WebSearch fallback needed for this ICP; Clay covers every layer.

### 6. Estimated pool size

Plan mode: method only. In execute mode, sample the first three pages of the company Search and report an approximate floor with `hasMore`, noting Search has no count endpoint.

### 7. Enrichment order (cheapest-first)

1. Firmographics already on the Search rows (free) -> pre-filter.
2. Company Employee Count, Enrich Company (cheap) -> confirm size, drop under-50 stragglers.
3. Company Latest Funding, Company Job Openings, Website Technology Stack (signal routines) -> only on rows past the firmographic gate.
4. Find People at Company (scoped to the persona titles) -> only on companies that still qualify.
5. Enrich Person and Find Contact Details, Work Email (most expensive) -> only on the qualified buyers.

Gate reason: no email credits spent on a company that would score `skip` downstream.

### 8. Refresh cadence

- Firmographics: quarterly (slow to change).
- Funding and news signals: weekly (a Series B closing is the whole trigger).
- Job openings: weekly.
- Contact emails: re-verify near send, or every 30 to 45 days, because email decays fastest.

### 9. Ownership map

Prefix `ab_`: `ab_source`, `ab_pool` = `serieb_saas_outbound`, `ab_signal_funding`, `ab_signal_hiring`, `ab_enriched_at`. Output convention only; no CRM write.

## Machine-readable summary

    {
      "source_type": "companies",
      "firmographic_filters": {
        "industries": ["Software Development"],
        "sizes": ["51-200", "201-500"],
        "country_names": ["United States"],
        "location_headquarters_only": true,
        "funding_amounts": ["25m_50m", "50m_100m"]
      },
      "exclusion_filters": { "industries_exclude": ["Advertising Services", "Marketing Services"] },
      "signal_filters": [
        { "signal": "recent Series B", "source": "Clay Routine", "routine": "Company Latest Funding" },
        { "signal": "hiring outbound roles", "source": "Clay Routine", "routine": "Company Job Openings" },
        { "signal": "outbound tech in stack", "source": "Clay Routine", "routine": "Website Technology Stack" }
      ],
      "persona_scope": {
        "job_title_keywords": ["VP Sales", "Head of Sales", "RevOps", "GTM", "Head of Growth"],
        "seniority": ["director", "vp", "head", "c_suite"]
      },
      "enrichment_order": ["Company Employee Count", "Enrich Company", "Company Latest Funding", "Company Job Openings", "Website Technology Stack", "Find People at Company", "Enrich Person and Find Contact Details", "Work Email"],
      "data_source_map": [
        { "layer": "firmographics", "primitive": "Search", "why": "native filters" },
        { "layer": "stage confirmation", "primitive": "Routine", "why": "stage not a search filter" }
      ],
      "estimated_pool": "plan mode: method only",
      "refresh_cadence": { "firmographics": "quarterly", "signals": "weekly", "contacts": "30-45 days" },
      "ownership_prefix": "ab_",
      "fallbacks_used": []
    }
