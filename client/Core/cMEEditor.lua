class("Editor" , MapEditor)

function MapEditor.Editor:__init(initialPosition) ; EGUSM.SubscribeUtility.__init(self)
	Controls.Add("Rotate/pan camera" , "VehicleCam")
	Controls.Add("Camera pan modifier" , "Shift")
	Controls.Add("Camera pan up" , "PrevWeapon")
	Controls.Add("Camera pan down" , "NextWeapon")
	
	self.camera = MapEditor.Camera(initialPosition)
	
	Mouse:SetVisible(true)
	
	self:EventSubscribe("ControlDown")
	self:EventSubscribe("ControlUp")
end

function MapEditor.Editor:Destroy()
	self:UnsubscribeAll()
	
	self.camera:Destroy()
	
	Mouse:SetVisible(false)
end

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
