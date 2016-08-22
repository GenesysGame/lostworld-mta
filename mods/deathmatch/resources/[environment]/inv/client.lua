addEventHandler("onClientResourceStart",resourceRoot,
function()
	window = guiCreateWindow(436, 322, 396, 435, "Inv", false)
    guiWindowSetSizable(window, false)
    grib = guiCreateGridList(9, 29, 377, 396, false, window)
    guiGridListAddColumn(grib, "Inventory", 0.9)
    guiSetVisible(window,false)
end)

function onLoad (allObjects)
	local character = localPlayer:getData("charModel")
	showCursor( not guiGetVisible(window))
	guiSetVisible(window, not guiGetVisible(window))
	guiGridListClear ( grib )
	if(guiGetVisible(window)) then
		for i, object in ipairs(allObjects) do
			if(object["charId"] == character.id) then 
				local row = guiGridListAddRow ( grib )
				guiGridListSetItemText ( grib, row, 1, "Название: "..object["name"].." | Вес: "..object["volume"].." | Объём: "..object["weight"].." | ID: "..object["id"], false, false )             
			end                             
		end
	end
end
addEvent("onLoad", true)
addEventHandler("onLoad", localPlayer, onLoad)

function showInventory(button, press)
    if press and button == "i" then
    	triggerServerEvent ( "onShowInventory", resourceRoot, localPlayer)
    end
end
addEventHandler("onClientKey", root, showInventory)