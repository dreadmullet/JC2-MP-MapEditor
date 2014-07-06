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
	
	-- Cancel if there aren't any selected objects.
	if #self.objects == 0 then
		self:Cancel()
		return
	end
	
	-- Populate self.properties.
	
	local TestProperty = function(property)
		local IsInObjects = function(propertyValue)
			if propertyValue ~= MapEditor.NoObject then
				local objectId = propertyValue:GetId()
				for index , object in ipairs(self.objects) do
					if object:GetId() == objectId then
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
	for index , object in ipairs(self.objects) do
		-- Recreate the object.
		object:Recreate()
		MapEditor.map:AddObject(object)
		MapEditor.map.selectedObjects:AddObject(object)
		-- Reparent the object's children.
		object:IterateChildren(function(child)
			child:SetParent(object)
		end)
		-- Readd the object to its parent's children.
		local parent = object:GetParent()
		if parent ~= MapEditor.NoObject then
			parent:AddChild(object)
		end
	end
	
	for index , propertyInfo in ipairs(self.properties) do
		propertyInfo.property:SetValue(propertyInfo.originalValue , propertyInfo.index)
	end
	
	MapEditor.map:UpdatePropertiesMenu()
end

function Actions.Delete:Redo()
	for index , object in ipairs(self.objects) do
		-- Remove the object from its parent's children.
		local parent = object:GetParent()
		if parent ~= MapEditor.NoObject then
			parent:RemoveChild(object)
		end
		-- Unparent the object's children.
		object:IterateChildren(function(child)
			child:SetParent(MapEditor.NoObject)
			-- Hack. SetParent will remove the child, so add it back so that undo works.
			table.insert(object.children , child)
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
