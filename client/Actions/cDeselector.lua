class("Deselector" , Actions)

function Actions.Deselector:__init(...) ; Actions.SelectorBase.__init(self , ...)
	self.color = Color.DarkRed
	self.objectSelectedFunction = function(object)
		MapEditor.map.selectedObjects:RemoveObject(object)
	end
end
