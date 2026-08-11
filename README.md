# gtm-engineer-stack

**Fit qualifies. Signals prioritize. Motions route.**

An opinionated Claude Code stack for B2B outbound, built to be cloned. It keeps one account universe: [icp-scoring](skills/icp-scoring/SKILL.md) scores every account against your ICP and assigns a tier (A, B, or C), buying signals set the priority within fit, and a motion decides how each account gets worked. Edit three config files for your business and the whole chain runs for you. One command, `/prospect <company-domain>`, runs the full chain in about 30 seconds and hands back a reasoning trail, a reviewed draft, and a verified contact. It never sends.

## Quickstart

1. Clone the repo, copy `.env.example` to `.env` with your `ANTHROPIC_API_KEY`, and install the Apollo MCP plugin in Claude Code.
2. Fill in the three configs: `config/icp.md` (who you target), `config/offering.md` (what you sell), `config/personas.md` (who you reach). Run `/setup` to populate them from documents you already have, or edit by hand. They ship generic with `TODO(setup):` markers, so a fresh clone fails the preflight gate until you replace them. A fully worked version lives in [examples/config/](examples/config/), which is Recap AI, a fictional example rather than a default. See [populating the configs](docs/setup/populating-configs.md).
3. Run `/prospect <company-domain>` for one account, or `/prospect-builder <ICP>` to build a tiered pool.

## Skills inventory

- **prospect-builder** - orchestrates the top of the funnel: sources and enriches a pool from Clay, then delegates tiering to icp-scoring, contacts to contact-resolver, and email checks to email-verification. Plan mode by default, `--execute` to run against Clay. Requires the Clay Agent Plugin. The app-side buying-signal check in `--execute` mode needs a one-time Claygent column setup, see [docs/setup](docs/setup/README.md).
- **account-research** - turns a company into a cited brief.
- **icp-scoring** - scores against your ICP, returns a tier and a recommended persona.
- **signal-classification** - classifies and ranks signals by event-aware recency for outbound fit.
- **contact-resolver** - resolves one real contact via the six-layer fallback waterfall with a confidence label.
- **icebreaker** - drafts peer-voice outreach calibrated to the trigger, with a stale-trigger gate.
- **email-verification** - turns Apollo status + catch-all into a verdict and a send recommendation.
- **meeting-prep** - builds a one-page pre-call brief from public and optional CRM context.
- **post-call** - turns call notes into a proposed CRM package and a reviewed follow-up.
- **output-review** - the five-criterion quality gate.

## Setup and docs

Most of the stack runs with just the three config edits above. The docs cover the rest:

- [Populating the configs](docs/setup/populating-configs.md) - where to find each field, what is Required versus Optional, and how to iterate.
- [Architecture decisions](docs/design/architecture-decisions.md) - why the stack is shaped this way (fit qualifies, signals prioritize, motions route).
- [Setup guides](docs/setup/README.md) - one-time setup for the `--execute` and write paths, including the Claygent buying-signal column for prospect-builder.

## Architecture

```
/prospect <company-domain>
        |
        v
  account-research ------> cited brief (snapshot, triggers, people, context)
        |
        v
  icp-scoring -----------> tier + recommended_persona  --[ tier = skip ]--> STOP (no contact spend)
        |
        v
  signal-classification -> ranked triggers (event-aware recency)
        |
        v
  contact-resolver ------> verified contact via the six-layer waterfall
        |                   (exact title -> family -> function -> founder -> senior -> fail)
        |                   + email-verification verdict
        v
  freshness gate --------> [ outbound_fit < 7 ] --> PAUSE (skip / override / wait)
        |
        v
  icebreaker ------------> peer-voice draft
        |
        v
  output-review ---------> PASS / REVISE (Criteria A-E + style-guard + citation-check)
        |
        v
  reasoning trail + draft + contact   (does not send)
```

## Slash commands

- **/prospect-builder** - build a tiered pool from an ICP definition (plan by default, `--execute` to source and enrich in Clay). Plan mode needs no setup; `--execute` with the app-side buying-signal check needs the Claygent column from [docs/setup](docs/setup/README.md).
- **/prospect** - the full chain on one company domain.
- **/draft-icebreaker** - one reviewed icebreaker for a known contact and trigger.
- **/verify-email** - a one-off email deliverability check.
- **/prep** - a pre-call meeting brief.
- **/wrap** - a proposed post-call package (review before writing to CRM).

## Motions and where their accounts come from

A motion decides how an account gets worked: its trigger, cadence, anchor style, approval, and suppression rules. The seven motions live in [config/motions/](config/motions/), and prospect-builder tags each account with an intended motion (`ab_motion`). Tier decides priority; motion decides treatment.

prospect-builder's firmographic sourcing naturally produces accounts for three of the seven motions:

- **cold-outbound** - ICP-fit accounts with no active signal (Tier C, or fit accounts with no live signal).
- **signal-based** - fit accounts with a fresh buying signal (default for Tier A and B).
- **nurture** - Tier C accounts, or accounts that exited a sequence without a reply.

The other four motions work against external data sources prospect-builder does not source, and each needs its own data feed:

- **abm** - a curated named-account list.
- **expansion** - existing customer data, from your CRM.
- **wake-the-dead** - closed-lost accounts, from your CRM.
- **inbound-followup** - form fills and demo requests, from your web forms.

The webhook receivers that ingest those four external feeds are planned for Tier 1 v2. Today you tag rows from those sources with the matching `--motion` manually.

## Hooks

- **style-guard.sh** - deterministic enforcement of banned phrases, cliches, jargon, and em dashes.
- **citation-check.sh** - deterministic enforcement of the source-preservation rule.

## Voice doctrine

See `CLAUDE.md`. Peer voice, no em dashes, source preservation, a three-component CTA, and banned cliches and SaaS jargon. Five output-reviewer criteria (A source preservation, B event specificity, C CTA structure, D robotic-CTA, E stale-trigger language) enforce the rules at draft time.

## Customization

- `config/icp.md` - who you target.
- `config/offering.md` - what you sell, how you describe it.
- `config/personas.md` - the buying committee, roles and titles.
- `/setup` - populates all three from documents you already have, marking anything the documents do not cover as `TODO(setup):` rather than guessing.
- `hooks/preflight-config.sh` - validates the three configs before any run that spends credits, and derives the Apollo employee buckets from the ICP employee range so the query cannot drift from the config.
- [examples/config/](examples/config/) - a fully worked version of all three, for Recap AI. A fictional example to read alongside the starters, not a default.
- Voice doctrine: edit `CLAUDE.md` only if you want to change the fundamental writing rules.

## CRM integration

The stack is designed to integrate with any CRM (HubSpot, Salesforce, Pipedrive, Attio, Close) via MCP plugins. Read operations are opt-in; write operations are NEVER auto-executed. `/wrap` outputs a proposed package the user reviews and writes manually. See [GETTING_STARTED.md](GETTING_STARTED.md) and the CRM integration sections in `skills/meeting-prep/SKILL.md` and `skills/post-call/SKILL.md`.

## Contact data provider

Apollo MCP is the default. To swap providers (Clearbit, ZoomInfo, Cognism, Lusha), edit the implementation section of the `contact-resolver` skill. The interface contract stays the same: domain plus a priority-ordered persona list in, one contact with title, LinkedIn, email, and a confidence label out.

## Production runtime

This Claude Code stack is the source of truth for prompts, voice doctrine, and quality rules. The same logic also runs in production via an n8n ICP-Aware Account Intelligence Engine: batch input from an Apollo CSV, signal-driven processing, persisted to Google Sheets, running on a daily signal feed. Same prompts, two execution surfaces. Local Claude Code for iteration; n8n for scale.

## Security model

All API keys and MCP credentials live on your machine, never in the repo:

- Your Anthropic API key goes in `.env` (gitignored).
- Your Apollo or other MCP connection is configured in Claude Code's local settings (gitignored).
- This repo contains prompts, rules, skills, and hooks only. No secrets.

## Stack

Claude Code, Apollo MCP, Clay Agent Plugin.

The `prospect-builder` skill and `/prospect-builder` command depend on the Clay Agent Plugin (the `clay` CLI plus its MCP tools), installed and authenticated in Claude Code. Clay is the primary source for TAM sourcing and enrichment, with Apollo MCP as the firmographic fallback and WebSearch as the last resort. See [docs/patterns/clay-integration.md](docs/patterns/clay-integration.md) for how the stack uses Clay's Search, Routines, and Tables primitives (including the read-only table limitation). The rest of the stack runs without Clay.
