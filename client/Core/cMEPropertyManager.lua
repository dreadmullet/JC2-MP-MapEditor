class("PropertyManager" , MapEditor)

function MapEditor.PropertyManager:__init()
	MapEditor.Marshallable.__init(self)
	
	self.AddProperty = MapEditor.PropertyManager.AddProperty
	self.SetProperty = MapEditor.PropertyManager.SetProperty
	self.RemoveProperty = MapEditor.PropertyManager.RemoveProperty
	self.HasProperty = MapEditor.PropertyManager.HasProperty
	self.Marshal = MapEditor.PropertyManager.Marshal
	
	self.properties = {}
end

function MapEditor.PropertyManager:AddProperty(args)
	local property = MapEditor.Property(args)
	self.properties[property.name] = property
end

function MapEditor.PropertyManager:SetProperty(name , value)
	local property = self.properties[name]
	if property == nil then
		error("Property doesn't exist: "..tostring(name))
		return
	end
	
	local oldValue = property.value
	property.value = value
	
	if self.OnPropertyChange then
		local args = {
			name = property.name ,
			newValue = property.value ,
			oldValue = oldValue ,
		}
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
