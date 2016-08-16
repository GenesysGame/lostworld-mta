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

-- Time setting
local minuteDuration = 60000

function startSetting( res )
	if res.name == "lw" then
		setMinuteDuration(minuteDuration)
		
		local realtime = getRealTime()
    	setTime(realtime.hour, realtime.minute)

    	setServerWeather()
    	Timer(setServerWeather, minuteDuration * 180, 0)
	end
end
addEventHandler("onResourceStart", getRootElement(), startSetting)

function isAdmin( playerSource )
	local accName = playerSource.account.name
	return ACLGroup.get("Admin"):doesContainObject("user."..accName)
end

function setServerTime( playerSource, _, hour, minute )
     if isAdmin(playerSource) then -- Does he have access to Admin functions?
        if not hour and not minute then
			local realtime = getRealTime()
    		setTime(realtime.hour, realtime.minute)
		elseif not minute then
			setTime(hour, 0)
		else
			setTime(hour, minute)
		end
     end
end
addCommandHandler("lw_settime", setServerTime)

local nextWeatherId = nil
function setServerWeather( playerSource, _, weatherId )
	if not playerSource or isAdmin(playerSource) then
		local nowId, nowBlendedID = getWeather()
		local hour, minutes = getTime()
		outputDebugString(hour..":"..minutes.." Started weather change: "..nowId.. " "..tostring(nowBlendedID))
		if not weatherId then
			local wId = nextWeatherId or math.random(0, 19)
			nextWeatherId = nil
			setWeather(nowBlendedID or nowId)
			setWeatherBlended(wId)
		else
			nextWeatherId = weatherId
			setWeather(nowBlendedID or nowId)
			setWeatherBlended(weatherId)
		end
		nowId, nowBlendedID = getWeather()
		hour, minutes = getTime()
		outputDebugString(hour..":"..minutes.." Finished weather change: "..nowId.. " "..tostring(nowBlendedID))
	end
end
addCommandHandler("lw_setweather", setServerWeather)

function setNextWeather( playerSource, _, weatherId )
	if isAdmin(playerSource) then
		nextWeatherId = weatherId
		outputChatBox("Next weather is "..(nextWeatherId or "random"), playerSource)
	end
end
addCommandHandler("lw_nextweather", setNextWeather)