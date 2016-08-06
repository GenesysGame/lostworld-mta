-- Database server configuration file

local db = dbConnect("mysql", "dbname=lw;host=212.109.220.208", "mta", "Y7YCQef8")

function login( username, password )
	local query = string.format("select count(id), passsalt from users where `name` like '%s';", username)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		local usercount = result[1]["count(id)"]
		local passsalt = result[1]["passsalt"]
		if usercount == 0 then
			return "Пользователь с таким именем не найден"
		else
			local hashPass = md5(password .. passsalt)
			query = string.format("select * from users where `name` like '%s' and password like '%s';", username, hashPass)
			result = db:query(query):poll(-1)
			if result ~= nil and table.getn(result) > 0 then
				return result[1]
			else
				return "Неверный логин или пароль " .. passsalt .. " " .. hashPass
			end
		end
	end
	return "Неизвестная ошибка входа"
end

function register( username, password, email, birthday )
	if not username or username:len() < 4 or username:len() > 32 then
		return "Имя пользователя должно быть не менее 4 и не более 32 символов"
	end
	if not password or password:len() < 6 or password:len() > 32 then
		return "Пароль должен быть не менее 6 и не более 32 символов"
	end
	local salt = makeSalt()
	local hashPass = md5(password .. salt)
	local dateFormat = "%e.%c.%Y"
	local query = string.format([[insert into users (`name`, email, birthDate, password, passsalt, isActivated, createdDate)
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