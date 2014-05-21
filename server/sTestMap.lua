Network:Subscribe("TestMap" , function(args , player)
	if args.mapType == "Racing" then
		local args = {
			players = {player} ,
			marshalledMap = args.marshalledMap ,
		}
		Events:Fire("CreateRaceFromMapEditor" , args)
	end
end)
