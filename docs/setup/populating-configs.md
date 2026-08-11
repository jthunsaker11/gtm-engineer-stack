# Populating the configs

The whole stack reads three config files. Once they describe your business, every skill works for you. This guide walks a cloning user through filling them in.

The files ship generic, with a `TODO(setup):` marker on every field that describes your business. A fresh clone hard-fails `hooks/preflight-config.sh` until you replace them, which is the point: an unfilled config fails loudly and a config full of someone else's ICP fails silently. A fully worked version lives in [examples/config/](../../examples/config/), for Recap AI, a fictional conversation-intelligence vendor. Read it alongside the starter you are filling in. It is a reference, never a default.

- `config/icp.md` — which companies you target (firmographics, exclusions, scoring dimensions).
- `config/personas.md` — who you talk to (the buying committee: roles and titles).
- `config/offering.md` — what you sell (product, positioning, objections, discovery questions, buying signals).

## The Required, Recommended, Optional convention

Every section header in the three configs is tagged so you know what to fill first:

- **(Required)** — the skill breaks or produces nonsense without it. Fill these before your first run. Examples: the ICP firmographic criteria, at least the economic-buyer persona, the offering product overview and value proposition.
- **(Recommended)** — the skill still works, but output quality drops without it. Fill these next. Examples: exclusions, the scoring dimensions, persona KPIs, differentiators, buying signals.
- **(Optional)** — polish. Fill when you have it. Examples: reference customers, pricing, objection handling, discovery questions, lookalike seed accounts.

Skills degrade gracefully: a missing Optional section costs some polish, a missing Recommended section costs some quality, and a missing Required section is what you fix first. Start by filling every (Required) section from your best current knowledge, then work down.

## Where to find this at your company

You rarely have all of this written down in one place. Here is who usually holds each piece.

- **ICP firmographics and exclusions** — the founder or head of sales for an early company; RevOps or the ICP owner at a larger one. Ask: who are our best customers, what do they have in common (industry, size, motion, geography, tech), and who do we deliberately not sell to.
- **Buyer personas** — the sales team and RevOps. Ask reps who they actually talk to, who signs, who champions internally, and who blocks (legal, security, procurement). Product marketing often has a documented buyer-persona set already.
- **Offering, positioning, differentiators** — product marketing owns this. Ask for the positioning doc, the value proposition, the competitive one-pager, and the standard objection-handling. If product marketing does not exist yet, the founder is the source.
- **Pricing** — sales or finance.
- **Buying signals** — RevOps and marketing. Ask what events have historically preceded a deal: a funding round, a specific hire, a competitor evaluation, a tooling migration. Your own closed-won history is the best source.
- **Discovery questions and objections** — the sales team, from real calls. Sales enablement often has these written down.

If you cannot get a meeting, your closed-won CRM records and your website's own positioning pages are a workable first draft for most of it.

## What to do if you do not have everything yet

Do not block on completeness. The configs are meant to be iterated. But do not fill a gap with a guess either.

Leave anything you do not know as its `TODO(setup):` marker. The preflight gate names the file and line of every remaining marker and refuses to spend credits, so an unfilled config stops you with a specific list of what to go find out. A guessed one does not stop you at all: it sources a pool, scores it, and hands you tiers that look exactly like real ones. That is the failure worth designing against, because nothing about the output tells you it happened.

- Fill every **(Required)** section before your first run. These are what the gate hard-fails on, and the stack cannot score without them.
- Fill **(Recommended)** sections as you learn them, ideally within the first week or two of use. Output quality drops without them, but the stack runs.
- Leave **(Optional)** sections as markers until you have real content. A missing Optional section only costs polish.
- Do not invent precise numbers you do not have. If you do not know your ACV band, leave the marker and ask someone who does.

One exception worth knowing: the calibrated sections of `offering.md` (signal weighting, the signal type vocabulary, sales-team scaling thresholds, and signal freshness windows) ship populated rather than as markers, because `icp-scoring` reads them directly and a blank weighting table produces untiered output. They are defaults grounded in cited research. Tune them when you have reason to; you do not need to fill them in to start.

A half-filled config that is honest about its gaps produces better output than a fully-filled config padded with guesses, because the skills surface the gaps instead of confidently acting on made-up detail.

## How to know if your configs are good

Run prospect-builder in plan mode (the default, no `--execute`, no credits spent):

```
/prospect-builder <a short description of your ICP>
```

Read the plan it produces. It is good when:

- The firmographic filters match how you would actually describe your best customers.
- The persona scope names the titles your reps really sell to.
- The buying signals are events you have genuinely seen precede deals.
- The exclusions catch the accounts you know are a waste of time.

If any of those reads wrong, the fix is in the config, not the skill. Also run `/prospect <a real company domain you know well>` and check that the tier and the recommended persona match your own judgment of that account. If the stack tiers an obvious A account as C, your scoring dimensions or ICP criteria need tuning.

## How to iterate as you observe outcomes

Treat the configs as living documents, not a one-time setup.

- When a motion underperforms, look at the config before the skill. A low reply rate on signal-based outreach often means the buying signals in offering.md are too broad, so weak signals are inflating tiers.
- When reps say a tier is wrong, adjust the scoring dimensions or exclusions in icp.md until the tiers match their lived experience.
- When a new objection keeps coming up on calls, add it to offering.md so meeting-prep and the icebreaker account for it.
- Revisit the configs on a regular cadence (monthly is reasonable) and after any real change to your ICP, pricing, or competitive set.

Because motions live in config too (config/motions/), the same iterate-in-config discipline applies to cadence and approval rules: tune the markdown, not the skill.

## Automated config population: /setup

Editing the three files by hand is one path. The other is `/setup`, which reads documents you already have and populates them for you.

```
/setup
```

It asks what you have before reading anything (an ICP one-pager, a product brief, persona notes, a positioning deck, a pitch deck, closed-won notes), reads what you point it at, and fills in only what those documents actually support. Anything they do not cover stays as its `TODO(setup):` marker rather than becoming a plausible guess. Every field it does populate records which document it came from, so you can audit the config the same way you audit a sourced claim in outreach.

It shows you a diff before writing anything and waits for your approval, then runs the preflight gate and reports what still needs a human.

`/setup` does not make anything up, so expect it to leave markers. That is the intended outcome, not a shortfall: the markers are a list of what to go ask your founder, your RevOps lead, or your product marketer about.
