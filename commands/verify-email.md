---
description: Verify a single email's deliverability. Enriches via Apollo for email_status and the domain catch-all flag, then runs the email-verification skill and reports the verdict.
argument-hint: <email> [company-domain] (or pass email_status and catchall directly)
model: haiku
---

Run an email deliverability check on the input in $ARGUMENTS.

1. Parse the input: an email address, optionally a company domain. If `email_status` and `email_domain_catchall` are supplied directly in the arguments, skip to step 3.
2. If only an email is given, enrich it via Apollo (`apollo_people_match` by email) to retrieve `email_status` and the domain catch-all flag. Enrichment costs 1 Apollo credit; confirm before spending it. If Apollo is not connected, ask the user to supply `email_status` and `email_domain_catchall` manually.
3. Run the `email-verification` skill with email, email_status, email_domain_catchall, and company_domain.
4. Report the verdict, confidence, recommendation, and reason. If the verdict is `catchall_unverifiable`, note that an SMTP verifier (Snov.io, MillionVerifier, NeverBounce) can resolve it definitively.
