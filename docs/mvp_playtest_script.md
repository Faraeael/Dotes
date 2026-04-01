# MVP Playtest Script

Use this script for short internal tests of the current coaching MVP. The goal is consistency, not perfect research rigor.

## Tester Goal

Ask the tester to imagine this prompt:

> "You want a simple coaching loop: import your account, get a focused 5-game plan, come back after those games, review whether the block helped, and save the result."

## Expected Flow

1. Import an account.
2. Read the dashboard and explain what the app wants them to do next.
3. Start the 5-game block.
4. Return with a completed block and review the result.
5. Save or copy the summary.

## Moderator Script

### 1. First Import

Say:

> "Please open the app and use it as if this is your first time. Narrate what you think the app is asking you to do."

Ask:

- "What do you think you need before you can use this app?"
- "What do you expect to happen after import?"

Observe silently:

- Do they understand what an account ID is?
- Do they hesitate before the import CTA?
- Do they understand that the first import creates the current read, not the review?

Pass checkpoint:

- Tester imports an account without extra explanation.
- Tester can say that the app will build a dashboard from recent matches.

Fail checkpoint:

- Tester cannot tell what to enter.
- Tester expects the first import to already contain a completed review.

### 2. Understanding The Dashboard

Say:

> "Without tapping anything yet, tell me what this dashboard is for and what you think the main loop is."

Ask:

- "What is the first thing you would read here?"
- "What do you think happens after you play the next 5 games?"

Observe silently:

- Do they understand Verdict, Session plan, Block review, and Training setup at a basic level?
- Do they find the core coaching section quickly?
- Do they read the onboarding card or ignore it?

Pass checkpoint:

- Tester can explain the loop: read current advice, play a 5-game block, re-import, review, save summary.

Fail checkpoint:

- Tester cannot explain what the app is asking them to do next.
- Tester mistakes the dashboard for a static stats page only.

### 3. Starting A 5-Game Block

Say:

> "Please start the block you think the app wants you to play."

Ask:

- "What do you think starting the block actually saves?"
- "When would you use restart instead of start?"

Observe silently:

- Do they find the Training block panel inside Session plan?
- Do they understand that start sets the review starting point?
- Do they understand restart is a reset, not a progress button?

Pass checkpoint:

- Tester starts the block confidently.
- Tester can explain that the next 5 newer games will be reviewed against this start point.

Fail checkpoint:

- Tester does not notice the block action.
- Tester thinks start immediately evaluates the block.
- Tester uses restart language incorrectly.

### 4. Reviewing A Completed Block

Say:

> "Assume you have now played the 5 games. Please use the app to review the block."

Ask:

- "What do you think this review is saying?"
- "Does the result feel fair?"

Observe silently:

- Do they know they need to re-import?
- Do they find Block review and End block summary?
- Can they read outcome, target result, adherence, takeaway, and next step without help?

Pass checkpoint:

- Tester re-imports or clearly states that re-import is needed.
- Tester can describe whether the block was on track, mixed, or off track.

Fail checkpoint:

- Tester does not understand how to trigger review.
- Tester cannot tell the difference between Block review and End block summary.

### 5. Saving Or Copying The Summary

Say:

> "Please save or copy the result you would want to share with a coach or teammate."

Ask:

- "What do you think this summary is for?"
- "Where would you paste or save this?"

Observe silently:

- Do they notice the Save summary action?
- Does the copy dialog feel sufficient even without native share?
- Do they understand the exported summary is the compact handoff output?

Pass checkpoint:

- Tester opens the summary dialog and copies the summary.
- Tester understands it is a shareable handoff of the completed block.

Fail checkpoint:

- Tester cannot find the action.
- Tester does not understand why the summary exists.

## Silent Observation Checklist

Track these during the session without interrupting:

- Where did the tester pause for more than 5 seconds?
- Which label did they misread or skip?
- Did they ask what import, start, restart, review, or save means?
- Did they trust the review result immediately, cautiously, or not at all?
- Did they use the app in the intended sequence?

## MVP Pass Or Fail

Mark the session as a provisional MVP pass if all are true:

- Tester completes first import without coaching.
- Tester explains the coaching loop in their own words.
- Tester starts a block correctly.
- Tester understands that completed review requires a later import.
- Tester can read the finished summary and copy it.

Mark as provisional MVP fail if any are true:

- Tester needs repeated explanation to move from one step to the next.
- Tester cannot tell when the app is reading current state versus reviewing a finished block.
- Tester does not trust or understand the completed review summary.

## Compact Feedback Template

Use this at the end of the session.

### Quick Feedback

- Was the app clear?
- What confused you most?
- Would you follow the session plan?
- Did block review feel fair?
- What would make you trust it more?

### Suggested Answer Format

- Clarity: Clear / Somewhat clear / Confusing
- Biggest confusion:
- Would follow the session plan: Yes / Maybe / No
- Block review felt fair: Yes / Mixed / No
- Trust would improve if:
