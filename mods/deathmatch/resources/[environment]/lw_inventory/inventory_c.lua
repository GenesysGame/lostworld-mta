-- Client file for inventory

addEvent("inventory:onLoad", true)
addEvent("inventory:onUpdate", true)
addEvent("inventory:setTextIsActivated", true)

local scrW, scrH = guiGetScreenSize()
local inventoryView = {}

addEventHandler("onClientResourceStart",resourceRoot, function()
	local window = guiCreateWindow(scrW - 380, scrH - 450, 360, 400, "Инвентарь 0.01", false)
    guiWindowSetSizable(window, false)
    local grid = guiCreateGridList(10, 30, 340, 305, false, window)
    guiGridListAddColumn(grid, "Ваши предметы", 0.9)
	local use = guiCreateButton( 10, 345, 100, 40, "E - Использовать", false, window)
	local delete = guiCreateButton( 250, 345, 100, 40, "DELETE - Выбросить", false, window)
    guiSetVisible(window,false)
	  
	local acceptWindow = guiCreateWindow(scrW - 800, scrH - 800, 280, 120, "Подтверждение", false)
    guiWindowSetSizable(acceptWindow, false)
	local accept = guiCreateButton( 10, 60, 130, 40, "Enter - Принять", false, acceptWindow)
	local cancel = guiCreateButton( 140, 60, 130, 40, "Backspace - Отменить", false, acceptWindow)
	local text = guiCreateLabel ( 10, 30, 280, 25, "Вы уверены, что хотите выбросить объект?", false, acceptWindow )
    guiSetVisible(acceptWindow,false)
	
    inventoryView.wdw = window
    inventoryView.grid = grid
	inventoryView.use = use
	inventoryView.delete = delete

	inventoryView.aWdw = acceptWindow
	inventoryView.aAccept = accept
	inventoryView.aCancel = cancel
	inventoryView.text = text
	
	guiSetEnabled(inventoryView.use, false)
	guiSetEnabled(inventoryView.delete, false)
    loadCustomObjects()
	
	addEventHandler ( "onClientGUIClick", source, function ()
		if source == inventoryView.use then useItem()
		elseif source == inventoryView.delete then guiSetVisible(inventoryView.aWdw, true)
		elseif source == inventoryView.grid then checkIsActivated()
		elseif source == inventoryView.aAccept then acceptDelete()
		elseif source == inventoryView.aCancel then guiSetVisible(inventoryView.aWdw, false)
		end
	end)
end)

function onLoad( )
	local character = localPlayer:getData("charModel")
	if not character then
		inventoryView.wdw.visible = false
		return
	end
	local inventoryModel = localPlayer:getData("inventoryModel")
	if not inventoryModel then return false end
	inventoryView.wdw.visible = not inventoryView.wdw.visible
	showCursor(inventoryView.wdw.visible)

	guiGridListClear(inventoryView.grid)
	if inventoryView.wdw.visible then
		for i, object in ipairs(inventoryModel) do
			local row = guiGridListAddRow(inventoryView.grid)
			guiGridListSetItemText(inventoryView.grid, row, 1, "Название: "..object["name"].." | Вес: "..object["weight"].." | Объём: "..object["volume"].." | ID: "..object["id"], false, false)                                        
		end
	end
end
addEventHandler("inventory:onLoad", localPlayer, onLoad)

function onUpdate()
	local character = localPlayer:getData("charModel")
	local inventoryModel = localPlayer:getData("inventoryModel")
	if not inventoryModel then return false end
	if not character then return end
	guiGridListClear(inventoryView.grid)
	for i, object in ipairs(inventoryModel) do 
		local row = guiGridListAddRow(inventoryView.grid)
		guiGridListSetItemText(inventoryView.grid, row, 1, "Название: "..object["name"].." | Вес: "..object["weight"].." | Объём: "..object["volume"].." | ID: "..object["id"], false, false)             
		guiSetText(inventoryView.use,"E - Использовать")
		guiSetEnabled(inventoryView.use, false)
		guiSetEnabled(inventoryView.delete, false)
	end
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
		guiSetText(inventoryView.use,"E - Убрать")
	else
		guiSetText(inventoryView.use,"E - Использовать")
	end
	guiSetEnabled(inventoryView.delete, true)
end
addEventHandler("inventory:setTextIsActivated", localPlayer, setTextIsActivated)

function showInventory(button, press)
    if press and button == "i" then
    	local charModel = localPlayer:getData("charModel")
    	if not charModel then return end
    	triggerServerEvent("onShowInventory", resourceRoot, localPlayer)
	end
	if(inventoryView.wdw.visible == true) then
		if press and button == "e" then
			useItem()
		elseif press and button == "delete" then
			guiSetVisible(inventoryView.aWdw, true)
		elseif press and button == "w" then
			if(guiGridListGetSelectedItem ( inventoryView.grid ) ~= 0) then
				guiGridListSetSelectedItem ( inventoryView.grid, guiGridListGetSelectedItem ( inventoryView.grid )-1, 1)
				checkIsActivated()
			end
		elseif press and button == "s" then
			if(guiGridListGetSelectedItem ( inventoryView.grid ) ~= guiGridListGetRowCount ( inventoryView.grid )-1) then
				guiGridListSetSelectedItem ( inventoryView.grid, guiGridListGetSelectedItem ( inventoryView.grid )+1, 1)
				checkIsActivated()
			end
		end
	end
	if(inventoryView.aWdw.visible == true) then
		if press and button == "enter" then
			acceptDelete()
		elseif press and button == "backspace" then
			guiSetVisible(inventoryView.aWdw, false)
		end
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
	local inventoryModel = localPlayer:getData("inventoryModel")
	if not inventoryModel then return false end
	if inventoryModel[guiGridListGetSelectedItem ( inventoryView.grid )+1] then
		triggerServerEvent ( "object:checkIsActivated", resourceRoot, localPlayer, inventoryModel[guiGridListGetSelectedItem ( inventoryView.grid )+1]["id"])
	else
		guiSetEnabled(inventoryView.use, false)
		guiSetEnabled(inventoryView.delete, false)
	end
end


function useItem()
	if guiGetEnabled(inventoryView.use) then
		local inventoryModel = localPlayer:getData("inventoryModel")
		if not inventoryModel then return false end
		triggerServerEvent ( "object:use", resourceRoot, localPlayer, inventoryModel[guiGridListGetSelectedItem ( inventoryView.grid )+1])
	end
end

function isEmpty(str)
  return str == nil or str == ''
end

function acceptDelete()
	local inventoryModel = localPlayer:getData("inventoryModel")
	if not inventoryModel then return false end
	guiSetVisible(inventoryView.aWdw, false)
	triggerServerEvent ( "object:delete", resourceRoot, localPlayer, inventoryModel[guiGridListGetSelectedItem ( inventoryView.grid )+1])
end