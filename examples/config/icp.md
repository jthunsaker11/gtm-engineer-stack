# Your Ideal Customer Profile

Recap AI is the reference ICP for this stack. Edit for your own business if you fork it.

## Companies you target (Required)
- Industry/vertical: B2B SaaS companies running an outbound sales motion
- Stage range: Series A through Series C. The category is horizontal, so the buyer exists wherever there is a real sales team, but the funded stages are where the budget is. Not currently enforced: it is a machine criterion, not a human-judgment one, and it stays blocked until `latest_funding_stage` is reachable. The bulk enrichment path returns no funding fields at all, while the single-domain endpoint does, so enforcing this today would cost one enrichment call per account. The preflight gate warns about this on every run, which is correct: it is a real gap with a known fix, not a permanent condition.
- Employee size: 51 to 500 employees, a coarse pre-filter only
- Sales team size: 10 to 100 reps (a mix of AEs, SDRs, and Sales Managers), enforced post-source on `departmental_head_count.sales`. This is the real qualification.
- Deal size: ACV $20K to $200K (human judgment). No available field carries a prospect's ACV, because it is a property of the deal rather than of the account. For a seat-based product it follows from the sales-team size already gated above: 10 to 100 seats at the roughly $2,000 per seat per year implied in [offering.md](offering.md) reproduces this band at both ends. So it is a sanity check a person applies when reviewing the pool, not an independent filter. Change one of the three numbers and the other two have to move with it.
- CRM: HubSpot or Salesforce as the primary CRM
- Geographic constraints: US and Canada primary, English-primary sales conversations
- Motion type: outbound sales motion (reps making calls), not inbound-only self-serve. Apollo has no motion filter, so this is confirmed post-source by the buying-signal research step (`ab_signal_sales_motion`), which reads the careers page and sales-tooling footprint and returns a verdict with a source.

## Targeting derivation (Recommended)

**Derived, not sourced.** Recap AI's published ICP could not be found, so the size range is
inferred rather than quoted. Treat it as a reasoned default to test against outcomes, not as
a fact about the company. Everything below is the reasoning, recorded so a future editor can
disagree with the argument rather than guess at the numbers.

The range is inferred from the product's mechanism of value. Conversation intelligence sells
against a manager who cannot listen to every call. That problem does not exist below roughly
8 to 10 reps, where a manager can still sit in on most of them, and above about 100 reps it is
usually already solved by an incumbent. Sales is typically 15 to 25 percent of headcount in
B2B SaaS, per the SDR and AE benchmarks cited in [offering.md](offering.md), which is what
turns a 10 to 100 rep range into a 51 to 500 employee range.

**Employee count is a pre-filter, not the qualification.** It exists because Apollo can filter
on it at source and cannot filter on sales headcount. The actual gate is
`departmental_head_count.sales` between 10 and 100, applied post-source.

Why 51 rather than 50: Apollo's fixed bands `["51,200","201,500"]` tile 51 to 500 exactly, so
the source query and the ICP describe the same set and there is no bucket slop to re-filter.
The previous 30 to 500 range lacked that property. Its tightest covering bands were
`["11,50","51,200","201,500"]`, which source 11 to 500 and quietly include everything from 11
to 29. A 100-company validation run sourced exactly that, and nothing narrowed the pool back
down. `hooks/preflight-config.sh` now reports the covered range before any spend and requires
the post-source re-filter with a dropped-row count, so the gap is visible rather than silent.
Choosing a range the bands tile exactly removes the problem instead of catching it.

Two cases from that run are the argument for gating on sales headcount rather than employee
count:

- An account with 130 employees and 5 sales reps scored Tier A on a leadership hire. The
  employee proxy passed it. The pain the product solves cannot exist at 5 reps, so the tier
  was real by the scoring rules and wrong by the mechanism.
- An account with 98 employees and 38 sales reps, 39 percent of headcount, is a strong fit. A
  headcount ceiling tuned to drop the first account would also drop this one.

The two cases fail in opposite directions from the same proxy, which is why the fix is a
different gate rather than a tighter bound on the same one.

**Stage range is not enforced.** See the note on the stage criterion above.

## Buyer personas you can sell to (Recommended)
See [personas.md](personas.md) for the role-ordered priority lists. In short, the buying committee is:
- Economic buyer: VP Sales, CRO, Chief Revenue Officer
- Champion: Head of RevOps, Sales Operations Manager, Sales Enablement Lead
- Influencer: VP Engineering (owns the CRM integration), Head of Customer Success (post-sale motion depends on the data)
- Blocker: VP Legal, Chief Compliance Officer (call-recording privacy and consent)

## Exclusions (Recommended)
- Consultancies and agencies (they sell services, not a seat-based sales tool)
- Single-founder pre-revenue shops (no sales team to record or coach)
- Sub-10-employee teams (below the 10-seat minimum, no real sales org)
- Companies with an existing rev intel deployment over 12 months old (entrenched, harder rip-out)
- Pure inbound-only companies with no outbound sales motion (no calls to record)
- Non-English-primary companies (transcription accuracy degrades)

These are the default exclusions for the Recap AI reference ICP. Customize them per client: if you actually sell TO one of these categories (for example a recruiting SaaS selling to staffing firms), remove that entry so it is not excluded.

### Source-time exclusions (Apollo `not_organization_sic_codes`)

When sourcing with `--source apollo`, exclude these SIC codes at source time so the categories never enter the pool. SIC (Standard Industrial Classification) codes are a real, industry-standard taxonomy. Adjust per client.

- `7361`: Employment agencies (recruiting firms)
- `8111`: Legal services (law firms)
- `7389`: Business services not elsewhere classified (many agencies)
- `2721`: Periodicals publishing (media companies)
- `8611`: Business associations
- `8221` and `8222`: Colleges and universities

### Post-source keyword exclusions

For rows the SIC filter misses, drop any account whose organization name or description contains one of these terms (case-insensitive). Adjust per client.

- recruiting, recruitment, talent acquisition, staffing, RPO
- agency, consultancy, consulting group
- law firm, law office, attorneys, legal services
- media, publishing, magazine, newspaper
- association, coalition, foundation
- nonprofit, non-profit, NGO
- university, college, academic

## Lookalike seed accounts (Optional)
Reference-shaped accounts to expand from as a lookalike seed:
- Bloomreach
- Kustomer
- LaunchDarkly
- Formstack

## Scoring dimensions (used by icp-scoring skill) (Recommended)
Edit the weights or descriptions if your ICP works differently:
- Stage fit (any stage that has a real, staffed sales team)
- Headcount fit (sales team of 10 to 100 reps; the 51 to 500 employee range is the pre-filter that finds them)
- Motion fit (outbound sales motion with reps on calls, not inbound-only)
- Buyer presence (a VP Sales, CRO, or Head of RevOps who owns sales tooling budget)
- Stack fit (HubSpot or Salesforce as the primary CRM)
- Buying-signal (funding, sales-team scaling, RevOps hire, or competitor evaluation; see the signal patterns in config/offering.md)
- Reachability
