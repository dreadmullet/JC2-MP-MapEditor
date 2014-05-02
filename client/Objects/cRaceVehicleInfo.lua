class("RaceVehicleInfo" , Objects)

function Objects.RaceVehicleInfo:__init(...) ; MapEditor.Object.__init(self , ...)
	self:SetProperty("modelId" , -1)
	self:SetProperty("templates" , {""})
end
