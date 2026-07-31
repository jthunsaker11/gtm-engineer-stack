---
name: signal-classification
description: Use when classifying and ranking raw signals about an account (news, funding, hires, posts, launches, tech changes) for outbound use, typically called by the prospect orchestrator on the account-research output. Returns signals classified by type, intensity, recency, and outbound fit, sorted best-first. Invoked explicitly by the orchestrator, not auto-triggered.
---

# Signal classification

Take raw signal data (from [account-research](../account-research/SKILL.md)) and classify each signal by type, intensity, recency, and source, then rank them for outbound use. Called explicitly by the prospect orchestrator.

## Signal types (closed taxonomy)

Every signal maps to exactly one type. Emit the **canonical** type from the signal type vocabulary in [config/offering.md](../../config/offering.md). One vocabulary across the stack: prospect-builder emits these names, icp-scoring weights them, and this skill classifies into them, so the weights key to exactly one set of names.

- `leadership_change` - a named senior hire in a buyer role (VP Sales, CRO, Head of RevOps)
- `sales_team_growth` - the sales org is scaling; see the scaling thresholds in config/offering.md
- `funding_event` - any round announced; note whether the exact round matched or only the amount band, since they weight differently
- `acquisition_event` - M&A activity, kept as its own type because post-acquisition consolidation is a budget event, not generic news
- `hiring_signal` - open roles below the sales_team_growth threshold
- `tech_stack_change` - adoption or removal of a relevant tool
- `news_event` - a dated public event with no stronger classification: product launches, market or segment expansion, podcasts, posts, talks, interviews, and anything else worth flagging that does not fit above
- `job_change` - a champion moved roles
- `website_intent` - tracked visit behaviour on your own domains

If nothing fits, use `news_event`; it is the catch-all. config/offering.md carries the mapping from this skill's older labels (`exec_hire`, `hiring_spike`, `funding_round`, `acquisition_or_merger`, `product_launch`, `expansion`, `public_statement`, `general_signal`) onto these names, so older output stays readable.

## Per-signal output (JSON)

    {
      "type": "<one of the taxonomy>",
      "headline": "<short description>",
      "source": "<URL or source name with date>",
      "recency_days": <integer days since signal>,
      "intensity": "high" | "medium" | "low",
      "outbound_fit": <0-10>,
      "rationale": "<one sentence on why this intensity and fit>"
    }

## Intensity rubric

- high: large funding round (>$25M), C-suite hire at a relevant ICP, acquisition, GA of a major product
- medium: smaller funding round, director-level hire, beta launch, public statement on a relevant pain
- low: minor signal, partnership, general PR

## outbound_fit rubric

outbound_fit weighs three inputs together: specificity (unique to this account versus a generic industry shift), source quality (can you cite it precisely, with a date), and recency. Recency is not a hard gate. It is scored against an event-aware band, because different event types stay outbound-relevant for different lengths of time.

### Recency bands by signal type

Keyed on the canonical types. Sub-labels in brackets are the older distinctions these bands were written for, kept because they still carry different decay.

| Type | high | medium | low |
|------|------|--------|-----|
| `acquisition_event` | 0-90 days | 90-180 | beyond 180 |
| `funding_event` (>$25M) | 0-60 | 60-120 | beyond 120 |
| `funding_event` (<=$25M) | 0-30 | 30-90 | beyond 90 |
| `leadership_change` | 0-45 | 45-90 | beyond 90 |
| `tech_stack_change` | 0-60 | 60-120 | beyond 120 |
| `hiring_signal` | while open | recently closed | past 90 days |
| `news_event` [product launch] | 0-21 | 21-60 | beyond 60 |
| `news_event` [public statement] | 0-45 | 45-90 | beyond 90 |
| `news_event` [expansion] | 0-60 | 60-120 | beyond 120 |
| `news_event` [other] | 0-30 | 30-60 | beyond 60 |

**Known conflict, being fixed next.** These bands score `outbound_fit` on this path, while the freshness windows in [config/offering.md](../../config/offering.md) decide expiry on the prospect-builder path, and the two disagree: `leadership_change` is high only to 45 days here but stays fresh to 90 days there. Until they are reconciled, the same event can read as fresh on one path and stale on the other. Reconciling the numbers is the immediately-next change; this table's keys were renamed to the canonical vocabulary first so the two paths at least speak the same names.

### Score

- 9-10: specific to this account + strong source + recency band is high for the type
- 7-8: specific + strong source + recency band medium, OR specific + medium source + high recency
- 5-6: relevant but generic, OR specific with a weak source, OR medium source + medium recency
- 3-4: weak link to outbound, hard to ground
- 0-2: not usable

A maximally specific, well-sourced signal in its high-recency band gets 9-10, whether that band is 21 days or 90 days. The bands respect how long each event type stays relevant in the real world.

## Output

Return the list of classified signals SORTED by `outbound_fit` descending. The top item is the recommended trigger for outbound. Every signal must carry a source with a date; drop or flag any signal that cannot be sourced.
