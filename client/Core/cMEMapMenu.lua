class("MapMenu" , MapEditor)

function MapEditor.MapMenu:__init() ; EGUSM.SubscribeUtility.__init(self)
	self.Destroy = MapEditor.MapMenu.Destroy
	
	self:CreateWindow()
	
	self:EventSubscribe("ResolutionChange")
	self:EventSubscribe("SetMenusEnabled")
end

function MapEditor.MapMenu:CreateWindow()
	local window = Window.Create()
	window:SetTitle("Map menu")
	window:SetSize(Vector2(308 , 58))
	window:SetClosable(false)
	self.window = window
	
	self:ResolutionChange({size = Render.Size})
	
	self.buttons = {}
	
	local buttonNames = {
		"Properties" ,
		"Save" ,
		"Load" ,
		"Validate" ,
		"Test" ,
	}
	for index , buttonName in ipairs(buttonNames) do
		local button = Button.Create(self.window)
		button:SetPadding(Vector2(8 , 5) , Vector2(8 , 5))
		button:SetMargin(Vector2(1 , 0) , Vector2(1 , 0))
		button:SetDock(GwenPosition.Left)
		button:SetText(buttonName)
		button:SizeToContents()
		button:SetDataString("name" , buttonName)
		button:Subscribe("Press" , self , self.ButtonPressed)
		self.buttons[buttonName] = button
	end
end

function MapEditor.MapMenu:Destroy()
	self:UnsubscribeAll()
	self.window:Remove()
end

function MapEditor.MapMenu:SetEnabled(enabled)
	for index , button in pairs(self.buttons) do
		button:SetEnabled(enabled)
	end
end

-- GWEN events

function MapEditor.MapMenu:ButtonPressed(button)
	local name = button:GetDataString("name")
	
	if name == "Properties" then
		MapEditor.map:OpenMapProperties()
	elseif name == "Save" then
		
	elseif name == "Load" then
		
	elseif name == "Validate" then
		-- TODO: It should focus on the source Object of the error.
		local successOrError = MapEditor.map.mapType.Validate(MapEditor.map)
		-- TODO: This should be a popup or something.
		if successOrError == true then
			Chat:Print("Validation successful" , Color(165 , 250 , 160))
		else
			Chat:Print("Validation failed: "..successOrError , Color(250 , 160 , 160))
		end
	elseif name == "Test" then
		MapEditor.map:Test()
	end
end

-- Events

function MapEditor.MapMenu:ResolutionChange(args)
	self.window:SetPosition(Vector2((args.size.x - self.window:GetWidth()) * 0.5 , 5))
end

function MapEditor.MapMenu:SetMenusEnabled(enabled)
	self:SetEnabled(enabled)
end
