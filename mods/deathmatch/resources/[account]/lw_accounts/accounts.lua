-- Server file for accounts management


--TODO: Delete ------------------------------------------------
local spawnX, spawnY, spawnZ = 1959.55, -1714.46, 19
function joinHandler()
	spawnPlayer(source, spawnX, spawnY, spawnZ)
	fadeCamera(source, true)
	setCameraTarget(source, source)
	outputChatBox("Welcome to Lost World Role Play [Dev]", source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)
---------------------------------------------------------------

function loginHandler( playerSource, _, username, password )
	local user = exports.lw_db:login(username, password)
	if user.id ~= nil then
		outputChatBox("Вы вошли как " .. user.name .. ".", playerSource)
	elseif type(user) == "string" then
		outputChatBox("Ошибка входа: " .. user)
	else
		for k,v in pairs(user) do
			outputChatBox("Ошибка входа: " .. v)
		end
	end
end
addCommandHandler("lw_login", loginHandler)

function registerHandler( playerSource, _, username, password, email, birthday )
	local user = exports.lw_db:register(username, password, email, birthday)
	if user.id ~= nil then
		outputChatBox("Вы зарегистрировались как " .. user.name .. ".", playerSource)
	elseif type(user) == "string" then
		outputChatBox("Ошибка регистрации: " .. user)
	else
		for k,v in pairs(user) do
			outputChatBox("Ошибка регистрации: " .. v)
		end
	end
end
addCommandHandler("lw_register", registerHandler)