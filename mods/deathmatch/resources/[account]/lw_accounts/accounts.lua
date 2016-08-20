-- Server file for accounts management

addEvent("server:login", true)
addEvent("server:register", true)
addEvent("server:createChar", true)

function loginHandler( username, password )
	login(client, _, username, password)
end
addEventHandler("server:login", root, loginHandler)

function registerHandler( username, password )
	register(client, _, username, password)
end
addEventHandler("server:register", root, registerHandler)

function createCharHandler( firstname, lastname, sex, race )
	createCharacter(client, _, firstname, lastname, sex, race)
end
addEventHandler("server:createChar", root, createCharHandler)

function login( playerSource, _, username, password )
	local user, char = exports.lw_db:login(username, password)
	if user.id ~= nil then
		outputChatBox("Вы вошли как " .. user.name .. ".", playerSource)
		playerSource:setData("userModel", user)
		if char ~= nil and char.id ~= nil then
			outputChatBox("Ваш персонаж: "..char.firstname.." "..char.lastname..".", playerSource)
			triggerEvent("onCharacterLoaded", playerSource, char)
		end
	elseif type(user) == "string" then
		outputChatBox("Ошибка входа: " .. user, playerSource)
	else
		for k,v in pairs(user) do
			outputChatBox("Ошибка входа: " .. v, playerSource)
		end
	end
	triggerClientEvent(playerSource, "client:updateLoginUI", playerSource)
end
addCommandHandler("lw_login", login)

function register( playerSource, _, username, password, email, birthday )
	local user, char = exports.lw_db:register(username, password, email, birthday)
	if user.id ~= nil then
		outputChatBox("Вы зарегистрировались как " .. user.name .. ".", playerSource)
		playerSource:setData("userModel", user)
		if char ~= nil and char.id ~= nil then
			outputChatBox("Ваш персонаж: "..char.firstname.." "..char.lastname..".", playerSource)
			triggerEvent("onCharacterLoaded", playerSource, char)
		end
	elseif type(user) == "string" then
		outputChatBox("Ошибка регистрации: " .. user, playerSource)
	else
		for k,v in pairs(user) do
			outputChatBox("Ошибка регистрации: " .. v, playerSource)
		end
	end
	triggerClientEvent(playerSource, "client:updateLoginUI", playerSource)
end
addCommandHandler("lw_register", register)

function createCharacter( playerSource, _, firstname, lastname, sex, race )
	sex = tonumber(sex)
	race = tonumber(race)
	local skinId = 0
	if sex == 0 and race == 0 then skinId = 23
	elseif sex == 1 and race == 0 then skinId = 56
	elseif sex == 0 and race == 1 then skinId = 22
	elseif sex == 1 and race == 1 then skinId = 13
	elseif sex == 0 and race == 2 then skinId = 121
	elseif sex == 1 and race == 2 then skinId = 169
	end
	local userModel = playerSource:getData("userModel")
	if not userModel then
		outputChatBox("Войдите, прежде чем создать персонажа", playerSource)
		return
	end
	local char = exports.lw_db:createCharacter(tonumber(userModel.id), firstname, lastname, skinId, sex, race)
	if char.id ~= nil then
		outputChatBox("Вы создали персонажа "..char.firstname.." "..char.lastname..".", playerSource)
		triggerEvent("onCharacterLoaded", playerSource, char)
	elseif type(char) == "string" then
		outputChatBox("Ошибка создания персонажа: " .. char, playerSource)
	else
		for k,v in pairs(char) do
			outputChatBox("Ошибка создания персонажа: " .. v, playerSource)
		end
	end
	triggerClientEvent(playerSource, "client:updateLoginUI", playerSource)
end
addCommandHandler("lw_createchar", createCharacter)

function logout( playerSource, _, firstname, lastname, sex, race )
	triggerEvent("onCharacterUnloaded", playerSource, "logout")
	playerSource:setData("userModel", nil)
	triggerClientEvent(playerSource, "client:updateLoginUI", playerSource)
end
addCommandHandler("lw_logout", logout)
