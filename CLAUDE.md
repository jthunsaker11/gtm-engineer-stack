# gtm-engineer-stack

An opinionated Claude Code stack that packages GTM engineering workflows as skills, commands, and hooks. The workflows: ICP scoring, account research, signal classification, Apollo + catch-all email verification, peer-voice icebreaker craft, pre-call meeting prep, post-call CRM + follow-up, and output review.

Pick whichever model is best suited for the task. Classification and parsing lean cheap; research and synthesis lean mid; voice-critical generation and judgment review lean top-tier.

## ICP and offering

- ICP definition lives in [config/icp.md](config/icp.md)
- Offering language lives in [config/offering.md](config/offering.md)
- Persona priority lists live in [config/personas.md](config/personas.md)

These are the customizable parts of this stack. Edit them for your business. The rest of CLAUDE.md is the voice doctrine and eval rules, which are the opinionated core. Do not edit the voice doctrine sections unless you want to change the fundamental writing rules.

## Universal rules

These govern every artifact a prospect or customer might see (outreach copy, sequences, research summaries, call prep).

- **Every claim about a company or person needs a citation**: the source and what it says. No claim without a source.
- **Never tell a prospect what their problem is.** Surface a specific observation and let them connect the pain themselves.
- **No em dashes anywhere.**

Calibration anchors (good/bad examples), the full trigger taxonomy, and the follow-up sequence rules live in [reference/voice.md](reference/voice.md). The `output-review` skill and the `style-guard` hook enforce what follows.

## Voice doctrine

Peer GTM operator with relevant context, not a vendor pitching. Casual but sharp, concrete not abstract. The whole email reads as one continuous thought. Plain words over clever ones. Default length 40-70 words. If you cross 80, cut.

### Always start with a greeting

Every message opens with "Hey [name]," or equivalent. Never skip it.

### Source-preservation rule (research-to-outreach contract)

Whenever the research step has surfaced a sourced fact about the recipient (a quote with a citation, a post with a date, a podcast with an episode), the outreach step must preserve that source attribution in the copy. Dropping the source while keeping the quote is banned, even when the quote is accurate, because the recipient cannot verify a floating "you said" claim and will read it as a guess.

Concrete patterns to flag:

- If the draft contains a verb of speaking (said, mentioned, wrote, shared, talked about, told, posted), the source must appear within fifteen words. Acceptable forms: "In the Apollo acquisition announcement you mentioned X." "On your Topline episode in May you said X." "In your March LinkedIn post you wrote X." Unacceptable forms: "You said X" with no nearby source. "You mentioned X" with no nearby source.
- If the research step's output JSON had a source field for a fact, and that fact gets reused in the icebreaker, the source field must travel with it into the icebreaker prompt and must appear in the final copy. The icebreaker-craft skill should treat dropping a source as a hard failure.
- Default when no source can be cited: drop the quote, reference only the observable event.

### ICP qualifier rule

When the trigger context (the recipient's company, role, or referenced public content) already establishes the ICP, drop the ICP qualifier from the offering sentence. "For B2B SaaS teams" or "for revenue teams" is filler when the recipient is obviously inside that space. The qualifier exists for emails where the recipient does not yet know what lane you work in. In high-context emails, repeating the ICP reads as throat-clearing and costs words without adding credibility.

Rule of thumb: if the trigger references a company the recipient leads or works at, and that company is clearly in your stated ICP, the ICP qualifier is dropped. If the email is going to someone whose space is unclear from context, the qualifier stays.

### Event-specificity rule

When referencing a corporate event, the wording must be specific enough that the recipient can identify which event you mean. "Pocus is joining Apollo" is ambiguous between acquisition, partnership, and the founder personally moving. "Saw Apollo acquired Pocus" is specific. "Saw you joined Apollo's leadership team" is specific. If the research step returned multiple possible event types, the icebreaker must pick one and frame it precisely.

### Plain over clever

If a normal person wouldn't say it in conversation with a peer, don't write it. No try-hard tech-bro phrasing. No filler pivots like "really stuck" or "got me thinking" or "blown away." Direct quote-back of what someone said is better than a reaction word.

### Calibrate to context

There is no fixed template. The VOICE is constant. The SHAPE adapts to recipient (role, persona, seniority), trigger (the specific reason for the outreach), offering (product, service, relationship), and desired next step. Calibrate the opener to the trigger. The "so" bridge between context and offer is always there. The full trigger taxonomy is in [reference/voice.md](reference/voice.md).

### CTA discipline rule

The CTA closes the email with three connected sentences working together:

- Exploration question. Ends with a question mark. Frames the call as honest deal exploration.
- Conditional bridge. "If so," or equivalent. Connects the question to the concrete next step.
- Time-bounded ask. Ends with a period. Names what they are saying yes to.

Why the three-sentence structure: a standalone exploration question followed by a standalone time-bounded ask reads as two disconnected statements. The "if so" bridge makes the second sentence conditional on the first, which is how a peer would actually write it.

Exploration question examples (always end with a question mark):

- "Want to explore whether there is a GTM engineering angle worth a conversation?"
- "Curious whether the integration creates a need on the GTM engineering side?"
- "Worth seeing if there is a fit on the work I do?"

Canonical time-bounded ask:

- "If so, would love to set up a quick 10-minute call in the next couple weeks."

Principle for the ask sentence: every CTA ask must have a soft lead-in verb, a concrete time bound, and an open time window. The combination is what makes it flow.

Soft lead-in verbs that work: would love to, happy to, would be great to

Concrete time bounds that work: a quick 10-minute call, 15 minutes, a short call

Open time windows that work: in the next couple weeks, sometime next week, whenever works on your end this month

Banned framings:

- "compare notes"
- "exchange ideas"
- "trade thoughts"
- "swap notes"
- "pick your brain"
- "would love to chat about X" with no specific frame
- Any CTA that promises content or assets the sender does not actually have

Robotic anti-patterns to avoid in the ask sentence:

- "Whenever works" alone as the time window (filler with no invitation)
- Day-naming like "Tuesday or Wednesday" (reads as a Calendly slot, not a peer asking)
- Missing soft lead-in verb ("Can grab 10 minutes" with no warmth)
- Choppy clauses that do not connect

The principle: every CTA is honest about what the call is. It is deal exploration. Not a peer chat, not a content delivery, not a networking touch. The recipient knows what they are saying yes to: a short conversation to find out if there is a real fit. That is the entire pitch.

### Flow test

Read aloud. Each sentence picks up the previous one. Use natural connective tissue: "so", "and", "because". If anything reads as bolted on, rewrite.

### Subject lines

Short, specific, no clickbait, no exclamation points. "Series B + Q3 attribution thought." "Followup to your GTMfund episode." Avoid "quick question" and anything generic.

## Hard bans

The `style-guard` hook flags these deterministically.

**Punctuation**
- Em dashes anywhere
- Exclamation points in body text

**Cliches**
- "quick question"
- "circling back"
- "touching base"
- "wanted to reach out"
- "very real, very fast"
- "I noticed your LinkedIn"
- "loved your post" (as a standalone opener)
- "huge fan"
- "hope this finds you well"

**Try-hard phrasing**
- "spun up an account" (use "signed up" or "created an account")
- "really stuck" (just quote what they said)
- "got me thinking" (skip the pivot, go straight to relevance)
- "blown away" (anything reaction-heavy)
- "deep dive" (use "look at" or "walk through")
- "in the weeds" (be specific instead)

**SaaS jargon**
- "synergy", "leverage" (as verb), "unlock", "level up", "scale up", "scale-up"
- "10x", "world-class", "best-in-class", "game-changer"
- "AI-powered", "intelligence layer", "unified platform"
- "help you [verb]" constructions

**Framing fouls**
- Diagnosing a pain without evidence
- Generic flattery without specifics
- Name-dropping
- Pre-offering a one-pager or alternative in the initial CTA (reserve for follow-up)
- Asking for an hour. Ten or fifteen is the ceiling.

## Required positives

- Greeting in line one
- Specific source in the first sentence after the greeting
- "So" or equivalent bridges context to relevance
- CTA is a single clean ask for a short call
- Uninterrupted flow from open to close
