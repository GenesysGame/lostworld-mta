-- Server file for inventory

local allObjects = {}

addEvent("onShowInventory", true)

function showInventory( localPlayer )
	local charModel = localPlayer:getData("charModel")
	if not charModel then return end
	triggerClientEvent(localPlayer, "inventory:onLoad", localPlayer, allObjects)
end
addEventHandler("onShowInventory", resourceRoot, showInventory)

function addObject( playerSource, commandName, volume, weight, name, charId )
	volume = tonumber(volume)
	if (charId) then charId = tonumber(charId) end
	weight = tonumber(weight)
	name = tostring(name)
	if (charId) then
		local players = getElementsByType ("player")
		for i,thePlayer in ipairs(players) do
			local character = thePlayer:getData("charModel")
			if not character then break end
			if(character.id == charId) then
				local totalvol = 0
				local totalwei = 0 
				for i, object in ipairs(allObjects) do
					if(object["charId"]) == character.id then
						totalvol = totalvol + object["volume"]
						totalwei = totalwei + object["weight"]
					end
				end
				if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
					outputChatBox("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!", playerSource)
				else
					id = exports.lw_db:addObject(volume, weight, name, character.id)
					table.insert(allObjects, { volume = volume, weight = weight, name = name, charId = character.id, id = id})
				end
				triggerClientEvent(thePlayer, "inventory:onUpdate", thePlayer, allObjects)
			end
		end
	else
		local character = playerSource:getData("charModel")
		if not character then return end
		local totalvol = 0
		local totalwei = 0 
		for i, object in ipairs(allObjects) do
			if(object["charId"]) == character.id then
				totalvol = totalvol + object["volume"]
				totalwei = totalwei + object["weight"]
			end
		end
		if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
			outputChatBox("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!", playerSource)
		else
			id = exports.lw_db:addObject(volume, weight, name, character.id)
			table.insert(allObjects, { volume = volume, weight = weight, name = name, charId = character.id, id = id})
		end
		triggerClientEvent (playerSource, "inventory:onUpdate", playerSource, allObjects)
	end
end
addCommandHandler("addObj", addObject)

function delObject( playerSource, commandName, id )
    id = tonumber(id)
    exports.lw_db:delObject(id)
	for i, object in ipairs(allObjects) do
		if(object["id"]) == id then
			local players = getElementsByType("player")
			for _,thePlayer in ipairs(players) do
				local character = thePlayer:getData("charModel")
				if not character then break end
				if(character.id == object["charId"]) then
					table.remove(allObjects, i)
					triggerClientEvent(thePlayer, "inventory:onUpdate", thePlayer, allObjects)
				end
			end
		end
	end
end
addCommandHandler("delObj", delObject)

function resourceStart( )
	allObjects = exports.lw_db:getObjects()
	if(allObjects == "Ошибка получения игровых объектов") then 
		allObjects = {}
	end
end
addEventHandler("onResourceStart", getRootElement(), resourceStart)