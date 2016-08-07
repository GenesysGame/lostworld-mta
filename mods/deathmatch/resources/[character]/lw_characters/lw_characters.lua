-- server characters file

local startX, startY, startZ = 300, 2450, 17

addEvent("onCharacterLoaded", true)

function specialEventHandler( charModel )
	source:spawn(startX, startY, startZ, 0, charModel.skinId, 0, 0)
	source.cameraTarget = source
end
addEventHandler("onCharacterLoaded", getRootElement(), specialEventHandler)