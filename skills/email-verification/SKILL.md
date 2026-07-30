---
name: email-verification
description: Use to acquire and verify a contact's work email into a deliverability verdict, confidence, and send recommendation. Routes email acquisition through Clay's Work Email waterfall (higher coverage), falling back to the Apollo contact email. Called by the prospect orchestrator after contact resolution, or standalone via /verify-email. Invoked explicitly, not auto-triggered. Deterministic verdict logic, fits a cheap model.
---

# Email verification

Acquires a contact's work email and converts what is known about it into a clear send decision. Email acquisition routes through Clay's Work Email waterfall first for coverage, then falls back to the Apollo contact email; the verdict logic below applies to whichever email is found. This formalizes the catch-all handling that used to live inline in the orchestrator's Apollo step.

## Email acquisition (Clay Work Email waterfall)

The Apollo contact record carries a single-source email that hits on roughly 50 to 60 percent of contacts. Clay's **Work Email** routine waterfalls across multiple email providers (Prospeo, Icypeas, Datagma, Findymail, and others) and lands 80 to 95 percent, so acquire the email there first:

1. contact-resolver returns the contact's name and `company_domain` (whether the account was sourced from Apollo or Clay).
2. Run Clay's **Work Email** routine with `Full Name`, `Company Domain`, and `Company Name` (its required inputs). It returns the email, its verification status, and the provider that produced the hit.
3. If Work Email returns an email, use it, and set `ab_email_source` to the provider it reports (for example `prospeo`, `icypeas`, `datagma`, `findymail`).
4. If Work Email returns nothing, fall back to the Apollo email on the contact record and set `ab_email_source` to `apollo-fallback` (retaining the previous behavior).

Never invent a provider name; use the provider Work Email actually reports. The routine name is `Work Email` (a Clay-managed function, roughly 1.1 credits per run); resolve its `function:<id>` from `clay routines list` at runtime.

## Input

- `full_name` (string) and `company_name` (string), plus `company_domain` (string): the Work Email routine's required inputs.
- Fallback fields from the Apollo contact record, used only when Work Email returns nothing: `email`, `email_status` (`verified`, `guessed`, `unknown`, or `none`), and `email_domain_catchall` (boolean).

## Verdict logic

Apply this to whichever email was acquired (Work Email or the Apollo fallback). Map the acquisition status onto the rows: a positively verified email is `verified`, a pattern-guessed one is `guessed`, and a found-but-unconfirmed one is `unknown`.

| email status | catch-all | verdict | confidence | recommendation |
|--------------|-----------|---------|------------|----------------|
| verified | false | `verified` | HIGH | `send` |
| verified | true | `verified` | MEDIUM | `send` |
| unknown | false | `likely_valid` | MEDIUM | `manual_verify_before_send` |
| unknown | true | `catchall_unverifiable` | LOW | `do_not_send_without_verification` |
| guessed | (any) | `guessed_risky` | LOW | `manual_verify_before_send` |
| none / no email | (any) | `invalid` | HIGH | `drop` |

Why verified-at-catchall stays trustworthy: a positively verified address (SMTP-probed by the Work Email provider or by Apollo) holds even on a catch-all domain, so the verdict is still `send` (confidence steps down to MEDIUM only because the domain accepts anything). The catch-all bites in the `unknown` row: no positive verification plus a domain that accepts everything means a pattern-guessed address often bounces. That is the worst case, `catchall_unverifiable`.

## Output (JSON)

    {
      "email": "<the acquired work email>",
      "email_source": "<provider from Work Email, e.g. prospeo | icypeas | datagma | findymail, or apollo-fallback>",
      "verdict": "verified | likely_valid | catchall_unverifiable | guessed_risky | invalid",
      "confidence": "HIGH | MEDIUM | LOW",
      "recommendation": "send | manual_verify_before_send | do_not_send_without_verification | drop",
      "reason": "<short string explaining the verdict>"
    }

## Pluggable SMTP verification

This skill is modular. The `catchall_unverifiable` case is exactly where a third-party SMTP verifier (Snov.io, MillionVerifier, NeverBounce) resolves the ambiguity into a definitive valid/invalid result. This reference implementation surfaces the warning and stops there; advanced users plug in their verifier of choice via its MCP and convert `catchall_unverifiable` into `verified` or `invalid` before sending.
