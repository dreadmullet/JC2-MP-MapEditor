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
	args.propertyManager = self
	local property = MapEditor.Property(args)
	self.properties[property.name] = property
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
		-- Special handling for Objects - use their id instead. -1 means no Object.
		if Objects[property.type] or Objects[property.subtype] then
			isObject = true
			
			if property.type == "table" then
				value = {}
				for index , object in ipairs(property.value) do
					if object ~= MapEditor.Property.NoObject then
						value[index] = object:GetId()
					else
						value[index] = -1
					end
				end
			else
				if property.value ~= MapEditor.Property.NoObject then
					value = property.value:GetId()
				else
					value = -1
				end
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
		
		local tableVar
		if property.type == "table" then
			tableVar = 1
		else
			tableVar = 0
		end
		
		-- Assign the property.
		t.properties[name] = {tableVar , FNV(actualType) , value}
	end
	
	return t
end

function MapEditor.PropertyManager:Unmarshal(properties)
	for name , propertyData in pairs(properties) do
		local property = self:GetProperty(name)
		if property then
			local isTable = propertyData[1] == 1
			local typeHash = propertyData[2]
			local value = propertyData[3]
			
			if isTable then
				property.value = {}
				for index , value in ipairs(value) do
					property.value[index] = MapEditor.PropertyManager.UnmarshalValue(typeHash , value)
				end
			else
				property.value = MapEditor.PropertyManager.UnmarshalValue(typeHash , value)
			end
		else
			warn("Property doesn't exist: "..tostring(name))
		end
		
		if self.OnPropertyChange then
			self:OnPropertyChange{
				name = property.name ,
				newValue = property.value ,
			}
		end
	end
end

MapEditor.PropertyManager.UnmarshalValue = function(typeHash , value)
	local unmarshalFunction = MapEditor.PropertyManager.UnmarshalByTypeHash[typeHash]
	if unmarshalFunction then
		return unmarshalFunction(value)
	else
		return value
	end
end

MapEditor.PropertyManager.UnmarshalByTypeHash = {}

MapEditor.PropertyManager.UnmarshalByTypeHash[FNV("Object")] = function(value)
	if value == -1 then
		return MapEditor.Property.NoObject
	else
		local object = MapEditor.map:GetObject(value)
		if object == nil then
			error("Couldn't find object with id: "..tostring(value))
		else
			return object
		end
	end
end

MapEditor.PropertyManager.UnmarshalByTypeHash[FNV("Color")] = function(value)
	return Color(value[1] , value[2] , value[3] , value[4])
end
