--!strict

-- Badge Info


---------- Services ----------

local BadgeService = game:GetService("BadgeService")


---------- Types ----------

export type BadgeInfo = {
	Name: string,
	Description: string,
	IconImageId: number,
	IsEnabled: boolean,
}


---------- Local functions ----------

local getBadgeInfo


----- Badge info -----

--[[
Retrieves information about a badge.

@return (BadgeInfo?) A <code>table</code> containing badge info; <code>nil</code> if failed.
]]
getBadgeInfo = function(badgeId: number): BadgeInfo?
	-- Get info in protected call
	local success, result = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)

	-- Return result
	if not success then
		warn(`[Badge Info]: Error while fetching badge info: {result}`)
		return nil
	end
	return result
end


---------- Module ----------

local Module = {}


----- Module fields -----

Module.getBadgeInfo = getBadgeInfo


---------- Return module ----------

table.freeze(Module)
return Module
