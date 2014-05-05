class("Property" , MapEditor)

function MapEditor.Property:__init(args)
	self.name = args.name
	self.type = args.type
	self.subtype = args.subtype
	self.defaultValue = args.default
	
	self.value = self.defaultValue
end
