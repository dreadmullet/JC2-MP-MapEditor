class("ObjectPlacer" , Actions)

function Actions.ObjectPlacer:__init(objectClass)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	local angle = Camera:GetAngle()
	local position = Camera:GetPosition() + angle * Vector3.Forward * 5
	angle.roll = 0
	angle.pitch = 0
	self.object = objectClass(position , angle)
	MapEditor.map:AddObject(self.object)
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseDown")
end

function Actions.ObjectPlacer:Confirm()
	
end

function Actions.ObjectPlacer:Cancel()
	
	self:Cancel()
end

-- Events

function Actions.ObjectPlacer:Render()
	local dir = Render:ScreenToWorldDirection(Mouse:GetPosition())
	local result = Physics:Raycast(Camera:GetPosition() , dir , 0.1 , 512)
	local position = result.position
	self.object:SetPosition(position)
end

function Actions.ObjectPlacer:MouseDown(args)
	if args.button == 1 then
		self:UnsubscribeAll()
		self:Confirm()
	elseif args.button == 2 then
		self.object:Destroy()
		MapEditor.map:RemoveObject(self.object)
		
		self:UnsubscribeAll()
		self:Cancel()
	end
end
