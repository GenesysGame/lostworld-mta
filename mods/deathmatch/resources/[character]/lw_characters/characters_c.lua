-- сlient characters file

local scrW, scrH = guiGetScreenSize()
local statesWindow = nil

addEvent("client:onCharacterUpdated", true)

function keyPressed(button, press)
	if not localPlayer:getData("charModel") then return end
    if press and button == "i" then
    	local show = not statesWindow.wdw.visible
    	if show then
    		updateCharacterStates()
    	end
        statesWindow.wdw.visible = show
    end
end
addEventHandler("onClientKey", root, keyPressed)

function initWindows( res )
	if res.name == "lw_characters" then
		statesWindow = createStatesWindow()
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),	initWindows)

function updateCharacterStates( )
	local charModel = localPlayer:getData("charModel")
	if not charModel then
		statesWindow.wdw.visible = false	
	else
		statesWindow.lblFirstname.text = charModel.firstname
		statesWindow.lblLastname.text = charModel.lastname
		statesWindow.lblSex.text = charModel.sex == 0 and "Мужской" or "Женский"
		statesWindow.lblRace.text = charModel.race == 0 and "Европеец" or charModel.race == 1 and "Негр" or "Азиат"
		statesWindow.lblAge.text = tostring(charModel.age).." лет"
		statesWindow.lblExp.text = tostring(charModel.experience).." ед."
		statesWindow.lblvol.text = tostring(charModel.inventoryVolume).." ед."
		statesWindow.lblwei.text = tostring(charModel.inventoryWeight).." кг"

		if charModel.skinName ~= nil then
			local texture = dxCreateTexture("textures/"..charModel.skinName..".png")
			exports.lw_tools:retexture(source, texture, charModel.skinName)
		end
	end
end
addEventHandler("client:onCharacterUpdated", localPlayer, updateCharacterStates)

addEventHandler( "onClientElementStreamIn", getRootElement(), function ()
    if source.type == "player" then
    	local charModel = source:getData("charModel")
    	if charModel.skinName then
			local texture = dxCreateTexture("textures/"..charModel.skinName..".png")
			exports.lw_tools:retexture(source, texture, charModel.skinName)	
		end
    end
end)

-- TODO: - delete shader when sream out

function createStatesWindow( )
	local x = 20
	local rX = 170
	local y = 0.5 * scrH - 135
	local width = 300
	local height = 270
	local aTable = {}
	aTable.wdw = guiCreateWindow(x, y, width, height, "Характеристики персонажа v0.02", false)

	x = 20
	y = 30
	width = 130
	height = 20
	guiCreateLabel(x, y, width, height, "Имя:", false, aTable.wdw)
	aTable.lblFirstname = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw)

	y = 60
	guiCreateLabel(x, y, width, height, "Фамилия:", false, aTable.wdw)
	aTable.lblLastname = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw)

	y = 90
	guiCreateLabel(x, y, width, height, "Пол:", false, aTable.wdw)
	aTable.lblSex = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw)

	y = 120
	guiCreateLabel(x, y, width, height, "Раса:", false, aTable.wdw)
	aTable.lblRace = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw)

	y = 150
	guiCreateLabel(x, y, width, height, "Возраст:", false, aTable.wdw)
	aTable.lblAge = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw)

	y = 180
	guiCreateLabel(x, y, width, height, "Жизненный опыт:", false, aTable.wdw)
	aTable.lblExp = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw) 

	y = 210
	guiCreateLabel(x, y, width, height, "Объем инвентаря:", false, aTable.wdw)
	aTable.lblvol = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw) 

	y = 240
	guiCreateLabel(x, y, width, height, "Грузоподъемность:", false, aTable.wdw)
	aTable.lblwei = guiCreateLabel(rX, y, width, height, "", false, aTable.wdw) 

	-- делаем окно невидимым
	guiSetVisible(aTable.wdw, false)
	return aTable
end