class("Move" , Actions)

function Actions.Move:__init()
	EGUSM.SubscribeUtility.__init(self)
	Actions.TransformBase.__init(self)
	
	self.sensitivity = 0.001
end

function Actions.Move:OnProcess(objectInfo , mouse , pivot)
	local distance = Vector3.Distance(Camera:GetPosition() , pivot)
	local mult = distance * self.sensitivity
	local delta = Camera:GetAngle() * Vector3(mouse.delta.x , -mouse.delta.y , 0) * mult
	
	objectInfo.endTransform.position = objectInfo.startTransform.position + delta
end
