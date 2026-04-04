# QA Regression Checklist — Coaching Loop

Use this checklist before each tester build or release candidate. Each scenario should complete end-to-end without stale state, crashes, or data leaking between accounts.

---

## 1. Import real account

- [ ] Enter a valid Dota account ID and tap Import account
- [ ] Dashboard loads with coaching read and session plan
- [ ] No stale state from any previous session (checkpoints, preferences, feedback all match the new account)
- [ ] Re-import the same account: dashboard refreshes; block review and session plan are consistent

---

## 2. Load demo scenario

- [ ] Tap Load demo for any scenario
- [ ] Dashboard shows the scenario label in the header (e.g. "Demo scenario: Completed on-track block")
- [ ] End block summary appears when the scenario includes a completed block
- [ ] Takeaway and outcome match the scenario description
- [ ] Save summary / Copy for sharing does not crash

---

## 3. Start block

- [ ] Import a real account with no previous checkpoint
- [ ] Dashboard shows "No active block yet" in the session plan block panel
- [ ] Tap Start block — button shows "Saving..." during the save and becomes the correct action label after
- [ ] Dashboard updates to "Restart block" label immediately after save
- [ ] Block review card does not appear yet (need 5 games first)

---

## 4. Restart block

- [ ] Import an account that already has an active started block
- [ ] Dashboard shows "Restart block" in the session plan block panel
- [ ] Tap Restart block — saves a new start snapshot
- [ ] Dashboard still shows "Restart block" (block is still active)
- [ ] Block review resets to the new start timestamp

---

## 5. Update manual hero block from Hero detail

- [ ] Open any hero from the dashboard hero link chips
- [ ] Training block card shows current coaching mode and locked block
- [ ] Tap Add / Replace / Remove — button shows "Saving..." and then updates label
- [ ] Rapid double-tap does NOT fire two concurrent saves (button disabled during first save)
- [ ] Return to dashboard: session plan "Heroes" tile and coaching source badge reflect the change
- [ ] For Replace: the replace dialog appears; cancelling returns to hero detail with no change

---

## 6. Update manual hero block from Hero compare

- [ ] Open Hero detail → tap Compare with → pick a second hero
- [ ] Both hero cards show correct block action labels (Use hero / Already in block)
- [ ] Tap Use hero on either card — shows "Saving..." and disables the button during save
- [ ] Return to dashboard: heroes tile updated correctly
- [ ] Cancelling the replace dialog leaves state unchanged

---

## 7. Re-import and review block

- [ ] Start a block, play 5+ games, then re-import the same account
- [ ] Block review card appears with Adherence and Target result tiles
- [ ] Overall outcome badge matches the combination of adherence and target result
- [ ] End block summary appears with correct takeaway and next step
- [ ] The word "improved" in the takeaway only appears when target result actually improved (not just good adherence)

---

## 8. Export / save summary

- [ ] With a completed block, tap Save summary
- [ ] Export dialog opens showing Outcome, Target result, Adherence, Takeaway, Next
- [ ] Tap Copy for sharing — snackbar confirms "Summary copied for sharing"
- [ ] Clipboard text contains "Target result:" (not old label variants)
- [ ] Tap Done — dialog closes cleanly; dashboard is still intact

---

## 9. Switch accounts

- [ ] Import account A; confirm dashboard shows A's data
- [ ] Tap Back to import; import account B
- [ ] Dashboard shows B's coaching read — no A checkpoints, preferences, or feedback visible
- [ ] Import account A again — A's previous data (checkpoints, preferences, feedback) reloads correctly
- [ ] Rapid account switches (A → B → A) do not leave B's state on A's dashboard

---

## 10. Account isolation edge cases

- [ ] After editing training preferences for account A, switch to account B while the save is in flight — B's preferences must not be overwritten
- [ ] After saving tester feedback for account A, switch to account B while the save is in flight — B's feedback must not be overwritten
- [ ] Demo scenario account does not appear in the saved accounts list

---

## 11. Fallback and empty states

- [ ] Dashboard with no imported account shows the empty state (not a crash)
- [ ] Demo scenario with no seeded checkpoint: block review and end summary do not appear
- [ ] Hero detail with no import: shows "Import a recent match sample first" (not a crash)
- [ ] Hero compare with no import: shows the empty section card (not a crash)

---

## Known pre-existing failures (not regressions)

- `widget_test.dart` — "shows the player import screen on launch" — fails due to TextField label not being findable by `find.text()` in headless test environment. Not a runtime bug.
