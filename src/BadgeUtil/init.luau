--!strict

-- Badge Util


---------- Services ----------

local RunService = game:GetService("RunService")


---------- Imports ----------

local BadgeAward = require(script:WaitForChild("BadgeAward"))
local BadgeInfo = require(script:WaitForChild("BadgeInfo"))
local CachedBadgeCheck = require(script:WaitForChild("CachedBadgeCheck"))


---------- Types ----------

export type BadgeInfo = BadgeInfo.BadgeInfo


---------- Constants ----------

local Constants = {}
Constants.awardLoopDelay = 1

table.freeze(Constants)


---------- Constants ----------

local Globals = {}
Globals.userBadgeString_throttled = {} :: {[string]: true?}


---------- Local functions ----------

local getUserBadgeString

local awardBadgeLoop_internal


----- Data -----

getUserBadgeString = function(userId: number, badgeId: number)
	return `{userId}_{badgeId}`
end


----- Award badge -----

awardBadgeLoop_internal = function(player: Player, badgeId: number, badgeName: string)
	-- Declare result variables
    local awardResult
	local checkResult

	-- Check if the user owns the badge
	repeat
		checkResult = CachedBadgeCheck.checkUserHasSingleBadge(player.UserId, badgeId)
		task.wait(Constants.awardLoopDelay)
	until checkResult ~= nil

	-- Only award if the user doesn't own the badge
	if checkResult == false then
		-- Repeatedly award badge until success
		repeat
			awardResult = BadgeAward.resolveAwardBadge(player, badgeId, badgeName)
			task.wait(Constants.awardLoopDelay)
		until awardResult
		CachedBadgeCheck.setUserHasBadge(player.UserId, badgeId, true)
	else
		if RunService:IsStudio() then
			print("[Badge Util]: Player already owns badge!")
		end
	end
end


---------- Module ----------

local BadgeUtil = {}


----- Sub-modules -----

BadgeUtil.BadgeAward = BadgeAward
BadgeUtil.BadgeInfo = BadgeInfo
BadgeUtil.CachedBadgeCheck = CachedBadgeCheck


----- Combination functions -----

--[[
Checks if the <code>Player</code> doesn't own the badge already, then repeatedly awards the badge until success.
]]
function BadgeUtil.awardBadgeLoop(player: Player, badgeId: number, badgeName: string)
	-- Validate server environment
	if not RunService:IsServer() then
		warn("[Badge Util]: Sorry, badges can only be awarded from the server!")
		return
	end

	-- Throttle check
	local userBadgeString = getUserBadgeString(player.UserId, badgeId)
	if Globals.userBadgeString_throttled[userBadgeString] then
		return
	end
	Globals.userBadgeString_throttled[userBadgeString] = true

	-- Award badge
	awardBadgeLoop_internal(player, badgeId, badgeName)

	-- Remove throttle
	Globals.userBadgeString_throttled[userBadgeString] = nil
end


---------- Return module ----------

table.freeze(BadgeUtil)
return BadgeUtil
