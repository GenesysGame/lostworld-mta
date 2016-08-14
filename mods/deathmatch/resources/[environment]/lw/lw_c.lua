-- Main client file

function clientJoin( resource )
	if resource.name ~= "lw" then return end
	if not localPlayer:getData("userModel") then
		outputChatBox("Welcome to Lost World Role Play [Dev]!")
		triggerEvent("onClientShowLoginWindow", localPlayer)
	elseif not localPlayer:getData("charModel") then
		triggerEvent("onClientShowCreateCharWindow", localPlayer)
	end

end
addEventHandler("onClientResourceStart", getRootElement(), clientJoin)