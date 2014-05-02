class("SelectorBase" , Actions)

function Actions.SelectorBase:__init(mouseButton)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Action.__init(self)
	
	self.mouseButton = mouseButton
	self.downPosition = Mouse:GetPosition()
	self.delta = Vector2(0 , 0)
	-- Inheritors overwrite these.
	self.color = Color.White
	self.objectSelectedFunction = function(object) end
	
	self:EventSubscribe("Render" , Actions.SelectorBase.Render)
	self:EventSubscribe("MouseUp" , Actions.SelectorBase.MouseUp)
end

-- Events

function Actions.SelectorBase:Render()
	self.delta = Mouse:GetPosition() - self.downPosition
	
	MapEditor.Utility.DrawArea(
		self.downPosition ,
		self.delta ,
		4 ,
		self.color
	)
end

function Actions.SelectorBase:MouseUp(args)
	if args.button == self.mouseButton then
		if self.delta:Length() > 16 then
			local pos1 = self.downPosition
			local pos2 = self.downPosition + self.delta
			local left =   math.min(pos1.x , pos2.x)
			local right =  math.max(pos1.x , pos2.x)
			local top =    math.min(pos1.y , pos2.y)
			local bottom = math.max(pos1.y , pos2.y)
			
			-- Iterate through all of the map's objects and call our function on those that are within
			-- the bounds of our selection rectangle.
			-- TODO: This won't scale very well...
			local screenPos , isOnScreen
			MapEditor.map:IterateObjects(function(object)
				screenPos , isOnScreen = Render:WorldToScreen(object:GetPosition())
				if isOnScreen then
					if
						screenPos.x > left and
						screenPos.x < right and
						screenPos.y > top and
						screenPos.y < bottom
					then
						self.objectSelectedFunction(object)
					end
				end
			end)
		end
		
		self:Confirm()
		self:UnsubscribeAll()
	end
end
