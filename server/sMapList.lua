JSON = require("JSON")

Network:Subscribe("RequestMapList" , function(unused , player)
	local fileNames = io.files("Maps/")
	local mapNames = {}
	
	for index , fileName in ipairs(fileNames) do
		if fileName:sub(-4) == ".map" then
			table.insert(mapNames , fileName:sub(1 , -5))
		end
	end
	
	Network:Send(player , "ReceiveMapList" , mapNames)
end)

Network:Subscribe("SaveMap" , function(args , player)
	print(player:GetName().." is saving map: "..args.name)
	
	io.createdir("Maps/")
	
	local file = io.open("Maps/"..args.name..".map" , "w")
	file:write(JSON:encode_pretty(args.marshalledSource))
	file:close()
	
	Network:Send(player , "ConfirmMapSave")
end)

Network:Subscribe("RequestMap" , function(args , player)
	print(player:GetName().." is loading map: "..args.name)
	
	local path = "Maps/"..args.name..".map"
	local file , openError = io.open(path , "r")
	if openError then
		Network:Send(player , "ReceiveMap" , nil)
		error("Cannot load "..tostring(path)..": "..openError)
	end
	
	local entireFile = file:read("*a")
	file:close()
	
	local marshalledSource = JSON:decode(entireFile)
	
	Network:Send(player , "ReceiveMap" , marshalledSource)
end)
