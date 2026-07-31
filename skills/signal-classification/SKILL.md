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
- `product_launch` - a new product, feature, GA, or new-market entry; its own type because it decays about three times faster than generic news and carries a budget trigger
- `hiring_signal` - open roles below the sales_team_growth threshold
- `tech_stack_change` - adoption or removal of a relevant tool
- `news_event` - a dated public event with no stronger classification: market or segment expansion, podcasts, posts, talks, interviews, and anything else worth flagging that does not fit above
- `job_change` - a champion moved roles
- `website_intent` - tracked visit behaviour on your own domains

If nothing fits, use `news_event`; it is the catch-all. config/offering.md carries the mapping from this skill's older labels (`exec_hire`, `hiring_spike`, `funding_round`, `acquisition_or_merger`, `expansion`, `public_statement`, `general_signal`) onto these names, so older output stays readable.

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

**The freshness window in [config/offering.md](../../config/offering.md) is the outer boundary.** Past its window a signal is expired, not merely low: it stops counting on the prospect-builder path, so it must not read as usable here either. The bands below grade quality *inside* the window; there is no band beyond it. One number governs expiry, and it is the cited one in config, so the same event can no longer be fresh on one path and stale on the other.

| Type | window | high | medium |
|------|--------|------|--------|
| `acquisition_event` | 90 | 0-90 | n/a |
| `funding_event` (>$25M) | 90 | 0-60 | 60-90 |
| `funding_event` (<=$25M) | 90 | 0-30 | 30-90 |
| `leadership_change` | 90 | 0-90 | n/a |
| `product_launch` | 60 | 0-21 | 21-60 |
| `tech_stack_change` | 180 | 0-60 | 60-180 |
| `hiring_signal` | 30 | while open | closed within 30 |
| `news_event` | 60 | 0-60 | n/a |
| `job_change` | 60 | 0-60 | n/a |
| `website_intent` | 14 | 0-14 | n/a |
| `sales_team_growth` | 30 | while the ratio holds | n/a |

A signal past its window scores `outbound_fit` 0-2 and is flagged stale. Do not score it as usable; prospect-builder drops it outright, and the two paths must agree.

Where a type shows `n/a` for medium, every signal inside the window grades the same: a leadership hire is as workable at day 80 as at day 10, which is why its window is 90 rather than a tighter high band. Types with a medium band decay inside the window instead: a launch is stale-ish by week four even though it is still worth referencing at week eight.

### Score

- 9-10: specific to this account + strong source + recency band is high for the type
- 7-8: specific + strong source + recency band medium, OR specific + medium source + high recency
- 5-6: relevant but generic, OR specific with a weak source, OR medium source + medium recency
- 3-4: weak link to outbound, hard to ground
- 0-2: not usable

A maximally specific, well-sourced signal in its high-recency band gets 9-10, whether that band is 21 days or 90 days. The bands respect how long each event type stays relevant in the real world.

## Output

Return the list of classified signals SORTED by `outbound_fit` descending. The top item is the recommended trigger for outbound. Every signal must carry a source with a date; drop or flag any signal that cannot be sourced.
