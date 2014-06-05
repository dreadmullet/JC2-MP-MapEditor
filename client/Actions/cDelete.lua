class("Delete" , Actions)

function Actions.Delete:__init()
	MapEditor.Action.__init(self)
	
	self.objects = {}
	-- If we delete an Object that is referenced elsewhere, those properties get reset.
	-- Each element is like, {property = Property , originalValue = blar , index = optional}
	self.properties = {}
	
	MapEditor.map.selectedObjects:IterateObjects(function(object)
		table.insert(self.objects , object)
	end)
	
	local TestProperty = function(property)
		local IsInObjects = function(propertyValue)
			if propertyValue ~= MapEditor.Property.NoObject then
				local objectId = propertyValue:GetId()
				for index , object in ipairs(self.objects) do
					if object:GetId() == objectId then
						return true
					end
				end
			end
			
			return false
		end
		
		if Objects[property.type] then
			if IsInObjects(property.value) then
				table.insert(self.properties , {property = property , originalValue = property.value})
			end
		elseif Objects[property.subtype] then
			for index , object in ipairs(property.value) do
				if IsInObjects(object) then
					local propertyInfo = {
						property = property ,
						index = index ,
						originalValue = object ,
					}
					table.insert(self.properties , propertyInfo)
				end
			end
		end
	end
	
	MapEditor.map:IterateProperties(TestProperty)
	
	MapEditor.map:IterateObjects(function(object)
		object:IterateProperties(TestProperty)
	end)
	
	if #self.objects > 0 then
		self:Redo()
		self:Confirm()
	else
		self:Cancel()
	end
end

function Actions.Delete:Undo()
	for index , object in ipairs(self.objects) do
		object:Recreate()
		MapEditor.map:AddObject(object)
		MapEditor.map.selectedObjects:AddObject(object)
	end
	
	for index , propertyInfo in ipairs(self.properties) do
		if propertyInfo.index then
			propertyInfo.property.value[propertyInfo.index] = propertyInfo.originalValue
		else
			propertyInfo.property.value = propertyInfo.originalValue
		end
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.Delete:Redo()
	for index , object in ipairs(self.objects) do
		object:Destroy()
		MapEditor.map.selectedObjects:RemoveObject(object)
		MapEditor.map:RemoveObject(object)
	end
	
	for index , propertyInfo in ipairs(self.properties) do
		if propertyInfo.index then
			propertyInfo.property.value[propertyInfo.index] = MapEditor.Property.NoObject
		else
			propertyInfo.property.value = MapEditor.Property.NoObject
		end
	end
	
	MapEditor.map:SelectionChanged()
end
