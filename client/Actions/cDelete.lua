class("Delete" , Actions)

function Actions.Delete:__init()
	MapEditor.Action.__init(self)
	
	self.objectsInfo = {}
	-- If we delete an Object that is referenced elsewhere, those properties get reset.
	-- Each element is like, {property = Property , originalValue = blar , index = optional}
	self.properties = {}
	
	MapEditor.map.selectedObjects:IterateObjects(function(object)
		local oldChildren = {}
		object:IterateChildren(function(child)
			table.insert(oldChildren , child)
		end)
		local objectInfo = {
			object = object ,
			oldParent = object:GetParent() ,
			oldChildren = oldChildren ,
		}
		table.insert(self.objectsInfo , objectInfo)
	end)
	
	-- Cancel if there aren't any selected objects.
	if #self.objectsInfo == 0 then
		self:Cancel()
		return
	end
	
	-- Populate self.properties.
	
	local TestProperty = function(property)
		local IsInObjects = function(propertyValue)
			if propertyValue ~= MapEditor.NoObject then
				local objectId = propertyValue:GetId()
				for index , objectInfo in ipairs(self.objectsInfo) do
					if objectInfo.object:GetId() == objectId then
						return true
					end
				end
			end
			
			return false
		end
		
		if MapEditor.IsObjectType(property.type) then
			if IsInObjects(property.value) then
				table.insert(self.properties , {property = property , originalValue = property.value})
			end
		elseif MapEditor.IsObjectType(property.subtype) then
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
	
	self:Redo()
	self:Confirm()
end

function Actions.Delete:Undo()
	for index , objectInfo in ipairs(self.objectsInfo) do
		local object = objectInfo.object
		-- Recreate the object.
		object:Recreate()
		MapEditor.map:AddObject(object)
		MapEditor.map.selectedObjects:AddObject(object)
		-- Reparent the object's children.
		for index , child in pairs(objectInfo.oldChildren) do
			child:SetParent(object , true)
		end
		-- Reparent the object.
		object:SetParent(objectInfo.oldParent , true)
	end
	
	for index , propertyInfo in ipairs(self.properties) do
		propertyInfo.property:SetValue(propertyInfo.originalValue , propertyInfo.index)
	end
	
	MapEditor.map:UpdatePropertiesMenu()
end

function Actions.Delete:Redo()
	for index , objectInfo in ipairs(self.objectsInfo) do
		local object = objectInfo.object
		-- Remove the object from its parent's children.
		if object:GetParent() ~= MapEditor.NoObject then
			object:SetParent(MapEditor.NoObject , true)
		end
		-- Unparent the object's children.
		object:IterateChildren(function(child)
			child:SetParent(MapEditor.NoObject , true)
		end)
		-- Destroy the object.
		object:Destroy()
		MapEditor.map.selectedObjects:RemoveObject(object)
		MapEditor.map:RemoveObject(object)
	end
	
	for index , propertyInfo in ipairs(self.properties) do
		propertyInfo.property:SetValue(MapEditor.NoObject , propertyInfo.index)
	end
	
	MapEditor.map:UpdatePropertiesMenu()
end
