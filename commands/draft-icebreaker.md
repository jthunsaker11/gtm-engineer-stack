---
description: Draft a single peer-voice icebreaker for a known contact and trigger, then run it through output-review. Standalone access to the icebreaker skill without the full prospect chain.
argument-hint: <contact, company, trigger + source, your offering and next step>
model: opus
---

Run the `icebreaker` skill on the context in $ARGUMENTS: recipient, the trigger with its source, the offering, and the desired next step. Apply the trigger freshness gate. Then run the draft through `output-review` (Criteria A-E plus the style-guard hook) and present only a passing draft.
