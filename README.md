# gtm-engineer-stack

An opinionated Claude Code stack that turns one slash command into a full outbound chain: account research, ICP scoring, signal classification, Apollo MCP contact resolution with a six-layer fallback waterfall, peer-voice icebreaker drafting, and five-criterion output review.

Built to be cloned. Edit three files for your business and you have a working AI-assisted GTM workspace in 10 minutes.

## What it does

- **account-research** - turns a company into a cited brief: snapshot, ranked triggers, key people, context.
- **icp-scoring** - scores a company against your ICP across seven dimensions, returns a tier and a recommended persona.
- **signal-classification** - classifies and ranks signals by type, intensity, and event-aware recency for outbound fit.
- **icebreaker** - drafts peer-voice outreach calibrated to the trigger, with a stale-trigger gate.
- **output-review** - a five-criterion quality gate (source preservation, event specificity, CTA structure, robotic-CTA, stale-trigger language) plus a deterministic style-guard hook.
- **/prospect** - the orchestrator that runs the whole chain on one company, resolves a real contact via Apollo, and hands back a draft plus a reasoning trail. It does not send.

## Quickstart

1. Clone this repo.
2. Copy `.env.example` to `.env` and add your `ANTHROPIC_API_KEY`.
3. Install the Apollo MCP plugin in Claude Code (see [GETTING_STARTED.md](GETTING_STARTED.md)).
4. Edit [config/icp.md](config/icp.md) - your ICP.
5. Edit [config/offering.md](config/offering.md) - what you sell.
6. Edit [config/personas.md](config/personas.md) - who you target.
7. Run `/prospect <company-domain>`.

## Architecture

```
/prospect <company-domain>
        |
        v
  account-research  ---> cited brief (snapshot, triggers, people, context)
        |
        v
  icp-scoring       ---> tier + recommended_persona  --[ tier = skip ]--> STOP (no Apollo spend)
        |
        v
  signal-classification -> ranked triggers (event-aware recency)
        |
        v
  Apollo waterfall  ---> verified contact (6 layers, confidence label)
        |
        v
  freshness gate    ---> [ outbound_fit < 7 ] --> PAUSE (skip / override / wait)
        |
        v
  icebreaker        ---> peer-voice draft
        |
        v
  output-review     ---> PASS / REVISE (Criteria A-E + style-guard)
        |
        v
  reasoning trail + draft + contact   (does not send)
```

## What's customizable vs. fixed

**Yours to edit (`config/`):**
- `config/icp.md` - your ideal customer profile and scoring dimensions
- `config/offering.md` - what you sell and how you describe it
- `config/personas.md` - title priority lists and waterfall expansions

**The opinionated core (leave alone unless you mean it):**
- `CLAUDE.md` voice doctrine - the peer-voice writing rules
- `skills/` - the scoring rubric, the waterfall logic, the review criteria
- `hooks/style-guard.sh` - the deterministic ban list

Change the core only if you want to change the fundamental writing rules or scoring logic. Full setup walkthrough in [GETTING_STARTED.md](GETTING_STARTED.md).
