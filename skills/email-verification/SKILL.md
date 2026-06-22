---
name: email-verification
description: Use to turn Apollo's email_status and catch-all flag into a deliverability verdict, confidence, and send recommendation. Called by the prospect orchestrator after Apollo contact resolution, or standalone via /verify-email. Invoked explicitly, not auto-triggered. Deterministic logic, fits a cheap model.
---

# Email verification

Converts what Apollo knows about an email into a clear send decision. This formalizes the catch-all handling that used to live inline in the orchestrator's Apollo step.

## Input

- `email` (string)
- `email_status` (from Apollo): `verified`, `guessed`, `unknown`, or `none`
- `email_domain_catchall` (boolean, from Apollo)
- `company_domain` (string)

## Verdict logic

| Apollo email_status | catch-all | verdict | confidence | recommendation |
|---------------------|-----------|---------|------------|----------------|
| verified | false | `verified` | HIGH | `send` |
| verified | true | `verified` | MEDIUM | `send` |
| unknown | false | `likely_valid` | MEDIUM | `manual_verify_before_send` |
| unknown | true | `catchall_unverifiable` | LOW | `do_not_send_without_verification` |
| guessed | (any) | `guessed_risky` | LOW | `manual_verify_before_send` |
| none / no email | (any) | `invalid` | HIGH | `drop` |

Why verified-at-catchall stays trustworthy: Apollo confirmed the address through SMTP probing, which holds even on a catch-all domain, so the verdict is still `send` (confidence steps down to MEDIUM only because the domain accepts anything). The catch-all bites in the `unknown` row: no positive verification plus a domain that accepts everything means a pattern-guessed address often bounces. That is the worst case, `catchall_unverifiable`.

## Output (JSON)

    {
      "verdict": "verified | likely_valid | catchall_unverifiable | guessed_risky | invalid",
      "confidence": "HIGH | MEDIUM | LOW",
      "recommendation": "send | manual_verify_before_send | do_not_send_without_verification | drop",
      "reason": "<short string explaining the verdict>"
    }

## Pluggable SMTP verification

This skill is modular. The `catchall_unverifiable` case is exactly where a third-party SMTP verifier (Snov.io, MillionVerifier, NeverBounce) resolves the ambiguity into a definitive valid/invalid result. This reference implementation surfaces the warning and stops there; advanced users plug in their verifier of choice via its MCP and convert `catchall_unverifiable` into `verified` or `invalid` before sending.
