# Your Offering

This is a starter config. Every `TODO(setup):` marker is a field you fill in with your own
business. A fresh clone fails the preflight gate until they are replaced. Run `/setup` to
populate it from your own documents, or edit by hand. For a worked version of every section,
see [examples/config/offering.md](../examples/config/offering.md), which is Recap AI, a
fictional example rather than a default.

Two kinds of content live in this file. The sections above "Buying signals" are facts about
your business, and every one is a `TODO(setup):`. The sections from "Signal weighting" down
are calibrated defaults that ship working: signal weights, freshness windows, and scaling
thresholds, each grounded in cited research. They are tunable per business, not blank. Do
not empty them; `icp-scoring` reads the weights and windows directly, so a blank table
produces untiered output.

## Product overview (Required)
TODO(setup): what you sell, in two or three plain sentences. What it does, for whom.

## Value proposition (Required)
TODO(setup): the one-liner for cold outreach and elevator pitches, in one plain sentence.
The icebreaker skill uses this exact line when it names what you do, so write it the way you
would say it out loud, not the way a landing page would print it.

## Category (Recommended)
TODO(setup): the category you compete in, and the two to four competitors a buyer would name
alongside you.

## Target market (Recommended)
TODO(setup): a one-paragraph restatement of your ICP. Full detail, including exclusions and
scoring dimensions, is in [icp.md](icp.md). If you state an employee range here, write it as
"N to M employees" and keep it identical to the range in icp.md; the preflight gate compares
them and fails when the same fact carries two values.

## Buyer personas (Recommended)
The buying committee and the title priority lists are in [personas.md](personas.md).

## Differentiators / Why We Win (Recommended)
- TODO(setup): the reasons you win, each one specific enough that a competitor could not
  copy the sentence onto their own site

## Reference customers (Optional)
TODO(setup): logos you are allowed to name. Cite these as logos only. Do not inflate a logo
into a case study, a metric, or a quote you cannot back up with a real source.

## Pricing model (Optional)
TODO(setup): how you charge, and any minimum.

## Common objections and responses (Optional)
- TODO(setup): the objections your reps actually hear, each with the response that works.
  Take these from real calls, not from a positioning doc.

## Discovery questions (Optional)
1. TODO(setup): the questions your best rep opens with

## Buying signals (Recommended)
Signals that indicate active buying intent for your product. The icp-scoring skill uses these
for the `signal` dimension and tier assignment; prospect-builder uses them as signal filters.

- TODO(setup): the events you have genuinely seen precede a deal. Your closed-won history is
  the best source. Common patterns: a funding round, a specific leadership hire, a hiring
  spike on the team that would use your product, a competitor evaluation, a tooling
  migration, an acquisition.

Each signal you list should map to one of the canonical signal types in the vocabulary below,
because that is what carries a weight.

## Signal weighting (Recommended)
Not all signals convert equally, so every signal type carries a weight. icp-scoring reads these weights for two things: the `signal` dimension inside the fit score, and the fresh-signal cap that sets the tier ceiling. Editing a weight here shifts tier distribution, so this section is load-bearing config, not documentation.

These are shipped defaults, calibrated against the research cited below. They work as-is.

| signal type | weight | why |
| --- | --- | --- |
| `leadership_change` | 3 | A hire into the buyer's own role is the highest-converting outbound trigger. |
| `sales_team_growth` | 3 | The clearest sign the team that would use your product is expanding; see the scaling thresholds below. |
| `funding_event` (exact round match) | 2 | The latest round matches a target round in the buying signals above. |
| `acquisition_event` | 2 | Post-acquisition consolidation is a budget event, stronger than a generic news mention. |
| `product_launch` | 2 | A launch or new-market entry is a real budget trigger with a new motion behind it, and it decays about three times faster than generic news, so it is its own type. |
| `funding_event` (amount band only) | 1 | Total raised falls in range, but the round itself is unconfirmed. |
| `hiring_signal` | 1 | Open roles below the sales_team_growth threshold. |
| `news_event` | 1 | A dated public event with no stronger classification. |
| `tech_stack_change` | 1 | Slow-moving, rarely a timing trigger on its own. |
| `job_change` | 1 | Not produced by the pipeline yet. |
| `website_intent` | 1 | Not produced by the pipeline yet. |

How icp-scoring uses the summed weight of an account's fresh signals:

- `signal` dimension: weight 3 or more scores 10, weight 2 scores 7, weight 1 scores 5, weight 0 scores 3.
- Fresh-signal cap: weight 3 or more applies no cap, weight 1 or 2 caps the tier at B, weight 0 caps at C.

The consequence is deliberate. One leadership hire (weight 3) lifts the cap on its own, while two weak signals (weight 1 each) do not: two weak signals are not equivalent to one leadership hire.

Why this ordering is research-backed rather than a judgment call:

- `leadership_change` at 3, the highest weight: new VP and C-level hires evaluate vendors within their first 90 to 120 days, and an executive change paired with recent funding is the highest-converting signal pair in B2B outbound, reported at 4 to 6 times the reply rate of cold prospecting (Overloop, Buying Signals Playbook, 2026; Lead Scorer, B2B Buying Signals, 2026).
- `product_launch` and `acquisition_event` at 2: product launches and M&A activity rank together at the tier below executive hires and funding (same sources).

Tune per business. A team whose thesis is post-merger consolidation raises `acquisition_event`; a team selling into founder-led orgs may lower `leadership_change`.

### Signal type vocabulary
These type names are canonical across the stack: prospect-builder emits them, signal-classification classifies into them, icp-scoring weights them. One vocabulary, so weights key to exactly one set of names. signal-classification's older labels map in as follows, kept visible here rather than buried in a skill:

| signal-classification label | canonical type |
| --- | --- |
| `exec_hire` | `leadership_change` |
| `hiring_spike` | `hiring_signal` |
| `funding_round` | `funding_event` |
| `acquisition_or_merger` | `acquisition_event` |
| `tech_stack_change` | `tech_stack_change` |
| `product_launch` | `product_launch` |
| `expansion` | `news_event` |
| `public_statement` | `news_event` |
| `general_signal` | `news_event` |

Things that decay differently are different types. `expansion` is genuinely news-shaped and decays on the same 60-day curve as generic news, and `public_statement` and `general_signal` are weak by construction, so `news_event` at weight 1 is the right home for those three. Two do not belong there: `acquisition_or_merger` keeps its own type and weight because a business whose thesis is M&A needs that knob, and `product_launch` keeps its own because it decays about three times faster than generic news (21 days versus 60) and carries a budget trigger that a generic mention does not.

## Sales-team scaling thresholds (Recommended)
The sales_team_growth signal measures hiring intensity: open roles relative to the current team size, not a growth-over-time delta (Apollo exposes current departmental headcount, not department history). It fires when the team is real and hiring above the replacement-hiring baseline.

Shipped defaults. Thresholds:

- Team floor: `departmental_head_count.sales >= 20`. Below this a ratio is noise; a founder-led or early team hiring a couple of reps is not a readable scaling signal.
- Scaling ratio: `open roles / headcount >= 0.15`.

Why a ratio, not an absolute count: raw open-role counts do not scale with team size. A 500-person org hiring 3 people is baseline replacement (about 0.6 percent); a 20-person org hiring 3 is real scaling (15 percent). Counting raw roles fires on the wrong accounts; the ratio normalizes for team size.

Scaling bands (open roles as a percent of headcount):

- 5 to 15 percent: baseline replacement hiring (backfill, normal churn). Signal does not fire.
- 15 to 25 percent: active scaling. Signal fires.
- 25 percent and above: hypergrowth.

Tune per business: an enterprise-selling team (longer ramps, larger orgs) may raise the floor to 50; a team that sells to seed-stage buyers may lower it to 10. The 15 percent ratio is the default active-scaling line. If the team that uses your product is not the sales team, point this threshold at that department instead.

Benchmarks these thresholds are grounded in:

- Growthspree, B2B SaaS SDR and AE quota and productivity benchmarks, 2026.
- ICONIQ, 2025 SDR-to-AE ratio data (compression from roughly 1.0:1 toward 0.8:1 as tooling absorbed SDR work).
- ModernLeads, SDR-to-AE ratio benchmarks, 2026.
- Sales-team size by stage: seed 1 to 3, Series A 3 to 8, Series B 5 to 15 (median about 11 at $10 to 50M ARR), Series C and later 15 to 50+, enterprise 50 to 200+.

## Signal freshness windows (Recommended)
Signals older than these windows are treated as expired and do not contribute to tier scoring. Windows are calibrated per signal type against 2026 GTM research (cited below), so tight signals do not fire on stale data and durable ones are not discarded early.

Shipped defaults. Why freshness is architectural here rather than cosmetic: trigger-based prospecting is reported at roughly four times the conversion of cold outreach, with sales cycles about 30 percent shorter, and the first seller to reach a trigger event is materially more likely to win it. That is what these windows protect. A signal worked late is worth a fraction of the same signal worked early, so an expired signal is treated as no signal at all rather than as a weak one, on both the prospect-builder and the signal-classification paths.

- funding_event: 90 days (elevated buy rate lasts through 90 days post-announcement)
- news_event: 60 days (attention decays over weeks)
- hiring_signal: 30 days (job postings churn fast and the ghost-posting rate is high, so a posting older than a month is unreliable)
- job_change: 60 days (new-role honeymoon)
- tech_stack_change: 180 days (stacks shift slowly)
- website_intent: 14 days (intent decays fastest)
- leadership_change: 90 days (a new leader buys tooling across the first quarter, and profile-update lag means a tighter window would miss real hires)
- acquisition_event: 90 days (consolidation reviews run for a quarter or more after the deal closes)
- product_launch: 60 days (a launch stops being news fast; the outbound-relevant window is the quarter it ships in)
- sales_team_growth: uses the hiring_signal window (30 days), applied to its open-roles numerator

Research these windows are grounded in:

- LinkedIn profile-update lag: 1 to 4 weeks typical, 2 weeks most common (Resume Worded, Forage, 2026). A new hire's record lags the actual start, so the leadership window stays at 90 days rather than tightening.
- New VP hires carry a 30 to 90 day outreach window and evaluate vendors through their first 90 to 120 days, which is the second reason `leadership_change` is 90 rather than tighter (Overloop, Buying Signals Playbook, 2026).
- Ghost-job-posting rate: 18 to 32 percent of active listings across studies (Clarify Capital 2026, Greenhouse, HR Dive). This is why the hiring window is 30 days, not longer.
- Funding buying window: peak intent in the first 2 to 3 weeks, elevated buy rate through 90 days post-announcement (Buska, Salesforge, 2026). This sets the funding window at 90 days.

Customize per business: aggressive teams may tighten windows (fast-moving categories like dev tools or AI infra); patient teams selling long enterprise cycles may loosen them. Job postings and leadership hires are different mechanics, so they keep separate windows: tighten the hiring window for churn, but not the leadership window, or real hires that surface late will be missed.
