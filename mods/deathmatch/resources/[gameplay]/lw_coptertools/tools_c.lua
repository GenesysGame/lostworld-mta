-- client file for copter tools

function playerPressedKey(button, press)
    if press and button == 'e' then
    	local isPoliceMaverickSecondPilot = localPlayer.vehicle and localPlayer.vehicle.model == 497 and localPlayer.vehicleSeat == 1
    	if isPoliceMaverickSecondPilot then
    		triggerServerEvent("coptertools:enableCopterCamera", localPlayer) 
    	end
    end
end
addEventHandler("onClientKey", root, playerPressedKey)