class("Map" , MapEditor)

MapEditor.Map.version = 1

function MapEditor.Map:__init(initialPosition , mapType)
	EGUSM.SubscribeUtility.__init(self)
	local memberNames = {
		"type" ,
		"version" ,
	}
	MapEditor.Marshallable.__init(self , memberNames)
	MapEditor.ObjectManager.__init(self)
	MapEditor.PropertyManager.__init(self)
	
	self.Destroy = MapEditor.Map.Destroy
	
	MapEditor.map = self
	
	self.type = mapType
	self.objectIdCounter = 1
	-- This is used for the filename and is set when saving or loading.
	self.name = nil
	self.isEnabled = true
	
	-- Temporary until preferences menu.
	Controls.Add("Rotate/pan camera" , "VehicleCam")
	Controls.Add("Camera pan modifier" , "Shift")
	Controls.Add("Move object" , "G")
	Controls.Add("Rotate object" , "R")
	Controls.Add("Undo" , "Z")
	Controls.Add("Redo" , "Y")
	Controls.Add("Delete" , "X")
	
	self.camera = MapEditor.Camera(initialPosition)
	
	self.undoableActions = {}
	self.redoableActions = {}
	self.currentAction = nil
	
	self.selectedObjects = MapEditor.ObjectManager()
	
	self.mapMenu = MapEditor.MapMenu()
	self.spawnMenu = MapEditor.SpawnMenu()
	self.propertiesMenu = nil
	
	for index , propertyArgs in ipairs(MapTypes[self.type].properties) do
		self:AddProperty(propertyArgs)
	end
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseDown")
	self:EventSubscribe("ControlDown")
	self:EventSubscribe("ControlUp")
end

function MapEditor.Map:SetEnabled(enabled)
	self.mapMenu:SetVisible(enabled)
	self.spawnMenu:SetVisible(enabled)
	if self.propertiesMenu then
		self.propertiesMenu:Destroy()
	end
	
	Mouse:SetVisible(enabled)
	
	self.camera.isEnabled = enabled
	self.camera.isInputEnabled = enabled
	
	self.isEnabled = enabled
end

function MapEditor.Map:Destroy()
	self:UnsubscribeAll()
	
	self.camera:Destroy()
	
	self.mapMenu:Destroy()
	self.spawnMenu:Destroy()
	if self.propertiesMenu then
		self.propertiesMenu:Destroy()
	end
	
	self:IterateObjects(function(object)
		object:Destroy()
	end)
	
	Mouse:SetVisible(false)
	
	MapEditor.map = nil
end

function MapEditor.Map:SetAction(actionClass , ...)
	if self.currentAction ~= nil then
		warn("Already have an Action!")
		return
	end
	
	local finished = false
	local cancelled = false
	
	self.ActionFinish = function() finished = true end
	self.ActionCancel = function() cancelled = true end
	
	self.currentAction = actionClass(...)
	
	self.ActionFinish = MapEditor.Map.ActionFinish
	self.ActionCancel = MapEditor.Map.ActionCancel
	
	if finished then
		table.insert(self.undoableActions , self.currentAction)
		self.redoableActions = {}
		self.currentAction = nil
	elseif cancelled then
		self.currentAction = nil
	else
		Events:Fire("SetMenusEnabled" , false)
	end
end

function MapEditor.Map:ActionFinish()
	Events:Fire("SetMenusEnabled" , true)
	
	table.insert(self.undoableActions , self.currentAction)
	self.redoableActions = {}
	
	self.currentAction = nil
end

function MapEditor.Map:ActionCancel()
	Events:Fire("SetMenusEnabled" , true)
	self.currentAction = nil
end

function MapEditor.Map:Undo()
	local count = #self.undoableActions
	if count > 0 then
		local action = self.undoableActions[count]
		table.remove(self.undoableActions , count)
		action:Undo()
		table.insert(self.redoableActions , action)
	end
end

function MapEditor.Map:Redo()
	local count = #self.redoableActions
	if count > 0 then
		local action = self.redoableActions[count]
		table.remove(self.redoableActions , count)
		action:Redo()
		table.insert(self.undoableActions , action)
	end
end

function MapEditor.Map:SelectionChanged()
	-- TODO: Support multiple objects for PropertiesMenu.
	local objects = {}
	self.selectedObjects:IterateObjects(function(object)
		table.insert(objects , object)
	end)
	
	if #objects > 0 then
		if self.propertiesMenu then
			self.propertiesMenu:Destroy()
		end
		
		self.propertiesMenu = MapEditor.PropertiesMenu(objects)
	else
		if self.propertiesMenu then
			self.propertiesMenu:Destroy()
			self.propertiesMenu = nil
		end
	end
end

function MapEditor.Map:OpenMapProperties()
	if self.propertiesMenu then
		self.propertiesMenu:Destroy()
	end
	
	self.propertiesMenu = MapEditor.PropertiesMenu({self})
end

function MapEditor.Map:Save()
	local args = {
		name = self.name ,
		marshalledSource = self:Marshal() ,
	}
	Network:Send("SaveMap" , args)
	
	self.mapMenu.canSave = true
end

function MapEditor.Map:Validate()
	-- TODO: It should focus on the source Object of the error.
	local successOrError = MapTypes[self.type].Validate(self)
	-- TODO: This should be a popup or something.
	if successOrError == true then
		Chat:Print("Validation successful" , Color(165 , 250 , 160))
		return true
	else
		Chat:Print("Validation failed: "..successOrError , Color(250 , 160 , 160))
		return false
	end
end

function MapEditor.Map:Test()
	local success = self:Validate()
	if success then
		local args = {
			mapType = self.type ,
			marshalledMap = self:Marshal() ,
		}
		Network:Send("TestMap" , args)
		
		self:SetEnabled(false)
		
		if MapTypes[self.type].Test then
			MapTypes[self.type].Test()
		end
	end
end

-- Static functions

MapEditor.Map.Load = function(marshalledSource)
	if MapEditor.Map.version ~= marshalledSource.version then
		-- TODO: something that is not this
		Chat:Print("Map cannot be loaded because it has a different file version" , Color.DarkRed)
		return
	end
	
	local map = MapEditor.Map(Vector3(-6550 , 215 , -3290) , marshalledSource.type)
	
	-- Unmarshal Objects.
	local highestId = 1
	for objectId , objectData in pairs(marshalledSource.objects) do
		if objectId > highestId then
			highestId = objectId
		end
		
		local object = MapEditor.Object.Unmarshal(objectData)
		map:AddObject(object)
	end
	-- Unmarshal Object properties. This is done here because some properties are Objects, so all
	-- Objects must be loaded first.
	for objectId , objectData in pairs(marshalledSource.objects) do
		MapEditor.PropertyManager.Unmarshal(map:GetObject(objectId) , objectData.properties)
	end
	-- Unmarshal map properties here, for the same reason as above.
	MapEditor.PropertyManager.Unmarshal(map , marshalledSource.properties)
	
	map.objectIdCounter = highestId + 1
	map.mapMenu.canSave = true
	
	return map
end

-- Events

function MapEditor.Map:Render()
	if self.isEnabled == false then
		return
	end
	
	Mouse:SetVisible(true)
	
	-- Draw map name.
	local mapName = self.name or "Untitled map"
	local position = Vector2(Render.Width - 6 , 34)
	position.x = position.x - Render:GetTextWidth(mapName)
	Render:DrawText(
		position ,
		mapName ,
		Color(196 , 196 , 196)
	)
	
	self:IterateObjects(function(object)
		MapEditor.Utility.DrawBounds(
			object.position ,
			object.angle ,
			object.bounds ,
			Color.White * 0.5
		)
		
		if object.OnRender then
			object:OnRender()
		end
		
		-- Highlight all selected objects.
		if self.selectedObjects:HasObject(object) then
			local boundsEnlarged = {}
			boundsEnlarged[1] = object.bounds[1] * 1.1
			boundsEnlarged[2] = object.bounds[2] * 1.1
			MapEditor.Utility.DrawBounds(
				object.position ,
				object.angle ,
				boundsEnlarged ,
				Color.LimeGreen * 0.8
			)
		end
	end)
end

function MapEditor.Map:MouseDown(args)
	if self.isEnabled == false then
		return
	end
	
	if self.currentAction == nil then
		if args.button == 1 then
			self:SetAction(Actions.Selector , args.button)
		elseif args.button == 2 then
			self:SetAction(Actions.Deselector , args.button)
		end
	end
end

function MapEditor.Map:ControlDown(args)
	if self.isEnabled == false then
		return
	end
	
	if self.currentAction == nil then
		if args.name == "Move object" then
			self:SetAction(Actions.Mover)
		elseif args.name == "Rotate object" then
			self:SetAction(Actions.Rotator)
		elseif args.name == "Delete" then
			self:SetAction(Actions.Deleter)
		end
	end
	
	if args.name == "Rotate/pan camera" then
		if self.currentAction == nil then
			self.camera.isInputEnabled = true
		end
	elseif args.name == "Undo" then
		self:Undo()
	elseif args.name == "Redo" then
		self:Redo()
	end
end

function MapEditor.Map:ControlUp(args)
	if self.isEnabled == false then
		return
	end
	
	if args.name == "Rotate/pan camera" then
		self.camera.isInputEnabled = false
	end
end
