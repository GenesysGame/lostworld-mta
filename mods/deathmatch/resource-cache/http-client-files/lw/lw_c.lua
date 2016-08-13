-- Main client file

local startX, startY, startZ = 500, 2580, 78
local lookAtX, lookAtY, lookAtZ = 300, 2450, 17
function clientJoin( resource )
	if resource.name ~= "lw" then return end
	if not localPlayer:getData("userModel") then
		outputChatBox("Welcome to Lost World Role Play [Dev]!")
		Camera.fade(true, 5)
		Camera.setMatrix(startX, startY, startZ, lookAtX, lookAtY, lookAtZ)
		triggerEvent("onClientShowLoginWindow", localPlayer)
	elseif not localPlayer:getData("charModel") then
		triggerEvent("onClientShowCreateCharWindow", localPlayer)
	end

end
addEventHandler("onClientResourceStart", getRootElement(), clientJoin)