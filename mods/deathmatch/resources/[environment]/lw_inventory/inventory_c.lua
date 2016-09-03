-- Client file for inventory

addEvent("inventory:onLoad", true)
addEvent("inventory:onUpdate", true)
addEvent("inventory:setTextIsActivated", true)

local scrW, scrH = guiGetScreenSize()
local inventoryView = {}

addEventHandler("onClientResourceStart",resourceRoot, function()
	local window = guiCreateWindow(scrW - 380, scrH - 450, 360, 400, "Инвентарь 0.02", false)
    guiWindowSetSizable(window, false)
    guiWindowSetMovable(window, false)
    local grid = guiCreateGridList(10, 30, 340, 320, false, window)
    guiGridListAddColumn(grid, "ID", 0.2)
    guiGridListAddColumn(grid, "Название", 0.4)
    guiGridListAddColumn(grid, "Объем", 0.15)
    guiGridListAddColumn(grid, "Вес", 0.15)
	local use = guiCreateButton(10, 360, 110, 30, "Использовать (Е)", false, window)
	local delete = guiCreateButton(240, 360, 110, 30, "Выбросить (Del)", false, window)
    guiSetVisible(window, false)
	
	local x = scrW - 355
	local y = scrH - 310
	local acceptWindow = guiCreateWindow(x, y, 310, 120, "Подтверждение", false)
    guiWindowSetSizable(acceptWindow, false)
    guiWindowSetMovable(acceptWindow, false)
	local accept = guiCreateButton(10, 70, 140, 30, "Принять (Enter)", false, acceptWindow)
	local cancel = guiCreateButton(160, 70, 140, 30, "Отменить (Backspace)", false, acceptWindow)
	local text = guiCreateLabel(10, 30, 280, 25, "Вы уверены, что хотите выбросить предмет?", false, acceptWindow)
	guiLabelSetHorizontalAlign(text, "center")
    guiSetVisible(acceptWindow,false)
	
    inventoryView.wdw = window
    inventoryView.grid = grid
	inventoryView.use = use
	inventoryView.delete = delete

	inventoryView.aWdw = acceptWindow
	inventoryView.aAccept = accept
	inventoryView.aCancel = cancel
	inventoryView.text = text

    loadCustomObjects()
	
	addEventHandler("onClientGUIClick", source, function ()
		if source == inventoryView.use then useItem()
		elseif source == inventoryView.delete then 
			guiSetEnabled(inventoryView.wdw, false)
			guiSetVisible(inventoryView.aWdw, true)
			guiBringToFront(inventoryView.aWdw)
		elseif source == inventoryView.grid then checkIsActivated()
		elseif source == inventoryView.aAccept then acceptDelete()
		elseif source == inventoryView.aCancel then 
			guiSetEnabled(inventoryView.wdw, true)
			guiSetVisible(inventoryView.aWdw, false)
		end
	end)
end)

function onLoad( inventoryModel )
	local character = localPlayer:getData("charModel")
	if not character then
		inventoryView.wdw.visible = false
		return
	end
	inventoryView.wdw.visible = not inventoryView.wdw.visible
	showCursor(inventoryView.wdw.visible)

	guiGridListClear(inventoryView.grid)
	if inventoryView.wdw.visible then
		drawInventory(inventoryModel)
	end
	guiSetEnabled(inventoryView.use, false)
	guiSetEnabled(inventoryView.delete, false)
end
addEventHandler("inventory:onLoad", localPlayer, onLoad)

function onUpdate( inventoryModel )
	local character = localPlayer:getData("charModel")
	if not character then return end
	guiGridListClear(inventoryView.grid)
	drawInventory(inventoryModel)
	checkIsActivated()
end
addEventHandler("inventory:onUpdate", localPlayer, onUpdate)

function drawInventory( inventoryModel )
	for i, anObject in ipairs(inventoryModel) do
		local row = guiGridListAddRow(inventoryView.grid)
		guiGridListSetItemText(inventoryView.grid, row, 1, anObject.id, false, true)
		guiGridListSetItemText(inventoryView.grid, row, 2, anObject.name, false, false)
		guiGridListSetItemText(inventoryView.grid, row, 3, anObject.volume, false, true)
		guiGridListSetItemText(inventoryView.grid, row, 4, anObject.weight, false, true)
	end
end

function setTextIsActivated( isActivated, isUsable )
	guiSetEnabled(inventoryView.use, isUsable == 1)
	guiSetText(inventoryView.use, isActivated == 1 and "Убрать (E)" or "Использовать (E)")
	guiSetEnabled(inventoryView.delete, true)
end
addEventHandler("inventory:setTextIsActivated", localPlayer, setTextIsActivated)

function pressedKeyHandler( button, press )
    if press and button == "i" then
    	local charModel = localPlayer:getData("charModel")
    	if not charModel then return end
    	triggerServerEvent("onShowInventory", resourceRoot, localPlayer)
	end
	if(inventoryView.wdw.visible == true) then
		if press and button == "e" then
			useItem()
		elseif press and button == "delete" then
			guiSetEnabled(inventoryView.wdw, false)
			guiSetVisible(inventoryView.aWdw, true)
			guiBringToFront(inventoryView.aWdw)
		elseif press and button == "w" then
			if(guiGridListGetSelectedItem(inventoryView.grid) ~= 0) then
				guiGridListSetSelectedItem(inventoryView.grid, guiGridListGetSelectedItem(inventoryView.grid ) - 1, 1)
				checkIsActivated()
			end
		elseif press and button == "s" then
			if(guiGridListGetSelectedItem(inventoryView.grid) ~= guiGridListGetRowCount(inventoryView.grid) - 1) then
				guiGridListSetSelectedItem(inventoryView.grid, guiGridListGetSelectedItem ( inventoryView.grid ) + 1, 1)
				checkIsActivated()
			end
		end
	end
	if(inventoryView.aWdw.visible == true) then
		if press and button == "enter" then
			guiSetEnabled(inventoryView.wdw, true)
			acceptDelete()
		elseif press and button == "backspace" then
			guiSetEnabled(inventoryView.wdw, true)
			guiSetVisible(inventoryView.aWdw, false)
		end
	end
end
addEventHandler("onClientKey", root, pressedKeyHandler)

-- custom object models

function loadCustomObjects( )
	local txd = engineLoadTXD("models/robmask.txd")
	local dff = engineLoadDFF("models/robmask.dff")
	engineImportTXD(txd, 2052)
	engineReplaceModel(dff, 2052)
	local bagTXD = engineLoadTXD("models/sportbag.txd")
    local bagDFF = engineLoadDFF("models/sportbag.dff")
    engineImportTXD(bagTXD, 2843)
    engineReplaceModel(bagDFF, 2843)

end

function checkIsActivated()
	local selectedObject = getSelectedObject()
	if selectedObject then
		triggerServerEvent("object:checkIsActivated", resourceRoot, localPlayer, selectedObject)
	else
		guiSetEnabled(inventoryView.use, false)
		guiSetEnabled(inventoryView.delete, false)
	end
end


function useItem()
	if guiGetEnabled(inventoryView.use) then
		local selectedObject = getSelectedObject()
		triggerServerEvent("object:use", resourceRoot, localPlayer, selectedObject)
	end
end

function getSelectedObject( )
	local inventoryModel = localPlayer:getData("inventoryModel")
	local selectedObjectId = tonumber(guiGridListGetItemText(inventoryView.grid, guiGridListGetSelectedItem(inventoryView.grid), 1))
	if selectedObjectId and inventoryModel then
		for i, anObject in ipairs(inventoryModel) do
			if anObject.id == selectedObjectId then
				return anObject
			end
		end
	end
	return nil
end

function isEmpty(str)
  return str == nil or str == ''
end

function acceptDelete()
	local inventoryModel = localPlayer:getData("inventoryModel")
	if not inventoryModel then return end
	guiSetVisible(inventoryView.aWdw, false)
	triggerServerEvent ( "object:delete", resourceRoot, localPlayer, inventoryModel[guiGridListGetSelectedItem(inventoryView.grid)+1])
end