class("Delete" , Actions)

function Actions.Delete:__init()
	MapEditor.Action.__init(self)
	
	self.objects = {}
	MapEditor.map.selectedObjects:IterateObjects(function(object)
		table.insert(self.objects , object)
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
	
	MapEditor.map:SelectionChanged()
end

function Actions.Delete:Redo()
	for index , object in ipairs(self.objects) do
		object:Destroy()
		MapEditor.map.selectedObjects:RemoveObject(object)
		MapEditor.map:RemoveObject(object)
	end
	
	MapEditor.map:SelectionChanged()
end
