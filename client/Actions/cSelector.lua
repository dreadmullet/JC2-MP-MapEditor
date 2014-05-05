class("Selector" , Actions)

function Actions.Selector:__init(...) ; Actions.SelectorBase.__init(self , ...)
	self.color = Color.LimeGreen
	self.objects = {}
end

function Actions.Selector:ObjectsSelected(objects)
	self.objects = objects
	-- Remove from the array all objects that are already selected.
	for n = #self.objects , 1 , -1 do
		if self.objects[n]:GetIsSelected() then
			table.remove(self.objects , n)
		end
	end
	
	self:Redo()
end

function Actions.Selector:Undo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(false)
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.Selector:Redo()
	for index , object in ipairs(self.objects) do
		object:SetSelected(true)
	end
	
	MapEditor.map:SelectionChanged()
end
