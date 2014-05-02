class("ObjectPlacer" , MapEditor)

function MapEditor.ObjectPlacer:__init(objectClass) ; EGUSM.SubscribeUtility.__init(self)
	local angle = Camera:GetAngle()
	local position = Camera:GetPosition() + angle * Vector3.Forward * 5
	angle.roll = 0
	angle.pitch = 0
	self.object = objectClass(position , angle)
	MapEditor.map:AddObject(self.object)
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseDown")
end

function MapEditor.ObjectPlacer:Confirm()
	self:UnsubscribeAll()
end

function MapEditor.ObjectPlacer:Cancel()
	self:UnsubscribeAll()
	self.object:Destroy()
	MapEditor.map:RemoveObject(self.object)
end

-- Events

function MapEditor.ObjectPlacer:Render()
	local dir = Render:ScreenToWorldDirection(Mouse:GetPosition())
	local result = Physics:Raycast(Camera:GetPosition() , dir , 0.1 , 512)
	local position = result.position
	self.object:SetPosition(position)
end

function MapEditor.ObjectPlacer:MouseDown(args)
	if args.button == 1 then
		self:Confirm()
	elseif args.button == 2 then
		self:Cancel()
	end
end
