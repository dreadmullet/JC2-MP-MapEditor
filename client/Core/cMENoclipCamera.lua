class("NoclipCamera" , MapEditor)

function MapEditor.NoclipCamera:__init(position , angle) ; EGUSM.SubscribeUtility.__init(self)
	self.position = position or Vector3(0 , 250 , 0)
	self.angle = angle or Angle()
	self.speed = 10
	
	self.moveBuffer = Vector3()
	self.rotateBuffer = Angle()
	self.speedChangeBuffer = 0
	
	self.maxPitch = math.rad(89)
	self.minSpeed = 0.2
	self.maxSpeed = 16384
	
	self.isEnabled = true
	self.isInputEnabled = false
	
	self.deltaTimer = Timer()
	
	self:EventSubscribe("ControlHeld")
	self:EventSubscribe("ControlDown")
	self:EventSubscribe("CalcView")
	self:EventSubscribe("PostTick")
end

function MapEditor.NoclipCamera:SetPosition(position)
	self.position = position
end

function MapEditor.NoclipCamera:ControlHeld(args)
	if self.isEnabled == false or self.isInputEnabled == false then
		return
	end
	
	if args.name == "Noclip camera: Forward" then
		self.moveBuffer.z = -args.state
	elseif args.name == "Noclip camera: Back" then
		self.moveBuffer.z = args.state
	elseif args.name == "Noclip camera: Left" then
		self.moveBuffer.x = -args.state
	elseif args.name == "Noclip camera: Right" then
		self.moveBuffer.x = args.state
	elseif args.name == "Noclip camera: Up" then
		self.moveBuffer.y = args.state
	elseif args.name == "Noclip camera: Down" then
		self.moveBuffer.y = -args.state
	elseif args.name == "Look left" then
		self.rotateBuffer.yaw = args.state
	elseif args.name == "Look right" then
		self.rotateBuffer.yaw = -args.state
	elseif args.name == "Look up" then
		self.rotateBuffer.pitch = args.state
	elseif args.name == "Look down" then
		self.rotateBuffer.pitch = -args.state
	end
end

function MapEditor.NoclipCamera:ControlDown(args)
	if args.name == "Noclip camera: Toggle" then
		self.isInputEnabled = not self.isInputEnabled
		Events:Fire("SetMenusEnabled" , not self.isInputEnabled)
	elseif args.name == "Mouse wheel up" then
		self.speedChangeBuffer = args.state
	elseif args.name == "Mouse wheel down" then
		self.speedChangeBuffer = -args.state
	end
end

function MapEditor.NoclipCamera:CalcView()
	if self.isEnabled == false then
		return true
	end
	
	-- Multiply everything by deltaTime to make sure things are not framerate-dependent.
	local deltaTime = self.deltaTimer:GetSeconds()
	self.deltaTimer:Restart()
	
	if self.moveBuffer:Length() > 1 then
		self.moveBuffer:Normalize()
	end
	
	local rb = self.rotateBuffer
	local mult = MapEditor.Preferences.camSensitivityRot
	self.angle = Angle(
		self.angle.yaw + rb.yaw * mult ,
		self.angle.pitch + rb.pitch * mult ,
		0
	)
	self.angle.pitch = math.clamp(self.angle.pitch , -self.maxPitch , self.maxPitch)
	if self.speedChangeBuffer ~= 0 then
		self.speedChangeBuffer = self.speedChangeBuffer * deltaTime
		-- wut
		self.speed = (
			self.speed *
			0.1 *
			math.pow(10 , 1 + self.speedChangeBuffer * 15)
		)
		self.speed = math.clamp(self.speed , self.minSpeed , self.maxSpeed)
	end
	self.moveBuffer = self.angle * (self.moveBuffer * (self.speed * deltaTime))
	self.position = self.position + self.moveBuffer * MapEditor.Preferences.camSensitivityMove
	
	self.moveBuffer = Vector3()
	self.rotateBuffer = Angle()
	self.speedChangeBuffer = 0
	
	Camera:SetPosition(self.position)
	Camera:SetAngle(self.angle)
	
	return false
end

function MapEditor.NoclipCamera:PostTick()
	if self.isEnabled == false then
		return
	end
	
	Mouse:SetVisible(not self.isInputEnabled)
end
