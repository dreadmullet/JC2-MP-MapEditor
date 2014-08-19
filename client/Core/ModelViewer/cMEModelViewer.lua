MapEditor.modelNames = {}

class("ModelViewer" , MapEditor)

function MapEditor.ModelViewer:__init()
	MapEditor.modelViewer = self
	
	self.staticObject = nil
	self.modelPath = nil
	self.isVisible = nil
	self.oldCameraPosition = nil
	self.oldCameraAngle = nil
	
	-- Window
	
	local size = Vector2(180 + Render.Width * 0.125 , 250 + Render.Height * 0.25)
	local position = Vector2(Render.Width - size.x - 5 , Render.Height / 2 - size.y / 2)
	local window = Window.Create()
	window:SetSize(size)
	window:SetPosition(position)
	window:SetTitle("Model viewer")
	window:Subscribe("WindowClosed" , self , self.WindowClosed)
	self.window = window
	
	-- Tab control
	
	self.tabControl = TabControl.Create(self.window)
	self.tabControl:SetMargin(Vector2(0 , 0) , Vector2(0 , 4))
	self.tabControl:SetDock(GwenPosition.Fill)
	self.tabs = {
		allModels = ModelViewerTabs.AllModels(self) ,
		tags = ModelViewerTabs.Tags(self) ,
		-- recentlyUsed = ModelViewerTabs.RecentlyUsed(self) ,
	}
	
	local slightlyLargeFontSize = 16
	local labelWidth = 60
	
	-- Tag textbox
	
	local base = BaseWindow.Create(self.window)
	base:SetMargin(Vector2(0 , 2) , Vector2(2 , 2))
	base:SetDock(GwenPosition.Bottom)
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(slightlyLargeFontSize)
	label:SetText("Tags: ")
	label:SizeToContents()
	label:SetWidth(labelWidth)
	
	local textBox = TextBox.Create(base)
	textBox:SetDock(GwenPosition.Fill)
	textBox:SetText("")
	textBox:SetEnabled(false)
	textBox:Subscribe("Blur" , self , self.TagsTextBoxChanged)
	self.tagsTextBox = textBox
	
	base:SetHeight(slightlyLargeFontSize + 2)
	
	-- Name textbox
	
	local base = BaseWindow.Create(self.window)
	base:SetMargin(Vector2(0 , 2) , Vector2(2 , 2))
	base:SetDock(GwenPosition.Bottom)
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(slightlyLargeFontSize)
	label:SetText("Name: ")
	label:SizeToContents()
	label:SetWidth(labelWidth)
	
	local textBox = TextBox.Create(base)
	textBox:SetDock(GwenPosition.Fill)
	textBox:SetText("")
	textBox:SetEnabled(false)
	textBox:Subscribe("Blur" , self , self.NameTextBoxChanged)
	self.nameTextBox = textBox
	
	base:SetHeight(slightlyLargeFontSize + 2)
	
	-- Model label
	
	local base = BaseWindow.Create(self.window)
	base:SetMargin(Vector2(0 , 2) , Vector2(0 , 2))
	base:SetDock(GwenPosition.Bottom)
	
	local label = Label.Create(base)
	label:SetMargin(Vector2(0 , 0) , Vector2(2 , 0))
	label:SetDock(GwenPosition.Left)
	label:SetAlignment(GwenPosition.CenterV)
	label:SetTextSize(slightlyLargeFontSize)
	label:SetText("Model: ")
	label:SizeToContents()
	label:SetWidth(labelWidth)
	
	local label = Label.Create(base)
	label:SetDock(GwenPosition.Fill)
	label:SetAlignment(bit32.bor(GwenPosition.CenterV , GwenPosition.Right))
	label:SetText("[None]")
	self.modelLabel = label
	
	base:SetHeight(slightlyLargeFontSize)
	
	-- Misc
	
	self:SetVisible(false)
	
	Network:Subscribe("ReceiveModelNames" , self , self.ReceiveModelNames)
	
	Network:Send("RequestModelNames" , ".")
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
	return self.modelPath
end

function MapEditor.ModelViewer:SetModelPath(modelPath)
	self.modelPath = modelPath
	-- Get the model's tags and set the text of the tags textbox.
	if self.modelPath ~= nil then
		self.nameTextBox:SetEnabled(true)
		self.nameTextBox:SetText(MapEditor.modelNames[self.modelPath] or "")
		
		self.tagsTextBox:SetEnabled(true)
		local tags = MapEditor.modelToTags[self.modelPath]
		if tags ~= nil then
			local text = table.concat(tags , ", ")
			self.tagsTextBox:SetText(text)
		else
			self.tagsTextBox:SetText("")
		end
	else
		self.nameTextBox:SetEnabled(false)
		self.nameTextBox:SetText("")
		
		self.tagsTextBox:SetEnabled(false)
		self.tagsTextBox:SetText("")
	end
end

function MapEditor.ModelViewer:SpawnStaticObject()
	local model = self:GetModelPath()
	if model == nil then
		return
	end
	
	self.modelLabel:SetText(model)
	
	if self.staticObject ~= nil then
		self.staticObject:Remove()
	end
	
	self.staticObject = ClientStaticObject.Create{
		position = MapEditor.map.camera:GetPosition() ,
		angle = Angle(math.tau/2 , 0 , 0) ,
		model = model ,
	}
end

-- Network events

function MapEditor.ModelViewer:ReceiveModelNames(modelNames)
	MapEditor.modelNames = modelNames
end

-- GWEN events

function MapEditor.ModelViewer:WindowClosed()
	self:SetVisible(false)
end

function MapEditor.ModelViewer:NameTextBoxChanged()
	local args = {model = self.modelPath , name = self.nameTextBox:GetText()}
	
	MapEditor.modelNames[args.model] = args.name
	
	self.tabs.allModels:SetModelName(args)
	self.tabs.tags:SetModelName(args)
	
	Network:Send("SetModelName" , args)
end

function MapEditor.ModelViewer:TagsTextBoxChanged()
	-- Get and clean the text.
	local text = self.tagsTextBox:GetText()
	text = text:gsub(", " , ",")
	text = text:gsub(" ," , ",")
	-- Get the newTags array.
	local newTags = text:split("," , true)
	if newTags[#newTags] == "" then
		table.remove(newTags)
	end
	-- Get the existingTags array.
	local existingTags = MapEditor.modelToTags[self.modelPath]
	-- If it doesn't exist yet, create it.
	if existingTags == nil then
		existingTags = {}
		MapEditor.modelToTags[self.modelPath] = existingTags
	end
	-- Find any tags in existingTags that aren't in newTags and remove them.
	for index = #existingTags , 1 , -1 do
		local tag = existingTags[index]
		if table.find(newTags , tag) == nil then
			-- Remove the tag from MapEditor.modelToTags[self.modelPath].
			table.remove(existingTags , index)
			-- Remove self.modelPath from MapEditor.taggedModels[tag].
			local models = MapEditor.taggedModels[tag]
			for index , model in ipairs(models) do
				if model == self.modelPath then
					table.remove(models , index)
					break
				end
			end
			-- If no more models have this tag, remove the tag entry from MapEditor.taggedModels.
			if #models == 0 then
				MapEditor.taggedModels[tag] = nil
				for index , tagEntry in ipairs(MapEditor.taggedModels) do
					if tagEntry[1] == tag then
						table.remove(MapEditor.taggedModels , index)
						break
					end
				end
			end
			-- Remove the model button from the tags tab.
			self.tabs.tags:RemoveModelButton{
				tag = tag ,
				model = self.modelPath ,
				removeTag = #models == 0 ,
			}
			-- Tell the server-side to remove the model's tag.
			Network:Send("TaggedModelRemove" , {tag = tag , model = self.modelPath})
		end
	end
	-- Find any tags in newTags that aren't in existingTags and add them.
	for index , tag in ipairs(newTags) do
		if table.find(existingTags , tag) == nil then
			-- Add the tag to MapEditor.modelToTags[self.modelPath].
			table.insert(existingTags , tag)
			-- If this is the first model with this tag, add an entry to MapEditor.taggedModels.
			local models = MapEditor.taggedModels[tag]
			if models == nil then
				models = {}
				local newEntry = {tag , models}
				table.insert(MapEditor.taggedModels , newEntry)
				
				MapEditor.taggedModels[tag] = models
			end
			-- Add self.modelPath to MapEditor.taggedModels[tag].
			table.insert(models , self.modelPath)
			-- Add the model button to the tags tab.
			self.tabs.tags:AddModelButton{tag = tag , model = self.modelPath}
			self.tabs.tags:UpdateTag(tag)
			-- Tell the server-side to add the model's tag.
			Network:Send("TaggedModelAdd" , {tag = tag , model = self.modelPath})
		end
	end
end
