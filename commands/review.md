---
description: Review a prospect-facing draft against the stack doctrine (voice, length, CTA discipline, citations, hard bans) and return PASS or a corrected version.
argument-hint: [paste a draft, or a path to a file containing one]
model: opus
---

Review the following draft (or, if it is a file path, the contents of that file) using the `output-review` skill. Run both passes: the mechanical style-guard scan and the judgment checklist. Return the skill's verdict - either PASS with a note that it is ready to send, or REVISE with each violation named and a corrected draft.

If no draft is provided below, review the most recent outreach draft in the conversation.

Draft:
$ARGUMENTS
