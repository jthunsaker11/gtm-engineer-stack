# Your Offering

Recap AI is the reference offering for this stack. Edit for your own business if you fork it.

## Product overview (Required)
Recap AI is AI meeting intelligence for B2B sales teams. It auto-records and transcribes
sales calls, extracts action items and deal-critical moments, syncs them to the CRM, and
generates coaching recommendations for reps and managers.

## Value proposition (Required)
The one-liner for cold outreach and elevator pitches: "Recap AI records your sales calls
and lands the moments, next steps, and coaching notes back in your CRM, so nothing from a
call gets lost and managers can coach from what actually happened." The icebreaker skill
uses this line when it names what we do; keep it in one plain sentence.

## Category (Recommended)
Rev intel / conversation intelligence. We compete with Gong, Chorus, Fathom, and Fireflies.

## Target market (Recommended)
B2B SaaS companies running an outbound sales motion, 51 to 500 employees, with a sales team
of 10 to 100 reps (AEs, SDRs, and Sales Managers), ACV $20K to $200K, on HubSpot or
Salesforce, primarily in the US and Canada. The category is horizontal, so the buyer exists
at any company stage where there is a real, staffed sales team. Full ICP detail, including
exclusions and scoring dimensions, is in [icp.md](icp.md).

## Buyer personas (Recommended)
The buying committee (economic buyer, champion, influencer, and the legal/compliance
blocker) and the title priority lists are in [personas.md](personas.md).

## Differentiators / Why We Win (Recommended)
- CRM-native integration depth for Salesforce and HubSpot: call data lands where reps already work, not in a separate silo they have to check.
- A coaching layer competitors are thin on: specific recommendations for reps and managers, not just call recording and search.
- Sub-24-hour setup versus the multi-week implementations typical of Gong and Chorus.
- Deal-critical moment extraction, not just a transcript: action items and next steps are pulled out and written to the CRM automatically.
- Low switching cost: because setup is fast and the data flows into the existing CRM, a team can trial Recap alongside an incumbent without a rip-out first.

## Reference customers (Optional)
Bloomreach, Kustomer, LaunchDarkly, Formstack. Cite these as logos only. Do not inflate a
logo into a case study, a metric, or a quote you cannot back up with a real source.

## Pricing model (Optional)
Seat-based, with a 10-seat minimum, so it scales with the size of the sales team.

**Illustrative, not sourced.** Recap AI's pricing is not findable, so rather than invent a
number this section states the figure the rest of the config already implies and shows the
arithmetic. A cloner replaces it with their real pricing.

The ICP gates the sales team at 10 to 100 reps and states an ACV band of $20K to $200K. Those
two facts pin the per-seat figure at both ends:

| seats | ACV | implied per seat per year |
| --- | --- | --- |
| 10 (the minimum) | $20K (band floor) | $2,000 |
| 100 (the ceiling) | $200K (band cap) | $2,000 |

Both endpoints give the same number, so the ACV band and the seat range are consistent with
each other at roughly **$2,000 per seat per year**. That is the figure to reason from, and it
is in the right order of magnitude for the conversation-intelligence category.

Keep the three numbers in step when you edit any of them. Seat range times per-seat price
should reproduce the ACV band in [icp.md](icp.md), or the config states two things that
cannot both be true.

## Common objections and responses (Optional)
- **"We already use Gong or Chorus."** Recap runs alongside an incumbent, so there is no rip-out to trial it. Setup is under a day, the per-seat cost is lower, and the coaching layer is where teams tell us the incumbents fall short. Ask what they wish their current tool did better.
- **"We can't record calls for privacy or consent reasons."** This is usually the legal or compliance blocker. Recap supports consent capture and region-based recording controls, and the compliance owner can be brought in early to set the policy. Do not hand-wave this; offer to walk their compliance lead through the controls.
- **"Reps won't adopt another tool."** There is no new tool for reps to open. Recording is automatic and the output lands in the CRM they already use, so the rep behavior change is close to zero. Adoption risk sits with managers using the coaching layer, not with reps.
- **"Standing up another integration is more work than we have time for."** Setup is under a day, and Recap connects to HubSpot or Salesforce out of the box, so there is no custom integration project. The engineering owner signs off on the connection once, and after that the data flows without ongoing engineering involvement. Offer to have their systems owner review the connector before they commit.
- **"It is not in this quarter's budget."** Frame against rep ramp time and how much more coaching a manager can do per week: the cost of a seat is small next to the cost of a rep missing quota for an extra quarter. Offer to start at the 10-seat minimum with the team that would benefit most.

## Discovery questions (Optional)
1. How is your team capturing what happens on sales calls today, and where does that end up?
2. What CRM are you on, and honestly how much of a call's context actually makes it into the record?
3. How do your managers coach reps right now, and how much call review can they realistically do in a week?
4. When a new rep ramps, how long until they hit quota, and what is the bottleneck?
5. Are you running any call recording or conversation intelligence today? If so, how long has it been in, and how is adoption?
6. Who owns the decision on sales tooling, and is there a legal or compliance step for call recording?
7. What would have to be true for a 10-seat rollout to be worth doing this quarter?

## Buying signals (Recommended)
Signals that indicate active buying intent for Recap AI. The icp-scoring skill uses these
for the `signal` dimension and tier assignment; prospect-builder uses them as signal filters.

- Recent funding (Series A, B, or C): budget for sales tooling exists.
- Job postings for VP Sales, Head of RevOps, or 5+ AE reqs open at once: the sales team is scaling.
- A recent RevOps or Sales Operations hire: GTM infrastructure is being built.
- A product launch or new-market-entry announcement: a new sales motion needs tooling.
- Migration from HubSpot Starter to HubSpot Pro, or onto Salesforce: getting serious about sales infrastructure.
- Competitor-evaluation signals (visiting Gong, Chorus, Fathom, or Fireflies pages).
- An acquisition or merger: post-acquisition tool consolidation forces a review of overlapping sales tooling, and the budget to act on it.
- Sales-team scaling: open sales roles at 15 percent or more of the current sales team, when the team is a real 20-plus-person org (see the sales-team scaling thresholds below).

## Signal weighting (Recommended)
Not all signals convert equally, so every signal type carries a weight. icp-scoring reads these weights for two things: the `signal` dimension inside the fit score, and the fresh-signal cap that sets the tier ceiling. Editing a weight here shifts tier distribution, so this section is load-bearing config, not documentation.

| signal type | weight | why |
| --- | --- | --- |
| `leadership_change` | 3 | A VP Sales, CRO, or Head of RevOps hire in the buyer's own role is the highest-converting outbound trigger. |
| `sales_team_growth` | 3 | The clearest sign the sales org is expanding; see the scaling thresholds below. |
| `funding_event` (exact round match) | 2 | The latest round matches a target round in the buying signals above. |
| `acquisition_event` | 2 | Post-acquisition consolidation is a budget event, stronger than a generic news mention. |
| `product_launch` | 2 | A launch or new-market entry is a real budget trigger with a new sales motion behind it, and it decays about three times faster than generic news, so it is its own type. |
| `funding_event` (amount band only) | 1 | Total raised falls in range, but the round itself is unconfirmed. |
| `hiring_signal` | 1 | Open sales roles below the sales_team_growth threshold. |
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

Tune per client. A team whose thesis is post-merger consolidation raises `acquisition_event`; a team selling into founder-led orgs may lower `leadership_change`.

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

Things that decay differently are different types. `expansion` is genuinely news-shaped and decays on the same 60-day curve as generic news, and `public_statement` and `general_signal` are weak by construction, so `news_event` at weight 1 is the right home for those three. Two do not belong there: `acquisition_or_merger` keeps its own type and weight because a client whose thesis is M&A needs that knob, and `product_launch` keeps its own because it decays about three times faster than generic news (21 days versus 60) and carries a budget trigger that a generic mention does not.

## Sales-team scaling thresholds (Recommended)
The sales_team_growth signal measures hiring intensity: open sales roles relative to the current sales team size, not a growth-over-time delta (Apollo exposes current departmental headcount, not sales-department history). It fires when the sales team is real and hiring above the replacement-hiring baseline.

Thresholds:

- Sales-team floor: `departmental_head_count.sales >= 20`. Below this a ratio is noise; a founder-led or early team hiring a couple of reps is not a readable scaling signal.
- Scaling ratio: `open sales roles / sales headcount >= 0.15`.

Why a ratio, not an absolute count: raw open-role counts do not scale with team size. A 500-person sales org hiring 3 SDRs is baseline replacement (about 0.6 percent); a 20-person org hiring 3 is real scaling (15 percent). Counting raw roles fires on the wrong accounts; the ratio normalizes for team size.

Scaling bands (open sales roles as a percent of sales headcount):

- 5 to 15 percent: baseline replacement hiring (backfill, normal churn). Signal does not fire.
- 15 to 25 percent: active scaling. Signal fires.
- 25 percent and above: hypergrowth.

Tune per client: an enterprise-selling team (longer ramps, larger orgs) may raise the floor to 50; a team that sells to seed-stage buyers may lower it to 10. The 15 percent ratio is the default active-scaling line.

Benchmarks these thresholds are grounded in:

- Growthspree, B2B SaaS SDR and AE quota and productivity benchmarks, 2026.
- ICONIQ, 2025 SDR-to-AE ratio data (compression from roughly 1.0:1 toward 0.8:1 as tooling absorbed SDR work).
- ModernLeads, SDR-to-AE ratio benchmarks, 2026.
- Sales-team size by stage: seed 1 to 3, Series A 3 to 8, Series B 5 to 15 (median about 11 at $10 to 50M ARR), Series C and later 15 to 50+, enterprise 50 to 200+.

## Signal freshness windows (Recommended)
Signals older than these windows are treated as expired and do not contribute to tier scoring. Windows are calibrated per signal type against 2026 GTM research (cited below), so tight signals do not fire on stale data and durable ones are not discarded early.

Why freshness is architectural here rather than cosmetic: trigger-based prospecting is reported at roughly four times the conversion of cold outreach, with sales cycles about 30 percent shorter, and the first seller to reach a trigger event is materially more likely to win it. That is what these windows protect. A signal worked late is worth a fraction of the same signal worked early, so an expired signal is treated as no signal at all rather than as a weak one, on both the prospect-builder and the signal-classification paths.

- funding_event: 90 days (elevated buy rate lasts through 90 days post-announcement)
- news_event: 60 days (attention decays over weeks)
- hiring_signal: 30 days (job postings churn fast and the ghost-posting rate is high, so a posting older than a month is unreliable)
- job_change: 60 days (new-role honeymoon)
- tech_stack_change: 180 days (stacks shift slowly)
- website_intent: 14 days (intent decays fastest)
- leadership_change: 90 days (a new sales leader buys tooling across the first quarter, and profile-update lag means a tighter window would miss real hires)
- acquisition_event: 90 days (consolidation reviews run for a quarter or more after the deal closes)
- product_launch: 60 days (a launch stops being news fast; the outbound-relevant window is the quarter it ships in)
- sales_team_growth: uses the hiring_signal window (30 days), applied to its open-sales-roles numerator

Research these windows are grounded in:

- LinkedIn profile-update lag: 1 to 4 weeks typical, 2 weeks most common (Resume Worded, Forage, 2026). A new hire's record lags the actual start, so the leadership window stays at 90 days rather than tightening.
- New VP hires carry a 30 to 90 day outreach window and evaluate vendors through their first 90 to 120 days, which is the second reason `leadership_change` is 90 rather than tighter (Overloop, Buying Signals Playbook, 2026).
- Ghost-job-posting rate: 18 to 32 percent of active listings across studies (Clarify Capital 2026, Greenhouse, HR Dive). This is why the hiring window is 30 days, not longer.
- Funding buying window: peak intent in the first 2 to 3 weeks, elevated buy rate through 90 days post-announcement (Buska, Salesforge, 2026). This sets the funding window at 90 days.

Customize per client: aggressive teams may tighten windows (fast-moving categories like dev tools or AI infra); patient teams selling long enterprise cycles may loosen them. Job postings and leadership hires are different mechanics, so they keep separate windows: tighten the hiring window for churn, but not the leadership window, or real hires that surface late will be missed.
