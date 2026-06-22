# Voice reference and calibration anchors

The rules live in [CLAUDE.md](../CLAUDE.md). This file holds the calibration material: how the skill applies the voice, the trigger taxonomy, the good/bad examples drafts are compared against, and the follow-up sequence rules.

## How the skill works

The icebreaker-craft skill takes context as input and writes the right message for that context. There is no fixed template. The VOICE is constant. The SHAPE adapts to:

- Recipient (role, persona, seniority)
- Trigger (the specific reason for the outreach)
- Offering (product, service, relationship)
- Desired next step

Calibrate the opener to the trigger. The "so" bridge between context and offer is always there. Voice doctrine governs the rest.

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
