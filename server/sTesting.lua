Network:Subscribe("Test" , function(marshalled)
	local json = require("JSON")
	local encoded = json:encode(marshalled)
	
	local file = io.open("test.course" , "w")
	file:write(json:encode_pretty(marshalled))
	file:close()
end)
