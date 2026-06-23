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

## The six-layer waterfall (default implementation: Apollo MCP)

Query `apollo_mixed_people_api_search` with the company domain. Stop at the first layer that returns a contact, and record which layer landed it and the confidence.

- **Layer 1 - exact title match (HIGH).** For each title in `recommended_persona`, query that exact title at the company domain. Return the top match if any layer-1 query lands.
- **Layer 2 - title family expansion (HIGH).** If layer 1 fails, expand each persona title to its family (see config/personas.md) and query the expanded set; return the most senior match. Defaults:
  - VP Sales -> VP Sales, VP of Sales, Vice President of Sales, SVP Sales, Chief Revenue Officer, CRO, Head of Sales
  - Head of RevOps -> Head of Revenue Operations, VP RevOps, Director of Revenue Operations, VP Sales Operations, Head of GTM Ops
  - Head of Growth -> VP Growth, Director of Growth, Head of Marketing, VP Marketing
  - Founder -> Founder, Co-founder, CEO, Chief Executive Officer
- **Layer 3 - functional area + seniority (MEDIUM).** Infer the department (Sales, Marketing, RevOps, Growth, Founder) from `recommended_persona`. Query with a department filter plus a seniority filter (VP-level and above). Return the most senior.
- **Layer 4 - founder/CEO fallback (MEDIUM-HIGH for under 30 employees, MEDIUM otherwise).** Query for the founder, co-founder, or CEO. Under 30 employees the founder is often the real buyer regardless of org chart.
- **Layer 5 - most senior person, any function (LOW).** Filter to C-suite, VP, or Founder seniority and return whoever is most senior.
- **Layer 6 - graceful failure.** If layers 1-5 return nothing, surface: "No contacts after the full waterfall. Consider manual sourcing via LinkedIn Sales Nav." Do not invent a contact.

## Email verification

After resolving the contact, run the [email-verification](../email-verification/SKILL.md) skill on the returned email, passing `email`, `email_status`, `email_domain_catchall`, and `company_domain`. Carry its verdict, confidence, recommendation, and reason. Email is a flag, never a gate. If no email was returned, offer LinkedIn-only as the fallback and include the LinkedIn URL.

## Output

One contact: name, title, LinkedIn URL; the layer that landed it; the confidence label (HIGH / MEDIUM-HIGH / MEDIUM / LOW); the email plus its verification verdict. On layer 6, the no-contact message instead.

## Swapping the contact data provider

Apollo MCP is the default. To use Clearbit, ZoomInfo, Cognism, or Lusha instead, replace the Apollo query in each layer with your provider's MCP read tools. The interface contract stays the same: input is a domain plus a priority-ordered persona list; output is one contact with title, LinkedIn, email, and a confidence label. Only the per-layer query implementation changes.
