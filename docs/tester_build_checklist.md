# Tester Build Checklist

Use this before handing a build to internal testers.

## Product framing

- [ ] `README.md` matches the current MVP behavior
- [ ] Tester notes explain the core loop: import -> coach -> start block -> re-import -> review -> export
- [ ] Known limitations are stated clearly (local-first, no auth, no cloud sync, no live assistance)

## Build sanity

- [ ] App launches to the import flow
- [ ] Real account import works with a known public test account
- [ ] At least one demo scenario still loads correctly
- [ ] Dashboard renders the expected core coaching cards
- [ ] Export summary dialog opens and copy action succeeds

## Regression pass

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter test test/dashboard_loaded_view_test.dart test/demo_scenario_flow_test.dart`
- [ ] Manual pass through `docs/qa_regression_checklist.md`

## Trust and copy review

- [ ] Import screen explains what an account ID is
- [ ] Import screen explains what first import vs later re-import means
- [ ] Low-confidence or fallback states still read calmly and honestly
- [ ] No copy overstates certainty of role or hero recommendations

## Release handoff

- [ ] Build date recorded
- [ ] Target platform recorded
- [ ] Notable changes summarized for testers
- [ ] Known issues listed so testers do not report expected behavior as a regression
