class("RaceCheckpoint" , Objects)

function Objects.RaceCheckpoint:__init(...) ; MapEditor.Object.__init(self , ...)
	-- Array of vehicle model ids.
	self:AddProperty{
		name = "validVehicles" ,
		type = "table" ,
		subtype = "number" ,
		default = {} ,
	}
	self:AddProperty{
		name = "allowAllVehicles" ,
		type = "boolean" ,
		default = false ,
	}
	self:AddProperty{
		name = "isRespawnable" ,
		type = "boolean" ,
		default = true ,
	}
	self:AddProperty{
		name = "testString" ,
		type = "string" ,
		default = "I'm the default value!" ,
	}
	self:AddProperty{
		name = "testObject" ,
		type = "RaceVehicleInfo" ,
	}
	self:AddProperty{
		name = "testTable" ,
		type = "table" ,
		subtype = "boolean" ,
		default = {true , false , true , false , true} ,
		-- defaultElement = true ,
	}
	
	self.bounds = {Vector3.One * -6 , Vector3.One * 6}
	
	self:OnRecreate()
end

function Objects.RaceCheckpoint:OnRecreate()
	self.ring = ClientParticleSystem.Create(
		AssetLocation.Game ,
		{
			position = self.position ,
			angle = self.angle ,
			path = "fx_race_firering_01.psm" ,
		}
	)
end

function Objects.RaceCheckpoint:OnDestroy()
	self.ring:Remove()
end

function Objects.RaceCheckpoint:OnRender()
	self.ring:SetAngle(Camera:GetAngle())
end

function Objects.RaceCheckpoint:OnPositionChange(position)
	self.ring:SetPosition(position)
end
