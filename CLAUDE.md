# Dotes AI Repo Guide

This repository is a local-first Flutter MVP. Treat this file as the operating manual for AI agents working here.

## 1. Project Overview

### What the app is

Dotes is a Dota 2 performance coaching app built around short, reviewable 5-game training blocks. It imports a player's recent OpenDota match sample, turns that sample into a coaching read, recommends a focused next block, lets the user start or restart that block, reviews the finished block, generates an end summary, and lets the user export that summary for sharing or tester notes.

The main user loop is:

`import -> coach -> start block -> review -> end summary -> export`

### What the app is not

- Not a live helper.
- Not an in-match assistant.
- Not a cheat tool.
- Not a generic Dota stats browser.
- Not a cloud product right now.
- Not an auth-based multi-device system.

### Current product shape

- Local-first MVP.
- No auth.
- No cloud sync.
- OpenDota is the only live data source.
- Demo scenarios, tester feedback, training preferences, checkpoints, and meta references are local.
- The app currently has two main routes: import and dashboard.

## 2. Product Principles

- Coaching-first, not generic analytics. Every new surface should help the player decide what to play next or how to review the last block.
- Personal sample first, meta second. The player's own recent matches drive the app. Meta is supporting context only.
- Manual overrides are valid when inference is noisy. If the user locks a role or hero block, respect it.
- Trustworthiness matters more than feature count. Calm, honest fallback states are better than a clever but shaky read.
- Be conservative when data is weak. Small samples, mixed role signals, and stale meta should narrow claims, not expand them.
- Never fake certainty. `Unknown`, `mixed`, `limited confidence`, and `leaning` are valid outcomes in this repo.

## 3. Tech Stack

- Flutter for app UI and navigation.
- Riverpod for providers, controllers, and derived state.
- Dio for OpenDota HTTP calls.
- `shared_preferences` via `SharedPreferencesAsync` for local persistence.
- OpenDota recent player profile and recent match import.
- Local demo scenarios in `lib/src/features/player_import/data/demo`.
- Local meta patch packs in `lib/src/features/meta_reference/data/patch_packs`.

## 4. Architecture Conventions

- Follow `lib/src/features/<feature>/{domain,application,data,presentation}`.
- Keep business logic out of widgets. Widgets should render domain models and forward user actions.
- Domain services decide coaching logic, thresholds, copy, and comparisons.
- Providers wire state and combine services. Controllers manage async session loading and saving.
- Repositories and local stores handle persistence and JSON encoding.
- Do not leak raw OpenDota maps into UI code. Map network data into domain models inside the data layer.
- `lib/src/app` owns app shell concerns: theme, router, and shared widgets.
- Prefer extending an existing feature's service or provider before creating a parallel system.

## 5. Existing Major Systems

- Player import: `PlayerImportController` imports either OpenDota data or a seeded demo scenario, clears session-scoped state before switching accounts, then populates `importedPlayerProvider`.
- Recent matches dashboard: the dashboard reads one imported player session and renders a coaching-first summary before details.
- Coaching insights: `CoachingInsightsAnalyzer` turns recent matches into ranked coaching signals like death risk, hero pool spread, comfort dependence, and limited confidence.
- Next 5 games focus: `NextGamesFocusGenerator` converts the top coaching signal into a concrete 5-game action with conservative wording.
- Comfort core: `ComfortCoreService` checks whether recent success is concentrated inside a small hero core.
- Verdict: `DashboardVerdictService` surfaces one biggest leak and one biggest edge from insights, progress, follow-through, and comfort signals.
- Session plan: `SessionPlanService` turns verdict + focus + preferences into the actual block plan the user should queue next, with manual preferences able to override inferred role and hero block.
- Block review: `BlockReviewService` judges the first 5 matches after the started checkpoint and scores adherence plus target outcome.
- End block summary: `EndBlockSummaryService` creates the final coaching takeaway only when a started snapshot exists and the review is complete.
- Export summary: `BlockSummaryExportService` builds the local share text shown in the export dialog and copied to clipboard.
- Checkpoints: the `checkpoints` feature stores coaching snapshots and powers active block state, history, and review baselines; passive draft saves and explicit block-start snapshots are intentionally different.
- Checkpoint save policy: `CheckpointSavePolicyService` skips duplicate or weakly new saves and only records meaningful checkpoint changes.
- Training history: `TrainingHistoryService` compares adjacent checkpoints to show whether previous blocks landed on track, mixed, or off track.
- Manual training preferences: `training_preferences` can lock a preferred role and hero block and can switch the coaching source from app read to manual setup.
- Coaching source indicator: `CoachingSourceSummaryService` tells the user whether the block is using app inference or manual setup.
- Onboarding: dashboard onboarding is locally persisted and currently app-wide, not per-account.
- Tester feedback: `tester_feedback` stores per-account local notes and also builds a cross-account local playtest summary.
- Demo scenarios: demo imports seed `ImportedPlayerData`, optional checkpoint history, preferences, and tester feedback without behaving like a real imported account.
- Meta reference patch-pack system: `meta_reference` loads local hero references from patch packs and applies freshness checks before using them.
- Hero detail: `HeroDetailService` combines sample stats, plan context, comfort core, block trend, and meta summary for one hero.
- Hero compare: `HeroCompareService` compares two hero detail reads and stays sample-first even when fresh meta exists.
- Saved/recent accounts: saved account launcher entries are local and intended for real imported accounts only; demo imports should not appear as real saved accounts.

## 6. Critical Trust Rules

- Do not add live in-match assistance, overlays, timers, draft helpers, or real-time recommendations.
- Do not build cheating features, automation, or anything that creates unfair live advantage.
- Do not overstate role inference accuracy. The current role system is intentionally conservative and should prefer `Unknown` over a forced label.
- Do not let stale meta override personal coaching, manual setup, or a stronger player sample.
- Do not silently rewrite active block baselines. Starting or restarting a block is an explicit user action and saves a snapshot used later for review.
- Do not break per-account isolation in providers, storage keys, or demo seeding flows.
- If data is missing, stale, or weak, show calm fallback states instead of bluffing.

## 7. Account Isolation Rules

The following must remain isolated per account:

- Checkpoints and checkpoint history.
- The active started block snapshot.
- Training preferences.
- Tester feedback.
- Training history derived from checkpoints.
- Saved account launcher behavior when opening a specific account.
- Any new user-specific local persistence you add.

Additional repo-specific rules:

- Existing per-account storage keys follow `feature_name.$accountId`, for example `coaching_checkpoint.$accountId`, `training_preferences.$accountId`, and `tester_feedback.$accountId`.
- Saved accounts are a global launcher list, but they must load the correct per-account data when opened.
- Demo scenarios must stay separate from real accounts. Current behavior already avoids saving demo scenarios into the real saved-account launcher; keep it that way.
- Keep the session-revision pattern used by controllers when async loads can complete after an account switch.

## 8. UI/UX Rules

- Preserve the current dark, premium, competitive style.
- Keep layouts tactical, readable, and compact.
- Put core coaching first and secondary detail below it.
- Avoid clutter and avoid adding cards that do not affect the coaching loop.
- Keep wording short, direct, and useful.
- Do not add flashy gimmicks, decorative motion, or novelty UI.
- Preserve the current visual language built around badges, headers, section cards, and metric tiles.
- Reuse `lib/src/app/widgets` and `lib/src/app/theme` patterns before inventing new primitives.
- Fallback states should feel calm and intentional, not empty or alarming.

## 9. Meta-Reference Rules

- Meta is secondary context, not the primary driver.
- Use freshness guards before trusting a patch reference.
- Keep meta local through the patch-pack structure already used in `meta_reference/data/patch_packs`.
- If a patch pack is outdated, degrade gracefully to sample-first messaging.
- If meta data is missing, fall back cleanly and keep core coaching usable.
- Never make meta a hard dependency for session plans, hero detail, or review flows.
- When updating a patch, keep `currentSupportedMetaPatchLabel`, the registry, and the pack content in sync.

## 10. Testing Expectations

- Prefer `flutter test`.
- `dart test` is not the correct primary runner in this repo.
- Add targeted tests for any new or changed service, provider, controller, repository, or widget.
- Preserve deterministic behavior. Inject clocks and dependencies when possible instead of baking in unstable time or network assumptions.
- Test account isolation and stale-session cases any time you touch persistence or async loading.
- Test demo mode separately from real imports and real saved accounts.
- If you change checkpointing or block review logic, test duplicate-save, overlap, and stale-baseline cases.
- If you change fallback logic, test small samples, missing meta, outdated meta, and malformed local persistence reads.

## 11. Safe Change Guidelines

- Prefer targeted fixes over broad refactors.
- Reuse existing services and providers before adding new abstractions.
- Keep migrations backward-compatible where possible.
- If adding persistence, document the key shape and whether it is per-account or global.
- Version global collection keys when needed, following the existing style like `player_import.saved_accounts.v1`.
- If changing flow-critical UI, explain the first-use impact and make sure the coaching loop still reads clearly from top to bottom.
- Keep OpenDota-specific parsing inside `player_import/data`.
- Preserve the separation between passive checkpoint saves and explicit started block snapshots.

## 12. Common Tasks for Future Agents

- Adding a new dashboard card: put logic in a domain service or provider first, then place the card in core coaching only if it changes the current recommendation; otherwise add it to details.
- Extending hero detail: add derived logic in `HeroDetailService` and keep hero detail widgets presentational.
- Extending training block workflow: update draft generation, start/restart snapshot behavior, review logic, end-summary logic, and export flow together so they stay consistent.
- Updating local meta patch packs: add or update the pack file, register it, update the supported patch label, and add freshness-path tests.
- Adding a new demo scenario: seed `ImportedPlayerData`, optional checkpoint history, optional training preferences, and optional tester feedback, and keep the source marked as demo.
- Adding a new local persistence feature: create a local store interface, a shared-preferences implementation, a repository, and a provider/controller; key by account if the data is user-specific.
- Hardening state or account isolation: follow the existing loaded-account and session-revision patterns so late async results cannot overwrite the active account session.

## 13. What to Avoid

- Giant refactors without a clear need.
- New backend, auth, or cloud complexity.
- Turning the app into a generic stats browser.
- Overusing AI summaries where deterministic rules are clearer and safer.
- Role-specific certainty beyond the data the app actually imports.
- Breaking saved accounts, checkpoints, tester feedback, training preferences, or demo separation.

## 14. Definition of a Good Change

A good change in this repo:

- Improves clarity, trust, or flow.
- Keeps logic deterministic and reviewable.
- Preserves account isolation.
- Preserves fallback behavior when data is weak, missing, or stale.
- Includes tests where appropriate.
- Does not weaken the `import -> coach -> start block -> review -> end summary -> export` loop.
