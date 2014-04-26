class("RaceCheckpoint")

function RaceCheckpoint:__init() ; MapEditor.Object.__init(self)
	-- Array of vehicle model ids.
	self:SetProperty("validVehicles" , {})
	self:SetProperty("allowAllVehicles" , false)
	self:SetProperty("isRespawnable" , true)
end
