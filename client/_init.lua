Events:Subscribe("ModuleLoad" , function()
	Actions.NewMap()
end)

Events:Subscribe("ModuleUnload" , function()
	if MapEditor.map then
		MapEditor.map:Destroy()
	end
end)
