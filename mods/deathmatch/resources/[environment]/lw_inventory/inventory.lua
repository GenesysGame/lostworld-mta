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
	outputDebugString("Use: "..isUsable)
	outputDebugString("Act: "..isActivated)
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
					totalvol = totalvol + object["volume"]
					totalwei = totalwei + object["weight"]
				end
				if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
					outputChatBox("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!", playerSource)
				else
					id = exports.lw_db:addObject(volume, weight, name, isUsable, isActivated, modelId, character.id)
					outputDebugString("ĪŠ: "..id)
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
			totalvol = totalvol + object["volume"]
			totalwei = totalwei + object["weight"]
		end
		if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
			outputChatBox("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!", playerSource)
		else
			id = exports.lw_db:addObject(volume, weight, name, isUsable, isActivated, modelId, character.id)
			outputDebugString("ĪŠ: "..id)
			table.insert(inventoryModel, { volume = volume, weight = weight, name = name, id = id, isUsable = isUsable, isActivated = isActivated, modelId = modelId, charId = character.id })
		end
		playerSource:setData("inventoryModel", inventoryModel)
		triggerClientEvent(playerSource, "inventory:onUpdate", playerSource, playerSource:getData("inventoryModel"))
	end
end
addCommandHandler("addObj", addObject)

function delObject(source, objectModel )
    exports.lw_db:delObject(objectModel["id"])
	local inventoryModel = source:getData("inventoryModel")
	for i, object in ipairs(inventoryModel) do
		if(object["id"]) == objectModel["id"] then
			local players = getElementsByType("player")
			for _,thePlayer in ipairs(players) do
				local character = thePlayer:getData("charModel")
				if not character then break end
				if(character.id == object["charId"]) then
					table.remove(inventoryModel, i)
					thePlayer:setData("inventoryModel", inventoryModel)
					triggerClientEvent(thePlayer, "inventory:onUpdate", thePlayer, thePlayer:getData("inventoryModel"))
				end
			end
		end
	end
end
addEventHandler("object:delete", resourceRoot, delObject)

function useObject(source, objectModel)
	local inventoryModel = source:getData("inventoryModel")
	outputChatBox("Use, ID: "..objectModel["id"])
	for i, object in ipairs(inventoryModel) do
		if(object["id"]) == objectModel["id"] then
			if(objectModel["isActivated"] == 0) then
				exports.lw_db:updateObject( objectModel["id"], "isActivated", 1 )
				object["isActivated"] = 1
			else
				exports.lw_db:updateObject( objectModel["id"], "isActivated", 0 )
				object["isActivated"] = 0
			end
		end
	end
	source:setData("inventoryModel", inventoryModel)
	triggerClientEvent(source, "inventory:onUpdate", source, source:getData("inventoryModel"))
end
addEventHandler("object:use", resourceRoot, useObject)

function checkIsActivated(source, objectId)
	local inventoryModel = source:getData("inventoryModel")
	for i, object in ipairs(inventoryModel) do
		if(object["id"]) == objectId then
			triggerClientEvent ( source, "inventory:setTextIsActivated", source, tonumber(object["isActivated"]), tonumber(object["isUsable"]))
		end
	end
end
addEventHandler("object:checkIsActivated", resourceRoot, checkIsActivated)

function resourceStart( )
	for i, thePlayer in ipairs(Element.getAllByType("player")) do
		initInventory (thePlayer)
	end
end
addEventHandler("onResourceStart", getRootElement(), resourceStart)

function initInventory ( thePlayer)
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
	print_r(inventoryModel)
	thePlayer:setData("inventoryModel", inventoryModel)
	outputDebugString("Загружен инвентарь")
end

function playerHasBag( pSource )
	local tempName = "Bag"
	local charModel = pSource:getData("charModel")
	if not charModel then return false end
	for i, object in ipairs(allObjects) do
		if charModel.id == object.charId then
			if object.name == tempName then
				return true
			end
		end
	end
	return false
end

function addBag( pSource )
	local tempName = "Bag"
	local hasBag = false
	local charModel = pSource:getData("charModel")
	if not charModel then return end
	if playerHasBag(pSource) then return end

	addObject(pSource, "", 4, 5, tempName, 0, 0, 9999, charModel.id)
end
addCommandHandler("addBag", addBag)

-- Temp: add robber mask command

function playerHasMask( pSource )
	local tempName = "Mask"
	local charModel = pSource:getData("charModel")
	if not charModel then return false end
	for i, object in ipairs(allObjects) do
		if charModel.id == object.charId then
			if object.name == tempName then
				return true
			end
		end
	end
	return false
end

function addMask( pSource )
	local tempName = "Mask"
	local hasMask = false
	local charModel = pSource:getData("charModel")
	if not charModel then return end
	if playerHasMask(pSource) then return end

	addObject(pSource, "", 2, 1, tempName, 1, 0, 2052, charModel.id)
end
addCommandHandler("addMask", addMask)

function wearMask( pSource )
	local charModel = pSource:getData("charModel")
	if not charModel then return end
	if charModel.mask then --temp solution
		exports.bone_attach:detachElementFromBone(charModel.mask)
		charModel.mask:destroy()
		charModel.mask = nil
	else
		charModel.mask = Object(2052, 0, 0, 0)
		exports.bone_attach:attachElementToBone(charModel.mask, pSource, 1, 0, 0, -0.6, 0, 0, 90)
	end
	pSource:setData("charModel", charModel)
end
addCommandHandler("wearMask", wearMask)

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            outputDebugString(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        outputDebugString(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        outputDebugString(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        outputDebugString(indent.."["..pos..'] => "'..val..'"')
                    else
                        outputDebugString(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                outputDebugString(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        outputDebugString(tostring(t).." {")
        sub_print_r(t,"  ")
        outputDebugString("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end