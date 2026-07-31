# Motion: cold-outbound

## Overview
Outreach to accounts that fit the ICP but show no active buying signal. This is the lowest-intent
motion in the stack: there is no event to anchor on, so the message leans on positioning and a
relevant pain point rather than timing. Pacing is patient because there is no reason to rush a
cold account, and a heavy cadence into a no-signal account reads as spam.

## Trigger
ICP fit alone. No signal is required to enroll. In practice this is the motion for Tier C accounts,
and the fallback for any fit account that has no fresher motion available.

## Anchor style
Generic pain point drawn from config/offering.md (the value proposition and the common objections).
When the account carries no fresh signal, there is no trigger to reference, so do not use recency
verbs. When it does carry one (the Tier C with a live signal case), anchor on that signal with its
source and date the way any dated trigger is handled; the patient cadence is what makes this motion
different from signal-based, not a rule against naming a real event. Either way, surface a relevant
problem and let the account connect it, per the voice doctrine in CLAUDE.md.

## Cadence
Patient: 3 touches over 3 weeks.
- Touch 1: day 0.
- Touch 2: day 7.
- Touch 3: day 21, the break-up message.
Break-up rule: after touch 3 with no reply, exit the account to nurture.

## Tier defaults
Not a tier default on its own; the router keys on tier plus fresh-signal count. Cold-outbound owns
two cells of that table: a Tier C account that does have a live signal (marginal fit, so it gets the
patient pace and a human, not the aggressive signal-based cadence), and the defensive case of a Tier
A or B account carrying zero fresh signals, which has fit but no event to anchor. It is also what
`--motion cold-outbound` forces for an explicit cold campaign. Tier C with no signal belongs to
nurture, not here.

## Approval requirements
Human-approve every touch. Cold accounts carry the highest misfire risk (no context to ground the
message), so a person reviews each send.

## Suppression rules
Strict. Respect every suppression list: unsubscribe, bounce, do-not-contact, the frequency cap, and
the active-sequence check (never enroll an account already in another sequence).

## Success signals
Reply rate and positive-reply rate (cold benchmarks are low, typically 1 to 3 percent), and meeting
rate. Track whether cold-outbound converts better than leaving the account in nurture, to justify the
human-approval cost.
