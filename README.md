# Badge Util

Simple module for badge operations with cache and error handling.

This is a Server module, meaning it should be placed in `ServerScriptService`.

Module functions:

* `awardBadgeLoop`
  * `BadgeUtil.awardBadgeLoop(player, badgeId, badgeName)`
  * Checks if the `Player` doesn't own the badge already, then repeatedly awards the badge until success.
  * Automatically updates the badge checking cache upon badge award.

* `CachedBadgeCheck.checkUserHasBadges`
  * `BadgeUtil.CachedBadgeCheck.checkUserHasBadges(userId, badgeIds)`
  * Checks if the `Player` owns multiple badges.
  * Returns a dictionary mapping badge ids to whether the `Player` owns the badge. `nil` if the badge check fails.

* `CachedBadgeCheck.checkUserHasSingleBadge`
  * `BadgeUtil.CachedBadgeCheck.checkUserHasSingleBadge(userId, badgeId)`
  * Checks if the `Player` owns the given badge.
  * Returns `true` if the `Player` owns the badge; `false` if the `Player` doesn't own the badge; `nil` if the badge check fails.

> [!NOTE]
> It's recommended to call `checkUserHasBadges` with multiple badges instead of this function to reduce API calls.

* `CachedBadgeCheck.setUserHasBadge`
  * `BadgeUtil.CachedBadgeCheck.setUserHasBadge(userId, badgeId, hasBadge)`
  * Updates and caches a known badge result for a `Player` and a badge.
