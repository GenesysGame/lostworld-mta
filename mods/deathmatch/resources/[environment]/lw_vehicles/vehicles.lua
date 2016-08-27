-- Server file for vehicles base

addEvent("vehicle:toogleTrunk", true)

function toogleTrunk( theVehicle )
	if source.vehicle and source.vehicleSeat == 0 then
		if theVehicle:getDoorOpenRatio(1) > 0 then
			theVehicle:setDoorOpenRatio(1, 0, 700)
		else
			theVehicle:setDoorOpenRatio(1, 1, 700)
		end
	end 
end
addEventHandler("vehicle:toogleTrunk", getRootElement(), toogleTrunk)