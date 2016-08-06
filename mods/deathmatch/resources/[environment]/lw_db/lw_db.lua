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
				return "Неверный логин или пароль"
			end
		end
	end
	return "Неизвестная ошибка входа"
end

function register( username, password, email, birthday )
	local query = string.format("call lw.register_user('%s', '%s', '%s', '%s');", username, password, email, birthday)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		return result[1]
	end
	return false
end