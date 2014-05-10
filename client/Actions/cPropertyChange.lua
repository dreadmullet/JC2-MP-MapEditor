class("PropertyChange" , Actions)

function Actions.PropertyChange:__init(args)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	self.properties = args.properties
	self.value = args.value
	self.index = args.index
	self.tableActionType = args.tableActionType
	if self.index then
		self.type = self.properties[1].subtype
	else
		self.type = self.properties[1].type
	end
	
	self.previousValues = {}
	self.oldButtonText = nil
	self.newButtonText = nil
	
	self.objectClass = Objects[self.type] ~= nil
	
	if self.objectClass and self.tableActionType ~= "Add" and self.tableActionType ~= "Remove" then
		Events:Fire("SetMenusEnabled" , false)
		-- Reusing self.value like this is questionable but makes it really convenient.
		self.objectChooseButton = self.value
		self.value = nil
		
		self.oldButtonText = self.objectChooseButton:GetText()
		
		self:EventSubscribe("Render")
		self:EventSubscribe("MouseUp")
	else
		self:Apply()
		self:Confirm()
	end
end

function Actions.PropertyChange:Apply()
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
	
	if IsValid(self.objectChooseButton) then
		self.objectChooseButton:SetText(self.oldButtonText)
	end
	
	MapEditor.map:SelectionChanged()
end

function Actions.PropertyChange:Redo()
	self:Apply()
	
	if IsValid(self.objectChooseButton) then
		self.objectChooseButton:SetText(self.newButtonText)
	end
	
	MapEditor.map:SelectionChanged()
end

-- Events

function Actions.PropertyChange:Render()
	-- Draw a simple cursor thing on the mouse.
	local mousePos = Mouse:GetPosition()
	local size = 60
	Render:DrawLine(
		mousePos + Vector2(-size , 0) ,
		mousePos + Vector2(size , 0) ,
		Color(127 , 127 , 127 , 127)
	)
	Render:DrawLine(
		mousePos + Vector2(0 , -size) ,
		mousePos + Vector2(0 , size) ,
		Color(127 , 127 , 127 , 127)
	)
end

function Actions.PropertyChange:MouseUp(args)
	if args.button == 1 then
		local object = MapEditor.map:GetObjectFromScreenPoint(Mouse:GetPosition())
		if object and class_info(object).name == self.type then
			self.value = object
			self:Apply()
			
			self.newButtonText = string.format("Object: %s (id: %i)" , self.type , object:GetId())
			self.objectChooseButton:SetText(self.newButtonText)
			
			self:UnsubscribeAll()
			self:Confirm()
		else
			self.value = MapEditor.Property.NoObject
			self:Apply()
			
			self.newButtonText = string.format("Object: (None)")
			self.objectChooseButton:SetText(self.newButtonText)
			
			self:UnsubscribeAll()
			self:Confirm()
		end
		
		Events:Fire("SetMenusEnabled" , true)
	elseif args.button == 2 then
		self:UnsubscribeAll()
		self:Cancel()
		
		Events:Fire("SetMenusEnabled" , true)
	end
end
