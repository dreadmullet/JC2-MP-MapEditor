class("RaceCheckpoint" , Objects)

function Objects.RaceCheckpoint:__init(...) ; MapEditor.Object.__init(self , ...)
	-- Array of vehicle model ids.
	self:SetProperty("validVehicles" , {})
	self:SetProperty("allowAllVehicles" , false)
	self:SetProperty("isRespawnable" , true)
	
	self.bounds = {Vector3.One * -6 , Vector3.One * 6}
	
	self.ring = ClientParticleSystem.Create(
		AssetLocation.Game ,
		{
			position = self.position ,
			angle = self.angle ,
			path = "fx_race_firering_01.psm" ,
		}
	)
end

function Objects.RaceCheckpoint:OnRender()
	self.ring:SetAngle(Camera:GetAngle())
end

function Objects.RaceCheckpoint:OnPositionChange(position)
	self.ring:SetPosition(position)
end

function Objects.RaceCheckpoint:OnDestroy()
	self.ring:Remove()
end
