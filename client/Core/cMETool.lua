class("Tool" , MapEditor)

function MapEditor.Tool:__init()
	self.Finish = MapEditor.Tool.Finish
end

function MapEditor.Tool:Finish()
	MapEditor.map:ToolFinish()
end
