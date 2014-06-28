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
		name = "nextCheckpoint" ,
		type = "RaceCheckpoint" ,
	}
	
	self.selectionStrategy = {type = "Radius" , radius = 10}
	
	self.timer = Timer()
	
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
	
	-- Render relationship line to our nextCheckpoint.
	local nextCheckpoint = self:GetProperty("nextCheckpoint").value
	if nextCheckpoint ~= MapEditor.NoObject then
		local position = self:GetPosition()
		local direction = (nextCheckpoint:GetPosition() - position):Normalized()
		local distance = Vector3.Distance(nextCheckpoint:GetPosition() , position)
		local lineLength = 30
		local lineSpacing = 15
		local speed = 30
		local offset = (self.timer:GetSeconds() * speed) % (lineLength + lineSpacing)
		
		for n = -lineLength , distance - lineLength , lineLength + lineSpacing do
			Render:DrawLine(
				position + direction * math.clamp(n + offset , 0 , distance) ,
				position + direction * math.min(distance , n + offset + lineLength) ,
				Color.Orange
			)
		end
	end
end

function Objects.RaceCheckpoint:OnPositionChange(position)
	self.ring:SetPosition(position)
end
