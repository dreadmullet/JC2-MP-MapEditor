class("ObjectManager" , MapEditor)

function MapEditor.ObjectManager:__init()
	local memberNames = {
		"objects" ,
	}
	MapEditor.Marshallable.__init(self , memberNames)
	
	self.AddObject = MapEditor.ObjectManager.AddObject
	self.GetObject = MapEditor.ObjectManager.GetObject
	self.RemoveObject = MapEditor.ObjectManager.RemoveObject
	self.HasObject = MapEditor.ObjectManager.HasObject
	self.IsEmpty = MapEditor.ObjectManager.IsEmpty
	self.IterateObjects = MapEditor.ObjectManager.IterateObjects
	self.GetObjectFromScreenPoint = MapEditor.ObjectManager.GetObjectFromScreenPoint
	
	self.objects = {}
end

function MapEditor.ObjectManager:AddObject(object)
	self.objects[object:GetId()] = object
end

function MapEditor.ObjectManager:GetObject(objectId)
	return self.objects[objectId]
end

function MapEditor.ObjectManager:RemoveObject(object)
	self.objects[object:GetId()] = nil
end

function MapEditor.ObjectManager:HasObject(object)
	return self.objects[object:GetId()] ~= nil
end

function MapEditor.ObjectManager:IsEmpty()
	for id , object in pairs(self.objects) do
		return false
	end
	
	return true
end

function MapEditor.ObjectManager:IterateObjects(func)
	for id , object in pairs(self.objects) do
		func(object)
	end
end

function MapEditor.ObjectManager:GetObjectFromScreenPoint(screenPointToTest)
	-- TODO: This won't scale very well.
	local nearestObject = nil
	local nearestObjectDistSquared = nil
	self:IterateObjects(function(object)
		local screenPoints = object:GetBoundingBoxScreenPoints()
		
		local xMin = 50000
		local xMax = 0
		local yMin = 50000
		local yMax = 0
		for index , screenPoint in ipairs(screenPoints) do
			xMin = math.min(xMin , screenPoint.x)
			xMax = math.max(xMax , screenPoint.x)
			yMin = math.min(yMin , screenPoint.y)
			yMax = math.max(yMax , screenPoint.y)
		end
		
		local isWithinBounds = (
			screenPointToTest.x > xMin and
			screenPointToTest.x < xMax and
			screenPointToTest.y > yMin and
			screenPointToTest.y < yMax
		)
		
		if isWithinBounds then
			local distanceSquared = Camera:GetPosition():DistanceSqr(object:GetPosition())
			
			if nearestObject == nil or distanceSquared < nearestObjectDistSquared then
				nearestObject = object
				nearestObjectDistSquared = distanceSquared
			end
		end
	end)
	
	return nearestObject
end
