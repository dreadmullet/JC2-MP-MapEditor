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
	Controls.Add("Move object" , "G")
	Controls.Add("Rotate object" , "R")
	Controls.Add("Undo" , "Z")
	Controls.Add("Redo" , "Y")
	
	self.camera = MapEditor.Camera(initialPosition)
	
	-- Actions are kept track of so we can undo and redo them.
	-- self.actions = {}
	self.currentAction = nil
	
	self.selectedObjects = MapEditor.ObjectManager()
	
	self.spawnMenu = MapEditor.SpawnMenu()
	
	Mouse:SetVisible(true)
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseDown")
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

function MapEditor.Map:SetAction(actionClass , ...)
	if self.currentAction ~= nil then
		warn("Already have an Action!")
		return
	end
	
	local finishedImmediately = false
	
	self.ActionFinish = function() finishedImmediately = true end
	
	self.currentAction = actionClass(...)
	
	self.ActionFinish = MapEditor.Map.ActionFinish
	
	if finishedImmediately then
		self.currentAction = nil
	else
		Events:Fire("ActionStart" , tostring(self.currentAction))
	end
end

function MapEditor.Map:ActionFinish()
	Events:Fire("ActionEnd" , tostring(self.currentAction))
	self.currentAction = nil
end

function MapEditor.Map:ActionCancel()
	Events:Fire("ActionEnd" , tostring(self.currentAction))
	self.currentAction = nil
end

-- Events

function MapEditor.Map:Render()
	-- Highlight all selected objects.
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
	if self.currentAction == nil then
		if args.button == 1 then
			self:SetAction(Actions.Selector , args.button)
		elseif args.button == 2 then
			self:SetAction(Actions.Deselector , args.button)
		end
	end
end

function MapEditor.Map:ControlDown(args)
	if self.currentAction == nil then
		if args.name == "Move object" then
			self:SetAction(Actions.Mover)
		elseif args.name == "Rotate object" then
			-- self:SetAction(Actions.Rotator)
		end
	end
	
	if args.name == "Rotate/pan camera" then
		self.camera.isInputEnabled = true
	end
end

function MapEditor.Map:ControlUp(args)
	if args.name == "Rotate/pan camera" then
		self.camera.isInputEnabled = false
	end
end
