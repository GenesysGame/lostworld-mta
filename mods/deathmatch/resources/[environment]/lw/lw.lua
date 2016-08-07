-- Main server file

function playerJoin()
	source:setHudComponentVisible("all", false)
end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

function playerSpawn()
	source:setHudComponentVisible("all", true)
end
addEventHandler("onPlayerSpawn", getRootElement(), playerSpawn)