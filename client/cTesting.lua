Events:Subscribe("ModuleLoad" , function()
	map = MapEditor.Map(Vector3(-6550 , 215 , -3290))
end)

Events:Subscribe("ModuleUnload" , function()
	map:Destroy()
end)
