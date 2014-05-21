class("Deselector" , Actions)

function Actions.Deselector:__init(...) ; Actions.SelectorBase.__init(self , ...)
	self.color = Color.DarkRed
	self.objects = {}
end

function Actions.Deselector:OnObjectsChosen(objects)
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

function Actions.Deselector:OnNothingChosen()
	self:Cancel()
end

function Actions.Deselector:Undo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(true)
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.Deselector:Redo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(false)
	end
	
	MapEditor.map:SelectionChanged()
end
