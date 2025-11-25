--!strict

-- Badge Util


---------- Services ----------

local RunService = game:GetService("RunService")


---------- Imports ----------

local BadgeAward = require(script:WaitForChild("BadgeAward"))
local CachedBadgeCheck = require(script:WaitForChild("CachedBadgeCheck"))


---------- Constants ----------

local Constants = {}
Constants.awardLoopDelay = 1

table.freeze(Constants)


---------- Module ----------

local BadgeUtil = {}


----- Sub-modules -----

BadgeUtil.BadgeAward = BadgeAward
BadgeUtil.CachedBadgeCheck = CachedBadgeCheck


----- Combination functions -----

--[[
Checks if the <code>Player</code> doesn't own the badge already, then repeatedly awards the badge until success.
]]

function BadgeUtil.awardBadgeLoop(player: Player, badgeId: number, badgeName: string)
    local awardResult
	local checkResult

	repeat
		checkResult = CachedBadgeCheck.checkUserHasBadge(player.UserId, badgeId)
		task.wait(Constants.awardLoopDelay)
	until checkResult ~= nil

	if checkResult == false then
		repeat
			awardResult = BadgeAward.resolveAwardBadge(player, badgeId, badgeName)
			task.wait(Constants.awardLoopDelay)
		until awardResult
	else
		if RunService:IsStudio() then
			print("[Badge Util]: Player already owned badge!")
		end
	end
end


---------- Return module ----------

table.freeze(BadgeUtil)
return BadgeUtil
