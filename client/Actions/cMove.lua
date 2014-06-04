class("Move" , Actions)

function Actions.Move:__init()
	Actions.TransformBase.__init(self)
	
	self.Destroy = Actions.Move.Destroy
	
	self.sensitivity = 0.001
	self.lockedAxis = nil
	
	Controls.Add("Lock to X axis" , "X")
	Controls.Add("Lock to Y axis" , "Y")
	Controls.Add("Lock to Z axis" , "Z")
	
	self.controlDisplayer = MapEditor.ControlDisplayer{
		name = "Move action" ,
		linesFromBottom = 2 ,
		"Lock to X axis" ,
		"Lock to Y axis" ,
		"Lock to Z axis" ,
	}
	
	self:EventSubscribe("ControlDown")
end

function Actions.Move:OnProcess(objectInfo , mouse , pivot)
	local distance = Vector3.Distance(Camera:GetPosition() , pivot)
	local mult = distance * self.sensitivity
	local delta = Camera:GetAngle() * Vector3(mouse.delta.x , -mouse.delta.y , 0) * mult
	
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
	
	objectInfo.endTransform.position = objectInfo.startTransform.position + delta
end

function Actions.Move:OnDestroy()
	self.controlDisplayer:Destroy()
end

-- Events

function Actions.Move:ControlDown(args)
	local LockAxis = function(axis)
		if self.lockedAxis == axis then
			self.lockedAxis = nil
		else
			self.lockedAxis = axis
		end
	end
	
	if args.name == "Lock to X axis" then
		LockAxis("X")
	elseif args.name == "Lock to Y axis" then
		LockAxis("Y")
	elseif args.name == "Lock to Z axis" then
		LockAxis("Z")
	end
end
