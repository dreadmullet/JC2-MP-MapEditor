Events:Subscribe("ModuleLoad" , function()
	map = MapEditor.Map()
	map:SetProperty("title" , "My Awesome Course")
	map:SetProperty("type" , "Linear")
	map:SetProperty("authors" , {"dreadmullet"})
	
	local vehicleInfoObject = RaceVehicleInfo()
	vehicleInfoObject:SetProperty("modelId" , 2)
	map:AddObject(vehicleInfoObject)
	
	local spawnPositions = {
		Vector3(-6864.663086, 208.981628, -3281.553711) ,
		Vector3(-6864.702148, 208.981628, -3270.327637) ,
		Vector3(-6874.663086, 208.981628, -3281.553711) ,
		Vector3(-6874.702148, 208.981628, -3270.327637) ,
	}
	for index , spawnPosition in ipairs(spawnPositions) do
		local spawn = RaceSpawn()
		spawn:SetPosition(spawnPosition)
		spawn:SetAngle(Angle(math.rad(-90) , 0 , 0))
		spawn:SetProperty("vehicles" , {vehicleInfoObject:GetId()})
		map:AddObject(spawn)
	end
	
	local checkpointPositions = {
		Vector3(-6831.844727, 208.981903, -3274.884521) ,
		Vector3(-6685.099609, 208.981903, -3274.505371) ,
		Vector3(-6552.171387, 208.976151, -3287.687012) ,
		Vector3(-6390.886719, 208.981903, -3446.683105) ,
		Vector3(-6388.179688, 208.979492, -3681.413086) ,
	}
	for index , checkpointPosition in ipairs(checkpointPositions) do
		local cp = RaceCheckpoint()
		cp:SetPosition(checkpointPosition)
		cp:SetProperty("validVehicles" , {2})
		map:AddObject(cp)
	end
	
	local marshalled = map:Marshal()
	
	-- print("Marshalled map:")
	-- Utility.PrintTable(marshalled)
	
	Network:Send("Test" , marshalled)
end)
