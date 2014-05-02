class("ObjectPlacer" , Tools)

function Tools.ObjectPlacer:__init(objectClass)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Tool.__init(self)
	
	local angle = Camera:GetAngle()
	local position = Camera:GetPosition() + angle * Vector3.Forward * 5
	angle.roll = 0
	angle.pitch = 0
	self.object = objectClass(position , angle)
	MapEditor.map:AddObject(self.object)
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseDown")
end

function Tools.ObjectPlacer:Confirm()
	self:UnsubscribeAll()
	self:Finish()
end

function Tools.ObjectPlacer:Cancel()
	self.object:Destroy()
	MapEditor.map:RemoveObject(self.object)
	
	self:UnsubscribeAll()
	self:Finish()
end

-- Events

function Tools.ObjectPlacer:Render()
	local dir = Render:ScreenToWorldDirection(Mouse:GetPosition())
	local result = Physics:Raycast(Camera:GetPosition() , dir , 0.1 , 512)
	local position = result.position
	self.object:SetPosition(position)
end

function Tools.ObjectPlacer:MouseDown(args)
	if args.button == 1 then
		self:Confirm()
	elseif args.button == 2 then
		self:Cancel()
	end
end
