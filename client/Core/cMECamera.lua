-- Hacken together from my trusty old OrbitCamera class.

class("Camera" , MapEditor)

function MapEditor.Camera:__init(position , angle)
	-- Public properties
	self.targetPosition = position or Vector3(0 , 0 , 0)
	self.minPitch = math.rad(-89)
	self.maxPitch = math.rad(89)
	self.minDistance = 0.5
	self.maxDistance = 32768
	self.collision = false
	self.sensitivityRot = 4.5
	self.sensitivityZoom = 0.04
	self.sensitivityPan = 2.5
	self.isInputEnabled = true
	-- Private properties
	self.position = position or Vector3(0 , 10000 , 0)
	self.angle = angle or Angle()
	self.distance = 50
	self.angleBuffer = self.angle
	self.distanceDeltaBuffer = 0
	self.panBuffer = Vector3(0 , 0 , 0)
	self.deltaTimer = Timer()
	self.deltaTime = 0.05
	-- Events
	self.eventSubs = {}
	for index , name in ipairs{
		"CalcView" ,
		"LocalPlayerInput" ,
		"MouseScroll" ,
		"PreTick" ,
	} do
		table.insert(self.eventSubs , Events:Subscribe(name , self , self[name]))
	end
end

function MapEditor.Camera:Destroy()
	for index , eventSub in ipairs(self.eventSubs) do
		Events:Unsubscribe(eventSub)
	end
end

function MapEditor.Camera:UpdateDistance()
	local distanceDelta = self.distanceDeltaBuffer
	self.distanceDeltaBuffer = 0
	
	self.distance = (
		self.distance *
		math.pow(10 , 1 + -distanceDelta * self.sensitivityZoom) / 10
	)
	self.distance = math.clamp(self.distance , self.minDistance , self.maxDistance)
end

function MapEditor.Camera:UpdatePosition()
	local cameraDirection = (self.angle * Vector3.Backward)
	if self.collision then
		-- Raycast test so the camera doesn't go into geometry.
		local result = Physics:Raycast(self.targetPosition , cameraDirection , 0 , self.distance)
		self.position = self.targetPosition + cameraDirection * result.distance
		-- If the raycast hit.
		if result.distance ~= self.distance then
			self.position = self.position + result.normal * 0.25
		end
	else
		self.position = self.targetPosition + cameraDirection * self.distance
	end
	
	local terrainHeight = Physics:GetTerrainHeight(self.position)
	if self.position.y < terrainHeight then
		self.position.y = terrainHeight + 0.25 + self.distance * 0.0025
	end
	
	-- If angle isn't set here, it acts strangely, as if something is delayed by a frame. I have no
	-- idea why this works.
	self.angle = Angle.FromVectors(Vector3.Backward , cameraDirection)
	self.angle.roll = 0
end

function MapEditor.Camera:UpdateAngle()
	self.angle = self.angleBuffer
end

function MapEditor.Camera:UpdateMovement()
	local velocity = self.panBuffer * self.sensitivityPan * self.deltaTime * self.distance
	local y = velocity.y
	velocity = Angle(self.angle.yaw , 0 , 0) * velocity
	velocity.y = y
	
	self.targetPosition = self.targetPosition + velocity
	
	local terrainHeight = Physics:GetTerrainHeight(self.targetPosition)
	if self.targetPosition.y < terrainHeight then
		self.targetPosition.y = terrainHeight
	end
	
	self.panBuffer = Vector3(0 , 0 , 0)
end

-- Events

function MapEditor.Camera:CalcView()
	Camera:SetPosition(self.position)
	Camera:SetAngle(self.angle)
	
	-- Disable our player.
	return false
end

function MapEditor.Camera:LocalPlayerInput(args)
	if self.isInputEnabled == false then
		return true
	end
	
	local RotateYaw = function(value)
		self.angleBuffer.yaw = self.angleBuffer.yaw + value * self.sensitivityRot * self.deltaTime
	end
	local RotatePitch = function(value)
		self.angleBuffer.pitch = self.angleBuffer.pitch + value * self.sensitivityRot * self.deltaTime
		self.angleBuffer.pitch = math.clamp(self.angleBuffer.pitch , self.minPitch , self.maxPitch)
	end
	
	if Controls.GetIsHeld("Rotate/pan camera") then
		if Controls.GetIsHeld("Camera pan modifier") then
			if args.input == Action.LookRight then
				self.panBuffer.x = -args.state
			elseif args.input == Action.LookLeft then
				self.panBuffer.x = args.state
			elseif args.input == Action.LookUp then
				self.panBuffer.z = -args.state
			elseif args.input == Action.LookDown then
				self.panBuffer.z = args.state
			end
		else
			if args.input == Action.LookRight then
				RotateYaw(-args.state)
			elseif args.input == Action.LookLeft then
				RotateYaw(args.state)
			elseif args.input == Action.LookUp then
				RotatePitch(-args.state)
			elseif args.input == Action.LookDown then
				RotatePitch(args.state)
			end
		end
	end
	
	return true
end

function MapEditor.Camera:MouseScroll(args)
	if Controls.GetIsHeld("Camera pan modifier") then
		self.panBuffer.y = args.delta
	else
		self.distanceDeltaBuffer = args.delta
	end
end

function MapEditor.Camera:PreTick()
	self.deltaTime = self.deltaTimer:GetSeconds()
	self.deltaTimer:Restart()
	
	-- What are these even
	self:UpdateAngle()
	self:UpdateMovement()
	self:UpdateDistance()
	self:UpdatePosition()
end
