-- server characters file

addEvent("onCharacterLoaded", true)

function spawn( pSource )
	local charModel = pSource:getData("charModel")
	local startX, startY, startZ = 378, 2507, 17
	pSource:spawn(startX, startY, startZ, 0, charModel.skinId, 0, 0)
	pSource.cameraTarget = pSource
end

function characterLoaded( charModel )
	source:setData("charModel", charModel)
	spawn(source)
end
addEventHandler("onCharacterLoaded", getRootElement(), characterLoaded)

function playerWasted( )
	Timer(spawn, 3000, 1, source)
end
addEventHandler("onPlayerWasted", getRootElement(), playerWasted)