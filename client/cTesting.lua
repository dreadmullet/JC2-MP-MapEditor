Events:Subscribe("ModuleLoad" , function()
	editor = MapEditor.Editor(Vector3(-6550 , 215 , -3290))
end)

Events:Subscribe("ModuleUnload" , function()
	editor:Destroy()
end)
