class("ObjectManager" , MapEditor)

function MapEditor.ObjectManager:__init()
	local memberNames = {
		"objects" ,
	}
	MapEditor.Marshallable.__init(self , memberNames)
	
	self.AddObject = MapEditor.ObjectManager.AddObject
	self.RemoveObject = MapEditor.ObjectManager.RemoveObject
	self.HasObject = MapEditor.ObjectManager.HasObject
	self.IterateObjects = MapEditor.ObjectManager.IterateObjects
	
	self.objects = {}
end

function MapEditor.ObjectManager:AddObject(object)
	self.objects[object:GetId()] = object
end

function MapEditor.ObjectManager:RemoveObject(object)
	self.objects[object:GetId()] = nil
end

function MapEditor.ObjectManager:HasObject(object)
	return self.objects[object:GetId()] ~= nil
end

function MapEditor.ObjectManager:IterateObjects(func)
	for id , object in pairs(self.objects) do
		func(object)
	end
end
