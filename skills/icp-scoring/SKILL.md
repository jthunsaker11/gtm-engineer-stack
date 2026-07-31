---
name: icp-scoring
description: Use when scoring a company against the ICP in config/icp.md, typically called by the prospect orchestrator after account-research produces a company profile. Returns a structured tier and score verdict as JSON. Invoked explicitly by the orchestrator, not auto-triggered on casual mention.
---

# ICP scoring

Given a company profile (the output of [account-research](../account-research/SKILL.md)), evaluate fit against the ICP defined in [config/icp.md](../../config/icp.md) and return a structured verdict. Called explicitly by the prospect orchestrator; it does not auto-trigger.

## Input

A company profile: stage, headcount, product and revenue motion, named people and personas, GTM stack, recent signals, and public footprint. Usually the account-research brief. If a dimension's data is absent, record it in `missing_data` rather than guessing.

Also take `fresh_signal_count`: how many of the account's signals passed the freshness windows in config/offering.md. The caller computes it (prospect-builder applies the freshness gate before delegating). If it is not supplied, treat it as 0 and say so in `tier_cap_reason`, since an unverified count is not evidence of a live signal.

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

The tier is the worse of two independent judgements: how well the account fits, and whether there is a live reason to reach out now. Fit and timing fail differently, so they are judged separately and the tier takes the lower of the two.

**1. Fit band**, from the 0-70 score above:

- A: score >= 55
- B: 40-54
- C: 25-39
- skip: < 25

**2. Fresh-signal cap**, from `fresh_signal_count`:

- 2 or more fresh signals: no cap, the fit band stands
- exactly 1 fresh signal: cap at B
- 0 fresh signals: cap at C

The tier is whichever is worse. Excluded companies land in skip regardless of either judgement; the cap never rescues an excluded or sub-25 account.

Why the cap exists: without it a perfect-fit account with no live signal scores 63 (six dimensions at 10 plus 3 for no signal) and lands in A, so the tier stops reflecting timing at all and nothing ever reaches C, which starves the nurture motion that Tier C feeds.

A high-fit, no-signal account capped to C is not a demotion and not a bad account. It is a good company at the wrong moment, which is exactly what nurture is for. The fit score stays visible next to the tier so that reads correctly: `score` and `tier_cap_reason` in the output below carry it, and prospect-builder persists them as `ab_fit_score` and `ab_tier_cap_reason`. A rep seeing "fit 63, Tier C, 0 fresh signals" has the right information, not a downgrade.

The `signal` dimension inside the fit score and the cap are related but not redundant: the dimension scores signal strength, the cap counts fresh signals. Both are deliberate.

## Output (JSON)

    {
      "tier": "A" | "B" | "C" | "skip",
      "score": <0-70, the fit score>,
      "fit_band": "A" | "B" | "C" | "skip",
      "fresh_signal_count": <integer>,
      "tier_cap_reason": "<why the tier differs from the fit band, or 'no cap, fit band stands'>",
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

- Always populate `tier_cap_reason`, even when no cap applied, so the two judgements are legible in the row rather than leaving a reader to reverse-engineer why the tier and the fit band differ. Write it as one line naming both numbers, for example "score 63, fit band A, capped to C by 0 fresh signals" or "no cap, fit band stands".
- If `missing_data` is non-empty, set `recommendation` to "needs more data" rather than scoring confidently on incomplete info. Still return the best-effort score and tier, but flag the gap.
- A strong fit with no current trigger (the `signal` dimension low) points to "nurture", not "pursue": good account, wrong moment.
- The reasoning cites the specific facts behind the scores. No unsourced assertions; if a fact came from research, it carries its source.
