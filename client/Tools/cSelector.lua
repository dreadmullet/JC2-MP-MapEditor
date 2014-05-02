class("Selector" , Tools)

function Tools.Selector:__init(...) ; Tools.SelectorBase.__init(self , ...)
	self.color = Color.LimeGreen
	self.objectSelectedFunction = function(object)
		MapEditor.map.selectedObjects:AddObject(object)
	end
end
