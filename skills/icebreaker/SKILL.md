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

## Process

1. **Classify the trigger** against the taxonomy in [reference/voice.md](../../reference/voice.md) (outbound, warm signal, relationship-stage, networking/partnership). The trigger type drives the opener phrasing.
2. **Open with the greeting and the specific source.** Line one is "Hey [name],". The first sentence after it names the concrete source. Quote back what they actually said over describing your reaction to it.
3. **Bridge with "so".** Connect the context to why it is relevant to them using "so", "and", or "because". The bridge is always there. Surface an observation; never tell them what their problem is.
4. **One clean CTA.** A single ask for a short call (10-15 minutes). Do not pre-offer a one-pager, deck, or alternative in an initial message.
5. **Hold the length.** Target 40-70 words. If it crosses 80, cut.
6. **Write a subject line.** Short, specific, no clickbait, no exclamation points.

## Sequences

If asked for a multi-touch sequence:

- The **initial message** keeps the single clean CTA. No one-pager.
- **Reply 2** (first follow-up after no response) is where the one-pager comes in, e.g. "Following up here. Happy to send a one-pager if it's easier to share with your team first, or grab 10 minutes whenever works."
- Each touch stays inside the voice doctrine and the length target.

## Before presenting

Run the draft through the `output-review` skill. Do not present a draft that has an open mechanical violation or fails a judgment check. If a required input was missing (especially a trigger source), surface that instead of shipping an uncited claim.
