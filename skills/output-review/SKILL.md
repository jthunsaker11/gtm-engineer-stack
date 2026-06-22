---
name: output-review
description: Use when reviewing any prospect-facing draft (icebreaker, cold email, multi-touch sequence, research summary, or call prep) before it is sent or delivered. Checks voice, length, CTA discipline, citations, framing, and the hard style bans against the stack doctrine. Best run on a top-tier model since the judgment passes are subjective.
---

# Output review

The quality gate for everything a prospect or customer might see. Run this before any draft ships. It has two passes: a mechanical pass that is deterministic, and a judgment pass that is not.

The rules are in [CLAUDE.md](../../CLAUDE.md). The calibration anchors are in [reference/voice.md](../../reference/voice.md). Read both before reviewing if they are not already in context.

## Pass 1: mechanical (deterministic)

Run the style-guard hook script against the draft. It flags every hard ban (em dashes, cliches, try-hard phrasing, SaaS jargon, exclamation points) with line numbers:

    printf '%s' "<draft text>" | "${CLAUDE_PLUGIN_ROOT:-.}/hooks/style-guard.sh"

Exit code 0 means clean. Exit code 2 means violations were printed to stderr. Every flagged item must be fixed. Do not exercise judgment here; these are bans.

## Pass 2: judgment

The script cannot catch these. Check each against the doctrine and the anchors in [reference/voice.md](../../reference/voice.md):

- **Length**: 40-70 words is the target. Over 80, cut. Count the words.
- **Greeting**: line one opens with "Hey [name]," or equivalent.
- **Specific source**: the first sentence after the greeting names a concrete source (the episode, the post, the funding round, the signup). Vague openers like "saw your team is scaling" fail.
- **The "so" bridge**: context connects to relevance with "so", "and", or "because". If the offer is bolted on, it fails.
- **Surface, don't diagnose**: the draft surfaces an observation and lets the recipient connect the pain. It never tells them what their problem is.
- **Citations**: every claim about the company or person traces to a source.
- **CTA discipline**: one clean ask for a 10-15 minute call. No one-pager, deck, or alternative pre-offered in an initial message. In a sequence, the one-pager belongs in Reply 2, not Reply 1.
- **Flow**: read it aloud. Each sentence picks up the previous one. Nothing reads as bolted on.
- **Peer voice, not vendor**: sharp observation, plain words, no flattery without specifics, no name-dropping.

## Verdict

Report one of:

- **PASS**: clean on both passes. State that it is ready to send.
- **REVISE**: list each violation with its category and the exact offending text, then provide a corrected draft that fixes everything while preserving the original intent and context.

Never pass a draft with an open mechanical violation. For judgment calls, when something is borderline, explain the tension and recommend the tighter option.
