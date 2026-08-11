---
name: meeting-prep
description: Use before a sales call or meeting to produce a grounded prep brief - who you are meeting, account context, deal and relationship state, talking points, questions, likely objections, and the desired next step. Invoked via /prep. Pulls public context from account-research and optional CRM context. Research and synthesis, fits a mid-tier model.
---

# Meeting prep

Turns a company plus contact (and any deal context) into a tight pre-call brief the rep can skim five minutes before the call.

## Inputs

- **Company + contact**: who the meeting is with (name, title, company or domain).
- **recent_context** (optional): deal stage, recent activity, prior touchpoints, notes, owner. Supplied manually or pulled from a CRM (see CRM integration). If empty, the skill falls back to public research only.
- **Meeting purpose** (optional): discovery, demo, negotiation, renewal, expansion.

## Process

1. If `recent_context` is empty, run [account-research](../account-research/SKILL.md) on the company for public context (snapshot, recent triggers, key people), all cited.
2. Combine the public context with `recent_context` (deal stage, prior meetings, notes, owner).
3. Build the brief below.

## Output: the brief

- **Who**: contact name, title, role in the deal; relationship owner if known.
- **Account snapshot**: one or two cited lines plus the single most relevant recent trigger.
- **Where the deal stands**: stage, amount, last activity, prior meetings (from `recent_context`; omit cleanly if absent).
- **Talking points**: two to four, tied to the trigger and the deal stage. Surface observations, do not diagnose.
- **Questions to ask**: three to five sharp, open questions that move the deal forward.
- **Likely objections**: one to three, each with a one-line response.
- **Desired outcome**: the single next step you want out of the call.

Keep it to a page. Cite public claims with their source; mark CRM-sourced facts as internal. This skill only reads context; it never writes anywhere.

## CRM integration (optional)

The `recent_context` input can be populated manually OR pulled from a CRM. To wire a CRM, add a tool call at the start of the skill that reads from your CRM's MCP. Reference shape for the CRM read:

Input to CRM read:

- `company_domain` (string)
- `contact_name` (string)

Expected output from CRM read (any subset is fine; missing fields skip gracefully):

- `deal_stage` (string)
- `deal_amount` (number, optional)
- `last_activity_date` (date string)
- `recent_notes` (string, recent notes on the contact or deal)
- `prior_meetings` (list, summaries of prior meetings)
- `relationship_owner` (string, the AE or CSM)

Once the CRM read completes, treat the returned data as the `recent_context` input and proceed with the skill logic. If the CRM returns nothing (no record for that company/contact), the skill falls back to the public account-research path only.

This skill DOES NOT WRITE to the CRM. It only reads.

## Review before presenting

Run the brief through [output-review](../output-review/SKILL.md) before presenting it. Call prep is inside the scope of the universal rules ([CLAUDE.md](../../CLAUDE.md)), which govern every artifact a prospect or customer might see, and a brief is where the seller's talking points, questions, and objection handling come from. What lands in the brief is what gets said on the call.

Both passes apply, with one adjustment. The mechanical pass is unchanged: the hard bans are bans, and jargon or an em dash in a talking point becomes jargon or a dropped clause in the seller's mouth. The judgment pass applies the criteria that carry over to a brief, which are source preservation and event specificity: every account claim needs its citation, and a trigger has to be specific enough to raise out loud. The criteria written for a cold email do not transfer, so skip the length target, the greeting, and the CTA structure. A brief is not an email and should not be trimmed to 70 words.
