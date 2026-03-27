# Role Read Architecture

The current role-read layer is a conservative estimate, not a replay-level role classifier.

## What The App Uses Today

The imported sample currently comes from OpenDota's recent-match summary data. In practice, the role engine only sees a small set of summary fields that are already in the app model:

- `lane`
- `lane_role`
- `is_roaming`
- `last_hits`
- `gold_per_min`
- `xp_per_min`
- `kills`
- `deaths`
- `assists`

These fields are useful, but they do not fully describe how a player actually occupied the map or shared resources with teammates.

## What The Current Rules Should Do

- Prefer `Unknown` over a forced role label.
- Treat the sample-level role result as an estimate.
- Only expose an exact role name in user-facing UI when one role dominates a solid sample with low ambiguity.
- Fall back to broader language like `core role leaning`, `support role leaning`, or `mixed / still estimating` when the read is not strong enough.

## Why This Is Weaker Than A Stronger Role Engine

Recent-match summary fields do not include enough context to fully separate:

- farm-heavy offlane games from true carry games
- lane starts from actual map occupation later in the match
- support play from core play using team-relative economy alone

## Future Data That Would Improve Accuracy

If the app moves beyond the recent-match summary import later, role accuracy would improve with richer parsed or replay-derived inputs such as:

- detailed parsed match fields like ward counts, purchase logs, and per-minute economy arrays
- team-relative economy signals and lane partner context
- replay-derived positional or movement data

That stronger data would justify a more specific role engine. Until then, the code should keep estimate-first wording and conservative trust gates.
