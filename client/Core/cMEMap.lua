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
	
	self.selectedObjects = MapEditor.ObjectManager()
	
	self.selectMouse = {
		button = 1 ,
		isDown = false ,
		isEnabled = true ,
		downPosition = Vector2(0 , 0) , -- Set when mouse is pressed, used to calculate delta.
		delta = Vector2(0 , 0) , -- Delta since pressed down.
	}
	self.deselectMouse = Copy(self.selectMouse)
	self.deselectMouse.button = 2
	self.selectMice = {self.selectMouse , self.deselectMouse}
	
	self.spawnMenu = MapEditor.SpawnMenu()
	
	Mouse:SetVisible(true)
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseDown")
	self:EventSubscribe("MouseUp")
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

function MapEditor.Map:SetCanSelect(canSelect)
	for index , mouse in ipairs(self.selectMice) do
		mouse.isEnabled = canSelect
		if self.canSelect == false then
			mouse.isDown = false
			mouse.isDown = false
		end
	end
end

-- Events

function MapEditor.Map:Render()
	if self.selectMouse.isDown then
		self.selectMouse.delta = Mouse:GetPosition() - self.selectMouse.downPosition
		MapEditor.Utility.DrawArea(
			self.selectMouse.downPosition ,
			self.selectMouse.delta ,
			4 ,
			Color.LimeGreen
		)
	end
	if self.deselectMouse.isDown then
		self.deselectMouse.delta = Mouse:GetPosition() - self.deselectMouse.downPosition
		MapEditor.Utility.DrawArea(
			self.deselectMouse.downPosition ,
			self.deselectMouse.delta ,
			4 ,
			Color.DarkRed
		)
	end
	
	self:IterateObjects(function(object)
		MapEditor.Utility.DrawBounds(object.position , object.bounds , Color.White * 0.5)
		
		if object.OnRender then
			object:OnRender()
		end
		
		if self.selectedObjects:HasObject(object) then
			local boundsEnlarged = {}
			boundsEnlarged[1] = object.bounds[1] * 1.1
			boundsEnlarged[2] = object.bounds[2] * 1.1
			MapEditor.Utility.DrawBounds(object.position , boundsEnlarged , Color.LimeGreen * 0.8)
		end
	end)
end

function MapEditor.Map:MouseDown(args)
	local mouse = self.selectMice[args.button]
	if mouse == nil or mouse.isEnabled == false then
		return
	end
	
	mouse.isDown = true
	mouse.downPosition = Mouse:GetPosition()
	
	if mouse.button == 1 then
		self.selectMice[2].isEnabled = false
	else
		self.selectMice[1].isEnabled = false
	end
end

function MapEditor.Map:MouseUp(args)
	local mouse = self.selectMice[args.button]
	if mouse == nil or mouse.isEnabled == false or mouse.isDown == false then
		return
	end
	
	mouse.isDown = false
	
	if mouse.button == 1 then
		self.selectMice[2].isEnabled = true
	else
		self.selectMice[1].isEnabled = true
	end
	
	if mouse.delta:Length() > 16 then
		local pos1 = mouse.downPosition
		local pos2 = mouse.downPosition + mouse.delta
		local left =   math.min(pos1.x , pos2.x)
		local right =  math.max(pos1.x , pos2.x)
		local top =    math.min(pos1.y , pos2.y)
		local bottom = math.max(pos1.y , pos2.y)
		
		-- Iterate through all of our objects and select those that are within the bounds.
		-- TODO: This won't scale very well...
		local screenPos , isOnScreen
		self:IterateObjects(function(object)
			screenPos , isOnScreen = Render:WorldToScreen(object:GetPosition())
			if isOnScreen then
				if
					screenPos.x > left and
					screenPos.x < right and
					screenPos.y > top and
					screenPos.y < bottom
				then
					if mouse == self.selectMouse then
						self.selectedObjects:AddObject(object)
					else
						self.selectedObjects:RemoveObject(object)
					end
				end
			end
		end)
	end
end

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
