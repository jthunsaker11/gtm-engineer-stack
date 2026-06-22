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
- **CTA discipline**: three connected components - exploration question, "if so" bridge, and a time-bounded ask. No banned framings, no robotic asks, no promised assets. Enforced as hard rejections in Criteria C and D.
- **Flow**: read it aloud. Each sentence picks up the previous one. Nothing reads as bolted on.
- **Peer voice, not vendor**: sharp observation, plain words, no flattery without specifics, no name-dropping.

## Source preservation and event specificity (hard rejections)

These reject regardless of how strong the rest of the draft is.

**Criterion A, source preservation:** Scan the draft for verbs of speaking: said, mentioned, wrote, shared, talked about, told, posted. If any of those verbs appears, verify that a named source (podcast plus episode info, post date, interview title, announcement, blog post name) appears within fifteen words. If not, reject with the exact reason: "source dropped between research and outreach. The research had a citation; the copy lost it. Restore the source in the copy or remove the quoted claim."

**Criterion B, event specificity:** If the draft references a corporate event using terms like joining, partnering, joined, moving to, acquired by, verify the framing makes the event type unambiguous. If a reader could reasonably interpret it as multiple events (acquisition vs exec hire vs partnership), reject with the exact reason: "ambiguous event reference. Specify the event type."

**Criterion C, CTA structure:** The CTA must contain all three components from the CTA discipline rule: an exploration question (ends with "?"), a conditional bridge ("if so", "if yes", or equivalent), and a time-bounded ask. Reject if any of the three is missing, with the exact reason: "incomplete CTA. It needs an exploration question, an 'if so' bridge, and a time-bounded ask."

**Criterion D, robotic-CTA detection:** Flag the ask sentence if the time window is "whenever works" with no qualifier after it (the phrase ends the sentence or is followed only by punctuation), if it names specific days of the week (for example Tuesday or Wednesday), if it lacks a soft lead-in verb (would love to, happy to, would be great to), or if it runs fewer than eight words. A qualified window such as "whenever works on your end this month" is acceptable and passes. Reject with the exact reason: "robotic CTA. The ask sentence needs a soft lead-in verb, a concrete time bound, and an open time window that reads as invitation, not transaction."

Also reject any banned framing (compare notes, exchange ideas, trade thoughts, swap notes, pick your brain) and any promised asset when no shareable_content input was provided.

## Verdict

Report one of:

- **PASS**: clean on both passes. State that it is ready to send.
- **REVISE**: list each violation with its category and the exact offending text, then provide a corrected draft that fixes everything while preserving the original intent and context.

Never pass a draft with an open mechanical violation. For judgment calls, when something is borderline, explain the tension and recommend the tighter option.
