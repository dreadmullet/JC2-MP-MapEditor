class("Object" , MapEditor)

MapEditor.Object.idCounter = 1

function MapEditor.Object:__init()
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
	self.position = Vector3(0 , 208 , 0)
	self.angle = Angle(0 , 0 , 0)
end

function MapEditor.Object:SetPosition(position)
	self.position = position
end

function MapEditor.Object:SetAngle(angle)
	self.angle = angle
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
