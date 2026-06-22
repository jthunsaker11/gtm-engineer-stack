---
description: Run the full prospecting funnel on a company - research, ICP scoring with skip-gate, signal classification, Apollo contact resolution, then a reviewed icebreaker to the verified contact. Produces a draft plus a reasoning trail and a contact; does not send.
argument-hint: <company name or domain>
model: opus
---

Run the prospect pipeline on the company in $ARGUMENTS. Default the offering to the consultancy's (GTM engineering: agentic outbound and lifecycle systems for B2B SaaS revenue teams) and the next step to a 10-15 minute call unless told otherwise. Carry every cited fact forward with its source and date. Do not send anything; the deliverable is a draft plus reasoning plus a verified contact for human review.

Run in this order.

1. **account-research** - Build the cited brief: snapshot, stage, ranked triggers (each with source and date), key people, context.

2. **icp-scoring** - Score the company profile. Read the verdict before spending anything:
   - If `tier` is `skip`, STOP HERE, before any Apollo call. Surface the verdict and the one-paragraph reason. Do not spend Apollo credits on a company that does not fit.
   - If `recommendation` is `needs more data`, STOP. Report `missing_data` and what to find next.
   - Otherwise continue, and carry `recommended_persona` (the priority-ordered title list) into the Apollo step.

3. **signal-classification** - Rank the signals. The top item is the candidate trigger. Record its type, source, and outbound_fit.

4. **Apollo contact resolution (six-layer waterfall)** - Find ONE real contact at the company using `apollo_mixed_people_api_search` with the company domain. Title strings vary wildly across companies, so walk the layers in order and stop at the first that returns a contact. Record which layer landed it and the confidence label.

   - **Layer 1 - exact title match (HIGH).** For each title in `recommended_persona`, query that exact title at the company domain. Return the top match if any layer-1 query lands.
   - **Layer 2 - title family expansion (HIGH).** If layer 1 fails, expand each persona title to its family and query the expanded set; return the most senior match.
     - VP Sales -> VP Sales, VP of Sales, Vice President of Sales, SVP Sales, Chief Revenue Officer, CRO, Head of Sales
     - Head of RevOps -> Head of Revenue Operations, VP RevOps, Director of Revenue Operations, VP Sales Operations, Head of GTM Ops
     - Head of Growth -> VP Growth, Director of Growth, Head of Marketing, VP Marketing
     - Founder -> Founder, Co-founder, CEO, Chief Executive Officer
   - **Layer 3 - functional area + seniority (MEDIUM).** Infer the department (Sales, Marketing, RevOps, Growth, Founder) from `recommended_persona`. Query with a department filter plus a seniority filter (VP-level and above). Return the most senior.
   - **Layer 4 - founder/CEO fallback (MEDIUM-HIGH for under 30 employees, MEDIUM otherwise).** Query for the founder, co-founder, or CEO. Under 30 employees the founder is often the real buyer regardless of org chart.
   - **Layer 5 - most senior person, any function (LOW).** Filter to C-suite, VP, or Founder seniority and return whoever is most senior.
   - **Layer 6 - graceful failure.** If layers 1-5 return nothing, surface: "Apollo returned no contacts after the full waterfall. Consider manual sourcing via LinkedIn Sales Nav." Do not invent a contact.

   **Email handling (flag, never gate):**
   - `email_status = verified` -> proceed clean.
   - `email_status = guessed` -> flag: "WARNING: pattern-guessed, not verified. Manually verify before send."
   - `email_domain_catchall = true` -> flag: "WARNING: catch-all domain. Pattern-guessed emails often bounce here. Manually verify before send (slice 6 will automate this)."
   - No email returned -> surface that, offer LinkedIn-only as the fallback, and include the LinkedIn URL.

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
       ICP tier: <tier> (score <n>)
       Recommended persona: <priority list>
       Apollo contact pulled: <name, title>
       Layer landed: <1-6> (<what matched>)
       Confidence: <HIGH | MEDIUM-HIGH | MEDIUM | LOW>
       Email: <address> (Apollo status: <verified | guessed | none>)
       Email catchall flag: <true | false>
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
