Events:Subscribe("ModuleLoad" , function()
	MapEditor.Map(Vector3(-6550 , 215 , -3290))
end)

Events:Subscribe("ModuleUnload" , function()
	if MapEditor.map then
		MapEditor.map:Destroy()
	end
end)
