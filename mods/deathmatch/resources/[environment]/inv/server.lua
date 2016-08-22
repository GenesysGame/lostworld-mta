local allObjects = {}

function showInventory (localPlayer)
	triggerClientEvent (localPlayer, "onLoad", localPlayer, allObjects)
end
addEvent("onShowInventory", true)
addEventHandler("onShowInventory", resourceRoot, showInventory)

function addObject (playerSource, commandName, volume, weight, name, charId)
	volume = tonumber(volume)
	if(charid) then charid = tonumber(charid) end
	weight = tonumber(weight)
	name = tostring(name)
	if(charId) then
		exports.lw_db:addObjects(volume, weight, name, charId)
		table.insert(allObjects, { id = allObjects[table.maxn(allObjects)]["id"]+1, volume = volume, weight = weight, name = name, charId = charId})
	else
		local character = playerSource:getData("charModel")
		local totalvol = 0
		local totalwei = 0
		for i, object in ipairs(allObjects) do
			if(object["charId"]) == character.id then
				totalvol = totalvol + object["volume"]
				totalwei = totalwei + object["weight"]
			end
		end
		outputDebugString("Vol: "..totalvol)
		outputDebugString("Wei: "..totalwei)
		if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
			outputDebugString("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!")
		else
			exports.lw_db:addObjects(volume, weight, name, character.id)
			table.insert(allObjects, { id = allObjects[table.maxn(allObjects)]["id"]+1, volume = volume, weight = weight, name = name, charId = character.id})
		end
	end
end
addCommandHandler ("addObj", addObject)

function delObject (playerSource, commandName, id)
    id = tonumber(id)
    exports.lw_db:delObjects(id)
	for i, object in ipairs(allObjects) do
		if(object["id"]) == id then
			table.remove(allObjects, i)
		end
	end
end
addCommandHandler ("delObj", delObject)

function resourceStart ()
	allObjects = exports.lw_db:getObjects()
end
addEventHandler ("onResourceStart", getRootElement(), resourceStart)