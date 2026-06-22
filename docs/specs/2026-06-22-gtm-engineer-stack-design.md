# gtm-engineer-stack: design

Date: 2026-06-22

## What this is

An opinionated Claude Code configuration that packages GTM engineering workflows as skills, slash commands, and hooks. Thesis: every GTM Engineer rebuilds the same workflows in different tools. This packages eight already-shipped systems (ICP scoring, account research, peer-voice icebreaker generation, Apollo + catch-all email verification, signal classification, pre-call meeting prep, post-call CRM + follow-up, output review) as a reusable stack to hand a new GTM Engineer on day one.

## Decisions

1. **Packaged as an installable Claude Code plugin** (`.claude-plugin/plugin.json`), not a loose config repo. One-command install matches the day-one handoff thesis.
2. **Hard style rules enforced by hook + skill split.** A deterministic regex hook (`style-guard`) blocks the mechanical bans (em dashes, banned phrases, exclamation points); the `output-review` skill handles the judgment rules (peer voice, surface-don't-tell, citations, CTA discipline, flow).
3. **MCP is a real `.mcp.json`** (Apollo, Notion, Slack) with env-var placeholders, not prose notes.

## Layout

    gtm-engineer-stack/
    .claude-plugin/plugin.json     manifest
    CLAUDE.md                      hard rules + voice doctrine (always loaded)
    README.md                      what it is, install, the 8 workflows
    .mcp.json                      Apollo / Notion / Slack config
    skills/                        output-review, icp-scoring, account-research,
                                   signal-classification, email-verification,
                                   icebreaker, meeting-prep, post-call
    commands/                      prospect, verify-email, prep, wrap, review
    hooks/                         style-guard.sh, citation-check.sh, hooks.json
    reference/                     voice.md (peer-voice anchors, shared by skills)

Commands map to workflows, not 1:1 to skills. Skills like `signal-classification` and `output-review` are invoked by the model mid-workflow.

## Build order

Build the cross-cutting quality gate first, then one full vertical slice to prove the pattern, then fill in breadth. Commit between each slice.

1. `CLAUDE.md` + `output-review` skill + `style-guard` hook + `reference/voice.md` + plugin manifest (the spine, installable, before anything it judges).
2. `icebreaker` skill + `review` command (highest-value, most voice-sensitive; slams into the review loop immediately).
3. `account-research` skill (the icebreaker's inputs; exercises citation discipline).
4. `icp-scoring` + `signal-classification` (the upstream which-accounts / what-timing layer).
5. `prospect` command (wires 2-4 into the end-to-end funnel).
6. `email-verification` + `verify-email` command (first hard Apollo dependency, isolated).
7. `meeting-prep` + `post-call` skills + `prep` / `wrap` commands (later-funnel, least coupled to voice).
8. `citation-check` hook, `README.md`, polish.

## Model assignment

Per task: Haiku for `signal-classification`, `email-verification` parsing, the style-guard logic; Sonnet for `account-research`, `meeting-prep`, `post-call`; top-tier for `icebreaker` and the judgment half of `output-review`. Encoded via `model:` frontmatter on commands where supported.

## Status

- **Slices 1-4 + CTA hardening (done):** committed.
- **Slice 5 (done):** /prospect orchestrator. Chain: account-research -> icp-scoring (skip-gate) -> signal-classification -> Apollo six-layer contact waterfall -> trigger freshness gate -> icebreaker -> output-review. icp-scoring gained recommended_persona. Validated end-to-end on Pocus (layer 1), Vitally (layer 2, unconventional title), and an off-ICP skip.
- **Stale-trigger gate (done):** icebreaker freshness gate + output-review Criterion E block recency-implying language on stale triggers.
- **Next:** slice 6, email-verification + verify-email (Apollo enrichment + catch-all handling).
