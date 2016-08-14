-- Main server file

function playerJoin()
	outputChatBox("Welcome to Lost World Role Play [Dev]!", source)
	triggerClientEvent(source, "client:updateLoginUI", source)
end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

function playerSpawn()
	source:setHudComponentVisible("all", true)
end
addEventHandler("onPlayerSpawn", getRootElement(), playerSpawn)