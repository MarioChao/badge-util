# Changelogs

## [v0.0.2] Badge info + Shared realm + Small changes | 2026/03/12

Added sub-module `BadgeInfo` for retrieving badge information.
- Separated out from the `BadgeAward` script.

Changed the module environment from Server to Shared.
- Warns the user when badge awarding is called from the client.

Migrated `BadgeService:AwardBadge()` to `:AwardBadgeAsync()`.

Added throttle check for `BadgeUtil.awardBadgeLoop()` when called on the same user id & badge id.

Decreased throttle for badge awarding per player from 3 seconds to 2 seconds.

## [v0.0.1] Update cache on award + Api update | 2025/12/09

When calling `BadgeUtil.awardBadgeLoop`, the badge checking cache is automatically updated upon badge award.

> [!NOTE]
> The cache doesn't update when calling `BadgeAward.resolveAwardBadge`.

Api updates:
- In `CachedBadgeCheck`, renamed `.userHasBadges` into `.checkUserHasBadges`.
- In `CachedBadgeCheck`, renamed `.checkUserHasBadge` into `.checkUserHasSingleBadge`.
- New function `CachedBadgeCheck.setUserHasBadge` to update the cache with known badge check results.

## [v0.0.0] Badge Util Project | 2025/11/24

Create `BadgeUtil`, a combination of `CachedBadgeCheck` and `BadgeAward`.

This is a Server module, meaning it should be placed in `ServerScriptService`.
