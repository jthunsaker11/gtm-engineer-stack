# Your Ideal Customer Profile

This is a starter config. Every `TODO(setup):` marker below is a field you fill in with
your own business. A fresh clone fails the preflight gate (`hooks/preflight-config.sh`)
until they are replaced, which is deliberate: an unfilled config fails loudly, and a
config filled with someone else's ICP fails silently.

Run `/setup` to populate this from your own sales and marketing documents, or edit it by
hand. For a fully worked version of every section, see
[examples/config/icp.md](../examples/config/icp.md). That example is Recap AI, a fictional
conversation-intelligence vendor used to show the shape. It is a reference, not a default.

## Companies you target (Required)
- Industry/vertical: TODO(setup): the industry or vertical you sell into
- Stage range: TODO(setup): company stage range, or "any" if your category is horizontal
- Employee size: TODO(setup): employee range written as "N to M employees", plus the size of the team that uses your product. The preflight gate derives the Apollo source buckets from these two numbers, so the "N to M" wording is load-bearing, not prose.
- Deal size: TODO(setup): your ACV band (human judgment)
- CRM: TODO(setup): the CRM or core system a target must run, if your product depends on one
- Geographic constraints: TODO(setup): regions and language constraints
- Motion type: TODO(setup): the go-to-market motion a target must run for your product to make sense

Keep this list to criteria that decide whether an account is worth working. The preflight
gate warns about any criterion with no filter or gate behind it, so a stated-but-unenforced
criterion stays visible instead of quietly doing nothing.

Some criteria no available field can express. ACV is the usual one: it is a property of your
deal rather than of the account, so nothing can filter on it. Tag those `(human judgment)`,
as the Deal size line above is, and the gate reports them as a note instead of a warning.
Use the tag only when no field could ever carry the criterion, not when the filter is merely
missing or blocked. A warning that can never be resolved trains people to ignore warnings,
and a criterion mislabeled as human judgment stops being something anyone intends to fix.

## Buyer personas you can sell to (Recommended)
See [personas.md](personas.md) for the role-ordered priority lists. In short, the buying
committee is:
- Economic buyer: TODO(setup): who owns the budget
- Champion: TODO(setup): who advocates internally
- Influencer: TODO(setup): who shapes the decision without owning it
- Blocker: TODO(setup): who can stop the deal (legal, security, procurement)

## Exclusions (Recommended)
- TODO(setup): the account types you deliberately do not sell to, and why

Write the reason next to each exclusion. The reason is what tells a future editor whether
the exclusion still applies.

### Source-time exclusions (Apollo `not_organization_sic_codes`)

When sourcing with `--source apollo`, exclude these SIC codes at source time so the
categories never enter the pool. SIC (Standard Industrial Classification) codes are a real,
industry-standard taxonomy.

These are shipped defaults, not client-specific: they exclude the categories that rarely buy
seat-based B2B software. Keep them, or adjust per business. If you sell TO one of these
categories (a recruiting SaaS selling to staffing firms, say), remove that entry so the
category is not excluded.

- `7361`: Employment agencies (recruiting firms)
- `8111`: Legal services (law firms)
- `7389`: Business services not elsewhere classified (many agencies)
- `2721`: Periodicals publishing (media companies)
- `8611`: Business associations
- `8221` and `8222`: Colleges and universities

### Post-source keyword exclusions

For rows the SIC filter misses, drop any account whose organization name or description
contains one of these terms (case-insensitive). Shipped defaults, same reasoning as the SIC
list above. Adjust per business.

- recruiting, recruitment, talent acquisition, staffing, RPO
- agency, consultancy, consulting group
- law firm, law office, attorneys, legal services
- media, publishing, magazine, newspaper
- association, coalition, foundation
- nonprofit, non-profit, NGO
- university, college, academic

## Lookalike seed accounts (Optional)
Reference-shaped accounts to expand from as a lookalike seed. Your closed-won list is the
best source.
- TODO(setup): 3 to 5 closed-won or best-fit customers

## Scoring dimensions (used by icp-scoring skill) (Recommended)
The dimensions icp-scoring reads. Edit the descriptions to match your ICP; each one should
name a criterion above so the score traces back to something written down.
- Stage fit: TODO(setup): what "right stage" means for you
- Headcount fit: TODO(setup): restate the employee and team-size range above
- Motion fit: TODO(setup): the motion that makes your product relevant
- Buyer presence: TODO(setup): the role whose presence means a real buyer exists
- Stack fit: TODO(setup): the system a target must run, if any
- Buying-signal: the events that precede a deal for you; see the signal patterns in config/offering.md
- Reachability

A dimension that scores the same value on every account is a gate, not a dimension. If one
of these never varies, it belongs in the criteria above or in the source query, not here.
