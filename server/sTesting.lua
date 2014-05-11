Network:Subscribe("TestMap" , function(args , player)
	if args.mapType ~= "Racing" then
		return
	end
	
	local json = require("JSON")
	local file = io.open("test.course" , "w")
	file:write(json:encode_pretty(args.marshalledMap))
	file:close()
	
	local args = {
		players = {player} ,
		map = args.marshalledMap ,
	}
	Events:Fire("CreateRace" , args)
end)
