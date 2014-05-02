class("Deleter" , Actions)

function Actions.Deleter:__init()
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

function Actions.Deleter:Undo()
	for index , object in ipairs(self.objects) do
		object:Recreate()
		MapEditor.map:AddObject(object)
		MapEditor.map.selectedObjects:AddObject(object)
	end
end

function Actions.Deleter:Redo()
	for index , object in ipairs(self.objects) do
		object:Destroy()
		MapEditor.map.selectedObjects:RemoveObject(object)
		MapEditor.map:RemoveObject(object)
	end
end
