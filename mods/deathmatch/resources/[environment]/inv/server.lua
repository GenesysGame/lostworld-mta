function load ( playerSource, commandName )
    objects = exports.lw_db:getObjects()
		for i, object in ipairs(objects) do
			outputDebugString("OBJECT: "..i)
			local string = ""
			for key, field in pairs(object) do
				string = string.."| "..key..": "..tostring(field).." "
			end
			outputDebugString(string)
		end
    triggerClientEvent ( playerSource, "onLoad", playerSource, objects)
end
addCommandHandler ( "load", load )


function addobj ( playerSource, commandName, volume, charid, posy, weight, posz, posx, name)
    local character = playerSource:getData("charModel")
	volume = tonumber(volume)
	charid = tonumber(charid)
	posy = tonumber(posy)
	weight = tonumber(weight)
	posz = tonumber(posz)
	posx = tonumber(posx)
	name = tostring(name)
	table = exports.lw_db:getCharObjects(charid)
	totalvol = 0
	totalwei = 0
	for i, object in ipairs(table) do
			totalvol = totalvol + object["volume"]
			totalwei = totalwei + object["weight"]
	end
	outputDebugString("Vol: "..totalvol)
	outputDebugString("Wei: "..totalwei)
	outputDebugString("Vol2: "..character.inventoryVolume)
	outputDebugString("Wei2: "..character.inventoryWeight)
	if(character.inventoryVolume < totalvol + volume or character.inventoryWeight < totalwei + weight) then
		outputDebugString("Низзя!")
	else
    	exports.lw_db:addObjects( volume, charid, posy, weight, posz, posx, name )
	end
end
addCommandHandler ( "addobj", addobj )

function delobj ( playerSource, commandName, id)
    id = tonumber(id)
    local character = playerSource:getData("charModel")
    exports.lw_db:delObjects( id )
end
addCommandHandler ( "delobj", delobj )