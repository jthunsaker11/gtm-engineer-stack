# Motions

A motion is how an account gets worked: its trigger, cadence, anchor style, approval rules, and
suppression rules. Each of the seven motions is one file in this folder. Skills that write or send
outreach read the relevant motion file to decide treatment; audience-builder tags each account with
an intended motion but does not execute it.

## Tier decides priority, motion decides treatment

Tier and motion are two orthogonal axes, and keeping them separate is the whole point of this design.

- **Tier (from icp-scoring: A, B, C)** answers *how good is this account and how hard should we work it*. It is a priority ranking: fit plus signal strength.
- **Motion (from this folder)** answers *how do we work it*: what triggers the outreach, how fast and how many touches, what the message anchors on, who approves it, and which suppression rules apply.

The same tier can run in different motions, and the same motion can hold different tiers. A Tier A
account might sit in signal-based (a fresh signal fired), in abm (it is on the named-account list), or
in wake-the-dead (it is closed-lost and a new hire landed). A single motion like nurture holds Tier C
accounts and also Tier A and B accounts that exhausted a sequence without a reply. Tier sets the
priority; motion sets the treatment.

audience-builder tags each row with an intended motion (`ab_motion`), auto-assigned per row from the
motion Tier defaults (Tier A and B to signal-based, Tier C to nurture) and overridable with the
`--motion` flag. It does not run the motion. Motion-aware execution belongs to later skills
(sequence-writer and its companions), which are not built yet.

## The seven motions

| Motion | One-line description |
| --- | --- |
| [cold-outbound](cold-outbound.md) | ICP-fit accounts with no signal; patient 3-touch pacing, generic pain anchor, human-approved. |
| [signal-based](signal-based.md) | A fresh buying signal fired; aggressive 4-touch over 10 days, event-anchored, first touch within 48 hours. |
| [abm](abm.md) | Curated named-account list; multi-channel coordinated campaign, 5 to 7 touches over 6 weeks, every touch human-approved. |
| [nurture](nurture.md) | Tier C or post-sequence accounts; monthly value-add content, indefinite until reply or unsubscribe, auto-send. |
| [inbound-followup](inbound-followup.md) | A hand-raise (form, demo, download); immediate follow-up, intent overrides tier, first touch human-approved. |
| [expansion](expansion.md) | Existing customer hits a milestone; single milestone-anchored message, auto-send, customer-context suppression. |
| [wake-the-dead](wake-the-dead.md) | Closed-lost account with new context; single honest re-engagement, human-approved, 6-month closed-lost cooldown. |

## Default and override

By default, audience-builder auto-assigns a motion per row from each motion's Tier defaults: Tier A
and B rows get **signal-based**, Tier C rows get **nurture**. The `--motion <name>` flag overrides
this, forcing a single motion across the whole run (useful for a named campaign), where `<name>` is
one of the seven files above. An unknown `--motion` name is rejected with the list of valid motions.
The assigned motion is written to the `ab_motion` column of the audience CSV so downstream skills know
the intended treatment for each row.
