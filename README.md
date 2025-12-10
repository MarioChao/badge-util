# Badge Util

Simple module for badge operations with cache and error handling.

This is a Server module, meaning it should be placed in `ServerScriptService`.

Module functions:
- `.awardBadgeLoop(player, badgeId, badgeName)`<br>
Checks if the `Player` doesn't own the badge already, then repeatedly awards the badge until success.<br>
Automatically updates the badge checking cache upon badge award.
- `.CachedBadgeCheck.checkUserHasBadges(userId, badgeIds)`<br>
Checks if the `Player` owns multiple badges.<br>
Returns a dictionary mapping badge ids to whether the <code>Player</code> owns the badge. <code>nil</code> if the badge check fails.
- `.CachedBadgeCheck.checkUserHasSingleBadge(userId, badgeId)`<br>
Checks if the `Player` owns the given badge.<br>
Returns <code>true</code> if the <code>Player</code> owns the badge; <code>false</code> if the <code>Player</code> doesn't own the badge; <code>nil</code> if the badge check fails.
    > [!NOTE]
    > It's recommended to call `checkUserHasBadges` with multiple badges instead of this function to reduce API calls.
- `.CachedBadgeCheck.setUserHasBadge(userId, badgeId, hasBadge)`<br>
Updates and caches a known badge result for a <code>Player</code> and a badge.
