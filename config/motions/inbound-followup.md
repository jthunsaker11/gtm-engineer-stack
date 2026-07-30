# Motion: inbound-followup

## Overview
Fast follow-up to a hand-raise. This is the highest-intent motion in the stack, because the prospect
initiated the contact. Speed is the whole game: response time is the single biggest lever on whether
an inbound action converts to a conversation.

## Trigger
An inbound action: a form fill, a demo request, a content download, or a chat interaction.

## Anchor style
Reference the specific inbound action: the form they filled, the demo they requested, or the asset
they downloaded. The context is already established, so the message picks up exactly where they left
off.

## Cadence
Immediate, then a short follow-up window.
- Demo requests: first touch within 5 minutes.
- Form fills: first touch within 1 hour.
- If no reply, follow-up pacing mirrors signal-based (touches over roughly 10 days).
Break-up rule: after the short follow-up window with no reply, exit the account to nurture.

## Tier defaults
Intent overrides tier. Any account that raises a hand enters inbound-followup regardless of its tier;
the inbound action outranks the account's fit tier.

## Approval requirements
Human-approve the first touch, because a hand-raise deserves a real person and speed is not an excuse
for a wrong message. Later touches are auto-eligible.

## Suppression rules
Bypass the frequency cap (inbound override: a hand-raise is not spam, so a concurrent sequence does not
block the response), but respect the unsubscribe and bounce lists.

## Success signals
Speed-to-first-touch is the core metric. Then reply rate (high, because intent is high), meeting-booked
rate, and inbound-to-opportunity conversion.
