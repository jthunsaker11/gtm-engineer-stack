---
name: signal-classification
description: Use when classifying and ranking raw signals about an account (news, funding, hires, posts, launches, tech changes) for outbound use, typically called by the prospect orchestrator on the account-research output. Returns signals classified by type, intensity, recency, and outbound fit, sorted best-first. Invoked explicitly by the orchestrator, not auto-triggered.
---

# Signal classification

Take raw signal data (from [account-research](../account-research/SKILL.md)) and classify each signal by type, intensity, recency, and source, then rank them for outbound use. Called explicitly by the prospect orchestrator.

## Signal types (closed taxonomy)

Every signal maps to exactly one type. If nothing fits, use `general_signal`.

- `acquisition_or_merger` - M&A activity
- `funding_round` - any round announced
- `exec_hire` - named senior hire
- `product_launch` - new feature, new product, GA
- `tech_stack_change` - adoption or removal of a relevant tool
- `public_statement` - podcast, post, talk, interview, blog with quotable content
- `hiring_spike` - multiple roles open, leadership hiring
- `expansion` - new market, geo, or segment
- `general_signal` - anything else worth flagging that does not fit above

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

| Type | high | medium | low |
|------|------|--------|-----|
| `acquisition_or_merger` | 0-90 days | 90-180 | beyond 180 |
| `funding_round` (>$25M) | 0-60 | 60-120 | beyond 120 |
| `funding_round` (<=$25M) | 0-30 | 30-90 | beyond 90 |
| `exec_hire` | 0-45 | 45-90 | beyond 90 |
| `product_launch` | 0-21 | 21-60 | beyond 60 |
| `tech_stack_change` | 0-60 | 60-120 | beyond 120 |
| `public_statement` | 0-45 | 45-90 | beyond 90 |
| `hiring_spike` | while open | recently closed | past 90 days |
| `expansion` | 0-60 | 60-120 | beyond 120 |
| `general_signal` | 0-30 | 30-60 | beyond 60 |

### Score

- 9-10: specific to this account + strong source + recency band is high for the type
- 7-8: specific + strong source + recency band medium, OR specific + medium source + high recency
- 5-6: relevant but generic, OR specific with a weak source, OR medium source + medium recency
- 3-4: weak link to outbound, hard to ground
- 0-2: not usable

A maximally specific, well-sourced signal in its high-recency band gets 9-10, whether that band is 21 days or 90 days. The bands respect how long each event type stays relevant in the real world.

## Output

Return the list of classified signals SORTED by `outbound_fit` descending. The top item is the recommended trigger for outbound. Every signal must carry a source with a date; drop or flag any signal that cannot be sourced.
