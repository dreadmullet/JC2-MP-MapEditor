MapEditor.models = {}

Events:Subscribe("ModuleLoad" , function()
	local sources = {
		"Cursor" ,
		"Move gizmo" ,
		"Rotate gizmo" ,
	}
	for index , source in ipairs(sources) do
		local args = {
			path = "Models/"..source
		}
		OBJLoader.Request(args , function(model) MapEditor.models[source] = model end)
	end
end)
