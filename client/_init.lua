Events:Subscribe("ModuleLoad" , function()
	Controls.Add("Orbit camera: Rotate/pan" ,    "Mouse3")
	Controls.Add("Orbit camera: Pan modifier" ,  "Shift")
	Controls.Add("Mouse wheel up" ,              "Mouse wheel up")
	Controls.Add("Mouse wheel down" ,            "Mouse wheel down")
	Controls.Add("Look up" ,                     "Mouse up")
	Controls.Add("Look down" ,                   "Mouse down")
	Controls.Add("Look left" ,                   "Mouse left")
	Controls.Add("Look right" ,                  "Mouse right")
	
	Actions.NewMap()
end)

Events:Subscribe("ModuleUnload" , function()
	if MapEditor.map then
		MapEditor.map:Destroy()
	end
end)