# Changelogs

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
