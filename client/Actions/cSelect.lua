class("Select" , Actions)

function Actions.Select:__init(...) ; Actions.SelectBase.__init(self , ...)
	self.color = Color.LimeGreen
	self.objects = {}
	self.unselectedEverything = false
end

function Actions.Select:OnObjectsChosen(objects)
	self.objects = objects
	-- Remove from the array all objects that are already selected.
	for n = #self.objects , 1 , -1 do
		if self.objects[n]:GetIsSelected() then
			table.remove(self.objects , n)
		end
	end
	
	self:Redo()
	
	self:Confirm()
end

function Actions.Select:OnNothingChosen()
	MapEditor.map:IterateObjects(function(object)
		if object:GetIsSelected() then
			table.insert(self.objects , object)
		end
	end)
	
	self.unselectedEverything = true
	
	self:Redo()
	
	if #self.objects > 0 then
		self:Confirm()
	else
		self:Cancel()
	end
end

function Actions.Select:Undo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(self.unselectedEverything == true)
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.Select:Redo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(self.unselectedEverything == false)
	end
	
	MapEditor.map:SelectionChanged()
end
