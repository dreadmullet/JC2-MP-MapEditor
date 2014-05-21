class("Object" , MapEditor)

-- Static

MapEditor.Object.memberNames = {
	"id" ,
	"type" ,
	"position" ,
	"angle" ,
}

MapEditor.Object.Unmarshal = function(o)
	local objectClass = Objects[o.type]
	if objectClass == nil then
		error("Object class not found: "..tostring(o.type))
	end
	
	local position = Vector3(o.position[1] , o.position[2] , o.position[3])
	local angle = Angle(o.angle[1] , o.angle[2] , o.angle[3] , o.angle[4])
	
	local object = objectClass(position , angle)
	object.id = o.id
	
	-- Properties must be done after this, which is annoying.
	
	return object
end

-- Instance

function MapEditor.Object:__init(initialPosition , initialAngle)
	MapEditor.Marshallable.__init(self , MapEditor.Object.memberNames)
	MapEditor.PropertyManager.__init(self)
	
	self.Destroy = MapEditor.Object.Destroy
	self.Recreate = MapEditor.Object.Recreate
	self.SetPosition = MapEditor.Object.SetPosition
	self.SetAngle = MapEditor.Object.SetAngle
	self.SetSelected = MapEditor.Object.SetSelected
	self.GetId = MapEditor.Object.GetId
	self.GetPosition = MapEditor.Object.GetPosition
	self.GetAngle = MapEditor.Object.GetAngle
	self.GetIsSelected = MapEditor.Object.GetIsSelected
	self.GetBoundingBoxScreenPoints = MapEditor.Object.GetBoundingBoxScreenPoints
	
	self.id = MapEditor.map.objectIdCounter
	MapEditor.map.objectIdCounter = MapEditor.map.objectIdCounter + 1
	self.type = class_info(self).name
	self.position = initialPosition or Vector3(0 , 208 , 0)
	self.angle = initialAngle or Angle(0 , 0 , 0)
	
	self.isSelected = false
	self.cursor = MapEditor.Cursor(self.position)
	self.bounds = {Vector3(-2 , -2 , -2) , Vector3(2 , 2 , 2)}
end

function MapEditor.Object:Destroy()
	if self.OnDestroy then
		self:OnDestroy()
	end
	
	if self.cursor then
		self.cursor:Destroy()
	end
end

function MapEditor.Object:Recreate()
	if self.OnRecreate then
		self:OnRecreate()
	end
	
	self.cursor = MapEditor.Cursor(self.position)
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

function MapEditor.Object:SetSelected(selected)
	if self.isSelected == selected then
		return
	end
	
	self.isSelected = selected
	
	if self.isSelected then
		MapEditor.map.selectedObjects:AddObject(self)
		if self.OnSelect then
			self:OnSelect()
		end
	else
		MapEditor.map.selectedObjects:RemoveObject(self)
		if self.OnDeselect then
			self:OnDeselect()
		end
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

function MapEditor.Object:GetIsSelected()
	return self.isSelected
end

function MapEditor.Object:GetBoundingBoxScreenPoints()
	local points = {}
	
	local positionsToCheck = {
		self.position + Vector3(self.bounds[1].x , self.bounds[1].y , self.bounds[1].z) ,
		self.position + Vector3(self.bounds[2].x , self.bounds[1].y , self.bounds[1].z) ,
		self.position + Vector3(self.bounds[1].x , self.bounds[1].y , self.bounds[2].z) ,
		self.position + Vector3(self.bounds[2].x , self.bounds[1].y , self.bounds[2].z) ,
		self.position + Vector3(self.bounds[1].x , self.bounds[2].y , self.bounds[1].z) ,
		self.position + Vector3(self.bounds[2].x , self.bounds[2].y , self.bounds[1].z) ,
		self.position + Vector3(self.bounds[1].x , self.bounds[2].y , self.bounds[2].z) ,
		self.position + Vector3(self.bounds[2].x , self.bounds[2].y , self.bounds[2].z) ,
	}
	
	for index , positionToCheck in ipairs(positionsToCheck) do
		local screenPos , success = Render:WorldToScreen(positionToCheck)
		if success then
			table.insert(points , screenPos)
		end
	end
	
	return points
end
