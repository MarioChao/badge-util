--!strict

-- Cached Badge Check


---------- Imports ----------

local BadgeCheckRaw = require(script:WaitForChild("BadgeCheckRaw"))


---------- Types ----------

type CacheEntryStatus = {
	cachedTime_seconds: number,
	expire_seconds: number,
	timeFunc: () -> number,
}

type BadgeFetchInfo = {
	fetchStatus: boolean,
	cacheEntryStatus: CacheEntryStatus,
}


---------- Constants ----------

local Constants = {}
Constants._expire_seconds = 64 -- around 1 minute

table.freeze(Constants)


---------- Global variables ----------

local Globals = {}
Globals.userBadgeFetchInfos = {} :: {[number]: {[number]: BadgeFetchInfo}}


---------- Local functions ----------

local getIsCacheEntryExpired
local createCacheEntry
local createFetchInfo
local cleanUpFetches
local startCleanUp
local getOrCreateUserCache
local getCached
local fetchAndCache
local setUserHasBadge
local checkUserHasBadges


----- Cache entry functions -----

getIsCacheEntryExpired = function(cacheEntry: CacheEntryStatus)
	local expireTime = cacheEntry.cachedTime_seconds + cacheEntry.expire_seconds
	return cacheEntry.timeFunc() > expireTime
end

createCacheEntry = function(expire_seconds: number, timeFunc: (() -> number)?)
	local realTimeFunc = timeFunc or time

	local newCacheEntry: CacheEntryStatus = {
		cachedTime_seconds = realTimeFunc(),
		expire_seconds = expire_seconds,
		timeFunc = realTimeFunc,
	}
	return newCacheEntry
end

createFetchInfo = function(fetchStatus: boolean, expire_seconds: number)
	local newFetchInfo: BadgeFetchInfo = {
		fetchStatus = fetchStatus,
		cacheEntryStatus = createCacheEntry(expire_seconds),
	}
	return newFetchInfo
end


----- Cache clean up -----

cleanUpFetches = function()
	for userId, fetchInfos in Globals.userBadgeFetchInfos do
		-- Clear expired badge results
		for badgeId, fetchInfo in fetchInfos do
			if getIsCacheEntryExpired(fetchInfo.cacheEntryStatus) then
				fetchInfos[badgeId] = nil
			end
		end

		-- Clear user table if empty
		if not next(fetchInfos) then
			Globals.userBadgeFetchInfos[userId] = nil
		end
	end
end

startCleanUp = function()
	while true do
		task.wait(Constants._expire_seconds * 2)
		cleanUpFetches()
	end
end


----- Badge cache -----

getOrCreateUserCache = function(userId: number)
	local result = Globals.userBadgeFetchInfos[userId] or (function()
		local result = {} :: {[number]: BadgeFetchInfo}
		Globals.userBadgeFetchInfos[userId] = result
		return result
	end)()
	return result
end

--[[
Gets the cached badge checking result for a <code>Player</code> and a badge.

@return (boolean) Whether the badge check is cached and not expired.
@return (boolean?) If cached, whether the <code>Player</code> owns the badge.
]]
getCached = function(userId: number, badgeId: number): (boolean, boolean?)
	-- Check cache table
	local badgeFetchInfos = Globals.userBadgeFetchInfos[userId]
	local fetchInfo = badgeFetchInfos and badgeFetchInfos[badgeId]
	local isFetchValid = (
		fetchInfo and not getIsCacheEntryExpired(fetchInfo.cacheEntryStatus)
	)

	-- Return result
	if isFetchValid then
		return true, fetchInfo.fetchStatus
	end
	return false
end

--[[
Performs badge checks using Roblox api, then cache the results.

@return ({[number]: boolean?}) Dictionary mapping badge ids to whether the <code>Player</code> owns the badge. <code>nil</code> if the badge check fails.
]]
fetchAndCache = function(userId: number, badgeIds: {number})
	-- Do a new fetch
	local fetchStatuses = BadgeCheckRaw.userHasBadges(userId, badgeIds)

	-- Get player's cache
	local badgeFetchInfos = getOrCreateUserCache(userId)

	-- Cache successful results
	for badgeId, result in fetchStatuses do
		if result then
			badgeFetchInfos[badgeId] = createFetchInfo(result, Constants._expire_seconds)
		end
	end

	-- Return result
	return fetchStatuses
end

--[[
Updates and caches a known badge result for a <code>Player</code> and a badge.
]]
setUserHasBadge = function(userId: number, badgeId: number, hasBadge: boolean)
	-- Get player's cache
	local badgeFetchInfos = getOrCreateUserCache(userId)

	-- Cache
	badgeFetchInfos[badgeId] = createFetchInfo(hasBadge, Constants._expire_seconds)
end


----- Cached badge check -----

--[[
Checks if the <code>Player</code> owns multiple badges.

@return ({number: boolean?}) Dictionary mapping badge ids to whether the <code>Player</code> owns the badge. <code>nil</code> if the badge check fails.
]]

checkUserHasBadges = function(userId: number, badgeIds: {number}): BadgeCheckRaw.BadgeCheckResult
	-- Sanitize input
	userId = tonumber(userId) :: number
	if not userId then
		return {}
	end

	-- Initialize result
	local checkResult: BadgeCheckRaw.BadgeCheckResult = {}

	-- Get uncached badge ids
	local uncachedBadgeIds: {number} = {}
	for _, badgeId in badgeIds do
		-- Store & skip cached result
		local cacheIsValid, cacheResult = getCached(userId, badgeId)
		if cacheIsValid then
			checkResult[badgeId] = cacheResult :: boolean
			continue
		end

		-- Store uncached badge ids
		table.insert(uncachedBadgeIds, badgeId)
	end

	-- Fetch and cache
	local fetchStatuses = fetchAndCache(userId, uncachedBadgeIds)

	-- Store results
	for badgeId, isAwarded in fetchStatuses do
		checkResult[badgeId] = isAwarded
	end

	-- Return result
	return checkResult
end


---------- Calling background functions ----------

task.defer(startCleanUp)


---------- Module ----------

local Module = {}


----- Module fields -----

Module.setUserHasBadge = setUserHasBadge

Module.checkUserHasBadges = checkUserHasBadges

--[[
Checks if the <code>Player</code> owns a single badge.

@return (boolean) <code>true</code> if the <code>Player</code> owns the badge; <code>false</code> if the <code>Player</code> doesn't own the badge; <code>nil</code> if the badge check fails.
]]
function Module.checkUserHasSingleBadge(userId: number, badgeId: number)
	return Module.checkUserHasBadges(userId, {badgeId})[badgeId]
end


---------- Return module ----------

table.freeze(Module)
return Module
