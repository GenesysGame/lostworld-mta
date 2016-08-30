-- Client file for inventory

addEvent("inventory:onLoad", true)
addEvent("inventory:onUpdate", true)
addEvent("inventory:setTextIsActivated", true)

local scrW, scrH = guiGetScreenSize()
local inventoryView = {}

addEventHandler("onClientResourceStart",resourceRoot, function()
	local window = guiCreateWindow(scrW - 380, scrH - 450, 360, 400, "Инвентарь 0.01", false)
    guiWindowSetSizable(window, false)
    local grid = guiCreateGridList(10, 30, 340, 330, false, window)
    guiGridListAddColumn(grid, "Ваши предметы", 0.9)
	local use = guiCreateButton( 10, 370, 100, 25, "Использовать", false, window)
	local delete = guiCreateButton( 250, 370, 100, 25, "Выбросить", false, window)
    guiSetVisible(window,false)
	  
    inventoryView.wdw = window
    inventoryView.grid = grid
	inventoryView.use = use
	inventoryView.delete = delete

    loadCustomObjects()
	
	addEventHandler ( "onClientGUIClick", inventoryView.use, useItem)
	addEventHandler ( "onClientGUIClick", inventoryView.delete, deleteItem)
	addEventHandler ( "onClientGUIClick", inventoryView.grid, checkIsActivated )
end)

function onLoad( allObjects )
	local character = localPlayer:getData("charModel")
	if not character then
		inventoryView.wdw.visible = false
		return
	end
	inventoryView.wdw.visible = not inventoryView.wdw.visible
	showCursor(inventoryView.wdw.visible)

	guiGridListClear(inventoryView.grid)
	if inventoryView.wdw.visible then
		for i, object in ipairs(allObjects) do
			if(object["charId"] == character.id) then 
				local row = guiGridListAddRow(inventoryView.grid)
				guiGridListSetItemText(inventoryView.grid, row, 1, "Название: "..object["name"].." | Вес: "..object["weight"].." | Объём: "..object["volume"].." | ID: "..object["id"], false, false)             
			end                             
		end
	end
end
addEventHandler("inventory:onLoad", localPlayer, onLoad)

function onUpdate( allObjects, objectId )
	local character = localPlayer:getData("charModel")
	if not character then return end
	guiGridListClear(inventoryView.grid)
	for i, object in ipairs(allObjects) do
		if(object["charId"] == character.id) then 
			local row = guiGridListAddRow(inventoryView.grid)
			guiGridListSetItemText(inventoryView.grid, row, 1, "Название: "..object["name"].." | Вес: "..object["weight"].." | Объём: "..object["volume"].." | ID: "..object["id"], false, false)             
		end
		if(object["id"] == objectId) then
			if(object["isActivated"] == 1) then
				guiSetText(inventoryView.use,"Убрать")
			else
				guiSetText(inventoryView.use,"Использовать")
			end
		end
	end
end
addEventHandler("inventory:onUpdate", localPlayer, onUpdate)

function onUpdate( allObjects )
	local character = localPlayer:getData("charModel")
	if not character then return end
	guiGridListClear(inventoryView.grid)
	for i, object in ipairs(allObjects) do
		if(object["charId"] == character.id) then 
			local row = guiGridListAddRow(inventoryView.grid)
			guiGridListSetItemText(inventoryView.grid, row, 1, "Название: "..object["name"].." | Вес: "..object["weight"].." | Объём: "..object["volume"].." | ID: "..object["id"], false, false)             
		end
	end
	guiSetText(inventoryView.use,"Использовать")
end
addEventHandler("inventory:onUpdate", localPlayer, onUpdate)

function setTextIsActivated(isActivated, isUsable)
	outputDebugString("Act: "..isActivated)
	outputDebugString("Use: "..isUsable)
	if(isUsable == 1) then
		guiSetEnabled(inventoryView.use, true)
	else
		guiSetEnabled(inventoryView.use, false)
	end
	if(isActivated == 1) then
		guiSetText(inventoryView.use,"Убрать")
	else
		guiSetText(inventoryView.use,"Использовать")
	end
end
addEventHandler("inventory:setTextIsActivated", localPlayer, setTextIsActivated)

function showInventory(button, press)
    if press and button == "i" then
    	local charModel = localPlayer:getData("charModel")
    	if not charModel then return end
    	triggerServerEvent("onShowInventory", resourceRoot, localPlayer)
    end
end
addEventHandler("onClientKey", root, showInventory)

-- custom object models

function loadCustomObjects( )
	local txd = engineLoadTXD("models/robmask.txd")
	local dff = engineLoadDFF("models/robmask.dff")
	engineImportTXD(txd, 2052)
	engineReplaceModel(dff, 2052)
end

function checkIsActivated()
	local objectId = guiGridListGetItemText ( inventoryView.grid, guiGridListGetSelectedItem ( inventoryView.grid ), 1 )
	objectId = string.sub (objectId, string.find(objectId,"ID: ")+3 )
	objectId = tonumber(objectId)
	triggerServerEvent ( "object:checkIsActivated", resourceRoot, localPlayer, objectId)
end


function useItem()
	if(guiGetEnabled(inventoryView.use)) then
		local objectId = guiGridListGetItemText ( inventoryView.grid, guiGridListGetSelectedItem ( inventoryView.grid ), 1 )
		objectId = string.sub (objectId, string.find(objectId,"ID: ")+3)
		triggerServerEvent ( "object:use", resourceRoot, localPlayer, objectId)
	end
end

function deleteItem()
	local objectId = guiGridListGetItemText ( inventoryView.grid, guiGridListGetSelectedItem ( inventoryView.grid ), 1 )
	objectId = string.sub (objectId, string.find(objectId,"ID: ")+3)
	triggerServerEvent ( "object:delete", resourceRoot, objectId)
end