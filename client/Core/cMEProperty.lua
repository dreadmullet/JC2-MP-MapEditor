class("Property" , MapEditor)

MapEditor.Property.GetDefaultValue = function(type)
	if type == "number" then
		return 0
	elseif type == "string" then
		return ""
	elseif type == "boolean" then
		return false
	elseif type == "table" then
		return {}
	elseif Objects[type] ~= nil then
		return -1
	end
end

function MapEditor.Property:__init(args)
	self.name = args.name
	self.type = args.type
	self.subtype = args.subtype
	
	self.value = args.default or MapEditor.Property.GetDefaultValue(self.type)
	
	if self.type == "table" then
		self.defaultElement = args.defaultElement or MapEditor.Property.GetDefaultValue(self.subtype)
	end
end
