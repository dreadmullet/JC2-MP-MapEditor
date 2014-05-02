class("PropertyManager" , MapEditor)

function MapEditor.PropertyManager:__init()
	MapEditor.Marshallable.__init(self)
	
	self.Marshal = MapEditor.PropertyManager.Marshal
	
	self.SetProperty = MapEditor.PropertyManager.SetProperty
	self.RemoveProperty = MapEditor.PropertyManager.RemoveProperty
	self.HasProperty = MapEditor.PropertyManager.HasProperty
	
	self.properties = {}
end

function MapEditor.PropertyManager:SetProperty(name , value)
	local oldProperty = self.properties[name]
	
	self.properties[name] = MapEditor.Property(name , value)
	
	if self.OnPropertyChange then
		local args = {
			name = name ,
			newValue = value ,
		}
		if oldProperty then
			args.oldValue = oldProperty.value
		end
		self:OnPropertyChange(args)
	end
end

function MapEditor.PropertyManager:RemoveProperty(propertyName)
	self.properties[propertyName] = nil
end

function MapEditor.PropertyManager:HasProperty(propertyName)
	return self.properties[propertyName] ~= nil
end

function MapEditor.PropertyManager:Marshal()
	local t = MapEditor.Marshallable.Marshal(self)
	t.properties = {}
	
	for name , property in pairs(self.properties) do
		t.properties[name] = MapEditor.Marshallable.MarshalValue(property.value)
	end
	
	return t
end
