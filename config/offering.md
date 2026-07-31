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
B2B SaaS companies running an outbound sales motion, 30 to 500 employees, with a sales team
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
$500 per seat per year, with a 10-seat minimum. Seat-based, so it scales with the size of
the sales team.

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
- Sales-team scaling: open sales roles at 15 percent or more of the current sales team, when the team is a real 20-plus-person org (see the sales-team scaling thresholds below).

## Signal weighting (Recommended)
Not all signals convert equally. For Recap AI's category:

- A leadership change (a recent VP Sales, CRO, or Head of RevOps hire) is the top-priority signal. A leadership hire in the buyer's own role is the highest-converting outbound trigger, so weight this signal highest.
- Sales-team growth (headcount scaling plus open sales roles) is the next strongest, since it is the clearest sign the sales org is expanding.
- An exact funding round match beats an amount-band match: when a company's latest round matches a target round in the buying signals above (Series A, B, or C), score it higher than a company whose total-raised amount merely falls in range.

icp-scoring reads these as weighting guidance; adjust per client.

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
Signals older than these windows are treated as expired and do not contribute to tier scoring. Windows are calibrated to typical decay per signal type. Adjust per client if the ICP warrants tighter or looser windows.

- funding_event: 90 days (budget window)
- news_event: 60 days (attention decays)
- hiring_signal: 45 days (postings churn fast)
- job_change: 60 days (new role honeymoon)
- tech_stack_change: 180 days (slow to shift)
- website_intent: 14 days (fastest decay)
- leadership_change: 90 days (new leader honeymoon; highest-converting signal)
- sales_team_growth: uses the hiring_signal window (45 days)

Customize per client: tighten windows for fast-moving categories (dev tools, AI infra) or loosen for slow enterprise deals.
