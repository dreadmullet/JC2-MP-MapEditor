class("PropertyManager" , MapEditor)

function MapEditor.PropertyManager:__init()
	MapEditor.Marshallable.__init(self)
	
	self.AddProperty = MapEditor.PropertyManager.AddProperty
	self.SetProperty = MapEditor.PropertyManager.SetProperty
	self.GetProperty = MapEditor.PropertyManager.GetProperty
	self.RemoveProperty = MapEditor.PropertyManager.RemoveProperty
	self.HasProperty = MapEditor.PropertyManager.HasProperty
	self.IterateProperties = MapEditor.PropertyManager.IterateProperties
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

function MapEditor.PropertyManager:GetProperty(propertyName)
	return self.properties[propertyName]
end

function MapEditor.PropertyManager:RemoveProperty(propertyName)
	self.properties[propertyName] = nil
end

function MapEditor.PropertyManager:HasProperty(propertyName)
	return self.properties[propertyName] ~= nil
end

function MapEditor.PropertyManager:IterateProperties(func)
	for name , property in pairs(self.properties) do
		func(property)
	end
end

function MapEditor.PropertyManager:Marshal()
	local t = MapEditor.Marshallable.Marshal(self)
	t.properties = {}
	
	for name , property in pairs(self.properties) do
		-- Special handling for Objects - use their id instead.
		if Objects[property.type] or Objects[property.subtype] then
			if property.type == "table" then
				t.properties[name] = {}
				for key , object in pairs(property.value) do
					t.properties[name][key] = object:GetId()
				end
			elseif property.value then
				t.properties[name] = property.value:GetId()
			end
		else
			t.properties[name] = MapEditor.Marshallable.MarshalValue(property.value)
		end
	end
	
	return t
end
