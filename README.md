# Badge Util

Simple module for badge operations with cache and error handling.

This is a Server module, meaning it should be placed in `ServerScriptService`.

Module functions:
- `.awardBadgeLoop(player, badgeId, badgeName)`<br>
Checks if the `Player` doesn't own the badge already, then repeatedly awards the badge until success.
- `.CachedBadgeCheck.userHasBadges(userId, badgeIds)`<br>
Checks if the `Player` owns multiple badges.<br>
Returns a dictionary mapping badge ids to whether the <code>Player</code> owns the badge. <code>nil</code> if the badge check fails.
