-- server characters file

addEvent("onCharacterLoaded", true)

local ageTable = { 4, 12, 22, 34, 48, 64, 82, 102, 124, 148, 174, 202, 232, 264, 302, 346, 396, 452, 514, 582, 656, 736, 822, 914, 1014, 1114, 1214, 1314, 1414 }

function updateCharacterAge( playerSource )
	local charModel = playerSource:getData("charModel")
	if not charModel then return end
	local age = 15
	for i, value in ipairs(ageTable) do
		if charModel.gametime < value then
			age = 15 + i
			break
		end
	end
	charModel.age = age
	playerSource:setData("charModel", charModel)
end

function spawn( pSource )
	local charModel = pSource:getData("charModel")
	local startX, startY, startZ = 378, 2507, 17
	pSource:spawn(startX, startY, startZ, 0, charModel.skinId, 0, 0)
	pSource.cameraTarget = pSource
end

function characterLoaded( charModel )
	source:setData("charModel", charModel)
	if charModel ~= nil then
		updateCharacterAge(source)
		spawn(source)
	end
	triggerClientEvent(source, "client:onCharacterUpdated", source)
end
addEventHandler("onCharacterLoaded", getRootElement(), characterLoaded)

function playerWasted( )
	Timer(spawn, 3000, 1, source)
end
addEventHandler("onPlayerWasted", getRootElement(), playerWasted)