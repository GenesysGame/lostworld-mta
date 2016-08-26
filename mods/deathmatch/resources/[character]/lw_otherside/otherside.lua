-- Main file for other side environment

local normalDimension = 0
local othersideDimension = 1

addEvent("otherside:login", false)
addEvent("otherside:logout", false)

local deadPeds = {}

addEventHandler("otherside:login", getRootElement(), function ( ammo, attacker, weapon, bodypart, stealth )
	local charModel = source:getData("charModel")
	local deadPosition = source.position
	local deadRotation = source.rotation

	--create dead ped for player
	if deadPeds[charModel.id] ~= nil then
		deadPeds[charModel.id]:destroy()
	end
	local ped = createPed(source.model, deadPosition.x, deadPosition.y, deadPosition.z, deadRotation.z)
	ped.alpha = 0
	ped.dimension = normalDimension
	ped:kill(attacker, weapon, bodypart, stealth)
	deadPeds[charModel.id] = ped

	Timer(function ( source )
		ped.alpha = 255
		--move player to otherside
		spawnOnOtherside(source)
	end, 5000, 1, source)
end)

function spawnOnOtherside( pSource )
	outputChatBox("Вы попали на \"другую сторону\". Умрите, чтобы вернуться.", pSource)
	local startX, startY, startZ = 21.212, 2242.826, 126.68
	pSource:spawn(startX, startY, startZ, 0, pSource.model, 0, othersideDimension)
end

addEventHandler("otherside:logout", getRootElement(), function ( )
	local charModel = source:getData("charModel")
	if deadPeds[charModel.id] ~= nil then
		outputChatBox("Вы покидаете \"другую сторону\".", source)
		deadPeds[charModel.id]:destroy()
		deadPeds[charModel.id] = nil
	end
end)


function removePed( playerSource, _, id )
	id = tonumber(id)
	for _id, ped in pairs(deadPeds) do
		if id == _id then
			ped:destroy()
		end
	end
	deadPeds[id] = nil
end
addCommandHandler("lw_removePed", removePed)