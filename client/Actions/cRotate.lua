class("Rotate" , Actions)

function Actions.Rotate:__init()
	Actions.TransformBase.__init(self)
	
	self.sensitivity = 1
	self.screenPivot = nil
	self.startMouseDirection = nil
	
	self.controlDisplayer.name = "Rotate"
	
	self.gizmoModel = nil
	
	local args = {
		path = "Models/Rotate gizmo"
	}
	OBJLoader.Request(args , self , function(self , model) self.gizmoModel = model end)
end

function Actions.Rotate:OnProcess(objectInfo , mouse , pivot)
	if mouse.delta == Vector2.Zero then
		return
	end
	
	if self.screenPivot == nil then
		local pos , success = Render:WorldToScreen(pivot)
		if success then
			self.screenPivot = pos
		else
			self.screenPivot = Render.Size/2
		end
		
		local dir = (mouse.start - self.screenPivot):Normalized()
		self.startMouseDirection = Vector3(dir.x , 0 , dir.y)
	end
	
	local dir = (Mouse:GetPosition() - self.screenPivot):Normalized()
	local mouseDirection = Vector3(dir.x , 0 , dir.y)
	
	local mouseAngle = Angle.FromVectors(
		self.startMouseDirection ,
		mouseDirection
	)
	
	local axis
	if self.lockedAxis then
		if self.lockedAxis == "X" then
			axis = Vector3.Right
		elseif self.lockedAxis == "Y" then
			axis = Vector3.Up
		elseif self.lockedAxis == "Z" then
			axis = Vector3.Forward
		end
		
		if self.isLocal then
			axis = objectInfo.startTransform.angle * axis
		end
		
		if self.gizmoModel then
			local angle
			if self.lockedAxis == "X" then
				angle = Angle(0 , 0 , 0)
			elseif self.lockedAxis == "Y" then
				angle = Angle(0 , 0 , math.tau / 4)
			elseif self.lockedAxis == "Z" then
				angle = Angle(math.tau / 4 , 0 , 0)
			end
			
			if self.isLocal then
				angle = objectInfo.startTransform.angle * angle
			end
			
			local transform = Transform3()
			transform:Translate(pivot)
			transform:Rotate(angle)
			Render:SetTransform(transform)
			
			self.gizmoModel:Draw()
			
			Render:ResetTransform()
		end
	else
		axis = Camera:GetAngle() * Vector3.Forward
	end
	
	local angle = Angle.AngleAxis(mouseAngle.yaw * self.sensitivity , -axis)
	
	objectInfo.endTransform.angle = angle * objectInfo.startTransform.angle
	
	local relativePosition = objectInfo.startTransform.position - pivot
	objectInfo.endTransform.position = pivot + angle * relativePosition
end

function Actions.Rotate:OnRender(mouse , pivot)
	if self.screenPivot then
		Render:DrawLine(self.screenPivot , Mouse:GetPosition() , Color(127 , 127 , 127 , 180))
	end
end
