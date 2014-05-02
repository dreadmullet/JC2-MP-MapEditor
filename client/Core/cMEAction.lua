class("Action" , MapEditor)

function MapEditor.Action:__init()
	self.Confirm = MapEditor.Action.Confirm
	self.Cancel = MapEditor.Action.Cancel
end

function MapEditor.Action:Confirm()
	MapEditor.map:ActionFinish()
end

function MapEditor.Action:Cancel()
	MapEditor.map:ActionCancel()
end
