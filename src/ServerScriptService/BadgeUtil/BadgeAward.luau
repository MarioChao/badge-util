--!strict

-- Badge Award


---------- Services ----------

local BadgeService = game:GetService("BadgeService")
local RunService = game:GetService("RunService")


---------- Types ----------

type BadgeInfo = {
	Name: string,
	Description: string,
	IconImageId: number,
	IsEnabled: boolean
}


---------- Global variables ----------

local Globals = {}
Globals.userIdThrottleTable = {} :: {[number]: boolean}


---------- Local functions ----------

local throttle
local getBadgeInfo
local awardBadge
local resolveAwardBadge


----- Throttle helper -----

throttle = function<K>(sourceTable: {[K]: boolean}, key: K, delay_seconds: number): boolean
	-- Check if throttled
	if sourceTable[key] then
		return false
	end

	-- Throttle
	sourceTable[key] = true
	task.delay(delay_seconds, function()
		sourceTable[key] = nil
	end)
	return true
end


----- Badge api functions -----

getBadgeInfo = function(badgeId: number): BadgeInfo?
	-- Get info in protected call
	local success, result = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)

	-- Return result
	if not success then
		return nil
	end
	return result
end

awardBadge = function(player: Player, badgeId: number): boolean
	-- Award badge in protected call
	local success, result = pcall(function()
		return BadgeService:AwardBadge(player.UserId, badgeId)
	end)

	-- Validate sucess
	if not success then
		return false
	end

	-- Return award result
	return result
end


----- Award badge handler -----

--[[
@return (boolean) Whether the badge was awarded to the player.
]]

resolveAwardBadge = function(player: Player, badgeId: number, badgeName: string)
	-- Throttle check
	if not throttle(Globals.userIdThrottleTable, player.UserId, 3) then
		return false
	end

	-- Validate badge
	local badgeInfo = getBadgeInfo(badgeId)
	if not (badgeInfo and badgeInfo.IsEnabled) then
		warn(`[Badge Award]: Badge {badgeId}: '{badgeName}' not available!`)
		return false
	end
	if badgeInfo.Name ~= badgeName then
		warn(`[Badge Award]: Badge name doesn't match! '{badgeInfo.Name}' | '{badgeName}'`)
		return false
	end

	-- Award badge
	if RunService:IsStudio() then
		print(`[Mock Badge Award]: {player.Name} won "{badgeInfo.Name}" award.`)
		return true
	else
		return awardBadge(player, badgeId)
	end
end


---------- Module ----------

local BadgeAward = {}


----- Module fields -----

BadgeAward.resolveAwardBadge = resolveAwardBadge


---------- Return module ----------

table.freeze(BadgeAward)
return BadgeAward
