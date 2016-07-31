-- Database server configuration file

local db = dbConnect("mysql", "dbname=lw;host=212.109.220.208", "mta", "Y7YCQef8")

function login( username, password )
	local result = db:query("call lw.login('" .. username .. "', '" .. password .. "');"):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		return result[1]
	end
	return false
end