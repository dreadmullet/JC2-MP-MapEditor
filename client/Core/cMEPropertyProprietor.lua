-- Used by MapEditor.PropertiesMenu when selecting multiple objects that have common properties.

class("PropertyProprietor" , MapEditor)

function MapEditor.PropertyProprietor:__init(properties)
	-- array of Propertys with the same name that are part of different PropertyManagers.
	self.properties = properties
	self.name = self.properties[1].name
	self.type = self.properties[1].type
	self.subtype = self.properties[1].subtype
	self.defaultElement = self.properties[1].defaultElement
	self.isObject = Objects[self.type] ~= nil or Objects[self.subtype] ~= nil
	-- If commonValue ends up nil, there is a conflict. Otherwise, all Propertys have the same value.
	commonValue = nil
	
	for index , property in ipairs(self.properties) do
		if property.type == "table" then
			if commonValue == nil then
				commonValue = property.value
			else
				local isIdentical = self:CompareTables(commonValue , property.value)
				if isIdentical == false then
					commonValue = nil
					break
				end
			end
		else
			if commonValue == nil then
				commonValue = property.value
			else
				-- Comparing class instances causes an error :|
				if self.isObject and commonValue ~= MapEditor.Property.NoObject then
					if
						property.value ~= MapEditor.Property.NoObject and
						property.value:GetId() ~= commonValue:GetId()
					then
						commonValue = nil
						break
					end
				else
					if property.value ~= commonValue then
						commonValue = nil
						break
					end
				end
			end
		end
	end
	
	if commonValue then
		if self.type == "table" then
			self.value = {}
			for index , value in ipairs(commonValue) do
				table.insert(self.value , value)
			end
		else
			self.value = commonValue
		end
	else
		if self.type == "table" then
			self.value = {}
		else
			self.value = MapEditor.Property.GetDefaultValue(self.type)
		end
	end
end

function MapEditor.PropertyProprietor:CompareTables(a , b)
	if #a == #b then
		for index = 1 , #a do
			if self.isObject then
				if type(a[index]) ~= type(b[index]) then
					return false
				elseif a[index] == MapEditor.Property.NoObject then
					if b[index] ~= MapEditor.Property.NoObject then
						return false
					end
				else
					if a[index]:GetId() ~= b[index]:GetId() then
						return false
					end
				end
			else
				if a[index] ~= b[index] then
					return false
				end
			end
		end
		
		return true
	else
		return false
	end
end

function MapEditor.PropertyProprietor:SetValue(value)
	local args = {
		properties = self.properties ,
		value = value ,
	}
	MapEditor.map:SetAction(Actions.PropertyChange , args)
	
	-- Object selection begins now, and value is the object button for some reason.
	if self.isObject == false then
		self.value = value
	end
end

function MapEditor.PropertyProprietor:SetTableValue(index , value)
	self:SyncTables()
	
	local args = {
		properties = self.properties ,
		value = value ,
		index = index ,
		tableActionType = "Set" ,
	}
	MapEditor.map:SetAction(Actions.PropertyChange , args)
	
	-- Object selection begins now, and value is the object button for some reason.
	if self.isObject == false then
		self.value[index] = value
	end
end

function MapEditor.PropertyProprietor:RemoveTableValue(index)
	self:SyncTables()
	
	local args = {
		properties = self.properties ,
		index = index ,
		tableActionType = "Remove" ,
	}
	MapEditor.map:SetAction(Actions.PropertyChange , args)
	
	table.remove(self.value , index)
end

function MapEditor.PropertyProprietor:AddTableValue()
	self:SyncTables()
	
	local args = {
		properties = self.properties ,
		tableActionType = "Add" ,
	}
	MapEditor.map:SetAction(Actions.PropertyChange , args)
	
	table.insert(self.value , self.defaultElement)
end

function MapEditor.PropertyProprietor:SyncTables()
	for index , property in ipairs(self.properties) do
		if self:CompareTables(self.value , property.value) == false then
			property.value = {}
			for index , value in ipairs(self.value) do
				property.value[index] = value
			end
		end
	end
end
