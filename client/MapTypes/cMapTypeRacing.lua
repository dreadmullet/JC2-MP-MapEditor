MapTypes.Racing = {
	objects = {
		"RaceCheckpoint" ,
		"RaceSpawn" ,
		"RaceVehicleInfo" ,
	} ,
	properties = {
		{
			name = "title" ,
			type = "string" ,
			default = "Untitled Course" ,
		} ,
		{
			name = "firstCheckpoint" ,
			type = "RaceCheckpoint" ,
		} ,
		{
			name = "laps" ,
			type = "number" ,
			default = 1 ,
		} ,
		-- TODO: Need tooltips; "-1 is random weather, 2 is max"
		{
			name = "weatherSeverity" ,
			type = "number" ,
			default = -1 ,
		} ,
		{
			name = "parachuteEnabled" ,
			type = "boolean" ,
			default = true ,
		} ,
		{
			name = "grappleEnabled" ,
			type = "boolean" ,
			default = true ,
		} ,
		-- Needs a groupbox as well
		{
			name = "forceCollision" ,
			type = "number" ,
			default = 0 ,
		} ,
		{
			name = "authors" ,
			type = "table" ,
			subtype = "string"
		} ,
	} ,
	Validate = function(map)
		-- Validate spawns. Make sure all spawns have at least one valid RaceVehicleInfo.
		
		local hasSpawn = false
		local errorString = nil
		map:IterateObjects(function(object)
			if object.type == "RaceSpawn" then
				hasSpawn = true
				
				local vehicleInfos = object:GetProperty("vehicles").value
				
				if #vehicleInfos == 0 then
					errorString = "RaceSpawn needs at least one RaceVehicleInfo"
					return
				end
				
				for index , vehicleInfo in ipairs(vehicleInfos) do
					if vehicleInfo == MapEditor.NoObject then
						errorString = "RaceSpawn vehicle element is empty (index "..tostring(index)..")"
						return
					end
				end
			end
		end)
		
		if errorString then
			return errorString
		end
		
		if hasSpawn == false then
			return "At least one RaceSpawn is required"
		end
		
		-- Validate checkpoints. Make sure it forms a line or a circuit and that there are no stranded
		-- checkpoints.
		
		-- Create a linked list of checkpoints.
		-- Values are like, {previous = table , checkpoint = RaceCheckpoint , next = table}
		local checkpointList = {}
		map:IterateObjects(function(object)
			if object.type == "RaceCheckpoint" then
				table.insert(checkpointList , {checkpoint = object})
			end
		end)
		for index , listItem in ipairs(checkpointList) do
			local nextCheckpoint = listItem.checkpoint:GetProperty("nextCheckpoint").value
			if nextCheckpoint ~= MapEditor.NoObject then
				for index2 , listItem2 in ipairs(checkpointList) do
					if listItem2.checkpoint:GetId() == nextCheckpoint:GetId() then
						listItem.next = listItem2
						listItem2.previous = listItem
					end
				end
			end
		end
		-- Make sure there is at least one checkpoint.
		if #checkpointList == 0 then
			return "At least one checkpoint is required"
		end
		-- Make sure each next checkpoint isn't the checkpoint itself.
		for index , listItem in ipairs(checkpointList) do
			if listItem.next then
				local nextCheckpoint = listItem.next.checkpoint
				if nextCheckpoint:GetId() == listItem.checkpoint:GetId() then
					return "Invalid checkpoint; Next Checkpoint cannot be the checkpoint itself, you git!"
				end
			end
		end
		-- Find the first checkpoint.
		local startingCheckpoint = checkpointList[1]
		local isCircuit = false
		while true do
			startingCheckpoint.beenTo = true
			
			if startingCheckpoint.previous then
				startingCheckpoint = startingCheckpoint.previous
				-- Prevent an infinite loop in case it's a circuit.
				if startingCheckpoint.beenTo then
					isCircuit = true
					break
				end
			else
				break
			end
		end
		-- Translate checkpointList into checkpoints array.
		local checkpoints = {}
		local cp = startingCheckpoint
		repeat
			for index , checkpoint in ipairs(checkpoints) do
				if checkpoint:GetId() == cp.checkpoint:GetId() then
					return "Invalid checkpoint; Are two checkpoints connected to each other?"
				end
			end
			table.insert(checkpoints , cp.checkpoint)
			cp = cp.next
		until cp == nil or cp == startingCheckpoint
		-- Make sure all checkpoints are accounted for.
		if #checkpoints ~= #checkpointList then
			return "Invalid checkpoint; Same Next Checkpoint or stranded checkpoint"
		end
		-- If this is a circuit, make sure we have firstCheckpoint.
		if isCircuit and map:GetProperty("firstCheckpoint").value == MapEditor.NoObject then
			return "Course is a circuit but First Checkpoint is not set in map properties"
		end
		
		return true
	end ,
	Test = function()
		MapTypes.Racing.raceEndSub = Events:Subscribe("RaceEnd" , function()
			Events:Unsubscribe(MapTypes.Racing.raceEndSub)
			
			MapEditor.map:SetEnabled(true)
		end)
	end
}
