-- Server file for inventory

local allObjects = {}

addEvent("onShowInventory", true)
addEvent("object:delete", true)
addEvent("object:use", true)
addEvent("object:checkIsActivated", true)

function showInventory( localPlayer )
	local charModel = localPlayer:getData("charModel")
	if not charModel then return end
	triggerClientEvent(localPlayer, "inventory:onLoad", localPlayer, allObjects)
end
addEventHandler("onShowInventory", resourceRoot, showInventory)

function addObject( playerSource, commandName, volume, weight, name, charId, isUsable, isActivated, modelId)
	outputDebugString("Use: "..isUsable)
	outputDebugString("Act: "..isActivated)
	if (charId) then charId = tonumber(charId) end
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
					id = exports.lw_db:addObject(volume, weight, name, character.id, isUsable, isActivated, modelId)
					table.insert(allObjects, { volume = volume, weight = weight, name = name, charId = character.id, id = id, isUsable = isUsable, isActivated = isActivated, modelId = modelId})
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
			id = exports.lw_db:addObject(volume, weight, name, character.id, isUsable, isActivated, modelId)
			table.insert(allObjects, { volume = volume, weight = weight, name = name, charId = character.id, id = id, isUsable = isUsable, isActivated = isActivated, modelId = modelId})
		end
		triggerClientEvent(playerSource, "inventory:onUpdate", playerSource, allObjects)
	end
end
addCommandHandler("addObj", addObject)

function delObject( id )
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
addEventHandler("object:delete", resourceRoot, delObject)

function useObject(source, objectId)
	objectId = tonumber(objectId)
	outputChatBox("Use, ID: "..objectId)
	for i, object in ipairs(allObjects) do
		if(object["id"]) == objectId then
			if(object["isActivated"] == 0) then
				exports.lw_db:updateObject( objectId, "isActivated", 1 )
				object["isActivated"] = 1
			else
				exports.lw_db:updateObject( objectId, "isActivated", 0 )
				object["isActivated"] = 0
			end
		end
	end
	triggerClientEvent(source, "inventory:onUpdate", source, allObjects)
end
addEventHandler("object:use", resourceRoot, useObject)

function checkIsActivated(source, objectId)
	for i, object in ipairs(allObjects) do
		if(object["id"]) == objectId then
			triggerClientEvent ( source, "inventory:setTextIsActivated", source, tonumber(object["isActivated"]), tonumber(object["isUsable"]))
		end
	end
end
addEventHandler("object:checkIsActivated", resourceRoot, checkIsActivated)

function resourceStart( )
	allObjects = exports.lw_db:getObjects()
	if(allObjects == "Ошибка получения игровых объектов") then 
		allObjects = {}
	end
	for i, thePlayer in ipairs(Element.getAllByType("player")) do
		local charModel = thePlayer:getData("charModel")
		local inventoryModel = {}
		for j, object in ipairs(allObjects) do
			if charModel.id == object["charId"] then
				table.insert(inventoryModel, object)
			end
		end
		thePlayer:setData("inventoryModel", inventoryModel)
	end
end
addEventHandler("onResourceStart", getRootElement(), resourceStart)

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

	addObject(pSource, "", 4, 5, tempName, charModel.id, 0, 0, 9999)
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

	addObject(pSource, "", 2, 1, tempName, charModel.id, 1, 0, 2052)
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