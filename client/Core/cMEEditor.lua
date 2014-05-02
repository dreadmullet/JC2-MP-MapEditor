class("Editor" , MapEditor)

function MapEditor.Editor:__init(initialPosition) ; EGUSM.SubscribeUtility.__init(self)
	self.Destroy = MapEditor.Editor.Destroy
	
	MapEditor.editor = self
	
	self.map = MapEditor.Map()
	MapEditor.map = self.map
	
	Controls.Add("Rotate/pan camera" , "VehicleCam")
	Controls.Add("Camera pan modifier" , "Shift")
	self.camera = MapEditor.Camera(initialPosition)
	
	MapEditor.SpawnMenu()
	
	Mouse:SetVisible(true)
	
	self:EventSubscribe("ControlDown")
	self:EventSubscribe("ControlUp")
end

function MapEditor.Editor:Destroy()
	self:UnsubscribeAll()
	
	self.camera:Destroy()
	
	self.map:IterateObjects(function(object)
		object:Destroy()
	end)
	
	Mouse:SetVisible(false)
end

-- Events

function MapEditor.Editor:ControlDown(args)
	if args.name == "Rotate/pan camera" then
		self.camera.isInputEnabled = true
	end
end

function MapEditor.Editor:ControlUp(args)
	if args.name == "Rotate/pan camera" then
		self.camera.isInputEnabled = false
	end
end
