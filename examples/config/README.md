# Worked config example: Recap AI

This directory holds a fully populated version of the three config files, so you can see the
shape you are filling in before you fill it in.

**This is an example, not a default.** Recap AI is a fictional conversation-intelligence
vendor invented for this repo. Nothing here describes a real company, and nothing here is
loaded by the stack at runtime. The stack reads `config/`, never `examples/config/`.

That separation is deliberate. Earlier versions of this repo shipped Recap AI as the contents
of `config/`, which meant a fresh clone passed every check and prospected against a fictional
company's ICP. A wrong config that runs is worse than no config, because no config fails
loudly and a wrong one fails silently. The starters in `config/` now carry `TODO(setup):`
markers on every business-specific field, so `hooks/preflight-config.sh` hard-fails until you
replace them.

## Files

- `icp.md`: the companies Recap AI targets, its exclusions, and its scoring dimensions.
- `personas.md`: its buying committee, with related titles and KPIs per role.
- `offering.md`: its product, positioning, objections, discovery questions, and buying
  signals.

## How to use it

Read it alongside the starter you are filling in. The two files have the same headings in the
same order, so you can work section by section.

To check your understanding of what a valid config looks like, run the preflight gate against
this directory:

```bash
hooks/preflight-config.sh --config-dir examples/config
```

It passes, and prints the Apollo employee buckets it derives from the ICP employee range.
Running it against a half-filled `config/` shows you exactly which lines still need work.

## What is calibration, not example

`offering.md` mixes two kinds of content, and only one of them is Recap-AI-specific.

The sections above "Buying signals" are facts about Recap AI's business: its product, value
proposition, pricing, objections. Replace all of it.

The sections from "Signal weighting" down are calibrated defaults that ship in the starter
config too: the signal weighting table, the signal type vocabulary, the sales-team scaling
thresholds, and the signal freshness windows. Each carries the research it is grounded in.
Those are tunable per business, not example content, and the starter ships them populated
rather than blank because `icp-scoring` reads the weights and windows directly. A blank
weighting table produces untiered output.

The same split applies to `icp.md`: the SIC and keyword exclusion lists are shipped defaults
that exclude categories which rarely buy seat-based B2B software, not Recap AI specifics.
