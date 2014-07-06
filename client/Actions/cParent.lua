class("Parent" , Actions)

function Actions.Parent:__init() ; MapEditor.Action.__init(self)
	-- Each element is like, {object = Object , originalParent = Object}
	self.objectsInfo = {}
	self.parent = nil
	
	MapEditor.map.selectedObjects:IterateObjects(function(object)
		table.insert(self.objectsInfo , {object = object , originalParent = object:GetParent()})
	end)
	
	MapEditor.ObjectChooser("Object" , self.ObjectChosen , self)
end

function Actions.Parent:Undo()
	for index , objectInfo in ipairs(self.objectsInfo) do
		objectInfo.object:SetParent(objectInfo.originalParent)
	end
	
	MapEditor.map:UpdatePropertiesMenu()
end

function Actions.Parent:Redo()
	for index , objectInfo in ipairs(self.objectsInfo) do
		objectInfo.object:SetParent(self.parent)
	end
	
	MapEditor.map:UpdatePropertiesMenu()
end

function Actions.Parent:ObjectChosen(object)
	if object then
		self.parent = object
		self:Redo()
		self:Confirm()
	else
		self:Cancel()
	end
end
