class("ModelViewer" , MapEditor)

function MapEditor.ModelViewer:__init()
	MapEditor.modelViewer = self
	
	self.staticObject = nil
	self.archive = nil
	self.model = nil
	self.isVisible = nil
	self.oldCameraPosition = nil
	self.oldCameraAngle = nil
	
	local size = Vector2(280 , Render.Height * 0.25 + 250)
	local position = Vector2(Render.Width - size.x - 5 , Render.Height / 2 - size.y / 2)
	local window = Window.Create()
	window:SetSize(size)
	window:SetPosition(position)
	window:SetTitle("Model viewer")
	window:Subscribe("WindowClosed" , self , self.WindowClosed)
	self.window = window
	
	self.tabControl = TabControl.Create(self.window)
	self.tabControl:SetMargin(Vector2(0 , 0) , Vector2(0 , 6))
	self.tabControl:SetDock(GwenPosition.Fill)
	self.tabs = {
		allModels = ModelViewerTabs.AllModels(self) ,
		-- tags = ModelViewerTabs.Tags(self) ,
		-- recentlyUsed = ModelViewerTabs.RecentlyUsed(self) ,
	}
	
	self:SetVisible(false)
end

function MapEditor.ModelViewer:Destroy()
	self:SetVisible(false)
	self.window:Remove()
end

function MapEditor.ModelViewer:SetVisible(visible)
	if self.isVisible == visible then
		return
	end
	self.isVisible = visible
	
	self.window:SetVisible(visible)
	
	if self.isVisible == true then
		if MapEditor.map ~= nil then
			MapEditor.map.spawnMenu:SetVisible(false)
			
			self.oldCameraPosition = MapEditor.map.camera.position
			self.oldCameraAngle = MapEditor.map.camera.angle
			local newCameraPosition = Copy(self.oldCameraPosition)
			newCameraPosition.y = 2200
			MapEditor.map:SetCameraType("Orbit" , newCameraPosition)
			
			MapEditor.map.controlDisplayers.camera:SetVisible(true)
		end
	else
		if MapEditor.map ~= nil then
			MapEditor.map.spawnMenu:SetVisible(true)
			
			local cameraType = MapEditor.Preferences.camType
			MapEditor.map:SetCameraType(cameraType , self.oldCameraPosition , self.oldCameraAngle)
		end
		
		if self.staticObject ~= nil then
			self.staticObject:Remove()
			self.staticObject = nil
		end
	end
end

function MapEditor.ModelViewer:GetModelPath()
	if self.archive == nil or self.model == nil then
		return nil
	end
	
	return self.archive.."/"..self.model
end

function MapEditor.ModelViewer:SetModelPath(modelPath)
	if modelPath == nil then
		self.archive = nil
		self.model = nil
		return
	end
	
	local result = modelPath:find("/+[^/]*$") -- Find the last '/' in modelPath.
	if result == nil then
		warn("Modelviewer received invalid model path: "..modelPath)
	end
	self.archive = modelPath:sub(1 , result)
	self.model = modelPath:sub(result + 1)
end

function MapEditor.ModelViewer:SpawnStaticObject()
	local model = self:GetModelPath()
	if model == nil then
		return
	end
	
	if self.staticObject ~= nil then
		self.staticObject:Remove()
	end
	
	self.staticObject = ClientStaticObject.Create{
		position = MapEditor.map.camera:GetPosition() ,
		angle = Angle(math.tau/2 , 0 , 0) ,
		model = model ,
	}
end

-- GWEN events

function MapEditor.ModelViewer:WindowClosed()
	self:SetVisible(false)
end
