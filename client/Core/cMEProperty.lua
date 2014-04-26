class("Property" , MapEditor)

function MapEditor.Property:__init(name , value)
	self.name = name
	self.value = value
	
	self.type = type(value)
	if self.type == "userdata" then
		self.type = value.__type or class_info(value).name
	end
end
