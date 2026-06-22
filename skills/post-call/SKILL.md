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
