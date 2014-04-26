class("RaceVehicleInfo")

function RaceVehicleInfo:__init() ; MapEditor.Object.__init(self)
	self:SetProperty("modelId" , -1)
	self:SetProperty("templates" , {""})
end
