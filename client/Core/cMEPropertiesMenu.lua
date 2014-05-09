class("PropertiesMenu" , MapEditor)

-- Y is relative to height.
MapEditor.PropertiesMenu.position = Vector2(5 , 0.25)
MapEditor.PropertiesMenu.size = Vector2(340 , 210)

function MapEditor.PropertiesMenu:__init(propertyManagers) ; EGUSM.SubscribeUtility.__init(self)
	self.Destroy = MapEditor.PropertiesMenu.Destroy
	
	self.propertyManagers = {}
	for key , propertyManager in pairs(propertyManagers) do
		table.insert(self.propertyManagers , propertyManager)
	end
	
	-- Key: property name (string)
	-- Value: PropertyProprietor
	self.propertyProprietors = {}
	
	self.controls = {}
	
	--
	-- Create window
	--
	
	local window = Window.Create()
	window:SetTitle("Properties menu")
	window:SetSize(MapEditor.PropertiesMenu.size)
	window:Subscribe("Resize" , function() MapEditor.PropertiesMenu.size = self.window:GetSize() end)
	window:Subscribe(
		"Render" ,
		function()
			local position = self.window:GetPosition()
			position.y = position.y / Render.Height
			MapEditor.PropertiesMenu.position = position
		end
	)
	self.window = window
	
	local scrollControl = ScrollControl.Create(self.window)
	scrollControl:SetDock(GwenPosition.Fill)
	scrollControl:SetScrollable(false , true)
	self.scrollControl = scrollControl
	
	self.textSize = 12
	
	self:ResolutionChange({size = Render.Size})
	
	-- Gather a list of common property names.
	-- Key: Property name (string)
	-- Value: array of Propertys
	local propertyMap = {}
	local propertyNameCount = 0
	for index , propertyManager in ipairs(self.propertyManagers) do
		propertyManager:IterateProperties(function(property)
			local existingArray = propertyMap[property.name]
			if existingArray then
				table.insert(existingArray , property)
			else
				propertyMap[property.name] = {property}
				propertyNameCount = propertyNameCount + 1
			end
		end)
	end
	
	local namesToRemove = {}
	-- Filter out Propertys that are not common or have different types or subtypes.
	for propertyName , propertyArray in pairs(propertyMap) do
		local type = propertyArray[1].type
		local subtype = propertyArray[1].subtype
		
		if #propertyArray == #self.propertyManagers then
			for index , property in ipairs(propertyArray) do
				if property.type ~= type or property.subtype ~= subtype then
					table.insert(namesToRemove , propertyName)
					break
				end
			end
		else
			table.insert(namesToRemove , propertyName)
		end
	end
	for index , propertyName in ipairs(namesToRemove) do
		propertyMap[propertyName] = nil
	end
	
	-- Populate self.propertyProprietors.
	for propertyName , propertyArray in pairs(propertyMap) do
		table.insert(self.propertyProprietors , MapEditor.PropertyProprietor(propertyArray))
	end
	table.sort(self.propertyProprietors , function(a , b) return a.name < b.name end)
	
	-- Get self.nameColumnWidth.
	self.nameColumnWidth = 0
	for index , propertyProprietor in ipairs(self.propertyProprietors) do
		local textWidth = Render:GetTextWidth(
			Utility.PrettifyVariableName(propertyProprietor.name) ,
			self.textSize
		)
		if textWidth > self.nameColumnWidth then
			self.nameColumnWidth = textWidth
		end
	end
	self.nameColumnWidth = self.nameColumnWidth + 6
	
	-- Create the property controls.
	for index , propertyProprietor in ipairs(self.propertyProprietors) do
		self:CreatePropertyControl(propertyProprietor)
	end
	
	--
	-- Event subs
	--
	
	self:EventSubscribe("ResolutionChange")
	self:EventSubscribe("ActionStart")
	self:EventSubscribe("ActionEnd")
end

function MapEditor.PropertiesMenu:CreatePropertyControl(propertyProprietor)
	local base = BaseWindow.Create(self.scrollControl)
	base:SetMargin(Vector2(0 , 2) , Vector2(0 , 2))
	base:SetDock(GwenPosition.Top)
	base:SetHeight(0)
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(self.textSize)
	label:SetText(Utility.PrettifyVariableName(propertyProprietor.name))
	label:SizeToContents()
	label:SetMargin(Vector2(0 , 0) , Vector2(self.nameColumnWidth - label:GetWidth() , 0))
	
	self:CreateEditControl(propertyProprietor , base)
	
	return base
end

function MapEditor.PropertiesMenu:CreateEditControl(propertyProprietor , parent , tableIndex)
	local propertyType
	if tableIndex then
		propertyType = propertyProprietor.subtype
	else
		propertyType = propertyProprietor.type
	end
	
	if propertyType == "number" then
		parent:SetHeight(parent:GetHeight() + self.textSize + 6)
		
		local control = TextBoxNumeric.Create(parent)
		control:SetDock(GwenPosition.Fill)
		control:SetDataObject("propertyProprietor" , propertyProprietor)
		if tableIndex then
			control:SetText(tostring(propertyProprietor.value[tableIndex]))
			control:SetDataNumber("tableIndex" , tableIndex)
			control:Subscribe("ReturnPressed" , self , self.TableNumberChanged)
		else
			control:SetText(tostring(propertyProprietor.value))
			control:Subscribe("ReturnPressed" , self , self.NumberChanged)
		end
		
		table.insert(self.controls , control)
		
		return control
	elseif propertyType == "string" then
		parent:SetHeight(parent:GetHeight() + self.textSize + 6)
		
		local textBox = TextBox.Create(parent)
		textBox:SetDock(GwenPosition.Fill)
		textBox:SetTextSize(self.textSize)
		textBox:SetDataObject("propertyProprietor" , propertyProprietor)
		if tableIndex then
			textBox:SetText(propertyProprietor.value[tableIndex])
			textBox:SetDataNumber("tableIndex" , tableIndex)
			textBox:Subscribe("ReturnPressed" , self , self.TableStringChanged)
		else
			textBox:SetText(propertyProprietor.value)
			textBox:Subscribe("ReturnPressed" , self , self.StringChanged)
		end
		
		table.insert(self.controls , textBox)
		
		return textBox
	elseif propertyType == "boolean" then
		parent:SetHeight(parent:GetHeight() + self.textSize + 4)
		
		local button = Button.Create(parent)
		button:SetDock(GwenPosition.Left)
		button:SetWidth(64)
		button:SetTextSize(self.textSize)
		button:SetText("")
		button:SetToggleable(true)
		button:SetDataObject("propertyProprietor" , propertyProprietor)
		if tableIndex then
			button:SetToggleState(propertyProprietor.value[tableIndex])
			button:SetDataNumber("tableIndex" , tableIndex)
			button:Subscribe("Toggle" , self , self.TableBooleanChanged)
		else
			button:SetToggleState(propertyProprietor.value)
			button:Subscribe("Toggle" , self , self.BooleanChanged)
		end
		
		table.insert(self.controls , button)
		
		return button
	elseif propertyType == "table" then
		if tableIndex then
			error("Property value cannot contain nested tables ("..propertyProprietor.name..")")
		end
		
		local base = BaseWindow.Create(parent)
		base:SetMargin(Vector2(0 , 2) , Vector2(0 , 2))
		base:SetDock(GwenPosition.Top)
		base:SetHeight(self.textSize + 6)
		local header = base
		
		local button = Button.Create(base)
		button:SetDock(GwenPosition.Left)
		button:SetTextSize(self.textSize)
		button:SetText("-")
		button:SetWidth(26)
		button:SetDataObject("propertyProprietor" , propertyProprietor)
		button:Subscribe("Press" , self , self.TableRemoveElement)
		table.insert(self.controls , button)
		local buttonRemove = button
		
		local button = Button.Create(base)
		button:SetDock(GwenPosition.Left)
		button:SetTextSize(self.textSize)
		button:SetText("+")
		button:SetWidth(26)
		button:SetDataObject("propertyProprietor" , propertyProprietor)
		button:Subscribe("Press" , self , self.TableAddElement)
		table.insert(self.controls , button)
		local buttonAdd = button
		
		local label = Label.Create(base)
		label:SetMargin(Vector2(4 , 0) , Vector2(0 , 0))
		label:SetDock(GwenPosition.Fill)
		label:SetAlignment(GwenPosition.CenterV)
		label:SetTextSize(self.textSize)
		label:SetText(string.format("%i elements" , #propertyProprietor.value))
		
		local gwenInfo = {}
		gwenInfo.label = label
		gwenInfo.base = parent
		gwenInfo.propertyControls = {}
		
		buttonRemove:SetDataObject("gwenInfo" , gwenInfo)
		buttonAdd:SetDataObject("gwenInfo" , gwenInfo)
		
		local height = base:GetHeight() + 4
		
		for index , value in ipairs(propertyProprietor.value) do
			local base = BaseWindow.Create(parent)
			base:SetMargin(Vector2(54 , 2) , Vector2(0 , 2))
			base:SetDock(GwenPosition.Top)
			base:SetHeight(0)
			self:CreateEditControl(propertyProprietor , base , index)
			
			table.insert(gwenInfo.propertyControls , base)
			
			height = height + base:GetHeight() + 4
		end
		
		parent:SetHeight(parent:GetHeight() + height)
		
		return header
	else -- TODO: Objects
		-- Fall back to just an "(unsupported)" label.
		local label = Label.Create(parent)
		label:SetDock(GwenPosition.Fill)
		label:SetAlignment(GwenPosition.CenterV)
		label:SetTextSize(self.textSize)
		label:SetText("(unsupported)")
		label:SetTextColor(Color.DarkRed)
		label:SizeToContents()
		
		parent:SetHeight(parent:GetHeight() + label:GetHeight() + 2)
		
		return label
	end
end

function MapEditor.PropertiesMenu:Destroy()
	self.window:Remove()
	
	self:UnsubscribeAll()
end

-- GWEN events

function MapEditor.PropertiesMenu:NumberChanged(control)
	local propertyProprietor = control:GetDataObject("propertyProprietor")
	propertyProprietor:SetValue(control:GetValue())
end

function MapEditor.PropertiesMenu:TableNumberChanged(control)
	local propertyProprietor = control:GetDataObject("propertyProprietor")
	local tableIndex = control:GetDataNumber("tableIndex")
	propertyProprietor:SetTableValue(tableIndex , control:GetValue())
end

function MapEditor.PropertiesMenu:StringChanged(textBox)
	local propertyProprietor = textBox:GetDataObject("propertyProprietor")
	propertyProprietor:SetValue(textBox:GetText())
end

function MapEditor.PropertiesMenu:TableStringChanged(textBox)
	local propertyProprietor = textBox:GetDataObject("propertyProprietor")
	local tableIndex = textBox:GetDataNumber("tableIndex")
	propertyProprietor:SetTableValue(tableIndex , textBox:GetText())
end

function MapEditor.PropertiesMenu:BooleanChanged(button)
	local propertyProprietor = button:GetDataObject("propertyProprietor")
	propertyProprietor:SetValue(button:GetToggleState())
end

function MapEditor.PropertiesMenu:TableBooleanChanged(button)
	local propertyProprietor = button:GetDataObject("propertyProprietor")
	local tableIndex = button:GetDataNumber("tableIndex")
	propertyProprietor:SetTableValue(tableIndex , button:GetToggleState())
end

function MapEditor.PropertiesMenu:TableRemoveElement(button)
	local propertyProprietor = button:GetDataObject("propertyProprietor")
	local gwenInfo = button:GetDataObject("gwenInfo")
	
	local propertyCount = #propertyProprietor.value
	
	if propertyCount == 0 then
		return
	end
	
	propertyProprietor:RemoveTableValue(propertyCount)
	
	-- gwenInfo.label:SetText(string.format("%i elements" , propertyCount - 1))
	-- 
	-- gwenInfo.propertyControls[propertyCount]:Hide()
	-- gwenInfo.propertyControls[propertyCount]:Remove()
	-- table.remove(gwenInfo.propertyControls , propertyCount)
	-- 
	-- gwenInfo.base:SetHeight(0)
	-- gwenInfo.base:SizeToChildren(false , true)
end

function MapEditor.PropertiesMenu:TableAddElement(button)
	local propertyProprietor = button:GetDataObject("propertyProprietor")
	local gwenInfo = button:GetDataObject("gwenInfo")
	
	propertyProprietor:AddTableValue()
	
	-- gwenInfo.label:SetText(string.format("%i elements" , #propertyProprietor.value))
	-- 
	-- local base = BaseWindow.Create(gwenInfo.base)
	-- base:SetMargin(Vector2(54 , 2) , Vector2(0 , 2))
	-- base:SetDock(GwenPosition.Top)
	-- base:SetHeight(0)
	-- self:CreateEditControl(propertyProprietor , base , #propertyProprietor.value)
	-- table.insert(gwenInfo.propertyControls , base)
	-- 
	-- gwenInfo.base:SetHeight(0)
	-- gwenInfo.base:SizeToChildren(false , true)
end

-- Events

function MapEditor.PropertiesMenu:ResolutionChange(args)
	local position = MapEditor.PropertiesMenu.position
	self.window:SetPosition(Vector2(position.x , position.y * args.size.y))
end

function MapEditor.PropertiesMenu:ActionStart(actionName)
	for index , control in ipairs(self.controls) do
		control:SetEnabled(false)
	end
end

function MapEditor.PropertiesMenu:ActionEnd(actionName)
	for index , control in ipairs(self.controls) do
		control:SetEnabled(true)
	end
end
