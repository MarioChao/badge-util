--!strict

-- Badge Award


---------- Services ----------

local BadgeService = game:GetService("BadgeService")
local RunService = game:GetService("RunService")


---------- Imports ----------

local BadgeInfo = require(script.Parent:WaitForChild("BadgeInfo"))


---------- Constants ----------

local Constants = {}
Constants.userIdThrottleTime = 2

table.freeze(Constants)


---------- Globals ----------

local Globals = {}
Globals.userId_throttled = {} :: {[number]: true?}


---------- Local functions ----------

local throttle
local awardBadge
local resolveAwardBadge


----- Throttle helper -----

throttle = function<K>(sourceTable: {[K]: boolean?}, key: K, delay_seconds: number): boolean
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

awardBadge = function(player: Player, badgeId: number): boolean
	-- Award badge in protected call
	local success, result = pcall(function()
		return BadgeService:AwardBadgeAsync(player.UserId, badgeId)
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
	-- Validate server environment
	if not RunService:IsServer() then
		warn("[Badge Award]: Sorry, badges can only be awarded from the server!")
		return false
	end

	-- Throttle check
	if not throttle(Globals.userId_throttled, player.UserId, Constants.userIdThrottleTime) then
		return false
	end

	-- Validate badge
	local badgeInfo = BadgeInfo.getBadgeInfo(badgeId)
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

local Module = {}


----- Module fields -----

Module.resolveAwardBadge = resolveAwardBadge


---------- Return module ----------

table.freeze(Module)
return Module
