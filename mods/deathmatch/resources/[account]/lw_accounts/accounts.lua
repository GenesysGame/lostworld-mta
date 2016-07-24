-- Server file for accounts management


--TODO: Delete ------------------------------------------------
local spawnX, spawnY, spawnZ = 1959.55, -1714.46, 19
function joinHandler()
	spawnPlayer(source, spawnX, spawnY, spawnZ)
	fadeCamera(source, true)
	setCameraTarget(source, source)
	outputChatBox("Welcome to My Server", source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)
---------------------------------------------------------------