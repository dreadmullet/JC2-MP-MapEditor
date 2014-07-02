class("Array" , Objects)

function Objects.Array:__init(...)
	EGUSM.SubscribeUtility.__init(self)
	MapEditor.Object.__init(self , ...)
	
	self:AddProperty{
		name = "sourceObject" ,
		type = "Object" ,
	}
	self:AddProperty{
		name = "count" ,
		type = "number" ,
	}
	-- Global position offsets
	self:AddProperty{
		name = "offsetX" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "offsetY" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "offsetZ" ,
		type = "number" ,
	}
	-- Global angle offsets
	self:AddProperty{
		name = "offsetYaw" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "offsetPitch" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "offsetRoll" ,
		type = "number" ,
	}
	-- Relative position offsets
	self:AddProperty{
		name = "relativeOffsetX" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "relativeOffsetY" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "relativeOffsetZ" ,
		type = "number" ,
	}
	-- Relative angle offsets
	self:AddProperty{
		name = "relativeOffsetYaw" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "relativeOffsetPitch" ,
		type = "number" ,
	}
	self:AddProperty{
		name = "relativeOffsetRoll" ,
		type = "number" ,
	}
	
	self.selectionStrategy = {type = "Icon" , icon = Icons.Array}
	
	self.objects = {}
	self.sourceObject = nil
	-- These two are used to update our object transforms when the original object's transform
	-- changes.
	self.lastObjectPosition = Vector3()
	self.lastObjectAngle = Angle()
	
	-- Hmm, meta arrays are confusing. Here's an example for putting lights on two sides of a road:
	-- * Array1's sourceObject is a Light, and it copies it down the right side of a road.
	-- * Array2's sourceObject is Array1. Its X offset is the width of the road.
	-- * Array3 is a meta array. It is one of many meta arrays created by Array2. Its sourceObject is
	--    the original Light. Its metaParent is Array1. It works just like Array1, but every object
	--    is offset (both position and angle) relative to Array1 (the metaParent).
	self.isMeta = false
	self.metaParent = nil
	
	self:EventSubscribe("PropertyChange")
end

function Objects.Array:CreateObject()
	if self.sourceObject == nil then
		return nil
	end
	
	-- The key here is to create the object but don't add it to the map's objects.
	local newObject = Objects[self.sourceObject.type](
		self.sourceObject:GetPosition() ,
		self.sourceObject:GetAngle()
	)
	
	-- If our source object is also an Array, then the new object is a meta array.
	if self.sourceObject.type == self.type then
		newObject.isMeta = true
		newObject.metaParent = self.sourceObject
	end
	
	-- Copy over the properties.
	self.sourceObject:IterateProperties(function(property)
		newObject:SetProperty(property.name , property.value)
	end)
	
	return newObject
end

function Objects.Array:UpdateObjectTransforms()
	if self.sourceObject == nil then
		return
	end
	
	local position = self.sourceObject:GetPosition()
	local angle = self.sourceObject:GetAngle()
	
	if self.isMeta then
		local deltaPosition = self:GetPosition() - self.metaParent:GetPosition()
		local a1 , a2 = self:GetAngle() , self.metaParent:GetAngle()
		-- This seems janky
		local deltaAngle = Angle(
			a1.yaw - a2.yaw ,
			a1.pitch - a2.pitch ,
			a1.roll - a2.roll
		)
		
		position = position + deltaPosition
		angle = angle * deltaAngle
	end
	
	local offsetPosition = Vector3(
		self:GetProperty("offsetX").value ,
		self:GetProperty("offsetY").value ,
		self:GetProperty("offsetZ").value
	)
	local offsetAngle = Angle(
		math.rad(self:GetProperty("offsetYaw").value) ,
		math.rad(self:GetProperty("offsetPitch").value) ,
		math.rad(self:GetProperty("offsetRoll").value)
	)
	local relativeOffsetPosition = Vector3(
		self:GetProperty("relativeOffsetX").value ,
		self:GetProperty("relativeOffsetY").value ,
		self:GetProperty("relativeOffsetZ").value
	)
	local relativeOffsetAngle = Angle(
		math.rad(self:GetProperty("relativeOffsetYaw").value) ,
		math.rad(self:GetProperty("relativeOffsetPitch").value) ,
		math.rad(self:GetProperty("relativeOffsetRoll").value)
	)
	
	local Next = function()
		position = position + angle * relativeOffsetPosition
		angle = angle * relativeOffsetAngle
		
		position = position + offsetPosition
		angle = offsetAngle * angle
	end
	
	for index , object in ipairs(self.objects) do
		Next()
		object:SetPosition(position)
		object:SetAngle(angle)
	end
end

function Objects.Array:OnRecreate()
	if self.sourceObject == nil then
		return
	end
	
	for n = 1 , self:GetProperty("count").value do
		local object = self:CreateObject()
		table.insert(self.objects , object)
	end
	
	self:UpdateObjectTransforms()
end

function Objects.Array:OnDestroy()
	-- Remove all of our duplicate objects.
	for index , object in ipairs(self.objects) do
		object:Destroy()
	end
	self.objects = {}
end

function Objects.Array:OnRender()
	if self.sourceObject ~= nil then
		if
			self.sourceObject:GetPosition() ~= self.lastObjectPosition or
			self.sourceObject:GetAngle() ~= self.lastObjectAngle
		then
			self:UpdateObjectTransforms()
			self.lastObjectPosition = self.sourceObject:GetPosition()
			self.lastObjectAngle = self.sourceObject:GetAngle()
		end
	end
	
	for index , object in ipairs(self.objects) do
		object:Render()
	end
end

function Objects.Array:OnPropertyChange(args)
	if args.name == "sourceObject" then
		-- Remove all of our duplicate objects.
		for index , object in ipairs(self.objects) do
			object:Destroy()
		end
		self.objects = {}
		-- If there is a new source object, recreate all of our objects.
		if args.newValue ~= MapEditor.NoObject then
			self.sourceObject = args.newValue
			self:OnRecreate()
		else
			self.sourceObject = nil
		end
	elseif args.name == "count" then
		if self.sourceObject ~= nil then
			if args.newValue > #self.objects then
				-- Add more objects.
				for n = #self.objects + 1 , args.newValue do
					local object = self:CreateObject()
					table.insert(self.objects , object)
				end
			elseif args.newValue < #self.objects then
				-- Remove some objects.
				for n = #self.objects , args.newValue + 1 , -1 do
					self.objects[n]:Destroy()
					table.remove(self.objects , n)
				end
			end
		end
		
		self:UpdateObjectTransforms()
	else
		self:UpdateObjectTransforms()
	end
end

function Objects.Array:OnPositionChange()
	if self.isMeta then
		self:UpdateObjectTransforms()
	end
end

function Objects.Array:OnAngleChange()
	if self.isMeta then
		self:UpdateObjectTransforms()
	end
end

-- Events

function Objects.Array:PropertyChange(args)
	local isOurObject = self.sourceObject ~= nil and self.sourceObject:GetId() == args.objectId
	if isOurObject == false then
		return
	end
	
	-- If this is our source object, mirror the changed property on all of our duplicate objects.
	for index , object in ipairs(self.objects) do
		object:SetProperty(args.name , self.sourceObject:GetProperty(args.name).value)
	end
end
