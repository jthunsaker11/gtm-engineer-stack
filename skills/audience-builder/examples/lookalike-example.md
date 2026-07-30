# Example: lookalike expansion from reference customers

This walks the skill through a full input with a lookalike seed, using the Recap AI reference
ICP. Plan mode, so no Clay calls run; the plan is what the user reviews before executing.

## Input

- **ICP description**: B2B SaaS companies running an outbound sales motion, 30 to 500 employees, sales team of 10 to 100 reps, on HubSpot or Salesforce, US and Canada.
- **Reference customers (seed)**: Bloomreach, Kustomer, LaunchDarkly, Formstack.
- **Exclusions**: no agencies or consultancies, nothing under 10 employees, no company already running a rev intel tool for more than 12 months, no inbound-only companies.
- **Offer**: the offering in config/offering.md (Recap AI, conversation intelligence for B2B sales teams).

## How the seed is used

The four reference customers are a lookalike seed, not filters. Two ways to expand from them in Clay:

- Enrich each seed with **Enrich Company** to read its real firmographics (industry label, size, funding, tech), then set the Search filters to the center of that cluster rather than to the ICP prose. The seed grounds the numbers.
- Feed the seed domains into Clay Search as an include-identifier reference where the workspace supports lookalike sourcing, and treat the ICP prose as the guardrail.

Reason: closed-won firmographics are a sharper target than a written ICP, because they are where the offer already landed.

## The plan

### 1. Firmographic filters (Clay Search, `--source-type companies`)

    {
      "industries": ["Software Development", "Technology, Information and Internet"],
      "minimum_member_count": 30,
      "maximum_member_count": 500,
      "country_names": ["United States", "Canada"]
    }

- `industries`: the seed companies classify here; keeps the pool in B2B SaaS. Reason: matches the reference-customer cluster.
- `minimum_member_count: 30` / `maximum_member_count: 500`: the ICP employee band. Reason: ICP size range; the 30 floor also clears the sub-10-employee exclusion.
- `country_names: United States, Canada`: the ICP geography. Reason: stated geography, and English-primary sales conversations for transcription accuracy.

The ICP is stage-agnostic (any stage with a real sales team), so no funding band is applied at the firmographic layer.

### 2. Signal filters

- Recent funding (any round) -> **Clay Routine**: Company Latest Funding. Confirms budget for sales tooling exists, and dates the round for recency.
- Hiring for AE, SDR, or RevOps roles -> **Clay Routine**: Company Job Openings. Weighted up because the offer sells to a scaling sales team, so open sales reqs are the strongest buying signal.
- CRM and existing rev intel in the stack -> **Clay Routine**: Website Technology Stack. HubSpot or Salesforce present qualifies; an entrenched competitor (Gong, Chorus, Fathom, Fireflies) flags the row for the rip-out exclusion.

Signals are weighted by the offer: hiring for sales roles ranks above generic news because it maps directly to what is being sold.

### 3. Persona scope (Clay Search, `--source-type people`, or Find People at Company)

    {
      "job_title_keywords": ["VP Sales", "CRO", "Head of RevOps", "Revenue Operations", "Sales Operations", "Sales Enablement"],
      "seniority": ["director", "vp", "head", "c_suite"]
    }

Reason: the buyer is the sales or RevOps leader who owns sales-tooling budget, per config/personas.md.

### 4. Exclusion filters

    {
      "industries_exclude": ["Business Consulting and Services", "Advertising Services"],
      "post_source_notes": "drop entrenched rev intel (>12mo) and inbound-only via the sales-motion check; drop under-10 via minimum_member_count"
    }

- `industries_exclude`: keeps agencies and consultancies out. Reason: stated exclusion.
- Entrenched rev intel (>12 months) and inbound-only: no native Search filter, so handled post-source by the sales-motion buying-signal check (the Claygent column or its WebSearch fallback). Reason: exclusions Search cannot express.
- Under-10 headcount: handled by `minimum_member_count: 30`. Reason: exclusion the floor already covers.

### 5. Data source map

| Layer | Primitive | Why |
| --- | --- | --- |
| Industry, size, geo | Clay Search | Native filters cover all three |
| Funding signal | Clay Routine (Company Latest Funding) | Not a Search filter |
| Hiring signal | Clay Routine (Company Job Openings) | Not a Search filter |
| CRM and rev-intel-in-stack | Clay Routine (Website Technology Stack) | Not a Search filter |
| Outbound-sales-motion qualifier | Claygent column, or WebSearch fallback | No Clay filter or routine reads a sales motion |
| Buyer contacts | Clay Search people, or Find People at Company | Native people search |
| Emails, phones | Clay Routine (Enrich Person and Find Contact Details, Work Email) | Enrichment, not search |

No Apollo fallback needed for this ICP; Clay plus the sales-motion check covers every layer.

### 6. Estimated pool size

Plan mode: method only. In execute mode, sample the first three pages of the company Search and report an approximate floor with `hasMore`, noting Search has no count endpoint.

### 7. Enrichment order (cheapest-first)

1. Firmographics already on the Search rows (free) -> pre-filter.
2. Company Employee Count, Enrich Company (cheap) -> confirm size and sales-team size.
3. Company Latest Funding, Company Job Openings, Website Technology Stack (signal routines) -> only on rows past the firmographic gate.
4. Sales-motion buying-signal check (Claygent or WebSearch) -> only on rows that carry a signal; this is the qualifier that drops inbound-only and entrenched accounts before any people spend.
5. Find People at Company (scoped to the persona titles) -> only on companies that still qualify.
6. Enrich Person and Find Contact Details, Work Email (most expensive) -> only on the qualified buyers.

Gate reason: no email credits spent on a company that would score `skip` downstream.

### 8. Refresh cadence

- Firmographics: quarterly (slow to change).
- Funding and news signals: weekly (a new round is a buying trigger).
- Job openings: weekly (open sales reqs are the strongest signal).
- Contact emails: re-verify near send, or every 30 to 45 days, because email decays fastest.

### 9. Ownership map

Prefix `ab_`: `ab_source`, `ab_pool` = `b2b_saas_sales_teams`, `ab_signal_funding`, `ab_signal_hiring`, `ab_signal_sales_motion`, `ab_enriched_at`. Output convention only; no CRM write.

## Machine-readable summary

    {
      "source_type": "companies",
      "firmographic_filters": {
        "industries": ["Software Development", "Technology, Information and Internet"],
        "minimum_member_count": 30,
        "maximum_member_count": 500,
        "country_names": ["United States", "Canada"]
      },
      "exclusion_filters": { "industries_exclude": ["Business Consulting and Services", "Advertising Services"] },
      "signal_filters": [
        { "signal": "recent funding", "source": "Clay Routine", "routine": "Company Latest Funding" },
        { "signal": "hiring sales roles", "source": "Clay Routine", "routine": "Company Job Openings" },
        { "signal": "crm and rev intel in stack", "source": "Clay Routine", "routine": "Website Technology Stack" },
        { "signal": "outbound sales motion", "source": "manual", "routine": null }
      ],
      "persona_scope": {
        "job_title_keywords": ["VP Sales", "CRO", "Head of RevOps", "Revenue Operations", "Sales Operations", "Sales Enablement"],
        "seniority": ["director", "vp", "head", "c_suite"]
      },
      "enrichment_order": ["Company Employee Count", "Enrich Company", "Company Latest Funding", "Company Job Openings", "Website Technology Stack", "Find People at Company", "Enrich Person and Find Contact Details", "Work Email"],
      "data_source_map": [
        { "layer": "firmographics", "primitive": "Search", "why": "native filters" },
        { "layer": "sales motion", "primitive": "WebSearch", "why": "no Clay filter or routine reads a sales motion" }
      ],
      "estimated_pool": "plan mode: method only",
      "refresh_cadence": { "firmographics": "quarterly", "signals": "weekly", "contacts": "30-45 days" },
      "ownership_prefix": "ab_",
      "fallbacks_used": []
    }
