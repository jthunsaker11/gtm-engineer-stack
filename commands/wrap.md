---
description: Turn call notes into a proposed post-call package - deal-stage recommendation, action items, a CRM-ready summary, and a reviewed follow-up email. Proposes only; never writes to a CRM.
argument-hint: <paste call notes> (optionally include the current deal stage)
model: sonnet
---

Run the `post-call` skill on the call notes in $ARGUMENTS. Produce the proposed package and run the follow-up email draft through `output-review`. Present the package for the user to review and write to their CRM themselves. Do not write to any CRM.
