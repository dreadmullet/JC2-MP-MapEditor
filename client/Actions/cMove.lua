class("Move" , Actions)

function Actions.Move:__init()
	Actions.TransformBase.__init(self)
	
	self.sensitivity = 0.001
	
	self.controlDisplayer.name = "Move"
end

function Actions.Move:OnProcess(objectInfo , mouse , pivot)
	local distance = Vector3.Distance(Camera:GetPosition() , pivot)
	local mult = distance * self.sensitivity
	local delta = Camera:GetAngle() * Vector3(mouse.delta.x , -mouse.delta.y , 0) * mult
	
	if self.lockedAxis then
		if self.lockedAxis == "X" then
			delta.y = 0
			delta.z = 0
		elseif self.lockedAxis == "Y" then
			delta.x = 0
			delta.z = 0
		elseif self.lockedAxis == "Z" then
			delta.x = 0
			delta.y = 0
		end
		
		if self.isLocal then
			delta = objectInfo.startTransform.angle * delta
		end
	end
	
	objectInfo.endTransform.position = objectInfo.startTransform.position + delta
end
