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
		-- Get value.
		local value = nil
		local isObject = false
		-- Special handling for Objects - use their id instead.
		if Objects[property.type] or Objects[property.subtype] then
			isObject = true
			
			if property.type == "table" then
				value = {}
				for key , object in pairs(property.value) do
					if object ~= MapEditor.Property.NoObject then
						value[key] = object:GetId()
					end
				end
			elseif property.value ~= MapEditor.Property.NoObject then
				value = property.value:GetId()
			end
		else
			value = MapEditor.Marshallable.MarshalValue(property.value)
		end
		
		-- Get type.
		-- Man, I really should have made it 'type' and 'isTable', not 'type' and 'subtype'.
		local actualType
		if isObject then
			actualType = "Object"
		elseif property.type == "table" then
			actualType = property.subtype
		else
			actualType = property.type
		end
		
		-- Assign the property.
		t.properties[name] = {FNV(actualType) , value}
	end
	
	return t
end

function MapEditor.PropertyManager:Unmarshal(properties)
	for name , propertyData in pairs(properties) do
		local property = self:GetProperty(name)
		if property then
			local typeHash = propertyData[1]
			local value = propertyData[2]
			
			if property.type == "table" then
				property.value = {}
				for key , value in pairs(value) do
					property.value[key] = MapEditor.Marshallable.UnmarshalValue(typeHash , value)
				end
			else
				property.value = MapEditor.Marshallable.UnmarshalValue(typeHash , value)
			end
		else
			warn("Property doesn't exist: "..tostring(name))
		end
	end
end
