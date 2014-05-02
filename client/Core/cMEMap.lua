class("Map" , MapEditor)

function MapEditor.Map:__init(initialPosition)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Marshallable.__init(self)
	MapEditor.ObjectManager.__init(self)
	MapEditor.PropertyManager.__init(self)
	
	self.Destroy = MapEditor.Map.Destroy
	
	MapEditor.map = self
	
	Controls.Add("Rotate/pan camera" , "VehicleCam")
	Controls.Add("Camera pan modifier" , "Shift")
	self.camera = MapEditor.Camera(initialPosition)
	
	MapEditor.SpawnMenu()
	
	Mouse:SetVisible(true)
	
	self:EventSubscribe("ControlDown")
	self:EventSubscribe("ControlUp")
end

function MapEditor.Map:Destroy()
	self:UnsubscribeAll()
	
	self.camera:Destroy()
	
	self:IterateObjects(function(object)
		object:Destroy()
	end)
	
	Mouse:SetVisible(false)
end

-- Events

function MapEditor.Map:ControlDown(args)
	if args.name == "Rotate/pan camera" then
		self.camera.isInputEnabled = true
	end
end

function MapEditor.Map:ControlUp(args)
	if args.name == "Rotate/pan camera" then
		self.camera.isInputEnabled = false
	end
end
