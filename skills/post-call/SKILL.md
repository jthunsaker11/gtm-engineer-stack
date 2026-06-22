---
name: post-call
description: Use after a sales call to turn notes into a proposed CRM update and follow-up - a deal-stage recommendation, action items with owners and deadlines, a CRM-ready summary, and a reviewed follow-up email. Invoked via /wrap. Proposes a package for human review; never writes to a CRM. Synthesis plus voice, fits a mid-tier model.
---

# Post-call

Turns call notes into a review-ready package. It proposes; it never writes.

## Inputs

- **Call notes or transcript** (required): what happened on the call.
- **Deal context** (optional): current stage, amount, owner, from CRM or supplied manually. Grounds the stage recommendation in the actual current stage.
- **Contact + company**.

## Output: the proposed package

1. **Deal stage update recommendation**: advance / stay / regress / on-hold, with a one-line reason tied to what happened on the call. Relative to the current stage when it is provided.
2. **Action items**: each with a proposed owner and a deadline.
3. **CRM-ready summary**: one tight paragraph capturing the outcome, the next steps, and the stage rationale.
4. **Follow-up email draft**: peer voice, recapping the call and confirming the agreed next step. Run it through [output-review](../output-review/SKILL.md) before presenting. Keep the ask clean; a post-call follow-up may reference materials that were actually discussed.

The package exists for the user to review and write themselves. This skill never writes to a CRM.

## CRM integration (optional)

The post-call output is structured so the user can review and write to CRM themselves. The skill DOES NOT WRITE to the CRM. To make the output CRM-ready:

Output already provides:

- Deal stage update recommendation (advance / stay / regress / on-hold)
- Action items with proposed owners and deadlines
- CRM-ready summary paragraph
- Follow-up email draft

To wire a CRM for proposing (not executing) writes:

- Read the current deal stage from CRM at the start of the skill, so the recommendation is relative to the actual current stage
- Format the action items as objects matching your CRM's task schema (HubSpot tasks have `title` + `due_date` + `assigned_to_owner_id`; Salesforce uses similar fields)
- Surface the FULL proposed CRM update package as a JSON block in the post-call output for easy copy-paste or script consumption

Recommended workflow for production:

1. User reviews the post-call package
2. User approves the changes
3. A separate script (NOT this skill) takes the approved JSON and writes it to CRM
4. The script logs each write back to a local audit trail

This separation keeps the stack itself safe (no accidental writes) while making the output trivially scriptable for users who want full automation.
