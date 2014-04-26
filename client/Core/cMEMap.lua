class("Map" , MapEditor)

function MapEditor.Map:__init()
	MapEditor.Marshallable.__init(self)
	MapEditor.ObjectManager.__init(self)
	MapEditor.PropertyManager.__init(self)
end
