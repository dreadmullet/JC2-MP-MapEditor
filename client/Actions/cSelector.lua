class("Selector" , Actions)

function Actions.Selector:__init(...) ; Actions.SelectorBase.__init(self , ...)
	self.color = Color.LimeGreen
	self.objectSelectedFunction = function(object)
		MapEditor.map.selectedObjects:AddObject(object)
	end
end
