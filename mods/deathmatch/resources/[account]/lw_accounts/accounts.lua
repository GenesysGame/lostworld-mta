-- Server file for accounts management

function loginHandler( playerSource, _, username, password )
	local user = exports.lw_db:login(username, password)
	if user.id ~= nil then
		outputChatBox("Вы вошли как " .. user.name .. ".", playerSource)
		playerSource:setData("userModel", user)
	elseif type(user) == "string" then
		outputChatBox("Ошибка входа: " .. user, playerSource)
	else
		for k,v in pairs(user) do
			outputChatBox("Ошибка входа: " .. v, playerSource)
		end
	end
end
addCommandHandler("lw_login", loginHandler)

function registerHandler( playerSource, _, username, password, email, birthday )
	local user = exports.lw_db:register(username, password, email, birthday)
	if user.id ~= nil then
		outputChatBox("Вы зарегистрировались как " .. user.name .. ".", playerSource)
	elseif type(user) == "string" then
		outputChatBox("Ошибка регистрации: " .. user, playerSource)
	else
		for k,v in pairs(user) do
			outputChatBox("Ошибка регистрации: " .. v, playerSource)
		end
	end
end
addCommandHandler("lw_register", registerHandler)

function createCharacter( playerSource, _, firstname, lastname, sex, race )
	sex = tonumber(sex)
	race = tonumber(race)
	local skinId = 0
	if sex == 0 and race == 0 then skinId = 289
	elseif sex == 1 and race == 0 then skinId = 56
	elseif sex == 0 and race == 1 then skinId = 22
	elseif sex == 1 and race == 1 then skinId = 13
	elseif sex == 0 and race == 2 then skinId = 121
	elseif sex == 0 and race == 3 then skinId = 255
	end
	local userModel = playerSource:getData("userModel")
	if not userModel then
		outputChatBox("Войдите, прежде чем создать персонажа", playerSource)
		return
	end
	outputDebugString(userModel.id.." "..firstname.." "..lastname.." "..skinId.. " "..sex.. " "..race)
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
end
addCommandHandler("lw_createchar", createCharacter)