class("Deselector" , Tools)

function Tools.Deselector:__init(...) ; Tools.SelectorBase.__init(self , ...)
	self.color = Color.DarkRed
	self.objectSelectedFunction = function(object)
		MapEditor.map.selectedObjects:RemoveObject(object)
	end
end
