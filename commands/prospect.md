---
description: Run the full prospecting funnel on a company - research, ICP scoring with skip-gate, signal classification, Apollo contact resolution, then a reviewed icebreaker to the verified contact. Produces a draft plus a reasoning trail and a contact; does not send.
argument-hint: <company name or domain>
model: opus
---

Run the prospect pipeline on the company in $ARGUMENTS. Default the offering to the one defined in [config/offering.md](../config/offering.md) and the next step to a 10-15 minute call unless told otherwise. Carry every cited fact forward with its source and date. Do not send anything; the deliverable is a draft plus reasoning plus a verified contact for human review.

Run in this order.

1. **account-research** - Build the cited brief: snapshot, stage, ranked triggers (each with source and date), key people, context.

2. **icp-scoring** - Score the company profile. Read the verdict before spending anything:
   - If `tier` is `skip`, STOP HERE, before any Apollo call. Surface the verdict and the one-paragraph reason. Do not spend Apollo credits on a company that does not fit.
   - If `recommendation` is `needs more data`, STOP. Report `missing_data` and what to find next.
   - Otherwise continue, and carry `recommended_persona` (the priority-ordered title list) into the Apollo step.

3. **signal-classification** - Rank the signals. The top item is the candidate trigger. Record its type, source, and outbound_fit.

4. **contact-resolver** - Resolve ONE real contact at the company. Pass `company_domain` and `recommended_persona` to the [contact-resolver](../skills/contact-resolver/SKILL.md) skill, which walks the six-layer Apollo waterfall (exact title -> family expansion -> function + seniority -> founder/CEO -> most senior -> graceful failure), runs `email-verification` on the result, and returns the contact, the layer that landed it, the confidence label, and the email verdict. If the email verdict is `catchall_unverifiable` or `guessed_risky`, surface a prominent warning above the draft. Email is a flag, never a gate. If no contact is found, surface that and stop before drafting.

5. **Trigger freshness gate.** Before drafting, check the top trigger's `outbound_fit` and recency status from signal-classification. If `outbound_fit` is below 7, OR the trigger is flagged undated, older, or stale, PAUSE here. Do NOT invoke the icebreaker. Surface the weak-trigger verdict and these options:
   - a) Skip - do not draft, mark as nurture.
   - b) Override - draft anyway with stale-appropriate framing (no recency verbs).
   - c) Wait for a fresher signal.
   Generate no draft until the user confirms an override or supplies a fresher trigger. On override, instruct the icebreaker to use anchored framing, not recency verbs.

6. **icebreaker** - Draft to the resolved contact, using the top signal as the trigger (source preserved), the offering, and the next step. **Confidence gate on persona claims:** if the contact's confidence is MEDIUM or lower, do not make persona-specific assumptions (no "you have been hiring", no role-specific guesses); stick to safe references tied to the company-level trigger. **Stale-trigger framing:** if this is an override of the freshness gate, avoid every recency-implying word (no "saw", "just", "recently", "shipped", "announced", "this week", "this month") and use anchored framing instead.

7. **output-review** - Run the mechanical pass (style-guard) and the judgment pass (Criteria A-E). Only present a draft that PASSES; if it returns REVISE, fix and re-review until it passes.

8. **Report** - Output the reasoning trail, then the draft, then the review verdict, in this shape:

       --- Reasoning trail ---
       Company: <name>
       Stage: <stage>
       ICP tier: <tier> (fit score <n>)
       Tier cap reason: <why the tier differs from the fit band, or "no cap, fit band stands">
       Recommended persona: <priority list>
       Apollo contact pulled: <name, title>
       Layer landed: <1-6> (<what matched>)
       Confidence: <HIGH | MEDIUM-HIGH | MEDIUM | LOW>
       Email: <address> (Apollo status: <verified | guessed | unknown | none>)
       Email verification verdict: <verdict>
       Verification confidence: <HIGH | MEDIUM | LOW>
       Verification recommendation: <send | manual_verify_before_send | do_not_send_without_verification | drop>
       Verification reason: <short explanation>
       LinkedIn: <url>
       Picked trigger: <signal> (<source>)
       Trigger freshness: <outbound_fit + status; note if this draft is a stale-trigger override>
       Offering angle: <one line>
       --- Draft ---
       Subject: <subject>
       <body>
       --- Review verdict ---
       <PASS, or REVISE with reasons>

The orchestrator does NOT send. It produces draft + reasoning + verified contact for human review. When the freshness gate or the ICP skip-gate halts the pipeline, the deliverable is the verdict and the reason.
