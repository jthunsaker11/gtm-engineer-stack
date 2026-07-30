# Your Ideal Customer Profile

Recap AI is the reference ICP for this stack. Edit for your own business if you fork it.

## Companies you target (Required)
- Industry/vertical: B2B SaaS companies running an outbound sales motion
- Stage range: any. This is a horizontal category. The buyer exists wherever there is a real sales team, from Series A through public.
- Employee size: 30 to 500 employees, with a sales team of 10 to 100 (a mix of AEs, SDRs, and Sales Managers)
- Deal size: ACV $20K to $200K
- CRM: HubSpot or Salesforce as the primary CRM
- Geographic constraints: US and Canada primary, English-primary sales conversations
- Motion type: outbound sales motion (reps making calls), not inbound-only self-serve

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
- Headcount fit (30 to 500 employees, sales team of 10 to 100 reps)
- Motion fit (outbound sales motion with reps on calls, not inbound-only)
- Buyer presence (a VP Sales, CRO, or Head of RevOps who owns sales tooling budget)
- Stack fit (HubSpot or Salesforce as the primary CRM)
- Buying-signal (funding, sales-team scaling, RevOps hire, or competitor evaluation; see the signal patterns in config/offering.md)
- Reachability
