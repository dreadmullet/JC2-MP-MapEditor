class("TransformBase" , Actions)

function Actions.TransformBase:__init()
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	self.GetAverageObjectPosition = Actions.TransformBase.GetAverageObjectPosition
	self.Undo = Actions.TransformBase.Undo
	self.Redo = Actions.TransformBase.Redo
	self.OnConfirmOrCancel = Actions.TransformBase.OnConfirmOrCancel
	
	self.mouse = {start = Mouse:GetPosition() , delta = Vector2(0 , 0)}
	-- Map of tables
	--    Key: Object id
	--    Value: map: {
	--       object =         MapEditor.Object ,
	--       startTransform = {position = Vector3 , angle = Angle} ,
	--       endTransform =   {position = Vector3 , angle = Angle} ,
	--    }
	self.objects = {}
	MapEditor.map.selectedObjects:IterateObjects(function(object)
		self.objects[object:GetId()] = {
			object =         object ,
			startTransform = {position = object:GetPosition() , angle = object:GetAngle()} ,
			endTransform =   {position = object:GetPosition() , angle = object:GetAngle()} ,
		}
	end)
	
	if table.count(self.objects) == 0 then
		self:Cancel()
		return
	end
	
	self.pivot = self:GetAverageObjectPosition()
	self.lockedAxis = nil
	
	Controls.Add("Lock to X axis" , "X")
	Controls.Add("Lock to Y axis" , "Y")
	Controls.Add("Lock to Z axis" , "Z")
	
	self.controlDisplayer = MapEditor.ControlDisplayer{
		name = "TransformBase" ,
		linesFromBottom = 3 ,
		"Lock to X axis" ,
		"Lock to Y axis" ,
		"Lock to Z axis" ,
	}
	
	self:EventSubscribe("Render" , Actions.TransformBase.Render)
	self:EventSubscribe("MouseUp" , Actions.TransformBase.MouseUp)
	self:EventSubscribe("ControlDown" , Actions.TransformBase.ControlDown)
end

function Actions.TransformBase:GetAverageObjectPosition()
	local position = Vector3(0 , 0 , 0)
	local count = 0
	for objectId , objectInfo in pairs(self.objects) do
		position = position + objectInfo.object:GetPosition()
		count = count + 1
	end
	position = position / count
	
	return position
end

function Actions.TransformBase:Undo()
	for objectId , objectInfo in pairs(self.objects) do
		objectInfo.object:SetPosition(objectInfo.startTransform.position)
		objectInfo.object:SetAngle(objectInfo.startTransform.angle)
	end
end

function Actions.TransformBase:Redo()
	for objectId , objectInfo in pairs(self.objects) do
		objectInfo.object:SetPosition(objectInfo.endTransform.position)
		objectInfo.object:SetAngle(objectInfo.endTransform.angle)
	end
end

function Actions.TransformBase:OnConfirmOrCancel()
	self.controlDisplayer:Destroy()
end

-- Events

function Actions.TransformBase:Render()
	self.mouse.delta = Mouse:GetPosition() - self.mouse.start
	
	if self.OnRender then
		self:OnRender(self.mouse ,self.pivot)
	end
	
	for objectId , objectInfo in pairs(self.objects) do
		-- TODO: probably just send the array (also make it an array, not a map)
		self:OnProcess(objectInfo , self.mouse , self.pivot)
		objectInfo.object:SetPosition(objectInfo.endTransform.position)
		objectInfo.object:SetAngle(objectInfo.endTransform.angle)
	end
end

function Actions.TransformBase:MouseUp(args)
	if args.button == 1 then
		self:UnsubscribeAll()
		self:Confirm()
	elseif args.button == 2 then
		self:Undo()
		
		self:UnsubscribeAll()
		self:Cancel()
	end
end

function Actions.TransformBase:ControlDown(args)
	local LockAxis = function(axis)
		if self.lockedAxis == axis then
			self.lockedAxis = nil
		else
			self.lockedAxis = axis
		end
	end
	
	if args.name == "Lock to X axis" then
		LockAxis("X")
	elseif args.name == "Lock to Y axis" then
		LockAxis("Y")
	elseif args.name == "Lock to Z axis" then
		LockAxis("Z")
	end
end
