-- client file for vehicles base

function playerPressedKey( button, press )
	if not localPlayer.vehicle then return end
    if press and button == "x" then
        triggerServerEvent("vehicle:toogleTrunk", localPlayer, localPlayer.vehicle)
    end
end
addEventHandler("onClientKey", root, playerPressedKey)