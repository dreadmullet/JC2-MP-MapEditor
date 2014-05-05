class("PropertiesMenu" , MapEditor)

function MapEditor.PropertiesMenu:__init(object) ; EGUSM.SubscribeUtility.__init(self)
	self.Destroy = MapEditor.PropertiesMenu.Destroy
	
	self.object = object
	
	self:CreateWindow()
	
	self:EventSubscribe("ResolutionChange")
end

function MapEditor.PropertiesMenu:CreateWindow()
	local window = Window.Create()
	window:SetTitle("Properties menu")
	window:SetSize(Vector2(340 , 180))
	self.window = window
	
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
	local base = BaseWindow.Create(self.window)
	base:SetMargin(Vector2(0 , 2) , Vector2(0 , 2))
	base:SetDock(GwenPosition.Top)
	
	base:SetHeight(self.textSize + 2)
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(self.textSize)
	label:SetText(Utility.PrettifyVariableName(property.name))
	label:SizeToContents()
	label:SetMargin(Vector2(0 , 0) , Vector2(self.nameColumnWidth - label:GetWidth() , 0))
	
	if property.type == "number" then
		base:SetHeight(self.textSize + 6)
		
		local control = TextBoxNumeric.Create(base)
		control:SetDock(GwenPosition.Fill)
		control:SetText(tostring(property.value))
		control:SetDataString("propertyName" , property.name)
		control:Subscribe("TextChanged" , self , self.NumberChanged)
	elseif property.type == "string" then
		base:SetHeight(self.textSize + 6)
		
		local textBox = TextBox.Create(base)
		textBox:SetDock(GwenPosition.Fill)
		textBox:SetTextSize(self.textSize)
		textBox:SetText(property.value)
		textBox:SetDataString("propertyName" , property.name)
		textBox:Subscribe("TextChanged" , self , self.StringChanged)
	elseif property.type == "boolean" then
		base:SetHeight(self.textSize + 4)
		
		local button = Button.Create(base)
		button:SetDock(GwenPosition.Left)
		button:SetWidth(64)
		button:SetTextSize(self.textSize)
		button:SetText("")
		button:SetToggleable(true)
		button:SetToggleState(property.value)
		button:SetDataString("propertyName" , property.name)
		button:Subscribe("Toggle" , self , self.BooleanChanged)
	else
		-- Fall back to just an "(unsupported)" label.
		local label = Label.Create(base)
		label:SetDock(GwenPosition.Fill)
		label:SetAlignment(GwenPosition.CenterV)
		label:SetTextSize(self.textSize)
		label:SetText("(unsupported)")
		label:SizeToContents()
	end
	
	return base
end

function MapEditor.PropertiesMenu:Destroy()
	self.window:Remove()
	
	self:UnsubscribeAll()
end

-- GWEN events

function MapEditor.PropertiesMenu:NumberChanged(control)
	local property = self.object:GetProperty(control:GetDataString("propertyName"))
	property.value = control:GetValue()
end

function MapEditor.PropertiesMenu:StringChanged(textBox)
	local property = self.object:GetProperty(textBox:GetDataString("propertyName"))
	property.value = textBox:GetText()
end

-- function MapEditor.PropertiesMenu:StringTableChanged(textBox)
	-- local property = self.object:GetProperty(textBox:GetDataString("propertyName"))
	-- property.value[textBox:GetDataNumber("index")] = textBox:GetText()
-- end

function MapEditor.PropertiesMenu:BooleanChanged(button)
	local property = self.object:GetProperty(button:GetDataString("propertyName"))
	property.value = button:GetToggleState()
end

-- Events

function MapEditor.PropertiesMenu:ResolutionChange(args)
	self.window:SetPosition(Vector2(5 , args.size.y * 0.25))
end
