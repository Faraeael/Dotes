# Dotes Data Source Strategy

This note records the current recommendation for how Dotes should evolve beyond an OpenDota `recentMatches`-only import without overcomplicating the MVP.

## Current State

Today the app is deliberately simple:

- OpenDota is the only live data source.
- The import flow reads `/players/{accountId}` and `/players/{accountId}/recentMatches`.
- Coaching stays local-first after import.
- Meta references are local patch packs, currently pinned to `7.41a`.

That shape matches the MVP well, but it also caps how trustworthy some reads can become. The current role-read note already calls out the main limitation: summary fields such as lane, lane role, roaming, GPM, XPM, last hits, kills, deaths, and assists are enough for conservative estimates, but not enough for replay-level certainty.

## What We Need More Data For

The next data upgrade should not be "get more stats everywhere." It should target one trust problem that noticeably improves the coaching loop.

Highest-value candidates:

- More trustworthy role classification.
- Fairer completed-block review when role or game shape changes across the 5 matches.
- Stronger hero-block recommendations with better evidence than summary-only recent matches.
- More reliable patch freshness and hero-context maintenance.

## Option 1: Stay OpenDota-Only

### What it gives us

- Lowest implementation cost because the app already uses it.
- No new auth or user-account complexity in the product.
- Good fit for the repo's local-first MVP constraints.
- Public endpoints with clear player/profile and recent-match coverage.

### What it limits

- `recentMatches` summary data does not fully explain map occupation, resource share, warding, item timing, or role context.
- Parsed or replay-derived enrichment is not guaranteed to be available immediately for every match.
- Rate limits matter if the app starts refreshing more often or adds heavier enrichment calls.
- Meta freshness still remains a separate maintenance problem.

### Best use of this option

Keep OpenDota as the base import and session bootstrap path even if richer data is added later.

## Option 2: Move To STRATZ-Only

### What it gives us

- A richer analytics-oriented API surface than the current OpenDota summary import.
- Better long-term upside if the product eventually needs deeper contextual match reads.
- A more direct path to enriched role, item, and trend signals if the API coverage lines up with the coaching needs.

### What it costs

- Higher integration complexity than the current MVP needs.
- More operational risk because the product would depend on a broader new data path all at once.
- A larger architecture shift before the team has proved which richer inputs actually improve trust.
- More product coupling to an external source before the app has validated one narrow enrichment win.

### Best use of this option

Do not take this path yet. It is too large a platform move for the current stage of the product.

## Option 3: Hybrid OpenDota + Targeted Enrichment

### What it gives us

- Keeps the current import flow stable and easy to reason about.
- Lets the app stay OpenDota-first for account import, recent sample loading, and existing coaching surfaces.
- Creates room to test one richer-data hypothesis at a time.
- Reduces the risk of replacing the whole pipeline before measuring value.

### What it costs

- Adds adapter complexity because the app would support more than one external data shape.
- Requires stronger source attribution and fallback handling in the UI.
- Needs a deliberate rule for when to trust enriched data versus the existing local sample.

### Best use of this option

Use a narrow enrichment layer behind one specific coaching surface first, then measure whether trust meaningfully improves.

## Recommendation

The recommended path is:

1. Keep OpenDota as the canonical base import source.
2. Do not replace the current pipeline with a STRATZ-only architecture yet.
3. Build one hybrid enrichment spike behind a small repository or service boundary.

The first spike should focus on one of these, in order:

1. Role trust.
2. Block-review fairness.
3. Hero-block recommendation quality.

Role trust is the best first target because it already has a clearly documented weakness and it influences how confident the rest of the coaching stack can be.

## Proposed Spike Scope

A good Sprint 3 spike is intentionally narrow:

- Keep current import behavior unchanged for the user.
- Add one optional enrichment path for a small set of matches or signals.
- Use the extra data only inside one service first.
- Surface explicit source and confidence language when enriched data changes the recommendation.
- Fall back cleanly to current OpenDota summary behavior when enrichment is missing, delayed, stale, or unavailable.

This avoids turning "try richer data" into a hidden rewrite.

## Decision Rules

Use these rules for the next implementation step:

- If richer data only produces marginal UI detail, do not widen the integration.
- If richer data materially changes one recommendation surface in a more trustworthy way, keep the adapter and expand carefully.
- If the richer path adds instability without improving coaching clarity, remove or demote it.
- Keep personal sample first and meta second, even when external enrichment exists.

## Patch Freshness Implication

The project also needs a separate freshness workflow because the local patch-pack system is still static:

- `currentSupportedMetaPatchLabel` is hard-coded to `7.41a`.
- `localMetaPatchPacksByLabel` currently contains only one pack.

That means data-source work and patch-freshness work should stay related but separate:

- richer match data is about coaching trust
- patch-pack maintenance is about supporting context staying current

## Concrete Next Move

Implement a role-trust enrichment spike behind a narrow interface, while keeping OpenDota summary import as the default path. Do not widen the product to a full second source until one recommendation area proves meaningfully better.

## External References

These sources informed the recommendation:

- [OpenDota API](https://www.opendota.com/api): public endpoint scope and documented usage limits for the base integration.
- [OpenDota FAQ](https://blog.opendota.com/2014/08/01/faq/): replay-derived and parsed data can be richer, but availability may lag behind basic public-match data.
- [STRATZ](https://stratz.com/): official product positioning around richer Dota analytics and API access.
- [Dota2ProTracker](https://dota2protracker.com/): a useful benchmark for how fresh role/build context feels to players in the current `7.41a` environment.
