-- client file for copter tools

function playerPressedKey(button, press)
	local isPoliceMaverickSecondPilot = localPlayer.vehicle.model == 497 and localPlayer.vehicleSeat == 1
    if press and button == 'e' and isPoliceMaverickSecondPilot then
        triggerServerEvent("coptertools:enableCopterCamera", localPlayer) 
    end
end
addEventHandler("onClientKey", root, playerPressedKey)