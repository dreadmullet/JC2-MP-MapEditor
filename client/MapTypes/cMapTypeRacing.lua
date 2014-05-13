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
		-- TODO: This should be a ComboBox where you can choose Linear and Circuit (as integers?)
		-- TODO: Actually, this isn't needed anymore, is it?
		{
			name = "type" ,
			type = "string" ,
			default = "Linear" ,
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
					if vehicleInfo == MapEditor.Property.NoObject then
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
			if nextCheckpoint ~= MapEditor.Property.NoObject then
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
		-- Find the first checkpoint.
		local firstChoice = checkpointList[1]
		local startingCheckpoint = firstChoice
		while true do
			if startingCheckpoint.previous then
				startingCheckpoint = startingCheckpoint.previous
				-- Prevent an infinite loop in case it's a circuit.
				if startingCheckpoint == firstChoice then
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
			table.insert(checkpoints , cp.checkpoint)
			cp = cp.next
		until cp == nil or cp == startingCheckpoint
		
		if #checkpoints ~= #checkpointList then
			return "Invalid checkpoint; do two checkpoints have the same next checkpoint?"
		end
		-- Make sure the checkpoints are in a valid order. If two checkpoints have the same
		-- nextCheckpoint, for example, it will fail.
		for index , checkpoint in ipairs(checkpoints) do
			local nextCheckpoint = checkpoint:GetProperty("nextCheckpoint").value
			if index == #checkpoints then
				-- It doesn't matter if the last checkpoint has a next one.
			elseif nextCheckpoint ~= MapEditor.Property.NoObject then
				if nextCheckpoint:GetId() ~= checkpoints[index + 1]:GetId() then
					return "Invalid checkpoint; Same Next Checkpoint or stranded checkpoint"
				end
			else
				return "Stranded checkpoint; make sure you set the Next Checkpoint properties correctly"
			end
		end
		-- Make sure each next checkpoint isn't the checkpoint itself.
		for index , checkpoint in ipairs(checkpoints) do
			local nextCheckpoint = checkpoint:GetProperty("nextCheckpoint").value
			if
				nextCheckpoint ~= MapEditor.Property.NoObject and
				nextCheckpoint:GetId() == checkpoint:GetId()
			then
				return "Invalid checkpoint; Next Checkpoint cannot be the checkpoint itself, you git!"
			end
		end
		
		return true
	end
}
