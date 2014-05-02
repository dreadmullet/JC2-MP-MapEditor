class("Object" , MapEditor)

MapEditor.Object.idCounter = 1

function MapEditor.Object:__init(initialPosition , initialAngle)
	self.Destroy = MapEditor.Object.Destroy
	self.SetPosition = MapEditor.Object.SetPosition
	self.SetAngle = MapEditor.Object.SetAngle
	self.GetId = MapEditor.Object.GetId
	self.GetPosition = MapEditor.Object.GetPosition
	self.GetAngle = MapEditor.Object.GetAngle
	
	local memberNames = {
		"id" ,
		"type" ,
		"position" ,
		"angle" ,
	}
	MapEditor.Marshallable.__init(self , memberNames)
	MapEditor.PropertyManager.__init(self)
	
	self.id = MapEditor.Object.idCounter
	MapEditor.Object.idCounter = MapEditor.Object.idCounter + 1
	self.type = class_info(self).name
	self.position = initialPosition or Vector3(0 , 208 , 0)
	self.angle = initialAngle or Angle(0 , 0 , 0)
	
	self.cursor = MapEditor.Cursor(self.position)
	self.bounds = {Vector3(-2 , -2 , -2) , Vector3(2 , 2 , 2)}
	
	self.renderSub = Events:Subscribe("Render" , self , MapEditor.Object.Render)
end

function MapEditor.Object:Destroy()
	if self.OnDestroy then
		self:OnDestroy()
	end
	
	if self.cursor then
		self.cursor:Destroy()
	end
	
	if IsValid(self.renderSub) then
		Events:Unsubscribe(self.renderSub)
	end
end

function MapEditor.Object:SetPosition(position)
	self.position = position
	
	if self.cursor then
		self.cursor.position = position
	end
	
	if self.OnPositionChange then
		self:OnPositionChange(position)
	end
end

function MapEditor.Object:SetAngle(angle)
	self.angle = angle
	
	if self.cursor then
		self.cursor.angle = angle
	end
	
	if self.OnAngleChange then
		self:OnAngleChange(angle)
	end
end

function MapEditor.Object:GetId()
	return self.id
end

function MapEditor.Object:GetPosition()
	return self.position
end

function MapEditor.Object:GetAngle()
	return self.angle
end

-- Events

function MapEditor.Object:Render()
	if self.bounds then
		MapEditor.Utility.DrawBounds(self.position , self.bounds , Color(127 , 127 , 127 , 127))
	end
	
	if self.OnRender then
		self:OnRender()
	end
end
