-- Server file for inventory

local allObjects = {}

addEvent("onShowInventory", true)
addEvent("object:delete", true)
addEvent("object:use", true)
addEvent("object:checkIsActivated", true)

function showInventory( localPlayer )
	local charModel = localPlayer:getData("charModel")
	local inventoryModel = localPlayer:getData("inventoryModel")
	if not charModel then return end
	triggerClientEvent(localPlayer, "inventory:onLoad", localPlayer, inventoryModel)
end
addEventHandler("onShowInventory", resourceRoot, showInventory)

function addObject( playerSource, commandName, volume, weight, name, isUsable, isActivated, modelId, charId)
	if (charId) then charId = tonumber(charId) end
	name = tostring(name)
	if (charId) then
		local players = getElementsByType ("player")
		for i,thePlayer in ipairs(players) do
			local character = thePlayer:getData("charModel")
			local inventoryModel = thePlayer:getData("inventoryModel")
			if not character then break end
			if(character.id == charId) then
				local totalvol = 0
				local totalwei = 0 
				for i, object in ipairs(inventoryModel) do
					totalvol = totalvol + object.volume
					totalwei = totalwei + object.weight
				end
				if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
					outputChatBox("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!", playerSource)
				else
					id = exports.lw_db:addObject(volume, weight, name, isUsable, isActivated, modelId, character.id)
					table.insert(inventoryModel, { volume = volume, weight = weight, name = name, id = id, isUsable = isUsable, isActivated = isActivated, modelId = modelId, charId = character.id })
				end
				thePlayer:setData("inventoryModel", inventoryModel)
				triggerClientEvent(thePlayer, "inventory:onUpdate", thePlayer, thePlayer:getData("inventoryModel"))
			end
		end
	else
		local character = playerSource:getData("charModel")
		local inventoryModel = playerSource:getData("inventoryModel")
		if not character then return end
		local totalvol = 0
		local totalwei = 0 
		for i, object in ipairs(inventoryModel) do
			totalvol = totalvol + object.volume
			totalwei = totalwei + object.weight
		end
		if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
			outputChatBox("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!", playerSource)
		else
			id = exports.lw_db:addObject(volume, weight, name, isUsable, isActivated, modelId, character.id)
			table.insert(inventoryModel, { volume = volume, weight = weight, name = name, id = id, isUsable = isUsable, isActivated = isActivated, modelId = modelId, charId = character.id })
		end
		playerSource:setData("inventoryModel", inventoryModel)
		triggerClientEvent(playerSource, "inventory:onUpdate", playerSource, playerSource:getData("inventoryModel"))
	end
end
addCommandHandler("addObj", addObject)

function delObject(source, objectModel )
    exports.lw_db:delObject(objectModel.id)
	local inventoryModel = source:getData("inventoryModel")
	for i, object in ipairs(inventoryModel) do
		if object.id == objectModel.id then
			local players = getElementsByType("player")
			for _,thePlayer in ipairs(players) do
				local character = thePlayer:getData("charModel")
				if not character then break end
				if character.id == object.charId then
					table.remove(inventoryModel, i)
					thePlayer:setData("inventoryModel", inventoryModel)
					triggerClientEvent(thePlayer, "inventory:onUpdate", thePlayer, thePlayer:getData("inventoryModel"))
				end
			end
		end
	end
end
addEventHandler("object:delete", resourceRoot, delObject)

function useObjectHandler( source, objectModel )
	local inventoryModel = source:getData("inventoryModel")
	for i, anObject in ipairs(inventoryModel) do
		if anObject.id == objectModel.id then
			inventoryModel[i] = useObject(source, objectModel)
		end
	end
	source:setData("inventoryModel", inventoryModel)
	triggerClientEvent(source, "inventory:onUpdate", source, inventoryModel)
end
addEventHandler("object:use", resourceRoot, useObjectHandler)

function checkIsActivated( source, objectModel )
	for i, anObject in ipairs(allObjects) do
		if objectModel.id == anObject.id and objectModel.charId == anObject.charId then
			triggerClientEvent(source, "inventory:setTextIsActivated", source, tonumber(objectModel.isActivated), tonumber(objectModel.isUsable))
			return
		end
	end
end
addEventHandler("object:checkIsActivated", resourceRoot, checkIsActivated)

function resourceStart( )
	for i, thePlayer in ipairs(Element.getAllByType("player")) do
		initInventory(thePlayer)
	end
end
addEventHandler("onResourceStart", getRootElement(), resourceStart)

function initInventory( thePlayer )
	allObjects = exports.lw_db:getObjects()
	if(allObjects == "Ошибка получения игровых объектов") then 
		allObjects = {}
	end
	local charModel = thePlayer:getData("charModel")
	if not charModel then return end
	local inventoryModel = {}
	for j, object in ipairs(allObjects) do
		if charModel.id == object["charId"] then
			table.insert(inventoryModel, object)
		end
	end
	thePlayer:setData("inventoryModel", inventoryModel)
	outputDebugString("Загружен инвентарь")
end

function addBag( pSource )
	local tempName = "Sport Bag"
	local hasBag = false
	local charModel = pSource:getData("charModel")
	if not charModel then return end

	addObject(pSource, "", 4, 1, tempName, 1, 0, 2843, charModel.id)
end
addCommandHandler("addBag", addBag)

-- Temp: add robber mask command

function addMask( pSource )
	local tempName = "Mask"
	local hasMask = false
	local charModel = pSource:getData("charModel")
	if not charModel then return end

	addObject(pSource, "", 2, 1, tempName, 1, 0, 2052, charModel.id)
end
addCommandHandler("addMask", addMask)

-- Objects using

function useObject( pSource, objectModel )
	local charModel = pSource:getData("charModel")
	if not objectModel.modelId or objectModel.modelId == 0 then
		-- Using of object without model
	else
		if objectModel.isActivated == 0 then
			local anObject = Object(objectModel.modelId, 0, 0, 0)
			exports.lw_db:updateObject(objectModel.id, "isActivated", 1)
			objectModel.isActivated = 1
			if objectModel.modelId == 2052 then -- is Mask
				charModel.mask = anObject
				exports.bone_attach:attachElementToBone(anObject, pSource, 1, 0, 0, -0.6, 0, 0, 90)
			elseif objectModel.modelId == 2843 then -- is Bag
				charModel.bag = anObject
				exports.bone_attach:attachElementToBone(anObject, pSource, 3, 0, 0, -0.23, 0, 0, 90)
			end
		else
			exports.lw_db:updateObject(objectModel.id, "isActivated", 0)
			objectModel.isActivated = 0
			if objectModel.modelId == 2052 then
				local mask = charModel.mask
				charModel.mask = nil
				if mask then
					exports.bone_attach:detachElementFromBone(mask)
					mask:destroy()
				end
			elseif objectModel.modelId == 2843 then
				local bag = charModel.bag
				charModel.bag = nil
				if bag then
					exports.bone_attach:detachElementFromBone(bag)
					bag:destroy()
				end
			end
		end
	end
	pSource:setData("charModel", charModel)
	return objectModel
end