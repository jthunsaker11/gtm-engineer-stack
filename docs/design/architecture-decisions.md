# Architecture decisions

Why the v2 stack is shaped the way it is. Each decision names what we do, why we do it, what breaks without it, and the production practice or research it is grounded in. The one-line summary of the whole design: fit qualifies, signals prioritize, motions route.

## Unified account universe with tiered treatment

We keep one account universe and score every account into a tier (A, B, or C), rather than maintaining a separate stack or list per outreach motion. icp-scoring assigns the tier from fit plus signal strength; the tier is the account's priority, and treatment is decided separately by its motion.

The reason is that an account does not belong to a motion, it moves through motions over time. The same company can be a cold-outbound account this quarter, a signal-based account when it raises a round, an ABM account when it lands on the strategic list, and a wake-the-dead account a year after a closed-lost. If each motion owns its own list, the same account is duplicated across lists, its state diverges, and suppression and reporting become impossible to keep straight. A single universe with a tier and a motion tag per account keeps one row per company and lets treatment change without re-sourcing.

Without a unified universe, you get the classic RevOps failure mode: three spreadsheets, three definitions of the same account, and a rep working a company in one sequence while marketing works it in another. Deduplication and suppression stop working, and the account experiences the disjointed outreach that account-based selling exists to prevent.

Reference: account-based tiering is standard ABM practice, formalized by ITSMA as the one-to-one, one-to-few, and one-to-many tiers, where a single account list is segmented by strategic value rather than split into disconnected campaigns.

## Signals as scoring inputs, not required gates

Buying signals feed the score; they do not gate an account out of the audience. Every firmographic-qualified account reaches icp-scoring and receives a tier, and the presence and freshness of signals raises or lowers that tier through the signal dimension. An account with zero signals still scores and still lands in the pool as Tier C.

We do this because a signal gate throws away the future pipeline. A signal is a statement about timing, not about fit. A perfect-fit account with no signal today is not a bad account, it is a good account at the wrong moment, and the right response is to keep it and nurture it, not to delete it from the universe. Using signals to gate conflates "not now" with "not ever," and the accounts you discard are exactly the ones a competitor picks up when their signal finally fires.

Without this, the pool silently shrinks to only accounts that happen to have a public event this week, and the nurture motion has nothing to work because the Tier C accounts it depends on were filtered out before they were ever recorded. The v1 behavior did exactly this, which is why Tier C accounts now stay in the CSV.

Reference: the distinction between fit (who to sell to) and intent or timing (when to reach them) is the foundation of signal-based and intent-based selling, and of Gartner's B2B buying research, which frames buying as an intermittent set of jobs a committee works over time rather than a single in-market moment.

## Motions live in config, not code

The seven motions are configuration files in config/motions/, each declaring its trigger, cadence, anchor style, tier defaults, approval requirements, suppression rules, and success signals. Skills read the relevant motion file at runtime to decide treatment. Cadence numbers, approval gates, and suppression policy are data, not branches in a skill.

We separate motion policy from skill logic because outbound policy changes far more often than orchestration logic does. A team tunes cadence pacing, flips a tier from auto-send to human-approve, or adds a suppression rule weekly, and none of that should require editing a skill or shipping code. Keeping motions in config means a non-engineer can change how outreach behaves by editing a markdown file, and the change is reviewable in a diff.

Without config-driven motions, every pacing tweak is a code change, the skill accumulates conditional branches for each motion, and the people who own the outbound strategy (RevOps, sales leadership) cannot change it without an engineer. The policy and the machinery calcify together.

Reference: this is the strict separation of config from code in the Twelve-Factor App methodology (factor III, config), applied to GTM: the machinery is the skill, the policy is the environment, and the two are versioned but not entangled.

## Fit as hard gate, signals as prioritization

Fit is the one hard gate in the funnel. An account that fails the ICP firmographic criteria or hits an exclusion is dropped before any spend. Everything downstream, including signals, only ranks and routes the accounts that already passed fit. Signals never rescue a non-fit account into the pool.

This ordering matters because fit and intent fail differently. A non-fit account with a strong signal is still a bad account: it will not close, it will not retain, and chasing its signal wastes cycles and email reputation. A fit account with a weak signal is a good account you are early on. So fit belongs at the gate, where a miss is fatal, and signals belong at the ranking step, where they change priority but not eligibility. Collapsing the two, or letting a hot signal override a fit miss, is how teams end up with a pipeline full of well-timed deals that never close.

Without fit as the hard gate, intent data pulls in loud but wrong accounts, and the cost discipline downstream breaks: contact and email credits get spent on companies that were never going to buy. The gate is what makes the rest of the spend defensible.

Reference: the fit-versus-intent matrix, long standard in account-based and demand-generation practice (popularized by TOPO and carried into Gartner), treats fit as the qualifying axis and intent as the prioritizing axis; MEDDIC likewise qualifies on economic-buyer fit and pain before timing.

## Delegate, do not duplicate (prospect-builder as orchestrator)

prospect-builder owns only the two jobs that are genuinely its own: sourcing a firmographic pool and enriching signals. Tiering is delegated to icp-scoring, contact discovery to contact-resolver, and email checks to email-verification. prospect-builder calls those skills and aggregates their outputs; it does not re-implement scoring, people search, or email logic.

The reason is one source of truth per concern. Scoring logic lives in exactly one place, so a change to how accounts are tiered is made once and every caller inherits it. When prospect-builder duplicated that logic inline, the same rules existed in two skills, and the two drifted: a fix to icp-scoring did not reach the copy inside prospect-builder, and the pool was tiered by stale rules. Delegation removes the second copy.

Without delegation, every shared concern is implemented as many times as it is used, and the copies diverge the moment one is edited. The audience gets scored one way in the standalone flow and another way in the pool build, and no one can say which tier is authoritative.

Reference: this is the Single Responsibility Principle and the Don't Repeat Yourself principle applied to skills. Each skill has one reason to change (Robert C. Martin, SOLID), and every piece of logic has a single authoritative representation (Hunt and Thomas, The Pragmatic Programmer).

## Provider-agnostic design (roadmap, not built yet)

The intended design is that every external dependency (contact data, enrichment, email verification, CRM) is reached through a stable interface, so the provider behind it can be swapped without touching the skills that call it. contact-resolver already documents this contract: a domain and a persona list go in, one contact comes out, and the per-layer query is the only thing that changes when you move from Apollo to another provider.

We want this because provider lock-in is a real operational risk in GTM tooling. Data vendors change pricing, coverage, and terms, and a stack hard-wired to one vendor has to be rewritten to move. An interface between the skill and the provider means the switch is a new adapter, not a rewrite, and it lets a cloning user run the stack on whatever data vendor they already pay for.

Without the abstraction, the provider's API shape leaks into every skill that touches it, and swapping vendors means editing every one of those call sites. This is on the roadmap for Tier 2 v2, not built yet: today Apollo is the default and the swap is documented but manual.

Reference: this is the Adapter pattern (Gamma and colleagues, Design Patterns) and the Dependency Inversion Principle (SOLID): skills depend on an abstraction, and the concrete provider depends on that same abstraction, so neither is welded to the other.

Signal fidelity scales with the connected providers. Some signals are richer from one provider than another: Apollo returns an exact funding round type and a trailing headcount-growth trend that this workspace's Clay routines do not (Clay's Company Latest Funding returns an amount only, and Enrich Company returns a single employee count). A user on Clay alone still gets the signal, through the documented fallbacks: the funding amount band in place of the exact round, and the open-sales-role count in place of the headcount-growth figure. This is intentional design. The stack degrades gracefully when a provider is missing rather than failing hard, so more connected providers mean higher signal fidelity, not a broken run.

## Mock and fixture default mode (roadmap, not built yet)

The intended default for development and testing is a mock mode that returns realistic fixture data instead of calling live providers, so a cloning user can run the whole chain, see its shape, and validate their configs without spending a single credit or needing every MCP connected.

We want this because the cost of trying the stack should be zero. A new user should be able to run prospect-builder in plan mode and a mock execute, watch fit-qualify, signals-prioritize, and motions-route end to end, and confirm their config produces sensible output, before they connect Apollo or Clay or spend anything. Mock mode also makes the stack testable: deterministic fixtures let a change be verified against a known-good output rather than against a live API whose results drift.

Without a mock default, the first run requires real credentials and real spend, evaluation is expensive and slow, and there is no hermetic way to test a change to a skill. This is on the roadmap for Tier 2 v2, not built yet: today plan mode is the free path, and execute mode requires live providers.

Reference: this is the test-double and fixture practice from automated testing (Gerard Meszaros, xUnit Test Patterns), applied to a GTM pipeline: hermetic, deterministic inputs stand in for live dependencies so behavior can be exercised and verified cheaply.

## Roadmap summary

Two decisions above describe intended design that is not built yet:

- **Provider-agnostic adapters** (Tier 2 v2): a stable interface per external dependency so vendors swap without skill edits.
- **Mock and fixture default mode** (Tier 2 v2): realistic fixtures so the chain runs and configs validate with zero spend.

The broader Tier 1 and Tier 2 v2 build list (sequence-writer and its companions, the /setup config generator, webhook receivers for the externally-sourced motions, and the provider and mock work above) is tracked outside this document.
