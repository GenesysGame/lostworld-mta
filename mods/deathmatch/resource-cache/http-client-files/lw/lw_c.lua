-- Main client file

local startX, startY, startZ = 500, 2580, 78
local lookAtX, lookAtY, lookAtZ = 300, 2450, 17
function clientJoin( resource )
	if resource.name ~= "lw" then return end
	-- spawnPlayer(source, spawnX, spawnY, spawnZ)
	-- fadeCamera(source, true)
	-- setCameraTarget(source, source)
	outputChatBox("Welcome to Lost World Role Play [Dev]!")
	-- slowly fade the camera in to make the screen visible
	Camera.fade(true, 5)
    Camera.setMatrix(startX, startY, startZ, lookAtX, lookAtY, lookAtZ)
end
addEventHandler("onClientResourceStart", getRootElement(), clientJoin)