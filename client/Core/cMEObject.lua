class("Object" , MapEditor)

-- Static

MapEditor.Object.iconRadius = 1
MapEditor.Object.shadowColor = Color(0 , 0 , 0 , 192)

MapEditor.Object.memberNames = {
	"id" ,
	"type" ,
	"position" ,
	"angle" ,
	"isClientSide" ,
}

MapEditor.Object.Unmarshal = function(o)
	local objectClass = Objects[o.type]
	if objectClass == nil then
		error("Object class not found: "..tostring(o.type))
	end
	
	local position = Vector3(o.position[1] , o.position[2] , o.position[3])
	local angle = Angle(o.angle[1] , o.angle[2] , o.angle[3] , o.angle[4])
	
	local object = objectClass(position , angle)
	object.id = o.id
	
	-- Properties are done in PropertyManager.Unmarshal later on.
	
	return object
end

MapEditor.Object.Compare = function(o1 , o2)
	if o1 == MapEditor.NoObject then
		if o2 == MapEditor.NoObject then
			return true
		else
			return false
		end
	else
		if o2 == MapEditor.NoObject then
			return false
		else
			return o1:GetId() == o2:GetId()
		end
	end
end

-- Instance

function MapEditor.Object:__init(initialPosition , initialAngle)
	MapEditor.Marshallable.__init(self , MapEditor.Object.memberNames)
	MapEditor.PropertyManager.__init(self)
	
	self.Destroy = MapEditor.Object.Destroy
	self.Recreate = MapEditor.Object.Recreate
	self.Render = MapEditor.Object.Render
	self.SetPosition = MapEditor.Object.SetPosition
	self.SetAngle = MapEditor.Object.SetAngle
	self.SetSelected = MapEditor.Object.SetSelected
	self.GetId = MapEditor.Object.GetId
	self.GetPosition = MapEditor.Object.GetPosition
	self.GetAngle = MapEditor.Object.GetAngle
	self.GetIsSelected = MapEditor.Object.GetIsSelected
	self.GetIsScreenPointWithin = MapEditor.Object.GetIsScreenPointWithin
	self.GetScreenPoints = MapEditor.Object.GetScreenPoints
	
	self.id = MapEditor.map.objectIdCounter
	MapEditor.map.objectIdCounter = MapEditor.map.objectIdCounter + 1
	self.type = class_info(self).name
	self.position = initialPosition or Vector3(0 , 208 , 0)
	self.angle = initialAngle or Angle(0 , 0 , 0)
	self.isClientSide = false
	
	self.isSelected = false
	-- Available types and their variables:
	-- * "Icon",   icon   (Image)
	-- * "Radius", radius (number)
	-- * "Bounds", bounds ({Vector3 , Vector3})
	self.selectionStrategy = {type = "Icon" , icon = Icons.Default}
	self.prettyType = Utility.PrettifyVariableName(self.type)
	self.labelColor = Color(208 , 208 , 208 , 192)
end

function MapEditor.Object:Destroy()
	if self.OnDestroy then
		self:OnDestroy()
	end
end

function MapEditor.Object:Recreate()
	if self.OnRecreate then
		self:OnRecreate()
	end
end

function MapEditor.Object:Render()
	local labelSourcePosition = Copy(self.position)
	if self.selectionStrategy.type == "Icon" then
		local transform = Transform3()
		transform:Translate(self.position)
		transform:Rotate(Camera:GetAngle())
		transform:Rotate(Angle(0 , math.tau/-4 , 0))
		Render:SetTransform(transform)
		
		MapEditor.iconModel:SetTexture(self.selectionStrategy.icon)
		MapEditor.iconModel:Draw()
		
		if self.isSelected then
			transform:Rotate(Angle(0 , math.tau/4 , 0))
			Render:SetTransform(transform)
			Render:DrawCircle(Vector3.Zero , MapEditor.Object.iconRadius , Color.LawnGreen)
		end
		
		Render:ResetTransform()
		
		labelSourcePosition.y = labelSourcePosition.y - MapEditor.Object.iconRadius
	elseif self.selectionStrategy.type == "Radius" then
		local transform = Transform3()
		transform:Translate(self.position)
		transform:Rotate(Camera:GetAngle())
		Render:SetTransform(transform)
		
		Render:DrawCircle(Vector3.Zero , self.selectionStrategy.radius , Color.Gray)
		
		if self.isSelected then
			Render:DrawCircle(Vector3.Zero , self.selectionStrategy.radius * 1.05 , Color.LawnGreen)
		end
		
		Render:ResetTransform()
		
		labelSourcePosition.y = labelSourcePosition.y - self.selectionStrategy.radius
	elseif self.selectionStrategy.type == "Bounds" then
		MapEditor.Utility.DrawBounds{
			position = self.position ,
			angle = self.angle ,
			bounds = self.selectionStrategy.bounds ,
			color = Color.Gray ,
		}
		
		if self.isSelected then
			local boundsEnlarged = {}
			boundsEnlarged[1] = self.selectionStrategy.bounds[1] * 1.1
			boundsEnlarged[2] = self.selectionStrategy.bounds[2] * 1.1
			MapEditor.Utility.DrawBounds{
				position = self.position ,
				angle = self.angle ,
				bounds = boundsEnlarged ,
				color = Color.LawnGreen ,
			}
		end
		
		labelSourcePosition.y = labelSourcePosition.y - self.selectionStrategy.bounds[2].y
	end
	
	if self.cursor then
		self.cursor:Render()
	end
	
	if self.OnRender then
		self:OnRender()
	end
	
	-- Draw label.
	if MapEditor.Preferences.drawLabels then
		local screenPosition , success = Render:WorldToScreen(labelSourcePosition)
		if success then
			local text = string.format("%i %s" , self.id , self.prettyType)
			local fontSize = 10
			local textSize = Render:GetTextSize(text , fontSize)
			screenPosition.x = screenPosition.x - textSize.x * 0.5
			screenPosition.y = screenPosition.y + 2
			
			Render:DrawText(screenPosition + Vector2.One , text , MapEditor.Object.shadowColor , fontSize)
			Render:DrawText(screenPosition , text , self.labelColor , fontSize)
		end
	end
end

function MapEditor.Object:SetPosition(position)
	self.position = position
	
	if self.cursor then
		self.cursor.position = position
	end
	
	if self.OnPositionChange then
		self:OnPositionChange(position)
	end
end

function MapEditor.Object:SetAngle(angle)
	self.angle = angle
	
	if self.cursor then
		self.cursor.angle = angle
	end
	
	if self.OnAngleChange then
		self:OnAngleChange(angle)
	end
end

function MapEditor.Object:SetSelected(selected)
	if self.isSelected == selected then
		return
	end
	
	self.isSelected = selected
	
	if self.isSelected then
		MapEditor.map.selectedObjects:AddObject(self)
		if self.OnSelect then
			self:OnSelect()
		end
	else
		MapEditor.map.selectedObjects:RemoveObject(self)
		if self.OnDeselect then
			self:OnDeselect()
		end
	end
end

function MapEditor.Object:GetId()
	return self.id
end

function MapEditor.Object:GetPosition()
	return self.position
end

function MapEditor.Object:GetAngle()
	return self.angle
end

function MapEditor.Object:GetIsSelected()
	return self.isSelected
end

function MapEditor.Object:GetIsScreenPointWithin(screenPointToTest)
	if self.selectionStrategy.type == "Bounds" then
		-- Take the bounding box screen points and convert them to a screen rect, then test to see if
		-- screenPointToTest is within that. Not perfect, but there's not much else to do.
		
		local screenPoints = self:GetScreenPoints()
		if #screenPoints == 0 then
			return false
		end
		
		local xMin = 50000
		local xMax = 0
		local yMin = 50000
		local yMax = 0
		for index , screenPoint in ipairs(screenPoints) do
			xMin = math.min(xMin , screenPoint.x)
			xMax = math.max(xMax , screenPoint.x)
			yMin = math.min(yMin , screenPoint.y)
			yMax = math.max(yMax , screenPoint.y)
		end
		
		local isWithinBounds = (
			screenPointToTest.x > xMin and
			screenPointToTest.x < xMax and
			screenPointToTest.y > yMin and
			screenPointToTest.y < yMax
		)
		
		return isWithinBounds
	else
		-- Test if screenPointToTest is within a determined screen radius of us.
		
		local screenPoint , success = Render:WorldToScreen(self.position)
		if success == false then
			return false
		end
		
		local distance = Vector3.Distance(Camera:GetPosition() , self.position)
		-- I'm not sure why this works exactly but it works.
		local screenRadius = (Render.Height * math.sqrt2) / distance
		local screenDistance = Vector2.Distance(screenPoint , screenPointToTest)
		
		if self.selectionStrategy.type == "Icon" then
			screenRadius = screenRadius * MapEditor.Object.iconRadius
		elseif self.selectionStrategy.type == "Radius" then
			screenRadius = screenRadius * self.selectionStrategy.radius
		else
			error("Invalid selection strategy: "..tostring(self.selectionStrategy.type))
		end
		
		return screenDistance <= screenRadius
	end
end

function MapEditor.Object:GetScreenPoints()
	local points = {}
	
	local positionsToCheck = {}
	if self.selectionStrategy.type == "Icon" then
		table.insert(positionsToCheck , self.position)
	elseif self.selectionStrategy.type == "Radius" then
		-- Not sure if this is the best idea.
		-- TODO: Use an rectangle/circle collision algorithm.
		local position = self.position
		local radius = self.selectionStrategy.radius
		local radius2 = radius * math.sqrt3 * 0.5
		positionsToCheck = {
			position ,
			position + Vector3(radius , 0 , 0) ,
			position + Vector3(-radius , 0 , 0) ,
			position + Vector3(0 , radius , 0) ,
			position + Vector3(0 , -radius , 0) ,
			position + Vector3(0 , 0 , radius) ,
			position + Vector3(0 , 0 , -radius) ,
			position + Vector3(radius2 , radius2 , radius2) ,
			position + Vector3(-radius2 , radius2 , radius2) ,
			position + Vector3(radius2 , radius2 , -radius2) ,
			position + Vector3(-radius2 , radius2 , -radius2) ,
			position + Vector3(radius2 , -radius2 , radius2) ,
			position + Vector3(-radius2 , -radius2 , radius2) ,
			position + Vector3(radius2 , -radius2 , -radius2) ,
			position + Vector3(-radius2 , -radius2 , -radius2) ,
		}
	elseif self.selectionStrategy.type == "Bounds" then
		local bounds = self.selectionStrategy.bounds
		local position = self.position
		local angle = self.angle
		positionsToCheck = {
			position ,
			position + angle * Vector3(bounds[1].x , bounds[1].y , bounds[1].z) ,
			position + angle * Vector3(bounds[2].x , bounds[1].y , bounds[1].z) ,
			position + angle * Vector3(bounds[1].x , bounds[1].y , bounds[2].z) ,
			position + angle * Vector3(bounds[2].x , bounds[1].y , bounds[2].z) ,
			position + angle * Vector3(bounds[1].x , bounds[2].y , bounds[1].z) ,
			position + angle * Vector3(bounds[2].x , bounds[2].y , bounds[1].z) ,
			position + angle * Vector3(bounds[1].x , bounds[2].y , bounds[2].z) ,
			position + angle * Vector3(bounds[2].x , bounds[2].y , bounds[2].z) ,
		}
	end
	
	for index , positionToCheck in ipairs(positionsToCheck) do
		local screenPos , success = Render:WorldToScreen(positionToCheck)
		if success then
			table.insert(points , screenPos)
		end
	end
	
	return points
end
