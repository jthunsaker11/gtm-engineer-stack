---
name: icp-scoring
description: Use when scoring a company against the consultancy ICP, typically called by the prospect orchestrator after account-research produces a company profile. Returns a structured tier and score verdict as JSON. Invoked explicitly by the orchestrator, not auto-triggered on casual mention.
---

# ICP scoring

Given a company profile (the output of [account-research](../account-research/SKILL.md)), evaluate fit against the ICP defined in [CLAUDE.md](../../CLAUDE.md) and return a structured verdict. Called explicitly by the prospect orchestrator; it does not auto-trigger.

## Input

A company profile: stage, headcount, product and revenue motion, named people and personas, GTM stack, recent signals, and public footprint. Usually the account-research brief. If a dimension's data is absent, record it in `missing_data` rather than guessing.

## Scoring dimensions

Score each 0-10. The total is the sum (0-70), bucketed into a tier.

| Dimension | 10 | 5 | low |
|-----------|----|----|-----|
| stage | seed through Series B | Series C | pre-seed 0, late stage/public 3 |
| headcount | 30-200 | near the edges | far outside, scaled down |
| motion | B2B SaaS revenue motion | adjacent | off-ICP 0 |
| buyer | named operator persona on the team | plausible | none 0 |
| stack | CRM + sequencer + enrichment | partial | none 2 |
| signal | recent funding, hiring spike, exec hire, or launch | weaker | none 3 |
| reachability | clear public footprint | mixed | dark 3 |

Operator personas: founder, VP Sales, Head of RevOps, CRO, Head of GTM Ops. Exclusions: pre-seed, lifestyle businesses, agencies, services firms, public companies over 1000 employees, anything where the buyer is not a revenue operator. An exclusion caps the relevant dimensions (motion, stage, or buyer) at 0 and should land the company in skip.

## Tiers

- A: score >= 55
- B: 40-54
- C: 25-39
- skip: < 25

## Output (JSON)

    {
      "tier": "A" | "B" | "C" | "skip",
      "score": <0-70>,
      "dimensions": {
        "stage": <0-10>, "headcount": <0-10>, "motion": <0-10>,
        "buyer": <0-10>, "stack": <0-10>, "signal": <0-10>, "reachability": <0-10>
      },
      "reasoning": "<one short paragraph>",
      "recommendation": "pursue" | "nurture" | "skip" | "needs more data",
      "missing_data": ["<dimensions where data was insufficient>"]
    }

## Rules

- If `missing_data` is non-empty, set `recommendation` to "needs more data" rather than scoring confidently on incomplete info. Still return the best-effort score and tier, but flag the gap.
- A strong fit with no current trigger (the `signal` dimension low) points to "nurture", not "pursue": good account, wrong moment.
- The reasoning cites the specific facts behind the scores. No unsourced assertions; if a fact came from research, it carries its source.
