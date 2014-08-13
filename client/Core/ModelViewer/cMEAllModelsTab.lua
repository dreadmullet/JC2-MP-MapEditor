class("AllModels" , ModelViewerTabs)

function ModelViewerTabs.AllModels:__init(modelViewer)
	self.modelViewer = modelViewer
	
	self.colors = {
		modelRow =                 Color(136 , 136 , 136 , 26) ,
		modelText =                Color(216 , 216 , 216 , 255) ,
		modelTextHovered =         Color(240 , 240 , 240 , 255) ,
		modelTextSelected =        Color(240 , 234 , 172 , 255) ,
		modelTextSelectedHovered = Color(255 , 238 , 168 , 255) ,
	}
	
	self.page = self.modelViewer.tabControl:AddPage("All models"):GetPage()
	
	self.selectedModelButton = nil
	
	-- If this uses a Tree like the modelviewer script does, it uses 500MB of memory and lags like
	-- crazy. This is because it creates thousands of controls for each model. This solution loads
	-- the archive names but only loads each archive's models when the archive is expanded.
	local scrollControl = ScrollControl.Create(self.page)
	scrollControl:SetDock(GwenPosition.Fill)
	scrollControl:SetScrollable(false , true)
	
	for index , archiveEntry in ipairs(MapEditor.modelList) do
		local archive = archiveEntry[1]
		local models = archiveEntry[2]
		
		local button = LabelClickable.Create(scrollControl)
		button:SetAlignment(GwenPosition.CenterV)
		button:SetDock(GwenPosition.Top)
		button:SetText(string.format("(%d) %s" , #models , archive))
		button:SizeToContents()
		button:SetHeight(button:GetHeight() + 4)
		button:SetDataString("archive" , archive)
		button:SetDataBool("hasLoadedModels" , false)
		button:Subscribe("Press" , self , self.ArchiveSelected)
		
		local modelsContainer = Rectangle.Create(scrollControl)
		modelsContainer:SetMargin(Vector2(24 , 0) , Vector2(0 , 0))
		modelsContainer:SetDock(GwenPosition.Top)
		modelsContainer:SetColor(self.colors.modelRow)
		modelsContainer:SetVisible(false)
		
		button:SetDataObject("modelsContainer" , modelsContainer)
	end
end

-- GWEN events

function ModelViewerTabs.AllModels:ArchiveSelected(archiveButton)
	self.modelViewer.archive = archiveButton:GetDataString("archive")
	local hasLoadedModels = archiveButton:GetDataBool("hasLoadedModels")
	local modelsContainer = archiveButton:GetDataObject("modelsContainer")
	
	if hasLoadedModels == false then
		local models = MapEditor.modelList[self.modelViewer.archive]
		
		local buttonHeight = 16
		
		for index , model in ipairs(models) do
			local button = LabelClickable.Create(modelsContainer)
			button:SetDock(GwenPosition.Top)
			button:SetText(model)
			button:SetHeight(buttonHeight)
			button:SetTextNormalColor(self.colors.modelText)
			button:SetTextHoveredColor(self.colors.modelTextHovered)
			button:SetDataString("model" , model)
			button:Subscribe("Press" , self , self.ModelSelected)
		end
		
		modelsContainer:SetHeight(#models * buttonHeight)
		
		archiveButton:SetDataBool("hasLoadedModels" , true)
	end
	
	modelsContainer:SetVisible(not modelsContainer:GetVisible())
end

function ModelViewerTabs.AllModels:ModelSelected(modelButton)
	if self.selectedModelButton ~= nil then
		self.selectedModelButton:SetTextNormalColor(self.colors.modelText)
		self.selectedModelButton:SetTextHoveredColor(self.colors.modelTextHovered)
		self.selectedModelButton:SetTextColor(self.colors.modelText)
	end
	
	modelButton:SetTextNormalColor(self.colors.modelTextSelected)
	modelButton:SetTextHoveredColor(self.colors.modelTextSelectedHovered)
	self.selectedModelButton = modelButton
	
	self.modelViewer.model = modelButton:GetDataString("model")
	
	self.modelViewer:SpawnStaticObject()
end
