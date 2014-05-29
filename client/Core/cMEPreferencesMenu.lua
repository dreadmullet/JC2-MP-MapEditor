class("PreferencesMenu" , MapEditor)

function MapEditor.PreferencesMenu:__init()
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	self.CreateWindow = MapEditor.PreferencesMenu.CreateWindow
	self.Destroy = MapEditor.PreferencesMenu.Destroy
	self.ResolutionChange = MapEditor.PreferencesMenu.ResolutionChange
	
	self:CreateWindow()
	
	self:ResolutionChange{size = Render.Size}
	
	self:EventSubscribe("ResolutionChange" , MapEditor.PreferencesMenu.ResolutionChange)
end

function MapEditor.PreferencesMenu:CreateWindow()
	local window = Window.Create()
	window:SetTitle("Preferences")
	window:SetSize(Vector2(340 , 380))
	self.window = window
	
	local sliderTextSize = 12
	local sliderTextWidth = Render:GetTextWidth("Camera movement sensitivity: 00.0" , sliderTextSize)
	
	-- Camera movement sensitivity slider
	
	local base = BaseWindow.Create(self.window)
	base:SetMargin(Vector2(2 , 2) , Vector2(2 , 4))
	base:SetDock(GwenPosition.Top)
	base:SetHeight(16)
	
	local slider = HorizontalSlider.Create(base)
	slider:SetDock(GwenPosition.Fill)
	slider:SetRange(0.1 , 1)
	slider:SetValue(MapEditor.Preferences.camSensitivityMove)
	slider:Subscribe("ValueChanged" , self , MapEditor.PreferencesMenu.CamSensitivityMoveSliderChanged)
	self.camSensitivityMoveSlider = slider
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(sliderTextSize)
	label:SetWidth(sliderTextWidth)
	self.camSensitivityMoveLabel = label
	
	self:CamSensitivityMoveSliderChanged()
	
	-- Camera rotation sensitivity slider
	
	local base = BaseWindow.Create(self.window)
	base:SetMargin(Vector2(2 , 2) , Vector2(2 , 4))
	base:SetDock(GwenPosition.Top)
	base:SetHeight(16)
	
	local slider = HorizontalSlider.Create(base)
	slider:SetDock(GwenPosition.Fill)
	slider:SetRange(0.05 , 1)
	slider:SetValue(MapEditor.Preferences.camSensitivityRot)
	slider:Subscribe("ValueChanged" , self , MapEditor.PreferencesMenu.CamSensitivityRotSliderChanged)
	self.camSensitivityRotSlider = slider
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(sliderTextSize)
	label:SetWidth(sliderTextWidth)
	self.camSensitivityRotLabel = label
	
	self:CamSensitivityRotSliderChanged()
	
	-- Bind menu
	
	local label = Label.Create(self.window)
	label:SetMargin(Vector2(0 , 3) , Vector2(24 , 1))
	label:SetDock(GwenPosition.Top)
	label:SetAlignment(GwenPosition.CenterH)
	label:SetTextSize(16)
	label:SetText("Controls")
	label:SizeToContents()
	
	local scrollControl = ScrollControl.Create(self.window)
	scrollControl:SetDock(GwenPosition.Fill)
	scrollControl:SetScrollable(false , true)
	scrollControl:SetAutoHideBars(false)
	
	-- TODO: These should probably be split into different sections.
	local bindMenu = BindMenu.Create(scrollControl)
	bindMenu:SetMargin(Vector2(0 , 0) , Vector2(2 , 0))
	bindMenu:SetDock(GwenPosition.Top)
	bindMenu:SetHeight(460)
	
	bindMenu:AddControl("Move object" ,                      "G")
	bindMenu:AddControl("Rotate object" ,                    "R")
	bindMenu:AddControl("Undo" ,                             "Z")
	bindMenu:AddControl("Redo" ,                             "Y")
	bindMenu:AddControl("Delete" ,                           "X")
	
	-- bindMenu:AddControl("Noclip camera: Toggle" ,            "J")
	-- bindMenu:AddControl("Noclip camera: Forward" ,           "OemComma")
	-- bindMenu:AddControl("Noclip camera: Back" ,              "O")
	-- bindMenu:AddControl("Noclip camera: Left" ,              "A")
	-- bindMenu:AddControl("Noclip camera: Right" ,             "E")
	-- bindMenu:AddControl("Noclip camera: Up" ,                "Space")
	-- bindMenu:AddControl("Noclip camera: Down" ,              "Control")
	-- bindMenu:AddControl("Noclip camera: Increase speed" ,    "Mouse wheel up")
	-- bindMenu:AddControl("Noclip camera: Decrease speed" ,    "Mouse wheel down")
	
	bindMenu:RequestSettings()
	
	self.bindMenu = bindMenu
end

function MapEditor.PreferencesMenu:SetVisible(visible)
	self.window:SetVisible(visible)
end

function MapEditor.PreferencesMenu:GetVisible()
	return self.window:GetVisible()
end

function MapEditor.PreferencesMenu:Destroy()
	self:UnsubscribeAll()
	
	self.bindMenu:Remove()
	self.window:Remove()
end

-- GWEN events

function MapEditor.PreferencesMenu:CamSensitivityMoveSliderChanged()
	local value = self.camSensitivityMoveSlider:GetValue()
	MapEditor.Preferences.camSensitivityMove = value
	self.camSensitivityMoveLabel:SetText(string.format("Camera movement sensitivity: %.1f" , value))
end

function MapEditor.PreferencesMenu:CamSensitivityRotSliderChanged()
	local value = self.camSensitivityRotSlider:GetValue()
	MapEditor.Preferences.camSensitivityRot = value
	self.camSensitivityRotLabel:SetText(string.format("Camera rotation sensitivity: %.2f" , value))
end

-- Events

function MapEditor.PreferencesMenu:ResolutionChange(args)
	local position = Vector2(
		(args.size.x - self.window:GetWidth()) * 0.5 ,
		(args.size.y - self.window:GetHeight()) * 0.4
	)
	self.window:SetPosition(position)
end
