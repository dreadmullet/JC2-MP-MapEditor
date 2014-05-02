class("Mover" , Actions)

function Actions.Mover:__init(objectClass)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	self.mousePosition = Mouse:GetPosition()
	self.delta = Vector3(0 , 0 , 0)
	self.sensitivity = 0.001
	-- Map of tables
	--    Key: Object id
	--    Value: map: {
	--       object = MapEditor.Object ,
	--       initialPosition = Vector3 ,
	--       endPosition = Vector3 ,
	--    }
	self.objects = {}
	MapEditor.map.selectedObjects:IterateObjects(function(object)
		self.objects[object:GetId()] = {
			object = object ,
			initialPosition = object:GetPosition() ,
			endPosition = object:GetPosition() ,
		}
	end)
	
	if table.count(self.objects) == 0 then
		self:Cancel()
		return
	end
	
	self:EventSubscribe("Render")
	self:EventSubscribe("MouseUp")
end

-- TODO: Change to median?
function Actions.Mover:GetAverageObjectPosition()
	local position = Vector3(0 , 0 , 0)
	local count = 0
	for objectId , objectInfo in pairs(self.objects) do
		position = position + objectInfo.object:GetPosition()
		count = count + 1
	end
	position = position / count
	
	return position
end

function Actions.Mover:Undo()
	for objectId , objectInfo in pairs(self.objects) do
		objectInfo.object:SetPosition(objectInfo.initialPosition)
	end
end

function Actions.Mover:Redo()
	for objectId , objectInfo in pairs(self.objects) do
		objectInfo.object:SetPosition(objectInfo.endPosition)
	end
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
		objectInfo.endPosition = objectInfo.initialPosition + self.delta
		objectInfo.object:SetPosition(objectInfo.endPosition)
	end
end

function Actions.Mover:MouseUp(args)
	if args.button == 1 then
		self:UnsubscribeAll()
		self:Confirm()
	elseif args.button == 2 then
		self:Undo()
		
		self:UnsubscribeAll()
		self:Cancel()
	end
end
