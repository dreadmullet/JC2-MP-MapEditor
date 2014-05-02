class("Mover" , Actions)

function Actions.Mover:__init(objectClass)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	self.mousePosition = Mouse:GetPosition()
	self.delta = Vector3(0 , 0 , 0)
	self.sensitivity = 0.001
	-- Map of tables
	--    Key: Object id
	--    Value: table: {object (MapEditor.Object), initialPosition (Vector3)}
	self.objects = {}
	MapEditor.map.selectedObjects:IterateObjects(function(object)
		self.objects[object:GetId()] = {object , object:GetPosition()}
	end)
	
	if table.count(self.objects) == 0 then
		self:Cancel()
		return
	end
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseUp")
end

function Actions.Mover:GetAverageObjectPosition()
	local position = Vector3(0 , 0 , 0)
	local count = 0
	for objectId , objectInfo in pairs(self.objects) do
		position = position + objectInfo[1]:GetPosition()
		count = count + 1
	end
	position = position / count
	
	return position
end

-- Events

function Actions.Mover:Render()
	local mouseDelta = Mouse:GetPosition() - self.mousePosition
	self.mousePosition = Mouse:GetPosition()
	
	if mouseDelta == Vector2.Zero then
		return
	end
	
	local distance = Vector3.Distance(Camera:GetPosition() , self:GetAverageObjectPosition())
	local mult = distance * self.sensitivity
	self.delta = self.delta + Camera:GetAngle() * Vector3(mouseDelta.x , -mouseDelta.y , 0) * mult
	
	for objectId , objectInfo in pairs(self.objects) do
		local object = objectInfo[1]
		local initialPosition = objectInfo[2]
		
		object:SetPosition(initialPosition + self.delta)
	end
end

function Actions.Mover:MouseUp(args)
	if args.button == 1 then
		self:UnsubscribeAll()
		self:Confirm()
	elseif args.button == 2 then
		for objectId , objectInfo in pairs(self.objects) do
			local object = objectInfo[1]
			local initialPosition = objectInfo[2]
			
			object:SetPosition(initialPosition)
		end
		
		self:UnsubscribeAll()
		self:Cancel()
	end
end
