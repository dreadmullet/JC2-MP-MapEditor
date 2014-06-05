class("Select" , Actions)

function Actions.Select:__init(...) ; Actions.SelectBase.__init(self , ...)
	self.color = Color.LimeGreen
	self.objects = {}
end

function Actions.Select:OnObjectsChosen(objectsToSelect)
	if Key:IsDown(VirtualKey.Shift) == false then
		MapEditor.map:IterateObjects(function(object)
			local objectId = object:GetId()
			-- Make sure this object isn't already in self.objects.
			for index , existingObject in ipairs(self.objects) do
				if existingObject:GetId() == objectId then
					return
				end
			end
			
			if object:GetIsSelected() then
				table.insert(self.objects , object)
			end
		end)
	end
	
	for index , object in ipairs(objectsToSelect) do
		-- There's a good chance that self.objects will already contain this object, which means it
		-- will be unselected and then selected again. This greatly simplifies the code, trust me.
		table.insert(self.objects , object)
	end
	
	if #self.objects == 0 then
		self:Cancel()
	else
		self:Redo()
		self:Confirm()
	end
end

function Actions.Select:OnNothingChosen()
	if Key:IsDown(VirtualKey.Shift) then
		return
	end
	
	MapEditor.map:IterateObjects(function(object)
		if object:GetIsSelected() then
			table.insert(self.objects , object)
		end
	end)
	
	if #self.objects > 0 then
		self:Confirm()
		self:Redo()
	else
		self:Cancel()
	end
end

function Actions.Select:Undo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(not object:GetIsSelected())
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.Select:Redo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(not object:GetIsSelected())
	end
	
	MapEditor.map:SelectionChanged()
end
