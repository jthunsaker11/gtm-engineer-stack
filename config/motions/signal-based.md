# Motion: signal-based

## Overview
Outreach triggered by a fresh, specific buying signal on a fit account. This is the highest-intent
cold motion: a real event has changed the account's context, so speed and event-anchoring do the
work. The whole advantage decays with time, which is why the first touch is measured in hours, not
days.

## Trigger
A fresh signal fires on a fit account: job change, funding round, hiring spike, competitor evaluation,
product launch, or any of the buying signals defined in config/offering.md. The first touch goes out
within 48 hours of the signal.

## Anchor style
Event-anchored. Reference the specific signal with its source and date, per the source-preservation
rule in CLAUDE.md. Recency verbs are appropriate here because the trigger is genuinely fresh.

## Cadence
Aggressive: 4 touches over 10 days.
- Touch 1: within 48 hours of the signal.
- Touch 2: day 3.
- Touch 3: day 6.
- Touch 4: day 10, the break-up message.
Break-up rule: after touch 4 with no reply, exit the account to nurture.

## Tier defaults
The default for a Tier A or Tier B account that carries at least one fresh signal, which after the
fresh-signal cap in icp-scoring is every Tier A and Tier B account. The fresh signal is required, not
incidental: this motion's trigger is an event and its first touch goes out within 48 hours of it, so
an account with nothing live to anchor on routes to cold-outbound instead.

## Approval requirements
Human-approve for Tier A. Auto-send for Tier B after the output-review pass (Criteria A to E) clears
the draft. Tier A always gets a human, because the highest-priority accounts are the ones a misfire
costs the most.

## Suppression rules
Strict. Respect every suppression list: unsubscribe, bounce, do-not-contact, the frequency cap, and
the active-sequence check.

## Success signals
Reply rate (higher than cold, typically 5 to 10 percent), meeting rate, time from signal to meeting,
and opportunity conversion. Signal-to-first-touch latency is a leading indicator; if it drifts past
48 hours the motion loses its edge.
