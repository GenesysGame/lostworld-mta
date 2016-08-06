-- Database server configuration file

local db = nil --dbConnect("mysql", "dbname=lw;host=212.109.220.208", "mta", "Y7YCQef8")

function initConnection()
	local handler = mysql_connect("212.109.220.208", "mta", "Y7YCQef8", "lw") -- Establish the connection
	if ( not handler ) then -- The connection failed
  		outputDebugString("Unable to connect to the MySQL server")
	end
	return handler
end

addEventHandler ("onResourceStart", root, 
    function ( resource )
    	if resource.name == "lw_db" then
    		outputDebugString("DB Connection starting...")
    		db = initConnection()
    	end
   end 
)

addEventHandler ("onResourceStop", root, 
    function ( resource )
    	if resource.name == "lw_db" then
    		outputDebugString("DB Connection stopped")
    		mysql_close(db)
    		db = nil
    	end
   end 
)

function login( username, password )
	local query = string.format("call lw.login('%s', '%s');", username, password)
	-- local result = db:query("call lw.login('" .. username .. "', '" .. password .. "');"):poll(-1)
	-- if result ~= nil and table.getn(result) > 0 then
	-- 	return result[1]
	-- end
	-- return false
	local result = mysql_query(db, query)
	if (not result) then
  		outputDebugString("Error executing the query: (" .. mysql_errno(db) .. ") " .. mysql_error(db))
	else
		for result,row in mysql_rows(result) do -- Iterate through all the result rows
  		mysql_field_seek(result, 1) -- Reset the field cursor to the first field
  		for k,v in ipairs(row) do
    		local field = mysql_fetch_field(result) -- Retreive the field data
    		if (v ~= mysql_null()) then
      			outputDebugString("row[" .. field["name"] .. "] = " .. v)
    		else
      			outputDebugString("row[" .. field["name"] .. "] = NULL")
    		end
  		end
	end
  		mysql_free_result(result) -- Freeing the result is IMPORTANT
	end
end

function register( username, password, email, birthday )
	local query = string.format("call lw.register_user('%s', '%s', '%s', '%s');", username, password, email, birthday)
	local result = db:query(query):poll(-1)
	if result ~= nil and table.getn(result) > 0 then
		return result[1]
	end
	return false
end