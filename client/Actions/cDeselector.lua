class("Deselector" , Actions)

function Actions.Deselector:__init(...) ; Actions.SelectorBase.__init(self , ...)
	self.color = Color.DarkRed
	self.objects = {}
end

function Actions.Deselector:ObjectsSelected(objects)
	self.objects = objects
	-- Remove from the array all objects that aren't selected.
	for n = #self.objects , 1 , -1 do
		if MapEditor.map.selectedObjects:HasObject(self.objects[n]) == false then
			table.remove(self.objects , n)
		end
	end
	
	self:Redo()
end

function Actions.Deselector:Undo()
	for index , object in ipairs(self.objects) do
		MapEditor.map.selectedObjects:AddObject(object)
	end
end

function Actions.Deselector:Redo()
	for index , object in ipairs(self.objects) do
		MapEditor.map.selectedObjects:RemoveObject(object)
	end
end
