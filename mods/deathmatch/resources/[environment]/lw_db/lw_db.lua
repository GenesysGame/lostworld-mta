-- Database server configuration file

local db = dbConnect("mysql", "dbname=lw;host=212.109.220.208", "mta", "Y7YCQef8")

local loginPattern = '[a-zA-Z0-9_%-]+'
local namePattern = '[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя]+'

-- Accounts, Characters

function login( username, password )
	local query = string.format("select count(id), passsalt from users where `name` like '%s';", username)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		local usercount = result[1]["count(id)"]
		local passsalt = result[1]["passsalt"]
		if usercount == 0 then
			return "Пользователь с таким именем не найден."
		else
			local hashPass = md5(password .. passsalt)
			query = string.format("select * from users where `name` like '%s' and password like '%s';", username, hashPass)
			result = db:query(query):poll(-1)
			if result ~= nil and table.getn(result) > 0 then
				local  userModel = result[1]
				local charModel = nil
				if userModel.id ~= nil then
					query = string.format("select * from characters where userId = %i", userModel.id)
					result = db:query(query):poll(-1)
					if result ~= nil and table.getn(result) > 0 then
						charModel = result[1]
					end
				end
				return userModel, charModel
			else
				return "Неверный логин или пароль."
			end
		end
	end
	return "Неизвестная ошибка входа."
end

function register( username, password, email, birthday )
	if username:match(loginPattern) ~= username then
		return "Имя пользователя может состоять только из букв латинского алфавита, цифр и символов - и _ ."
	end 
	if password:match(loginPattern) ~= password then
		return "Пароль может состоять только из букв латинского алфавита, цифр и символов - и _ ."
	end
	if not username or username:len() < 4 or username:len() > 32 then
		return "Имя пользователя должно быть не менее 4 и не более 32 символов."
	end
	if not password or password:len() < 6 or password:len() > 32 then
		return "Пароль должен быть не менее 6 и не более 32 символов."
	end
	local query = string.format("select count(id) from users where `name` like '%s';", username)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		local usercount = result[1]["count(id)"]
		if usercount == 1 then
			return "Пользователь с таким именем уже существует."
		end
	end
	local salt = makeSalt()
	local hashPass = md5(password .. salt)
	local dateFormat = "%e.%c.%Y"
	query = string.format([[insert into users (`name`, email, birthDate, password, passsalt, isActivated, createdDate)
		values ('%s', '%s', str_to_date('%s', '%s'), '%s', '%s', 1, now());]], username, email or '', birthday or '', dateFormat, hashPass, salt)
	db:query(query):free()
	return login(username, password)
end

function makeSalt()
	local str = ""
	local all = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J", "K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
	for i=1, 8 do 
		str = str .. all[math.random(1, #all)] 
	end
  return str
end

function createCharacter(userId, firstname, lastname, skinId, sex, race)
	if not userId or not firstname or not lastname or not skinId or not sex or not race then return "Не хватает входных данных" end
	if  firstname:match(namePattern) ~= firstname then
		return "Имя персонажа должно состоять только из букв русского алфавита и начинаться с большой буквы"
	end
	if lastname:match(namePattern) ~= lastname then
		return "Фамилия персонажа должно состоять только из букв русского алфавита и начинаться с большой буквы"
	end
	if firstname:len() == 0 or firstname:len() > 32 then
		return "Имя персонажа должно быть непустым и не более 32 символов"
	end
	if lastname:len() == 0 or lastname:len() > 32 then
		return "Фамилия персонажа должно быть непустым и не более 32 символов"
	end
	if sex ~= 0 and sex ~= 1 then
		return "Неизвестный пол персонажа (0 - муж., 1 - жен.)"
	end
	if race < 0 or race > 2 then
		return "Неизвестная раса персонажа (0 - европеец, 1 - чернокожий, 2 - азиат)"
	end
	local query = string.format("select count(id) from characters where userId = %i;", userId)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		local count = result[1]["count(id)"]
		if count == 0 then
			query = string.format("select count(id) from users where id = %i;", userId)
			result = db:query(query):poll(-1)
			if result ~= nil and table.getn(result) > 0 then
				count = result[1]["count(id)"]
				if count == 1 then
					query = string.format([[insert into characters (userId, firstname, lastname, skinId, sex, race, createdDate)
						values (%i, '%s', '%s', %i, %i, %i, now());]], userId, firstname, lastname, skinId, sex, race)
					db:query(query):free()
					query = string.format("select * from characters where userId = %i;", userId)
					result = db:query(query):poll(-1)
					if result ~= nil and table.getn(result) > 0 then
						local charId = result[1]["id"]
						query = string.format("update users set charId = %i where id = %i;", charId, userId)
						db:query(query):free()
						return result[1]
					else
						return "Персонаж не создан"
					end
				else
					return "Пользователь не найден"
				end
			else
				return "Неизвестная ошибка создания персонажа"
			end
		else
			return "Персонаж уже создан"
		end
	end
	return "Неизвестная ошибка создания персонажа"
end

function updateCharacter( charModel )
	local query = string.format("update characters set gametime = %i, experience = %i, startPosX = %.3f, startPosY = %.3f, startPosZ = %.3f, startPosRotation = %.3f, startPosDimension = %i, startPosInterior = %i where id = %i;", 
		charModel.gametime, charModel.experience, charModel.startPosX, charModel.startPosY, charModel.startPosZ, charModel.startPosRotation, charModel.startPosDimension, charModel.startPosInterior, charModel.id)
	db:query(query):free()
end

-- Objects

function getObjects( )
	local query = "select * from objects;"
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		return result
	else
		return "Ошибка получения игровых объектов"
	end
end

function addObjects( volume, weight, name, charId )
	query = string.format([[insert into objects (volume, weight, name, charId)
	values ('%d', '%d', '%s' , '%d');]], volume, weight, name, charId)
	db:query(query):free()
	query = string.format("select * from objects where id=LAST_INSERT_ID();")
	local result = db:query(query):poll(-1)
	for i, object in ipairs(result) do
		return object["id"]
	end
end

function delObjects( id )
	query = string.format("delete from objects WHERE id = %i;", id)
	result = db:query(query):poll(-1)
end

-- Delete after ...

function eff() 
	local query = string.format("ALTER TABLE objects AUTO_INCREMENT = 1;")
	db:query(query):free()
	outputDebugString("allgood")
end
addCommandHandler("eff",eff)