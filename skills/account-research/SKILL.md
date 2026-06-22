---
name: account-research
description: Use when researching a company or account before outreach - gathering recent triggers, key people, and context into a cited brief that feeds the icebreaker skill. Triggers include "research [company]", "build an account brief", "what is going on at [company]", "find a trigger for [company]". Research and synthesis work, fits a mid-tier model.
---

# Account research

Turns a company into a cited brief an operator can act on. The output exists to feed the [icebreaker](../icebreaker/SKILL.md) skill a real trigger and the context around it. The rules are in [CLAUDE.md](../../CLAUDE.md); the trigger taxonomy is in [reference/voice.md](../../reference/voice.md).

## The one non-negotiable rule

**Every claim about the company or a person needs a citation: the source and what it says.** If you cannot source a fact, drop it. Do not infer, round up, or fill gaps with plausible-sounding detail. An uncited claim is worse than a missing one, because it poisons the outreach that depends on it.

## Inputs

- **Company**: name or domain (required).
- **Target persona**: the role or person you intend to reach (optional but sharpens the search).
- **Offering**: what you sell or propose (optional; focuses research on relevant context).

## Sources, in order of trust

1. The company's own surfaces: site, blog, newsroom, docs, careers page.
2. The target person's public activity: posts, podcasts, talks, interviews - anything where they said something quotable.
3. Recent news and funding records (date everything).
4. Hiring signals: open roles and job postings (what they are building, where they are investing).
5. Apollo MCP enrichment when connected (`.mcp.json`): organization enrich, job postings, people search. Use it for firmographics and contact data, not for claims you cannot otherwise see.

Note freshness. A trigger from this week beats a fact from last year. Stale triggers are weak triggers.

## Output: the brief

Produce these sections. Every line that asserts something carries its source inline.

- **Snapshot**: one or two cited lines on what the company is and does.
- **Recent triggers**: ranked by outreach relevance. For each: the trigger type (mapped to the taxonomy in [reference/voice.md](../../reference/voice.md)), the specific fact, the source, and the date. Lead with the freshest, most specific, most relevant.
- **Key people**: name, role, seniority, and any public activity worth quoting back.
- **Context**: tech stack, tooling, market position - whatever is relevant to the offering, cited.
- **Recommended angle**: the single best trigger to lead with, shaped as the icebreaker's inputs - recipient, trigger + source, offering, desired next step.

## Framing

Report facts; do not diagnose problems. Write "posted that RevOps spends Fridays reconciling pipeline across four tools [LinkedIn, 2026-06-21]", not "they clearly have a broken pipeline process." The icebreaker turns the fact into an observation. Your job is to hand it a true, sourced fact.

## Example (compact)

> **Snapshot**: Rippling, HR + IT + finance platform, ~3,000 employees [rippling.com/about, 2026-06].
>
> **Recent triggers**
> 1. Public pickup: VP Sales David Lin posted that RevOps loses every Friday reconciling pipeline across four tools [LinkedIn, 2026-06-21]. Fresh, specific, role-relevant.
> 2. Hire: posted a "RevOps Systems Lead" req last week [careers page, 2026-06-16]. Signals investment in the exact problem.
>
> **Key people**: David Lin, VP Sales, senior decision-maker; active on LinkedIn about GTM data.
>
> **Recommended angle**: Reach David Lin. Trigger = the Friday-reconciliation post [LinkedIn, 2026-06-21]. Offering = pipeline source-of-truth sync. Next step = 10-minute call.

Hand the Recommended angle block straight to the icebreaker skill.
