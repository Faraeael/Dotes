# Dotes

Dotes is a local-first Dota 2 performance coaching app built around short, reviewable 5-game training blocks.

It imports a player's recent OpenDota sample, turns that sample into a conservative coaching read, recommends a focused next block, lets the player start or restart that block, and later reviews the finished block after a re-import.

The main loop is:

`import -> coach -> start block -> re-import -> review -> export summary`

## Who It Is For

Dotes is for players who want a tighter practice loop than a generic stats page provides.

It is especially aimed at players who want help answering:

- What should I queue next?
- Which 1 to 2 heroes should I stay on for the next block?
- Did the last 5 games actually follow the plan?
- What short summary would I share with a coach or teammate?

## Current MVP Scope

The current app supports:

- Importing a real Dota account through OpenDota.
- Loading local demo scenarios for testing the coaching loop.
- Reading a coaching verdict from recent matches.
- Building a focused 5-game session plan.
- Browsing the recent matches card in a compact view with a `See more` toggle for older games.
- Starting or restarting a training block.
- Re-importing later to review the finished block.
- Exporting a compact end-of-block summary.
- Local training preferences, checkpoints, tester feedback, and saved accounts.

The current app does not support:

- Live in-match help.
- Draft assistance or overlays.
- Cloud sync or auth.
- Cross-device accounts.
- Full generic Dota statistics browsing.

## Product Principles

- Coaching first, not generic analytics.
- Personal sample first, meta second.
- Trustworthiness over certainty.
- Conservative wording when data is noisy.
- Manual overrides are valid when inference is weak.

## Data Notes

- OpenDota is the only live data source right now.
- The app currently relies on recent player profile and recent match data.
- Meta references are stored locally through patch packs.
- Role reads are intentionally conservative and should prefer mixed or limited-confidence language over forced certainty.

## Running The App

### Requirements

- Flutter SDK
- Dart SDK bundled with Flutter
- A platform toolchain for your target device

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## Testing And Analysis

Run analysis:

```bash
flutter analyze
```

Run the full test suite:

```bash
flutter test
```

Run a focused regression slice:

```bash
flutter test test/dashboard_loaded_view_test.dart test/demo_scenario_flow_test.dart
```

## First-Time Import Notes

To use a real account import, you need the numeric Dota account ID.

The app reads public recent-match data from OpenDota, so the account's public match data needs to be available. If a player has just enabled public match data, richer data may not appear immediately.

## Project Structure

The repo follows a feature-first structure:

- `lib/src/app`: app shell, theme, router, shared widgets
- `lib/src/features/*`: feature folders split into `domain`, `application`, `data`, and `presentation`
- `docs/`: playtest, QA, and project planning docs
- `test/`: widget, provider, controller, and service coverage

## Important Docs

- [How To Use Dotes](docs/how_to_use_dotes.md)
- [Next Step Plan](docs/next_step_plan.md)
- [Role Read Architecture](docs/role_read_architecture.md)
- [MVP Playtest Script](docs/mvp_playtest_script.md)
- [QA Regression Checklist](docs/qa_regression_checklist.md)
- [CLAUDE Guide](CLAUDE.md)

