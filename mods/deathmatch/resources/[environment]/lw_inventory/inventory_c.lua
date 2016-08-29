-- Client file for inventory

addEvent("inventory:onLoad", true)
addEvent("inventory:onUpdate", true)

local scrW, scrH = guiGetScreenSize()
local inventoryView = {}

addEventHandler("onClientResourceStart",resourceRoot, function()
	local window = guiCreateWindow(scrW - 380, scrH - 420, 360, 400, "Инвентарь 0.01", false)
    guiWindowSetSizable(window, false)
    local grid = guiCreateGridList(10, 30, 340, 360, false, window)
    guiGridListAddColumn(grid, "Ваши предметы", 0.9)
    guiSetVisible(window,false)

    inventoryView.wdw = window
    inventoryView.grid = grid
end)

function onLoad( allObjects )
	local character = localPlayer:getData("charModel")
	if not character then
		inventoryView.wdw.visible = false
		return
	end
	inventoryView.wdw.visible = not inventoryView.wdw.visible

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
end
addEventHandler("inventory:onUpdate", localPlayer, onUpdate)

function showInventory(button, press)
    if press and button == "i" then
    	local charModel = localPlayer:getData("charModel")
    	if not charModel then return end
    	triggerServerEvent("onShowInventory", resourceRoot, localPlayer)
    end
end
addEventHandler("onClientKey", root, showInventory)