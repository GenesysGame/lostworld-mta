-- Database server configuration file

local db = dbConnect("mysql", "dbname=lw;host=212.109.220.208", "mta", "Y7YCQef8")

function login( username, password )
	local query = string.format("call lw.login('%s', '%s');", username, password)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		return result[1]
	end
	return false
end

function register( username, password, email, birthday )
	local query = string.format("call lw.register_user('%s', '%s', '%s', '%s');", username, password, email, birthday)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		return result[1]
	end
	return false
end