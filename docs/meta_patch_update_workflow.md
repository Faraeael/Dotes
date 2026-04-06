# Meta Patch Update Workflow

Use this checklist whenever Dota rolls to a new supported patch and the local meta references need to catch up.

## Source Of Truth

The supported local patch is defined in two places that must stay aligned:

- `lib/src/features/meta_reference/data/local_meta_patch_config.dart`
- `lib/src/features/meta_reference/data/patch_packs/local_meta_patch_registry.dart`

The patch-pack file itself must use the same label in every `HeroMetaReference` entry.

## Update Steps

1. Confirm the new target patch label.
2. Duplicate or replace the current local patch-pack file with a new file for that patch.
3. Update every `patchLabel` in the new pack so it matches exactly.
4. Register the new pack in `local_meta_patch_registry.dart`.
5. Point `latestAvailableLocalMetaPatchPack` at the new pack.
6. Update `currentSupportedMetaPatchLabel` in `local_meta_patch_config.dart`.
7. Review the seeded hero pool and refresh role/item/build guidance.
8. Run the targeted meta freshness tests and hero detail tests.
9. Check one fresh hero detail screen and one stale-meta path before shipping.

## Minimum Validation

Run these before considering the patch rollover done:

- `dart analyze`
- `flutter analyze`
- `flutter test test/hero_meta_freshness_service_test.dart test/session_plan_meta_sanity_service_test.dart test/hero_detail_service_test.dart test/hero_detail_meta_reference_card_test.dart`

## UX Expectation

If the patch pack is behind, the app should stay calm and explicit:

- show which local patch is behind
- show which patch is currently supported
- keep personal sample guidance primary until the patch pack is refreshed

## Notes

This workflow is intentionally manual for now. The goal is reliable patch rollovers, not automatic scraping or hidden patch-state drift.
