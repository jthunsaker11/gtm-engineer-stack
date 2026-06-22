---
name: icebreaker
description: Use when writing outreach to a prospect, customer, or contact - a single cold or warm message, or a multi-touch sequence. Takes context (recipient, trigger, offering, desired next step) and writes peer-voice copy that follows the stack doctrine. Triggers include "write an icebreaker", "draft outreach", "cold email", "write a follow-up", "build a sequence". Voice-critical, so run it on a top-tier model.
---

# Icebreaker craft

Turns context into the right outreach message. There is no fixed template: the VOICE is constant, the SHAPE adapts to the situation. The rules are in [CLAUDE.md](../../CLAUDE.md) and the calibration anchors are in [reference/voice.md](../../reference/voice.md). Read both before drafting if they are not already in context.

## Inputs

Gather these before writing. If any are missing, ask for them rather than inventing:

- **Recipient**: name, role, seniority, company.
- **Trigger**: the specific reason for the outreach, and its source. Every trigger needs a citation (the episode, the post, the funding announcement, the signup event). No source means no claim. If there is no trigger, treat it as a cold prospect (lowest hit rate) and say so.
- **Offering**: the product, service, or relationship being proposed.
- **Desired next step**: defaults to a 10-15 minute call.
- **Shareable content** (optional): a specific asset you actually have and could send. Without this field, the copy may not promise or offer any asset. Even when present, assets are follow-up material, not part of the initial ask.

## Process

1. **Classify the trigger** against the taxonomy in [reference/voice.md](../../reference/voice.md) (outbound, warm signal, relationship-stage, networking/partnership). The trigger type drives the opener phrasing.
2. **Open with the greeting and the specific source.** Line one is "Hey [name],". The first sentence after it names the concrete source. Quote back what they actually said over describing your reaction to it.
3. **Bridge with "so".** Connect the context to why it is relevant to them using "so", "and", or "because". The bridge is always there. Surface an observation; never tell them what their problem is.
4. **Build the CTA as three connected components.** An exploration question (ends with "?"), a conditional bridge ("if so" or equivalent), then a time-bounded ask (soft lead-in verb, concrete time bound, open time window). Produce all three. Follow the CTA discipline rule in [CLAUDE.md](../../CLAUDE.md). Never use a banned framing, never write a robotic ask, and never promise an asset unless a shareable content input was provided.
5. **Hold the length.** Target 40-70 words. If it crosses 80, cut.
6. **Write a subject line.** Short, specific, no clickbait, no exclamation points.

## The offering sentence

When you write the line naming what you do, apply the ICP qualifier rule from [CLAUDE.md](../../CLAUDE.md). Check whether the recipient's company is already named and clearly inside the ICP:

- If yes, drop the trailing qualifier. Write "that thesis is what I build agentic outbound and lifecycle systems around," not "...around for B2B SaaS teams." The context already established the lane.
- If no, and the recipient's space is unclear from context, keep the qualifier so they know what lane you work in.

## The CTA

Every CTA uses one pattern: honest deal exploration, built from three connected components.

1. **Exploration question** ending with "?" that frames the call as finding out if there is a real fit.
2. **Conditional bridge** ("If so," or equivalent) that makes the ask conditional on the question.
3. **Time-bounded ask** with a soft lead-in verb (would love to, happy to, would be great to), a concrete time bound (a quick 10-minute call, 15 minutes), and an open time window (in the next couple weeks, sometime next week). Canonical: "If so, would love to set up a quick 10-minute call in the next couple weeks."

Produce all three components. The call is framed as a short conversation to find out if there is a real fit, never as a peer chat, a content delivery, or a networking touch.

Hard rejections when building the CTA:

- Banned framing: "compare notes", "exchange ideas", "trade thoughts", "swap notes", "pick your brain".
- Robotic ask: bare "whenever works" as the time window, day-naming (Tuesday or Wednesday), a missing soft lead-in verb, or an ask sentence under eight words.
- A promise of content or assets (for example "happy to share what I put together") unless a `shareable_content` input was actually provided.

Full phrasings are in the CTA discipline rule in [CLAUDE.md](../../CLAUDE.md).

## Sequences

If asked for a multi-touch sequence:

- The **initial message** keeps the single clean CTA. No one-pager.
- **Reply 2** (first follow-up after no response) is where the one-pager comes in, e.g. "Following up here. Happy to send a one-pager if it's easier to share with your team first, or grab 10 minutes whenever works."
- Each touch stays inside the voice doctrine and the length target.

## Before presenting

Run the draft through the `output-review` skill. Do not present a draft that has an open mechanical violation or fails a judgment check. If a required input was missing (especially a trigger source), surface that instead of shipping an uncited claim.
