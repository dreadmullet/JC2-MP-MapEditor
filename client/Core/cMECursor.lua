class("Cursor" , MapEditor)

function MapEditor.Cursor:__init(initialPosition) ; EGUSM.SubscribeUtility.__init(self)
	self.position = initialPosition or Vector3(0 , 208 , 0)
	self.angle = Angle()
	self.cursorModel = nil
	
	local args = {
		path = "Models/Cursor"
	}
	OBJLoader.Request(args , self , function(self , model) self.cursorModel = model end)
	
	self:EventSubscribe("Render")
end

-- Events

function MapEditor.Cursor:Render()
	if self.cursorModel then
		local transform = Transform3()
		transform:Translate(self.position)
		transform:Rotate(self.angle)
		Render:SetTransform(transform)
		
		self.cursorModel:Draw()
		
		Render:ResetTransform()
	end
end
