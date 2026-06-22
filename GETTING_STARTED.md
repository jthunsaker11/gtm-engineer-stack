# Getting started

This walks you from a fresh clone to your first `/prospect` run, then shows where to customize.

## 1. Install Claude Code

Install Claude Code (CLI, desktop app, or IDE extension) from Anthropic, then open this repo as your working directory. The stack is a Claude Code plugin: its `skills/`, `commands/`, and `hooks/` load automatically when Claude Code runs inside the repo.

Verify Claude Code sees the stack by running `/prospect` with no argument; it should describe the orchestrator.

## 2. Get an Anthropic API key

1. Create a key at the Anthropic Console (console.anthropic.com).
2. Copy `.env.example` to `.env`.
3. Paste the key into `.env` as `ANTHROPIC_API_KEY=...`.

`.env` is gitignored. Never commit it.

## 3. Connect the Apollo MCP plugin

The `/prospect` contact-resolution step calls Apollo through MCP. Add the Apollo MCP server in Claude Code (via the MCP settings UI or `claude mcp add`), pointing at Apollo's hosted MCP endpoint. Apollo uses OAuth, so you authorize once in the browser; server metadata is published at `https://mcp.apollo.io/.well-known/oauth-authorization-server`.

Contact **search** is free. Revealing a verified email is **enrichment**, which costs 1 Apollo credit per contact and the orchestrator will ask before spending it.

If Apollo is not connected, the rest of the chain still runs; the contact step reports that Apollo is unavailable and falls back to manual sourcing.

## 4. Edit the three config files

This is the whole customization surface. With your values in place, the stack works for your business.

- `config/icp.md` - your ideal customer profile: industry, stage range, employee size, motion, buyer personas, exclusions, and the scoring dimensions.
- `config/offering.md` - what you sell and the exact sentence the icebreaker uses to describe it, plus when to drop the ICP qualifier.
- `config/personas.md` - the title priority lists per stage, and the title-family expansions the Apollo waterfall uses at layer 2.

The files ship with a worked example (a GTM-engineering consultancy) so you can see the shape, then replace the values.

## 5. Run your first /prospect

```
/prospect <company-domain>
```

The orchestrator runs account research, scores the company against your ICP, classifies its signals, resolves a contact through the Apollo waterfall, drafts a peer-voice icebreaker, runs it through the review gate, and returns a reasoning trail plus the draft plus the contact. It does not send anything.

If the company is off-ICP, the ICP gate stops the run before any Apollo call. If the best trigger is stale, the freshness gate pauses and asks whether to skip, override, or wait for a fresher signal.

## 6. Customizing the voice doctrine (advanced)

The voice doctrine in `CLAUDE.md`, the scoring rubric in `skills/icp-scoring`, the waterfall in `commands/prospect.md`, and the review criteria in `skills/output-review` are the opinionated core. They encode how the stack writes and judges outreach.

Changing them changes the fundamentals. If your outreach voice is genuinely different from the peer-operator default, edit the voice doctrine sections of `CLAUDE.md` and the calibration anchors in `reference/voice.md` together, then re-read the output-review criteria so the gate still matches your intent. Most users never need to touch these.
