class("Light" , Objects)

function Objects.Light:__init(...) ; MapEditor.Object.__init(self , ...)
	self.isClientSide = true
	
	self:AddProperty{
		name = "radius" ,
		type = "number" ,
		default = 12 ,
	}
	self:AddProperty{
		name = "multiplier" ,
		type = "number" ,
		default = 2 ,
	}
	self:AddProperty{
		name = "color" ,
		type = "Color" ,
		default = Color(255 , 255 , 255) ,
	}
	self:AddProperty{
		name = "attenuationConstant" ,
		type = "number" ,
		default = 0 ,
	}
	self:AddProperty{
		name = "attenuationLinear" ,
		type = "number" ,
		default = 0 ,
	}
	self:AddProperty{
		name = "attenuationQuadratic" ,
		type = "number" ,
		default = 1 ,
	}
	
	self.selectionStrategy = {type = "Icon" , icon = Icons.Light}
	
	self:OnRecreate()
end

function Objects.Light:OnRecreate()
	self.light = ClientLight.Create{
		position = self:GetPosition() ,
		color = self:GetProperty("color").value ,
		multiplier = self:GetProperty("multiplier").value ,
		radius = self:GetProperty("radius").value ,
		constant_attenuation = self:GetProperty("attenuationConstant").value ,
		linear_attenuation = self:GetProperty("attenuationLinear").value ,
		quadratic_attenuation = self:GetProperty("attenuationQuadratic").value ,
	}
end

function Objects.Light:OnDestroy()
	self.light:Remove()
end

function Objects.Light:OnPositionChange(position)
	self.light:SetPosition(position)
end

function Objects.Light:OnPropertyChange(args)
	-- Luabuse is fun
	self.light[({
		color = "SetColor" ,
		multiplier = "SetMultiplier" ,
		radius = "SetRadius" ,
		attenuationConstant = "SetConstantAttenuation" ,
		attenuationLinear = "SetLinearAttenuation" ,
		attenuationQuadratic = "SetQuadraticAttenuation" ,
	})[args.name]](self.light , args.newValue)
end
