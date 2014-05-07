class("PropertiesMenu" , MapEditor)

-- Y is relative to height.
MapEditor.PropertiesMenu.position = Vector2(5 , 0.25)
MapEditor.PropertiesMenu.size = Vector2(340 , 210)

function MapEditor.PropertiesMenu:__init(object) ; EGUSM.SubscribeUtility.__init(self)
	self.Destroy = MapEditor.PropertiesMenu.Destroy
	
	self.object = object
	
	self:CreateWindow()
	
	self:EventSubscribe("ResolutionChange")
end

function MapEditor.PropertiesMenu:CreateWindow()
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
	
	propertiesSorted = {}
	self.nameColumnWidth = 0
	self.object:IterateProperties(function(property)
		table.insert(propertiesSorted , property)
		local textWidth = Render:GetTextWidth(
			Utility.PrettifyVariableName(property.name) ,
			self.textSize
		)
		if textWidth > self.nameColumnWidth then
			self.nameColumnWidth = textWidth
		end
	end)
	table.sort(propertiesSorted , function(a , b) return a.name < b.name end)
	
	self.nameColumnWidth = self.nameColumnWidth + 6
	
	for index , property in ipairs(propertiesSorted) do
		self:CreatePropertyControl(property)
	end
end

function MapEditor.PropertiesMenu:CreatePropertyControl(property)
	local base = BaseWindow.Create(self.scrollControl)
	base:SetMargin(Vector2(0 , 2) , Vector2(0 , 2))
	base:SetDock(GwenPosition.Top)
	base:SetHeight(0)
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(self.textSize)
	label:SetText(Utility.PrettifyVariableName(property.name))
	label:SizeToContents()
	label:SetMargin(Vector2(0 , 0) , Vector2(self.nameColumnWidth - label:GetWidth() , 0))
	
	self:CreateEditControl(property , base)
	
	return base
end

function MapEditor.PropertiesMenu:CreateEditControl(property , parent , tableIndex)
	local propertyType
	if tableIndex then
		propertyType = property.subtype
	else
		propertyType = property.type
	end
	
	if propertyType == "number" then
		parent:SetHeight(parent:GetHeight() + self.textSize + 6)
		
		local control = TextBoxNumeric.Create(parent)
		control:SetDock(GwenPosition.Fill)
		control:SetDataObject("property" , property)
		if tableIndex then
			control:SetText(tostring(property.value[tableIndex]))
			control:SetDataNumber("tableIndex" , tableIndex)
			control:Subscribe("TextChanged" , self , self.TableNumberChanged)
		else
			control:SetText(tostring(property.value))
			control:Subscribe("TextChanged" , self , self.NumberChanged)
		end
		
		return control
	elseif propertyType == "string" then
		parent:SetHeight(parent:GetHeight() + self.textSize + 6)
		
		local textBox = TextBox.Create(parent)
		textBox:SetDock(GwenPosition.Fill)
		textBox:SetTextSize(self.textSize)
		textBox:SetDataObject("property" , property)
		if tableIndex then
			textBox:SetText(property.value[tableIndex])
			textBox:SetDataNumber("tableIndex" , tableIndex)
			textBox:Subscribe("TextChanged" , self , self.TableStringChanged)
		else
			textBox:SetText(property.value)
			textBox:Subscribe("TextChanged" , self , self.StringChanged)
		end
		
		return textBox
	elseif propertyType == "boolean" then
		parent:SetHeight(parent:GetHeight() + self.textSize + 4)
		
		local button = Button.Create(parent)
		button:SetDock(GwenPosition.Left)
		button:SetWidth(64)
		button:SetTextSize(self.textSize)
		button:SetText("")
		button:SetToggleable(true)
		button:SetDataObject("property" , property)
		if tableIndex then
			button:SetToggleState(property.value[tableIndex])
			button:SetDataNumber("tableIndex" , tableIndex)
			button:Subscribe("Toggle" , self , self.TableBooleanChanged)
		else
			button:SetToggleState(property.value)
			button:Subscribe("Toggle" , self , self.BooleanChanged)
		end
		
		return button
	elseif propertyType == "table" then
		if tableIndex then
			error("Property value cannot contain nested tables ("..property.name..")")
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
		button:SetDataObject("property" , property)
		button:Subscribe("Press" , self , self.TableRemoveElement)
		local buttonRemove = button
		
		local button = Button.Create(base)
		button:SetDock(GwenPosition.Left)
		button:SetTextSize(self.textSize)
		button:SetText("+")
		button:SetWidth(26)
		button:SetDataObject("property" , property)
		button:Subscribe("Press" , self , self.TableAddElement)
		local buttonAdd = button
		
		local label = Label.Create(base)
		label:SetMargin(Vector2(4 , 0) , Vector2(0 , 0))
		label:SetDock(GwenPosition.Fill)
		label:SetAlignment(GwenPosition.CenterV)
		label:SetTextSize(self.textSize)
		label:SetText(string.format("%i elements" , #property.value))
		
		local gwenInfo = {}
		gwenInfo.label = label
		gwenInfo.base = parent
		gwenInfo.propertyControls = {}
		
		buttonRemove:SetDataObject("gwenInfo" , gwenInfo)
		buttonAdd:SetDataObject("gwenInfo" , gwenInfo)
		
		local height = base:GetHeight() + 4
		
		for index , value in ipairs(property.value) do
			local base = BaseWindow.Create(parent)
			base:SetMargin(Vector2(54 , 2) , Vector2(0 , 2))
			base:SetDock(GwenPosition.Top)
			base:SetHeight(0)
			self:CreateEditControl(property , base , index)
			
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
	local property = control:GetDataObject("property")
	property.value = control:GetValue()
end

function MapEditor.PropertiesMenu:TableNumberChanged(control)
	local property = control:GetDataObject("property")
	local tableIndex = control:GetDataNumber("tableIndex")
	property.value[tableIndex] = control:GetValue()
end

function MapEditor.PropertiesMenu:StringChanged(textBox)
	local property = textBox:GetDataObject("property")
	property.value = textBox:GetText()
end

function MapEditor.PropertiesMenu:TableStringChanged(textBox)
	local property = textBox:GetDataObject("property")
	local tableIndex = textBox:GetDataNumber("tableIndex")
	property.value[tableIndex] = textBox:GetText()
end

function MapEditor.PropertiesMenu:BooleanChanged(button)
	local property = button:GetDataObject("property")
	property.value = button:GetToggleState()
end

function MapEditor.PropertiesMenu:TableBooleanChanged(button)
	local property = button:GetDataObject("property")
	local tableIndex = button:GetDataNumber("tableIndex")
	property.value[tableIndex] = button:GetToggleState()
end

function MapEditor.PropertiesMenu:TableRemoveElement(button)
	local property = button:GetDataObject("property")
	local gwenInfo = button:GetDataObject("gwenInfo")
	
	local propertyCount = #property.value
	
	if propertyCount == 0 then
		return
	end
	
	table.remove(property.value , propertyCount)
	
	gwenInfo.label:SetText(string.format("%i elements" , propertyCount - 1))
	
	gwenInfo.propertyControls[propertyCount]:Hide()
	gwenInfo.propertyControls[propertyCount]:Remove()
	table.remove(gwenInfo.propertyControls , propertyCount)
	
	gwenInfo.base:SetHeight(0)
	gwenInfo.base:SizeToChildren(false , true)
end

function MapEditor.PropertiesMenu:TableAddElement(button)
	local property = button:GetDataObject("property")
	local gwenInfo = button:GetDataObject("gwenInfo")
	
	table.insert(property.value , property.defaultElement)
	
	gwenInfo.label:SetText(string.format("%i elements" , #property.value))
	
	local base = BaseWindow.Create(gwenInfo.base)
	base:SetMargin(Vector2(54 , 2) , Vector2(0 , 2))
	base:SetDock(GwenPosition.Top)
	base:SetHeight(0)
	self:CreateEditControl(property , base , #property.value)
	table.insert(gwenInfo.propertyControls , base)
	
	gwenInfo.base:SetHeight(0)
	gwenInfo.base:SizeToChildren(false , true)
end

-- Events

function MapEditor.PropertiesMenu:ResolutionChange(args)
	local position = MapEditor.PropertiesMenu.position
	self.window:SetPosition(Vector2(position.x , position.y * args.size.y))
end
