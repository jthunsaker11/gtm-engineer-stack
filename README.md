# gtm-engineer-stack

An opinionated Claude Code stack that turns one slash command into a full B2B outbound chain: account research, ICP scoring with skip gate, signal classification with event-aware recency, Apollo MCP contact resolution with a six-layer fallback waterfall, peer-voice icebreaker drafting, email verification with catch-all detection, plus a deterministic style-guard hook and a five-criterion output reviewer.

Built to be cloned. Edit three config files for your business and you have a working AI-assisted GTM workspace in 10 minutes.

## What it does

One command: `/prospect <company-domain>`. The agent runs the full chain in about 30 seconds and hands back a reasoning trail, a reviewed draft, and a verified contact. It never sends.

Other commands: `/audience-builder`, `/draft-icebreaker`, `/verify-email`, `/prep`, `/wrap`.

## Quick start

1. Clone this repo.
2. Copy `.env.example` to `.env`, add your `ANTHROPIC_API_KEY`.
3. Install the Apollo MCP plugin in Claude Code (or your chosen contact data provider).
4. Edit `config/icp.md` (who you target).
5. Edit `config/offering.md` (what you sell).
6. Edit `config/personas.md` (which titles you reach).
7. Run `/prospect <company-domain>` in Claude Code.

## Setup guides

Most of the stack runs with just the config edits above. A few skills have an `--execute` or write path that needs a one-time setup, documented in [docs/setup](docs/setup/README.md):

- **Claygent column for audience-builder** - `audience-builder --execute` confirms Claude API production usage with a Clay Claygent web-research column fed by an inbound webhook. Build it once per workspace before running `--execute` with the app-side check. Plan mode and the WebSearch fallback need nothing. See [docs/setup/claygent-claude-usage-column.md](docs/setup/claygent-claude-usage-column.md).

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

## Skills inventory

- **audience-builder** - turns an ICP definition into a Clay-sourced, enriched list of accounts and contacts. Sits upstream of icp-scoring: it builds the pool, scoring ranks it. Plan mode by default, `--execute` to run against Clay. Requires the Clay Agent Plugin. The app-side Claude-usage check in `--execute` mode needs a one-time Claygent column setup, see [docs/setup](docs/setup/README.md).
- **account-research** - turns a company into a cited brief.
- **icp-scoring** - scores against your ICP, returns a tier and a recommended persona.
- **signal-classification** - classifies and ranks signals by event-aware recency for outbound fit.
- **contact-resolver** - resolves one real contact via the six-layer fallback waterfall with a confidence label.
- **icebreaker** - drafts peer-voice outreach calibrated to the trigger, with a stale-trigger gate.
- **email-verification** - turns Apollo status + catch-all into a verdict and a send recommendation.
- **meeting-prep** - builds a one-page pre-call brief from public and optional CRM context.
- **post-call** - turns call notes into a proposed CRM package and a reviewed follow-up.
- **output-review** - the five-criterion quality gate.

## Slash commands

- **/audience-builder** - build an audience from an ICP definition (plan by default, `--execute` to source and enrich in Clay). Plan mode needs no setup; `--execute` with the app-side Claude-usage check needs the Claygent column from [docs/setup](docs/setup/README.md).
- **/prospect** - the full chain on one company domain.
- **/draft-icebreaker** - one reviewed icebreaker for a known contact and trigger.
- **/verify-email** - a one-off email deliverability check.
- **/prep** - a pre-call meeting brief.
- **/wrap** - a proposed post-call package (review before writing to CRM).

## Hooks

- **style-guard.sh** - deterministic enforcement of banned phrases, cliches, jargon, and em dashes.
- **citation-check.sh** - deterministic enforcement of the source-preservation rule.

## Voice doctrine

See `CLAUDE.md`. Peer voice, no em dashes, source preservation, a three-component CTA, and banned cliches and SaaS jargon. Five output-reviewer criteria (A source preservation, B event specificity, C CTA structure, D robotic-CTA, E stale-trigger language) enforce the rules at draft time.

## Customization

- `config/icp.md` - who you target.
- `config/offering.md` - what you sell, how you describe it.
- `config/personas.md` - title priority lists by stage.
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

The `audience-builder` skill and `/audience-builder` command depend on the Clay Agent Plugin (the `clay` CLI plus its MCP tools), installed and authenticated in Claude Code. Clay is the primary source for TAM sourcing and enrichment, with Apollo MCP as the firmographic fallback and WebSearch as the last resort. See [docs/patterns/clay-integration.md](docs/patterns/clay-integration.md) for how the stack uses Clay's Search, Routines, and Tables primitives (including the read-only table limitation). The rest of the stack runs without Clay.
