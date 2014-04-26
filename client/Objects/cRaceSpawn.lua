class("RaceSpawn")

function RaceSpawn:__init() ; MapEditor.Object.__init(self)
	-- Array of Object ids.
	self:SetProperty("vehicles" , {})
end
