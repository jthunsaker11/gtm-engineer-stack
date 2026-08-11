---
description: Build a pre-call meeting brief - account context, deal state, talking points, questions, likely objections, and the desired next step.
argument-hint: <contact name> at <company or domain> (optionally paste deal/CRM context)
model: sonnet
---

Run the `meeting-prep` skill for the meeting in $ARGUMENTS. If deal or CRM context is included, use it as `recent_context`; otherwise fall back to public account-research.

Run the brief through `output-review` before presenting it, as the skill's review step describes: the mechanical pass in full, and the judgment criteria that carry over to a brief (source preservation and event specificity). Skip the email-shaped criteria; a brief is not an email. Present only a brief that passes.
