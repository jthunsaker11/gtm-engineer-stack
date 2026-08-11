---
description: Populate the three config files (icp.md, personas.md, offering.md) from documents you already have. Asks what is available before reading anything, fills in only what the documents support, leaves everything else as an explicit TODO(setup) marker rather than guessing, records where each populated field came from, shows a diff before writing, and ends by running the preflight gate.
argument-hint: [paths to any ICP, product, persona, or positioning documents you have]
model: opus
---

Populate `config/icp.md`, `config/personas.md`, and `config/offering.md` from the user's own materials, so a fresh clone reaches a working config without hand-editing three files.

This command spends nothing. Do not call Apollo, do not call Clay, do not run any enrichment. It reads local documents and writes local markdown.

## The rule that governs every decision here

Populate only what the source documents actually support. Anything they do not cover stays as its `TODO(setup):` marker.

Inventing an ICP is worse than leaving it blank. A blank config fails loudly: `hooks/preflight-config.sh` names the file and line and refuses to spend credits, which sends the user to go ask their founder or RevOps lead. A guessed config fails silently: it sources a pool, scores it, assigns tiers, and hands back output indistinguishable from the real thing. Nothing downstream can detect it.

So a plausible inference is not support. If a positioning deck says "we sell to fast-growing SaaS teams," that supports an industry of B2B SaaS. It does not support an employee range, an ACV band, or a stage. Leave those as markers. Expect to finish with markers remaining; that is the intended outcome, not a shortfall. The markers are the user's list of what to go find out.

## 1. Ask what documents exist, before reading anything

Do not assume a file layout. Do not go looking for `docs/icp.pdf` or guess at a `sales/` directory. Ask first.

If `$ARGUMENTS` already names paths, use those and skip to step 2. Otherwise ask the user what they have, offering the common shapes as prompts rather than as a required list:

- An ICP one-pager or target-account definition
- A product brief, positioning doc, or messaging framework
- Persona notes, or a buyer-persona set from product marketing
- A pitch deck or sales deck
- A pricing page or pricing sheet
- Closed-won notes, a customer list, or a CRM export
- A public website or docs site they want read
- Nothing written down, in which case they can describe the business in chat and that transcript becomes the source

Accept whatever they name: file paths, pasted text, or a URL. Ask for the paths rather than searching the filesystem for likely candidates, because a file that looks like an ICP doc and is actually a stale draft is exactly the kind of source that produces a confident wrong config.

If the user has nothing at all and does not want to describe the business, stop and say so plainly. The configs stay as shipped, the preflight gate keeps failing, and that is the correct state. Do not populate from general knowledge of their industry.

## 2. Read the sources

Read every document the user named. For a URL, fetch it. For a PDF or deck, read it. Note what each document is and what it covers, because you will cite it per field.

Read the three starter configs too, plus [examples/config/](../examples/config/) for the worked shape of each section.

If a named path does not exist or cannot be read, say which one and continue with the rest. Do not silently drop it.

## 3. Extract, field by field

Work through the three files section by section, in this order: `icp.md`, then `personas.md`, then `offering.md`. For each field, decide one of three outcomes:

- **Supported.** The document states it, or states something it follows from directly. Populate it, and record the source.
- **Partially supported.** The document constrains the field but does not settle it. Populate what is supported and leave the rest explicit. "Industry: B2B SaaS. TODO(setup): narrow to a vertical if you sell to one." is a good outcome. Silently picking a vertical is not.
- **Unsupported.** Leave the `TODO(setup):` marker untouched.

Field-specific rules that matter more than the rest:

- **Employee size** must be written as `N to M employees` when it is supported at all. The preflight gate parses those two numbers to derive the Apollo source buckets, so the wording is load-bearing. If the documents give a fuzzy size ("mid-market", "growth-stage"), that is unsupported. Leave the marker rather than converting a vague word into numbers the user never wrote down.
- **The employee range appears in two files.** If you populate it in `icp.md`, restate it identically in the `offering.md` target market section. The gate fails when the same fact carries two values.
- **Value proposition** is the exact sentence the icebreaker uses to say what the user does. Take it verbatim from their materials when a usable one-liner exists. Do not improve it, do not compress it into something punchier, and do not write one from the product overview. If no single sentence in their documents does the job, leave the marker; a value proposition the user did not write is one they will not recognize in their own outbound.
- **Personas** need real role names in the headings, replacing the `TODO(setup): economic buyer role` placeholders. Related titles are what the Apollo waterfall expands to at layer 2, so populate them from titles the documents actually name, not from title variants you can generate.
- **Buying signals** should come from the user's closed-won history or stated experience. A generic signal list is not support. Map each one you populate to a canonical signal type from the vocabulary in `offering.md`, since that is what carries a weight.
- **Exclusions** are worth asking about directly if no document covers them. Who they deliberately do not sell to is usually known and rarely written down.

Do not touch the calibrated sections of `offering.md`: signal weighting, the signal type vocabulary, sales-team scaling thresholds, and signal freshness windows. Those ship populated with cited research and are tuned later against observed outcomes, not extracted from a positioning deck. Same for the SIC and keyword exclusion lists in `icp.md`. If a source document gives a genuine reason to change one (the user sells to recruiting firms, so SIC 7361 should come out), raise it with the user rather than editing it as part of the sweep.

## 4. Record provenance for every populated field

Same discipline the ownership map applies to enriched rows: a value in the config should be traceable to where it came from, so a future reader can tell a sourced fact from an inherited default.

Append a provenance table to the end of each file you populate:

```markdown
## Provenance (populated by /setup)

Where each populated field came from. Fields still carrying a `TODO(setup):` marker are not listed.

| field | source | where in it |
| --- | --- | --- |
| Industry/vertical | icp-onepager.pdf | page 1, "Who we sell to" |
| Employee size | icp-onepager.pdf | page 1, target account table |
| Value proposition | messaging-v3.docx | section 2, verbatim |
```

Cite the document and the specific location, the same standard the stack applies to a claim about a prospect. "From the deck" is not a citation. If a field came from the user describing the business in chat rather than from a document, say so: source `user, this conversation`. That is a legitimate source and it should be legible as one, because it is the field most worth revisiting later.

## 5. Show the diff and hold

Do not write anything yet. Show the user what will change, per file, as a diff against the current starter. For each file report:

- Which fields will be populated, with their values and sources.
- Which `TODO(setup):` markers will remain, and why the documents did not support them.
- Anything you found conflicting between two documents, with both readings, rather than silently picking one.

Then stop and wait for approval. The user may correct values, supply a missing fact directly, or tell you to leave something as a marker. Apply their corrections and show the diff again if the changes are substantial.

Only write the files after explicit approval.

## 6. Run the preflight gate and report what still needs a human

After writing, run it:

```bash
hooks/preflight-config.sh
```

Report the result honestly.

If it passes, say so, and show the derived Apollo employee buckets it printed along with whether a post-source re-filter is required. That is the query the user's next sourcing run will use, and this is the moment to check it against their own understanding of their ICP.

If it fails, that is a normal outcome of an honest run, not an error to work around. List every remaining `TODO(setup):` by file and line, grouped by what the user would need to go find out and who usually holds it:

- ICP firmographics and exclusions: the founder or head of sales at an early company, RevOps or the ICP owner at a larger one.
- Buyer personas: the sales team and RevOps, or an existing product-marketing persona set.
- Offering, positioning, differentiators: product marketing, or the founder.
- Pricing: sales or finance.
- Buying signals: RevOps and marketing, and the closed-won history.
- Discovery questions and objections: the sales team, from real calls.

Close by telling the user which sections are (Required) and therefore blocking, versus (Recommended) and (Optional) which they can fill in over the first couple of weeks. Do not offer to fill the blocking ones in yourself from inference, and do not suggest a placeholder value to get the gate to pass. The gate failing is the config working.

Report any warnings the gate printed as well: those name ICP criteria that are stated but have no filter or gate behind them, which is worth the user knowing before they read a tier as meaningful.
