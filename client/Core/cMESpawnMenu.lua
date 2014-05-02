class("SpawnMenu" , MapEditor)

function MapEditor.SpawnMenu:__init()
	-- Take all class names in the Objects namespace and add them to self.objectNames.
	self.objectNames = {}
	for key , value in pairs(Objects) do
		table.insert(self.objectNames , tostring(key))
	end
	
	self.objectPlacer = nil
	
	self:CreateWindow()
end

function MapEditor.SpawnMenu:CreateWindow()
	local window = Window.Create()
	window:SetTitle("Spawn menu")
	window:SetSize(Vector2(140 , 300))
	window:SetPosition(Vector2(Render.Width - window:GetWidth() - 5 , 200))
	window:SetClosable(false)
	self.window = window
	
	for index , objectName in ipairs(self.objectNames) do
		local button = Button.Create(self.window)
		button:SetPadding(Vector2(8 , 0) , Vector2(8 , 0))
		button:SetMargin(Vector2(0 , 1) , Vector2(0 , 1))
		button:SetDock(GwenPosition.Top)
		button:SetText(Utility.PrettifyVariableName(objectName))
		button:SetDataString("objectName" , objectName)
		button:Subscribe("Press" , self , self.SpawnButtonPressed)
	end
end

function MapEditor.SpawnMenu:SpawnButtonPressed(button)
	local objectName = button:GetDataString("objectName")
	local objectClass = Objects[objectName]
	self.objectPlacer = MapEditor.ObjectPlacer(objectClass)
end
