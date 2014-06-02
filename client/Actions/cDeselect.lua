class("Deselect" , Actions)

function Actions.Deselect:__init(...) ; Actions.SelectBase.__init(self , ...)
	self.color = Color.DarkRed
	self.objects = {}
end

function Actions.Deselect:OnObjectsChosen(objects)
	self.objects = objects
	-- Remove from the array all objects that aren't selected.
	for n = #self.objects , 1 , -1 do
		if self.objects[n]:GetIsSelected() == false then
			table.remove(self.objects , n)
		end
	end
	
	self:Redo()
	
	self:Confirm()
end

function Actions.Deselect:OnNothingChosen()
	self:Cancel()
end

function Actions.Deselect:Undo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(true)
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.Deselect:Redo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(false)
	end
	
	MapEditor.map:SelectionChanged()
end
