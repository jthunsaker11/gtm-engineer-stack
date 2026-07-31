---
name: contact-resolver
description: Use to resolve ONE real contact at a company, walking a six-layer fallback waterfall from exact title to most-senior-person with a confidence label, then verifying the email. Called by the prospect orchestrator after ICP scoring. Apollo MCP is the default provider; swap providers by editing the implementation. Invoked explicitly.
---

# Contact resolver

Finds one real contact at a company and labels how confident the match is. Title strings vary wildly across companies, so it walks the layers in order and stops at the first that returns a contact.

## Input

- `company_domain`
- `recommended_persona`: the priority-ordered title list from [icp-scoring](../icp-scoring/SKILL.md). The per-stage lists and the layer-2 title-family expansions live in [config/personas.md](../../config/personas.md).
- `employee_count` (optional): used by the layer-4 founder heuristic.
- `company_name` (optional): passed through to email-verification for the Work Email waterfall. If it is not supplied, take it from the resolved contact's `organization.name` in the provider response.

## The six-layer waterfall (default implementation: Apollo MCP)

Query `apollo_mixed_people_api_search` with the company domain. Stop at the first layer that returns a contact, and record which layer landed it and the confidence.

- **Layer 1 - exact title match (HIGH).** For each title in `recommended_persona`, query that exact title at the company domain. Return the top match if any layer-1 query lands.
- **Layer 2 - title family expansion (HIGH).** If layer 1 fails, expand each persona title into its equivalent titles using the expansions defined in [config/personas.md](../../config/personas.md), then query the expanded set and return the most senior match. If a persona title has no expansion listed there, query the title itself only. Do not hardcode expansions in this skill; config/personas.md is the single source.
- **Layer 3 - functional area + seniority (MEDIUM).** Infer the function or department the persona sits in from `recommended_persona` (the buying-committee roles defined in config/personas.md). Query with a function filter plus a seniority filter (VP-level and above). Return the most senior.
- **Layer 4 - company leader fallback (MEDIUM-HIGH at small companies, MEDIUM otherwise).** Query for the CEO or founder, the top of the org chart. `employee_count` tunes the confidence: at a small company the top executive is more likely to own a tooling decision directly, so a leader match is stronger there than at a large one.
- **Layer 5 - most senior person, any function (LOW).** Filter to C-suite, VP, or Founder seniority and return whoever is most senior.
- **Layer 6 - graceful failure.** If layers 1-5 return nothing, surface: "No contacts after the full waterfall. Consider manual sourcing via LinkedIn Sales Nav." Do not invent a contact.

## Email verification

After resolving the contact, run the [email-verification](../email-verification/SKILL.md) skill, passing the contact's `full_name` plus the account's `company_name` and `company_domain`. Those three are the Work Email waterfall's required inputs; without them email-verification cannot run the waterfall and silently drops to single-source coverage. Also pass the contact record's `email`, `email_status`, and `email_domain_catchall` as the fallback fields it uses when the waterfall returns nothing.

Both `full_name` and `company_name` are already in hand, so neither costs an extra call: the people-search match returns the person's name and its `organization.name`. Carry back the verdict, confidence, recommendation, reason, and the email source. Email is a flag, never a gate. If no email was returned, offer LinkedIn-only as the fallback and include the LinkedIn URL.

## Output

One contact: name, title, LinkedIn URL; the layer that landed it; the confidence label (HIGH / MEDIUM-HIGH / MEDIUM / LOW); the email plus its verification verdict. On layer 6, the no-contact message instead.

## Swapping the contact data provider

Apollo MCP is the default. To use Clearbit, ZoomInfo, Cognism, or Lusha instead, replace the Apollo query in each layer with your provider's MCP read tools. The interface contract stays the same: input is a domain plus a priority-ordered persona list; output is one contact with title, LinkedIn, email, and a confidence label. Only the per-layer query implementation changes.
