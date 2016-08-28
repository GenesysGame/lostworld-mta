-- server characters file

addEvent("onCharacterLoaded", false)
addEvent("onCharacterUnloaded", false)

local ageTable = { 4, 12, 22, 34, 48, 64, 82, 102, 124, 148, 174, 202, 232, 264, 302, 346, 396, 452, 514, 582, 656, 736, 822, 914, 1014, 1114, 1214, 1314, 1414 }
local gametimeTimers = {} -- Timer objects for gametime updating
local playerStartTimes = {} -- gametime value for every player when character loaded
local startGametimes = {} -- start tick count values for every player

-- dimensions
local normalDimension = 0
local othersideDimension = 1
local unloggedDimension = 65535

function updateCharacterAge( pSource )
	local charModel = pSource:getData("charModel")
	if not charModel then return end
	local age = 15
	for i, value in ipairs(ageTable) do
		if (charModel.gametime / 60) < value then
			age = 15 + i
			break
		end
	end
	charModel.age = age
	pSource:setData("charModel", charModel)
end

function updateCharacterGametime( pSource )
	local charModel = pSource:getData("charModel")
	if not gametimeTimers[charModel.id] then
		gametimeTimers[charModel.id] = Timer(updateCharacterGametime, 60000, 0, pSource)
		playerStartTimes[charModel.id] = charModel.gametime
		startGametimes[charModel.id] = getTickCount()
	else
		local playedTime = (getTickCount() - startGametimes[charModel.id]) / 60000 --played minutes
		charModel.gametime = playerStartTimes[charModel.id] + playedTime
		outputDebugString("New game time for "..charModel.firstname.." "..charModel.lastname..": "..charModel.gametime.." minutes.")
	end
	pSource:setData("charModel", charModel)
	updateCharacterAge(pSource)
end

function spawn( pSource )
	local charModel = pSource:getData("charModel")
	pSource:spawn(charModel.startPosX, charModel.startPosY, charModel.startPosZ, charModel.startPosRotation, charModel.skinId, charModel.startPosInterior, charModel.startPosDimension)
	pSource.cameraTarget = pSource
end

function characterLoaded( charModel )
	source:setData("charModel", charModel)
	if charModel ~= nil then
		updateCharacterGametime(source)
		spawn(source)
	end
	local allPlayers = Element.getAllByType("player")
	triggerClientEvent(source, "client:onCharacterUpdated", source)
end
addEventHandler("onCharacterLoaded", getRootElement(), characterLoaded)

function characterUnloaded( quitType )
	updateCharacterGametime(source)
	local charModel = source:getData("charModel")
	if source.dimension == normalDimension then
		local pos = source.position
		charModel.startPosX = pos.x
		charModel.startPosY = pos.y
		charModel.startPosZ = pos.z
		charModel.startPosRotation = source.rotation.z
		charModel.startPosInterior = source.interior
		charModel.startPosDimension = source.dimension
	end
	source.dimension = unloggedDimension
	source.vehicle = nil
	source.frozen = true
	if charModel ~= nil then
		gametimeTimers[charModel.id]:destroy()
		gametimeTimers[charModel.id] = nil
		playerStartTimes[charModel.id] = nil
		startGametimes[charModel.id] = nil
		exports.lw_db:updateCharacter(charModel)
	end
	triggerEvent("otherside:logout", source)
	source:setData("charModel", nil)
	triggerClientEvent(source, "client:onCharacterUpdated", source)
end
addEventHandler("onCharacterUnloaded", getRootElement(), characterUnloaded)

function playerWasted( ammo, attacker, weapon, bodypart, stealth )
	if source.dimension == normalDimension then
		triggerEvent("otherside:login", source, ammo, attacker, weapon, bodypart, stealth)
	else
		Timer(function ( source )
			triggerEvent("otherside:logout", source)
			spawn(source)
		end, 5000, 1, source)
	end
end
addEventHandler("onPlayerWasted", getRootElement(), playerWasted)

function startSetting( res )
	if res.name == "" then
		for i,timer in ipairs(gametimeTimers) do
			timer:destroy()
		end
		gametimeTimers = {} -- Timer objects for gametime updating
		playerStartTimes = {} -- gametime value for every player when character loaded
		startGametimes = {} -- start tick count values for every player
	end
end
addEventHandler ("onResourceStart", getRootElement(), startSetting)

function stopSetting( res )
	if res.name == "" then
		for i,timer in ipairs(gametimeTimers) do
			timer:destroy()
		end
		gametimeTimers = {} -- Timer objects for gametime updating
		playerStartTimes = {} -- gametime value for every player when character loaded
		startGametimes = {} -- start tick count values for every player
	end
end
addEventHandler ("onResourceStop", getRootElement(), stopSetting)
