allObjects = {}

function showInventory (localPlayer)
	triggerClientEvent (localPlayer, "onLoad", localPlayer, allObjects)
end
addEvent("onShowInventory", true)
addEventHandler("onShowInventory", resourceRoot, showInventory)

function addObject (playerSource, commandName, volume, weight, name, charId)
	volume = tonumber(volume)
	if(charId) then charId = tonumber(charId) end
	weight = tonumber(weight)
	name = tostring(name)
	if(charId) then
		local players = getElementsByType ("player")
		for i,thePlayer in ipairs(players) do
			local character = thePlayer:getData("charModel")
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
					outputDebugString("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!")
				else
					id = exports.lw_db:addObjects(volume, weight, name, character.id)
					outputDebugString("C: "..id)
					table.insert(allObjects, { volume = volume, weight = weight, name = name, charId = character.id, id = id})
					print_r(allObjects)
				end
				triggerClientEvent (thePlayer, "onUpdate", thePlayer, allObjects)
			end
		end
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
		if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
			outputDebugString("Невозможно добавить предмет данному игроку. Вес или объём исчерпан!")
		else
			id = exports.lw_db:addObjects(volume, weight, name, character.id)
			outputDebugString("C: "..id)
			table.insert(allObjects, { volume = volume, weight = weight, name = name, charId = character.id, id = id})
			print_r(allObjects)
		end
		triggerClientEvent (playerSource, "onUpdate", playerSource, allObjects)
	end
end
addCommandHandler ("addObj", addObject)

function delObject (playerSource, commandName, id)
    id = tonumber(id)
    exports.lw_db:delObjects(id)
	for i, object in ipairs(allObjects) do
		if(object["id"]) == id then
			local players = getElementsByType ("player")
			for _,thePlayer in ipairs(players) do
				local character = thePlayer:getData("charModel")
				if(character.id == object["charId"]) then
					table.remove(allObjects, i)
					triggerClientEvent (thePlayer, "onUpdate", thePlayer, allObjects)
				end
			end
		end
	end
end
addCommandHandler ("delObj", delObject)

function resourceStart ()
	allObjects = exports.lw_db:getObjects()
	if(allObjects == "Ошибка получения игровых объектов") then 
		allObjects = {}
	else
		for i, object in ipairs(allObjects) do
			table.insert(allObjects, { volume = object["volume"], weight = object["weight"], name = object["name"], charId = object["charId"], id = object["id"]})
		end
	end
	print_r(allObjects)
end
addEventHandler ("onResourceStart", getRootElement(), resourceStart)

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