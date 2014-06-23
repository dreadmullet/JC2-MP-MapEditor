class("RaceVehicleInfo" , Objects)

function Objects.RaceVehicleInfo:__init(...) ; MapEditor.Object.__init(self , ...)
	self:AddProperty{
		name = "modelId" ,
		type = "number" ,
		-- range = {-1 , 91} ,
		default = -1 ,
	}
	self:AddProperty{
		name = "templates" ,
		type = "table" ,
		subtype = "string" ,
		default = {""} ,
	}
	
	self.selectionStrategy = {type = "Icon" , icon = Icons.VehicleInfo}
end
