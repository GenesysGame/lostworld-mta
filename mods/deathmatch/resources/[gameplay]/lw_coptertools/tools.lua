-- Server file for copter tools

addEvent("coptertools:enableCopterCamera", true)

function enterVehicle( thePlayer, seat, jacked ) -- when a player enters a vehicle
    if source.model == 497 and seat == 1 then
    	outputChatBox("Чтобы воспользоваться камерой слежения, нажмите <Е>", thePlayer)
    end
end
addEventHandler("onVehicleEnter", getRootElement(), enterVehicle) -- add an event handler for onVehicleEnter

function enableCopterCamera( )
	if source.vehicle.model == 497 and source.vehicleSeat == 1 then
		outputChatBox("Активация камеры наблюдения...", source)
	end
end
addEventHandler("coptertools:enableCopterCamera", getRootElement(), enableCopterCamera)