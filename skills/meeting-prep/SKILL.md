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
