class("PropertyChange" , Actions)

function Actions.PropertyChange:__init(args)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	self.properties = args.properties
	self.value = args.value
	self.index = args.index
	self.tableActionType = args.tableActionType
	
	self.previousValues = {}
	
	self:Redo()
	
	self:Confirm()
	
	-- local isObject = 
	
	-- if isObject then
		-- self:EventSubscribe("Render")
		-- self:EventSubscribe("MouseUp")
	-- end
end

function Actions.PropertyChange:Undo()
	for index , property in ipairs(self.properties) do
		
		if property.type == "table" then
			if self.tableActionType == "Set" then
				property.value[self.index] = self.previousValues[index]
			elseif self.tableActionType == "Remove" then
				table.insert(property.value , self.index , self.previousValues[index])
			elseif self.tableActionType == "Add" then
				table.remove(property.value , #property.value)
			end
		else
			property.value = self.previousValues[index]
		end
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.PropertyChange:Redo()
	for index , property in ipairs(self.properties) do
		if property.type == "table" then
			if self.tableActionType == "Set" then
				self.previousValues[index] = property.value[self.index]
				property.value[self.index] = self.value
			elseif self.tableActionType == "Remove" then
				self.previousValues[index] = property.value[self.index]
				table.remove(property.value , self.index)
			elseif self.tableActionType == "Add" then
				table.insert(property.value , property.defaultElement)
			end
		else
			self.previousValues[index] = property.value
			property.value = self.value
		end
	end
	
	MapEditor.map:SelectionChanged()
end

-- Events

-- function Actions.PropertyChange:Render()
	
-- end

-- function Actions.PropertyChange:MouseUp(args)
	-- if args.button == 1 then
		-- self:UnsubscribeAll()
		-- self:Confirm()
	-- elseif args.button == 2 then
		-- self:Undo()
		
		-- self:UnsubscribeAll()
		-- self:Cancel()
	-- end
-- end
