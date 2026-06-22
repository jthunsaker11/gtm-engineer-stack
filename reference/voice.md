# Voice reference and calibration anchors

The rules live in [CLAUDE.md](../CLAUDE.md). This file holds the calibration material: how the skill applies the voice, the trigger taxonomy, the good/bad examples drafts are compared against, and the follow-up sequence rules.

## How the skill works

The icebreaker-craft skill takes context as input and writes the right message for that context. There is no fixed template. The VOICE is constant. The SHAPE adapts to:

- Recipient (role, persona, seniority)
- Trigger (the specific reason for the outreach)
- Offering (product, service, relationship)
- Desired next step

Calibrate the opener to the trigger. The "so" bridge between context and offer is always there. Voice doctrine governs the rest.

## Source-preservation rule (research-to-outreach contract)

Whenever the research step has surfaced a sourced fact about the recipient (a quote with a citation, a post with a date, a podcast with an episode), the outreach step must preserve that source attribution in the copy. Dropping the source while keeping the quote is banned, even when the quote is accurate, because the recipient cannot verify a floating "you said" claim and will read it as a guess.

Concrete patterns to flag:

- If the draft contains a verb of speaking (said, mentioned, wrote, shared, talked about, told, posted), the source must appear within fifteen words. Acceptable forms: "In the Apollo acquisition announcement you mentioned X." "On your Topline episode in May you said X." "In your March LinkedIn post you wrote X." Unacceptable forms: "You said X" with no nearby source. "You mentioned X" with no nearby source.
- If the research step's output JSON had a source field for a fact, and that fact gets reused in the icebreaker, the source field must travel with it into the icebreaker prompt and must appear in the final copy. The icebreaker-craft skill should treat dropping a source as a hard failure.
- Default when no source can be cited: drop the quote, reference only the observable event.

## ICP qualifier rule

When the trigger context (the recipient's company, role, or referenced public content) already establishes the ICP, drop the ICP qualifier from the offering sentence. "For B2B SaaS teams" or "for revenue teams" is filler when the recipient is obviously inside that space. The qualifier exists for emails where the recipient does not yet know what lane you work in. In high-context emails, repeating the ICP reads as throat-clearing and costs words without adding credibility.

Rule of thumb: if the trigger references a company the recipient leads or works at, and that company is clearly in your stated ICP, the ICP qualifier is dropped. If the email is going to someone whose space is unclear from context, the qualifier stays.

## Event-specificity rule

When referencing a corporate event, the wording must be specific enough that the recipient can identify which event you mean. "Pocus is joining Apollo" is ambiguous between acquisition, partnership, and the founder personally moving. "Saw Apollo acquired Pocus" is specific. "Saw you joined Apollo's leadership team" is specific. If the research step returned multiple possible event types, the icebreaker must pick one and frame it precisely.

## CTA discipline rule

The CTA closes the email with three connected sentences working together:

- Exploration question. Ends with a question mark. Frames the call as honest deal exploration.
- Conditional bridge. "If so," or equivalent. Connects the question to the concrete next step.
- Time-bounded ask. Ends with a period. Names what they are saying yes to.

Why the three-sentence structure: a standalone exploration question followed by a standalone time-bounded ask reads as two disconnected statements. The "if so" bridge makes the second sentence conditional on the first, which is how a peer would actually write it.

Exploration question examples (always end with a question mark):

- "Want to explore whether there is a GTM engineering angle worth a conversation?"
- "Curious whether the integration creates a need on the GTM engineering side?"
- "Worth seeing if there is a fit on the work I do?"

Canonical time-bounded ask:

- "If so, would love to set up a quick 10-minute call in the next couple weeks."

Principle for the ask sentence: every CTA ask must have a soft lead-in verb, a concrete time bound, and an open time window. The combination is what makes it flow.

Soft lead-in verbs that work: would love to, happy to, would be great to

Concrete time bounds that work: a quick 10-minute call, 15 minutes, a short call

Open time windows that work: in the next couple weeks, sometime next week, whenever works on your end this month

Banned framings:

- "compare notes"
- "exchange ideas"
- "trade thoughts"
- "swap notes"
- "pick your brain"
- "would love to chat about X" with no specific frame
- Any CTA that promises content or assets the sender does not actually have

Robotic anti-patterns to avoid in the ask sentence:

- "Whenever works" alone as the time window (filler with no invitation)
- Day-naming like "Tuesday or Wednesday" (reads as a Calendly slot, not a peer asking)
- Missing soft lead-in verb ("Can grab 10 minutes" with no warmth)
- Choppy clauses that do not connect

The principle: every CTA is honest about what the call is. It is deal exploration. Not a peer chat, not a content delivery, not a networking touch. The recipient knows what they are saying yes to: a short conversation to find out if there is a real fit. That is the entire pitch.

## Trigger types (non-exhaustive)

The skill picks the opener phrasing based on trigger.

**Outbound**
- Funding event (any round, valuation, listing)
- Hire (exec, role opening, hiring spike, leadership change)
- Product launch, feature release, market expansion
- M&A activity
- Tech stack change
- Public pickup: podcast, post, talk, interview where they said something quotable
- Cold prospect with no trigger (lowest hit rate; use only when context is missing)

**Warm signals**
- Trial signup, demo request
- Webinar or event attendance
- Content download or repeated engagement
- Inbound referral

**Relationship-stage**
- Champion job change (reach them at new company)
- Champion left old company (reach new contact at old company)
- Dormant lead re-engagement
- Renewal approaching
- Expansion opportunity
- Win-back
- Competitive displacement

**Networking and partnerships**
- Networking on a shared topic
- Partnership initiation
- Investor or intro request

## Reference examples

These are calibration anchors. The output-review skill compares new drafts against these for shape, length, voice, and CTA discipline.

**GOOD (podcast pickup, 50 words)**

> Hey Sarah, listened to your GTMfund episode last week. You mentioned marketing keeps claiming credit for deals AEs started. We built something that tags every touch with its source the moment it lands in HubSpot, so the attribution argument resolves itself. Open to 10 minutes next week?

**GOOD (funding signal, 43 words)**

> Hey Marcus, saw the Series B, congrats. The multi-region spec you posted yesterday is going to be interesting on the GTM data side. We built something for revenue teams running into exactly that. Open to grabbing 10 minutes next week?

**GOOD (trial signup, 39 words)**

> Hey Priya, saw you signed up this morning. Most teams hit the ICP setup step and bail because the docs are dense. Want to grab 10 minutes today and I'll walk you through it?

**GOOD (champion job change, 38 words)**

> Hey Jordan, saw you landed at Notion, congrats. The work you did at Ramp on lifecycle was exactly the kind of thing the Notion team has been hiring for. Open to catching up in the next couple weeks?

**BAD**

> Hey Sarah, quick question about your attribution setup. Saw your team is scaling fast and wanted to reach out because we help GTM leaders unlock pipeline visibility. Our platform leverages AI to give you world-class attribution, happy to send a one-pager or grab a 15-min chat next week?

Why bad: "quick question" cliche, "wanted to reach out" cliche, vague "saw your team is scaling", "help you unlock" + "leverages AI" + "world-class" jargon stack, dual CTA pre-offering the one-pager.

## Follow-up sequence note

When the cold-email skill generates a multi-touch sequence, Reply 2 (the first follow-up after no response) is where the one-pager comes in. Example follow-up phrasing:

> Following up here. Happy to send a one-pager if it's easier to share with your team first, or grab 10 minutes whenever works.

The sequence builder must never pre-offer the one-pager in the initial message. Reserving the value-add asset for the moment it has the most leverage (when they have engaged but need a bridge) keeps the initial message tight and the ask clear.
