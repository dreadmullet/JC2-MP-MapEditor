class("ControlDisplayer" , MapEditor)

function MapEditor.ControlDisplayer:__init(args) ; EGUSM.SubscribeUtility.__init(self)
	self.name = args.name
	self.linesFromBottom = args.linesFromBottom
	-- Each element is a table, {name = "" , control = {}}
	self.controls = {}
	for index , controlName in ipairs(args) do
		self:AddControl(controlName)
	end
	
	self.textSize = 20
	self.x = 0
	self.isVisible = true
	
	self:EventSubscribe("Render")
end

function MapEditor.ControlDisplayer:SetVisible(isVisible)
	self.isVisible = isVisible
end

function MapEditor.ControlDisplayer:AddControl(controlName)
	local control = Controls.Get(controlName)
	if control then
		table.insert(self.controls , {name = control.name , control = control})
	else
		warn("ControlDisplayer can't find control: "..tostring(controlName))
	end
end

function MapEditor.ControlDisplayer:SetControlDisplayedName(controlName , newName)
	for index , controlInfo in ipairs(self.controls) do
		if controlInfo.control.name == controlName then
			controlInfo.name = newName
			break
		end
	end
end

function MapEditor.ControlDisplayer:DrawText(text , color)
	local shadowColor = Color.Black * 0.45
	Render:DrawText(Vector2(self.x - 2 , 2) , text , shadowColor , self.textSize)
	Render:DrawText(Vector2(self.x - 2 , -2) , text , shadowColor , self.textSize)
	Render:DrawText(Vector2(self.x - -2 , 2) , text , shadowColor , self.textSize)
	Render:DrawText(Vector2(self.x - -2 , -2) , text , shadowColor , self.textSize)
	Render:DrawText(Vector2(self.x - 2 , 0) , text , shadowColor , self.textSize)
	Render:DrawText(Vector2(self.x - 0 , 2) , text , shadowColor , self.textSize)
	Render:DrawText(Vector2(self.x - -2 , 0) , text , shadowColor , self.textSize)
	Render:DrawText(Vector2(self.x - 0 , -2) , text , shadowColor , self.textSize)
	
	Render:DrawText(Vector2(self.x , 0) , text , color , self.textSize)
	
	self.x = self.x + Render:GetTextWidth(text , self.textSize)
end

-- Events

function MapEditor.ControlDisplayer:Render()
	if Game:GetState() ~= GUIState.Game or self.isVisible == false then
		return
	end
	
	local transform = Transform2()
	local position = Vector2(
		90 ,
		Render.Height - self.linesFromBottom * (self.textSize + 2)
	)
	transform:Translate(position)
	Render:SetTransform(transform)
	
	self.x = 0
	
	self:DrawText(self.name.."  " , Color(192 , 192 , 192))
	
	for index , controlInfo in ipairs(self.controls) do
		local text = controlInfo.name..": "..controlInfo.control.valueString.."   "
		local color
		if index % 2 == 0 then
			color = Color(255 , 234 , 234)
		else
			color = Color(230 , 234 , 255)
		end
		self:DrawText(text , color)
	end
	
	Render:ResetTransform()
end
