class("RaceSpawn" , Objects)

function Objects.RaceSpawn:__init(...) ; MapEditor.Object.__init(self , ...)
	-- Array of Object ids.
	self:AddProperty{
		name = "vehicles" ,
		type = "table" ,
		subtype = "RaceVehicleInfo" ,
		default = {} ,
	}
	
	self.selectionStrategy = {
		type = "Bounds" ,
		bounds = {Vector3(-0.95 , 0 , -2.25) , Vector3(0.95 , 1.45 , 2.25)} ,
	}
	
	self.cursor = MapEditor.Cursor(self.position)
end

function Objects.RaceSpawn:OnRender()
	for index , vehicleInfo in ipairs(self:GetProperty("vehicles").value) do
		if vehicleInfo ~= MapEditor.NoObject then
			Render:DrawLine(self.position , vehicleInfo.position , Color.Gray)
		end
	end
end
