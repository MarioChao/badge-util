--!strict

-- Cached Badge Check


---------- Imports ----------

local BadgeCheckHelper = require(script:WaitForChild("BadgeCheckRaw"))


---------- Types ----------

type CacheStatus = {
	cachedTime_seconds: number,
	expire_seconds: number,
	timeFunc: () -> number,
}

type BadgeFetchInfo = {
	fetchStatus: boolean,
	cacheStatus: CacheStatus,
}


---------- Constants ----------

local Constants = {}
Constants._expire_seconds = 64 -- around 1 minute

table.freeze(Constants)


---------- Global variables ----------

local Globals = {}
Globals.userBadgeFetchInfos = {} :: {[number]: {[number]: BadgeFetchInfo}}


---------- Local functions ----------

local isCacheExpired
local createCache
local createFetchInfo
local cleanUpFetches
local startCleanUp
local getCached
local fetchAndCache
local userHasBadges


----- Cache functions -----

isCacheExpired = function(cache: CacheStatus)
	local expireTime = cache.cachedTime_seconds + cache.expire_seconds
	return cache.timeFunc() > expireTime
end

createCache = function(expire_seconds: number, timeFunc: (() -> number)?)
	local realTimeFunc = timeFunc or time

	local newCache: CacheStatus = {
		cachedTime_seconds = realTimeFunc(),
		expire_seconds = expire_seconds,
		timeFunc = realTimeFunc,
	}
	return newCache
end

createFetchInfo = function(fetchStatus: boolean, expire_seconds: number)
	local newFetchInfo: BadgeFetchInfo = {
		fetchStatus = fetchStatus,
		cacheStatus = createCache(expire_seconds),
	}
	return newFetchInfo
end


----- Cache clean up -----

cleanUpFetches = function()
	for userId, fetchInfos in Globals.userBadgeFetchInfos do
		-- Clear expired badge results
		for badgeId, fetchInfo in fetchInfos do
			if isCacheExpired(fetchInfo.cacheStatus) then
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

getCached = function(userId: number, badgeId: number): (boolean, boolean?)
	-- Check cache table
	local badgeFetchInfos = Globals.userBadgeFetchInfos[userId]
	local fetchInfo = badgeFetchInfos and badgeFetchInfos[badgeId]
	local isFetchValid = (
		fetchInfo and not isCacheExpired(fetchInfo.cacheStatus)
	)

	-- Return result
	if isFetchValid then
		return true, fetchInfo.fetchStatus
	end
	return false
end

fetchAndCache = function(userId: number, badgeIds: {number})
	-- Do a new fetch
	local fetchStatuses = BadgeCheckHelper.userHasBadges(userId, badgeIds)

	-- Initialize player's cache
	local badgeFetchInfos = Globals.userBadgeFetchInfos[userId]
	if not badgeFetchInfos then
		badgeFetchInfos = {} :: {[number]: BadgeFetchInfo}
		Globals.userBadgeFetchInfos[userId] = badgeFetchInfos
	end

	-- Cache successful results
	for badgeId, result in fetchStatuses do
		badgeFetchInfos[badgeId] = createFetchInfo(result, Constants._expire_seconds)
	end

	-- Return result
	return fetchStatuses
end


----- Cached badge check -----

--[[
Checks if the <code>Player</code> owns multiple badges.

@return ({number: boolean?}) Dictionary mapping badge ids to whether the <code>Player</code> owns the badge. <code>nil</code> if the badge check fails.
]]

userHasBadges = function(userId: number, badgeIds: {number}): BadgeCheckHelper.BadgeCheckResult
	-- Sanitize input
	userId = tonumber(userId) :: number
	if not userId then
		return {}
	end

	-- Initialize result
	local checkResult: BadgeCheckHelper.BadgeCheckResult = {}

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

local CachedBadgeCheck = {}


----- Module fields -----

CachedBadgeCheck.userHasBadges = userHasBadges

function CachedBadgeCheck.checkUserHasBadge(userId: number, badgeId: number)
	return CachedBadgeCheck.userHasBadges(userId, {badgeId})[badgeId]
end


---------- Return module ----------

table.freeze(CachedBadgeCheck)
return CachedBadgeCheck
