# gtm-engineer-stack

An opinionated Claude Code stack that packages GTM engineering workflows as skills, commands, and hooks. The workflows: ICP scoring, account research, signal classification, Apollo + catch-all email verification, peer-voice icebreaker craft, pre-call meeting prep, post-call CRM + follow-up, and output review.

Pick whichever model is best suited for the task. Classification and parsing lean cheap; research and synthesis lean mid; voice-critical generation and judgment review lean top-tier.

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

### Plain over clever

If a normal person wouldn't say it in conversation with a peer, don't write it. No try-hard tech-bro phrasing. No filler pivots like "really stuck" or "got me thinking" or "blown away." Direct quote-back of what someone said is better than a reaction word.

### Calibrate to context

There is no fixed template. The VOICE is constant. The SHAPE adapts to recipient (role, persona, seniority), trigger (the specific reason for the outreach), offering (product, service, relationship), and desired next step. Calibrate the opener to the trigger. The "so" bridge between context and offer is always there. The full trigger taxonomy is in [reference/voice.md](reference/voice.md).

### CTA: ask for the call

The initial outreach asks for one thing: a short call (10-15 minutes). Clean, single ask. Do not pre-offer a one-pager, deck, or alternative in the initial message. Examples that work:

- "Open to 10 minutes next week?"
- "Worth a quick call?"
- "Have 15 minutes Tuesday or Wednesday?"
- "Open to catching up in the next couple weeks?"

One-pagers, decks, recorded walkthroughs, and other materials are FOLLOW-UP assets. They get sent if the prospect responds with hesitation, asks for more before committing, or wants to share internally before booking. The follow-up reply (Reply 2 in a sequence) is where you offer "happy to send a one-pager if that's easier to share with your team first."

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
