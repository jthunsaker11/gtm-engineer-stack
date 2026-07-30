---
name: icp-scoring
description: Use when scoring a company against the ICP in config/icp.md, typically called by the prospect orchestrator after account-research produces a company profile. Returns a structured tier and score verdict as JSON. Invoked explicitly by the orchestrator, not auto-triggered on casual mention.
---

# ICP scoring

Given a company profile (the output of [account-research](../account-research/SKILL.md)), evaluate fit against the ICP defined in [config/icp.md](../../config/icp.md) and return a structured verdict. Called explicitly by the prospect orchestrator; it does not auto-trigger.

## Input

A company profile: stage, headcount, product and revenue motion, named people and personas, GTM stack, recent signals, and public footprint. Usually the account-research brief. If a dimension's data is absent, record it in `missing_data` rather than guessing.

## Scoring dimensions

Score each 0-10 against the ICP in [config/icp.md](../../config/icp.md). The total is the sum (0-70), bucketed into a tier.

- **stage**: 10 if within your target stage range, about 5 if one stage adjacent, low (0-3) for far-off or excluded stages.
- **headcount**: 10 if within your target employee size, scaled down the further outside it the company sits.
- **motion**: 10 for your target motion, 5 adjacent, 0 off-ICP.
- **buyer**: 10 if a named target persona (config/personas.md) is on the team, 5 plausible, 0 none.
- **stack**: 10 if the company's tooling matches the stack fit defined in config/icp.md, 5 partial, 2 none.
- **signal**: 10 for a recent funding round, hiring spike, exec hire, or launch; 5 weaker; 3 none.
- **reachability**: 10 for a clear public footprint, 5 mixed, 3 dark.

Anything in the Exclusions list in config/icp.md caps the relevant dimensions (stage, motion, or buyer) at 0 and lands the company in skip.

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
      "recommended_persona": ["<title in priority order>"],
      "missing_data": ["<dimensions where data was insufficient>"]
    }

## Recommended persona

Populate `recommended_persona` from the priority lists in [config/personas.md](../../config/personas.md), in the order defined there. For any off-ICP or excluded company (per the Exclusions in config/icp.md), return an empty list (the tier will be skip).

## Rules

- If `missing_data` is non-empty, set `recommendation` to "needs more data" rather than scoring confidently on incomplete info. Still return the best-effort score and tier, but flag the gap.
- A strong fit with no current trigger (the `signal` dimension low) points to "nurture", not "pursue": good account, wrong moment.
- The reasoning cites the specific facts behind the scores. No unsourced assertions; if a fact came from research, it carries its source.
