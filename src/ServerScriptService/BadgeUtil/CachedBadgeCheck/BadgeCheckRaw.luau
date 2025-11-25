--!strict

-- Badge Check Raw


---------- Services ----------

local BadgeService = game:GetService("BadgeService")


---------- Types ----------

export type BadgeCheckResult = {[number]: boolean}


---------- Constants ----------

local Constants = {}
Constants._badgeBatchSize = 10

table.freeze(Constants)


---------- Local functions ----------

local userHasBadges_http
local userHasBadges_badgeService_singleChecks
local userHasBadges_badgeService
local userHasBadges


----- Badge check functions -----

-- Check badges using http endpoint (TODO)
userHasBadges_http = function(userId: number, badgeIds: {number}): BadgeCheckResult
	-- ServerInvoke + http request to a proxy to "https://badges.roblox.com/v1/users/{userId}/badges/awarded-dates"
	return {}
end

userHasBadges_badgeService_singleChecks = function(userId: number, badgeIds: {number}): BadgeCheckResult
	-- Initialize result
	local checkResult: BadgeCheckResult = {}

	-- Go through each badge
	local checkCount = 0
	for _, badgeId in badgeIds do
		task.defer(function()
			-- Check badge
			local success, result = pcall(function()
				return BadgeService:UserHasBadgeAsync(userId, badgeId)
			end)

			-- Combine result
			if success then
				checkResult[badgeId] = result
			end

			-- Increment count
			checkCount += 1
		end)
	end

	-- Wait
	local waitTime = time()
	while checkCount < #badgeIds and time() < waitTime + 5 do
		task.wait(0.05)
	end

	-- Return result
	return checkResult
end

-- Check badges using badge service
userHasBadges_badgeService = function(userId: number, badgeIds: {number}): BadgeCheckResult
	-- No badge ids provided
	if not badgeIds or #badgeIds == 0 then
		return {}
	end

	-- A few badge ids
	if #badgeIds <= Constants._badgeBatchSize // 2 then
		return userHasBadges_badgeService_singleChecks(userId, badgeIds)
	end

	-- At most batch-size badge ids
	if #badgeIds <= Constants._badgeBatchSize then
		-- Check badges
		local success, result = pcall(function()
			return BadgeService:CheckUserBadgesAsync(userId, badgeIds)
		end)

		-- Validate result
		if not success then
			return userHasBadges_badgeService_singleChecks(userId, badgeIds)
		end


		---------- Build check result ----------

		local checkResult: BadgeCheckResult = {}

		-- Awarded badges
		for _, badgeId in result do
			checkResult[badgeId] = true
		end

		-- Unawarded badges
		for _, badgeId in badgeIds do
			if not checkResult[badgeId] then
				checkResult[badgeId] = false
			end
		end


		-- Return check result
		return checkResult
	end

	-- Many badge ids
	do
		-- Group badges into batches
		local badgeIdBatches: {{number}} = {}
		local temporaryBatch = {}
		for _, badgeId in badgeIds do
			-- Insert batch and create new empty batch
			if #temporaryBatch >= Constants._badgeBatchSize then
				table.insert(badgeIdBatches, temporaryBatch)
				temporaryBatch = {}
			end

			-- Store id in the batch
			table.insert(temporaryBatch, badgeId)
		end
		-- Insert final batch
		table.insert(badgeIdBatches, temporaryBatch)

		-- Check by batches
		local batchCheckResults: {BadgeCheckResult} = {}
		for _, idBatch in badgeIdBatches do
			local batchCheckResult = userHasBadges_badgeService(userId, idBatch)
			table.insert(batchCheckResults, batchCheckResult)
		end

		-- Combine batch results
		local checkResult: BadgeCheckResult = {}
		for _, batchCheckResult in batchCheckResults do
			for badgeId, isAwarded in batchCheckResult do
				checkResult[badgeId] = isAwarded
			end
		end

		-- Return check result
		return checkResult
	end
end


----- Badge check main -----

-- Check badges
userHasBadges = function(userId: number, badgeIds: {number}): BadgeCheckResult
	-- No badge ids provided
	if not badgeIds or #badgeIds == 0 then
		return {}
	end

	-- Use Http service
	if false then
		return userHasBadges_http(userId, badgeIds)
	end

	-- Use badge service
	return userHasBadges_badgeService(userId, badgeIds)
end


---------- Module ----------

local Module = {}


----- Module fields -----

Module.userHasBadges = userHasBadges


---------- Return module ----------

table.freeze(Module)
return Module
