# Dotes Next-Step Plan

This plan turns the current project assessment into a practical execution backlog.

## Status Snapshot

- Sprint 1 status: Done
- Sprint 2 status: Done
- Sprint 3 status: Done
- Phase 4 status: Done
- Phase 5 status: Done
- Last updated: 2026-04-06

Completed in Sprint 1:

- Rewrote product-facing repo messaging in `README.md`.
- Updated the app/package description in `pubspec.yaml`.
- Improved first-run import guidance and validation copy.
- Added import-screen help for coaching flow and account ID lookup.
- Cleaned `docs/qa_regression_checklist.md`.
- Added `docs/tester_build_checklist.md`.

Completed in Sprint 2:

- Added trust/confidence labels and short explanatory copy to the main recommendation surfaces.
- Updated Verdict and Next 5 games focus to show more honest confidence framing.
- Added focused tests for the new trust/confidence behavior.
- Tightened import failure messages for not found, timeout, network, and rate-limit cases.
- Added repository-level tests for import failure mapping and controller-level regression coverage.
- Added provider-level regression coverage for completed-block re-import review and end summary behavior.
- Integrated rank-based tone switching (Introductory, Standard, Advanced) into the coaching engine.
- Implemented dynamic session block sizes (5-10 games) scaled by play frequency.
- Updated UI summary surfaces to display rank and play cadence context.
- Verified all regressions with 271+ passing tests.

Still next:

- Reassess the next personalization layer after broader playtesting feedback.

The app already has a working MVP coaching loop:

1. Import a Dota account.
2. Read a coaching verdict and session plan (now personalized by rank and play cadence).
3. Start a 5-to-10 game block.
4. Re-import after the block.
5. Review and export the result.

The next goal is not to rebuild the product. It is to make the current loop easier to understand, more trustworthy, and more production-ready.

## Priority Order

Work in this order:

1. Clarify the product and first-run experience.
2. Increase trust in the coaching output.
3. Harden networking, state handling, and release polish.
4. Improve data richness and meta freshness.
5. Expand post-MVP differentiation.

## Phase 1 - Must Have Before Wider Playtesting

### 1. Replace starter project messaging

Problem:
The repository and package metadata still read like a default Flutter starter, which hides the real product value.

Actions:

- Rewrite `README.md` to explain what Dotes is, who it is for, and the current coaching loop.
- Update app/package description in `pubspec.yaml`.
- Add a short "Current MVP scope" section so testers know what is intentionally in and out.
- Add setup instructions for Flutter, supported platforms, and how to run tests.

Definition of done:

- A new contributor can understand the product in under 2 minutes.
- The repo landing page matches the actual app behavior.

### 2. Improve first-run import guidance

Problem:
The main onboarding risk is still "What is an account ID?" and "What will happen after import?"

Actions:

- Add inline help below the account ID field explaining where the ID comes from.
- Add a small "How to find your account ID" helper flow or dialog.
- Add a short expectation note near the CTA:
  First import creates the read.
  Later import reviews the finished block.
- Add a friendlier invalid-input error state for empty, too-short, or obviously malformed IDs.
- Consider a paste-friendly flow that trims spaces and common profile URL fragments.

Definition of done:

- A first-time tester can import without moderator help.
- The number of pauses at the import screen drops in playtests.

### 3. Reduce confusion in the coaching loop

Problem:
The app logic is clear, but some concepts still require explanation: start block, restart block, re-import to review, save summary.

Actions:

- Audit key labels across import, dashboard, and summary flows.
- Add one-line helper text where users commonly confuse "read current state" vs "review finished block."
- Make the session plan block action wording more explicit.
- Add a lightweight "How this works" explainer that is available from both import and dashboard.
- Convert the current playtest script into a small in-app checklist or guided empty-state content later if needed.

Definition of done:

- Testers can describe the intended loop in their own words.
- Fewer users mistake the dashboard for a static stats page.

### 4. Clean documentation and QA artifacts

Problem:
Project docs are useful but still look internal-only, and at least one file has visible encoding artifacts.

Actions:

- Fix encoding issues in `docs/qa_regression_checklist.md`.
- Add a release checklist for tester builds.
- Add a changelog or release notes template for internal playtest drops.
- Consolidate overlapping docs where possible.

Definition of done:

- Docs are readable, shareable, and ready for repeated tester use.

## Phase 2 - Must Have Before Public Alpha

### 5. Add trust and transparency around coaching output

Problem:
The biggest product risk is not "Can the app generate advice?" It is "Will users trust the advice?"

Actions:

- Add visible confidence language to role reads and session-plan recommendations.
- Surface why a recommendation exists using short, plain-language evidence.
- Make low-confidence states more obvious and less authoritative.
- Add patch/source attribution where meta references are shown.
- Add a "Why this recommendation?" detail affordance for verdict, target, and hero block suggestions.

Definition of done:

- Users can tell whether the app is confident, tentative, or missing enough signal.
- Recommendations feel explained rather than mysterious.

### 6. Harden network behavior and degraded states

Problem:
The network layer is minimal and likely fine for development, but not strong enough for rough public usage.

Actions:

- Add user-facing handling for timeouts, unavailable network, and rate-limit failures.
- Add retry strategy for safe read-only requests.
- Add optional API key support for OpenDota if needed.
- Add logging around import failures and slow requests.
- Define empty, loading, stale, and partial-data states explicitly in UI copy.

Definition of done:

- Import failures fail clearly instead of feeling broken.
- The app remains understandable under weak network conditions.

### 7. Expand automated regression coverage for core flows

Problem:
There is already good test coverage, but the highest-risk user flows deserve stronger integration-style protection.

Actions:

- Add or extend tests for:
  invalid import input
  network error states
  re-import after completed block
  account switching during in-flight saves
  stale meta/outdated patch indicators
- Keep the most important regression suite fast enough for regular local use.
- Separate smoke tests from slower scenario tests.

Definition of done:

- The key coaching loop is protected by stable, intentional automated checks.

### 8. Polish shipping details

Problem:
The app experience is cohesive, but some release-facing details still feel MVP-internal.

Actions:

- Review app icon, app name presentation, and platform metadata.
- Decide whether light theme support is required for alpha or explicitly out of scope.
- Review copy tone across dialogs, cards, and empty states for consistency.
- Confirm snackbar, dialog, and loading states are accessible and legible.

Definition of done:

- The app feels intentionally shipped, not just locally functional.

## Phase 3 - Highest Value Product Upgrade

### 9. Improve data richness beyond `recentMatches`

Problem:
Current coaching quality is capped by summary-only import data.

Actions:

- Define the exact missing signals that would most improve trust:
  warding
  item timings
  lane partner context
  team-relative farm
  per-minute economy
  richer role evidence
- Evaluate which of those can come from OpenDota parsed match data versus a STRATZ integration.
- Choose one richer data source path first instead of trying to upgrade everything at once.
- Build a narrow enrichment spike around one high-value use case:
  more trustworthy role classification
  stronger hero block recommendations
  better block review fairness

Definition of done:

- One recommendation area becomes materially smarter because of richer input data.

### 10. Add meta freshness workflow

Problem:
The app already tracks local patch metadata, but keeping it current is still manual.

Actions:

- Define a source of truth for the supported patch label.
- Add a simple workflow for updating or validating local patch packs each time Dota patches.
- Show "current" vs "outdated" meta status clearly in the UI.
- Add tests around patch freshness behavior.
- Consider a small internal script or checklist for patch updates.

Definition of done:

- Patch rollovers are easy to maintain.
- Users can tell when meta advice may be stale.

### 11. Introduce data-source strategy

Problem:
The project needs a deliberate answer to "How far do we go with OpenDota alone?"

Actions:

- Compare OpenDota-only, STRATZ-only, and hybrid approaches.
- Evaluate cost, rate limits, freshness, reliability, and implementation complexity.
- Decide whether the product promise depends on richer data than OpenDota summary endpoints can provide.
- Record the decision in a short architecture note.

Definition of done:

- The team has a clear data roadmap instead of incremental endpoint drift.

## Phase 4 - Differentiation After The Core Is Trusted

### 12. Improve summary sharing and longitudinal coaching

Status: Done

Completed so far:

- Added per-account saved-summary archive storage for completed blocks.
- Wired the Save summary flow to persist summaries locally before opening the share dialog.
- Added a dashboard details card for saved summaries with one-tap copy actions.
- Added a multi-block trend summary to training history so the dashboard can show how recent completed cycles are stacking over time.
- Upgraded summary export formatting so saved and copied summaries read like a cleaner coaching handoff with block setup context.
- Added optional practice-note capture before saving so intentional goals carry into the archive and copied handoff text.

### 13. Deepen hero and role explainability

Status: Done

Completed so far:

- Added explicit hero rationale lines in hero detail and hero compare surfaces.
- Explained why a hero is in the block, outside the block, comfort-backed, sample-limited, or trailing the current block.
- Folded prior block usage context into the hero rationale copy when review context exists.
- Added concrete before-vs-in-block hero win-rate comparisons so hero surfaces can show what changed since the last started block.
- Extended explainability into the role-read surface with explicit role rationale lines on the imported sample card.


### 14. Add stronger personalization

Status: Done

Completed so far:

- Added a per-account coaching goal note to training preferences so intentional goals persist locally.
- Surfaced that saved goal back into the training setup summary on the dashboard.
- Added a per-account focus-priority preference and let it bias the session-plan target toward deaths, hero pool, or comfort-block discipline.
- Added a per-account coaching-style preference so users can choose steadier or more direct target phrasing without changing the app's underlying confidence rules.
- Added a per-account queue-discipline preference so users can lock the next block to solo queue or party queue and see that reflected in the session plan.
- Extended coaching-style phrasing into the Next 5 games focus and saved summary export so tone stays consistent across the main coaching surfaces.

Still next:

- Reassess whether deeper manual setup is still needed after collecting playtest feedback on the current preference set.

## Suggested Execution Sprints

If work is done in short cycles, use this sequence:

### Sprint 1

Status: Done

- Rewrite `README.md` and package description.
- Improve account ID guidance.
- Tighten import and session-plan copy.
- Fix doc encoding issues.

### Sprint 2

Status: Done

- Add trust and confidence UX.
- Harden import failure states.
- Add focused regression tests for import and re-import review flow.

Completed in this sprint:

- Trust and confidence UX on Verdict and Next 5 games focus.
- Import failure-state copy for the main OpenDota failure cases.
- Focused repository and controller regression coverage for import failures.
- Provider-level regression coverage for the completed re-import review flow.

### Sprint 3

Status: Done

- Decide data-source direction.
- Build one richer-data spike for role trust or review fairness.
- Add patch freshness maintenance workflow.

Completed so far in this sprint:

- Wrote docs/data_source_strategy.md comparing OpenDota-only, STRATZ-only, and hybrid approaches.
- Chose a recommended path: keep OpenDota as the base import source and test one narrow hybrid enrichment spike before widening the architecture.
- Implemented a narrow role-trust spike that cross-checks summary-role reads against local hero-role references without relaxing the conservative fallback rules.
- Added focused regression coverage for the role-trust cross-check behavior.
- Added explicit patch-version freshness copy in the app's meta surfaces and sanity messaging.
- Added docs/meta_patch_update_workflow.md for manual patch-rollover maintenance.
- Added focused freshness tests for the model, sanity service, hero detail service, and hero detail card.

## Recommended Owner Questions

Before Phase 3, answer these clearly:

1. Is the near-term goal internal playtesting, public alpha, or coach-facing demo credibility?
2. Is trust in recommendations currently blocked more by UX wording or by missing data?
3. Are we willing to depend on a richer external data source if it meaningfully improves recommendation quality?

## Immediate Next 5 Tasks

If only a small amount of time is available, do these first:

1. Rewrite `README.md` and `pubspec.yaml` descriptions.
2. Improve the account ID form with better help and clearer post-import expectations.
3. Fix doc cleanup issues, especially `docs/qa_regression_checklist.md`.
4. Add trust/confidence copy to the most important recommendation surfaces.
5. Write a short architecture note comparing OpenDota summary data vs richer parsed or third-party sources.

## Reference Notes

These external references informed the plan:

- OpenDota official API: free tier limits and endpoint scope.
- OpenDota FAQ: advanced replay-derived data is richer but not always immediately available.
- STRATZ official positioning: richer GraphQL and enriched analytics.
- Dota2ProTracker current `7.41a` surface: high-MMR role/build freshness that users may implicitly compare against.












