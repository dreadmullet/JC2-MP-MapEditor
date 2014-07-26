MapEditor.VersionConversion = {}

MapEditor.VersionConversion.Convert = function(marshalledSource)
	if marshalledSource.version == MapEditor.version then
		return marshalledSource
	end
	
	if marshalledSource.version > MapEditor.version then
		return {error = "Map version is higher than editor version. Update your map editor!"}
	end
	
	for n = marshalledSource.version , MapEditor.version - 1 do
		print("Updating map from version "..n.." to "..(n + 1))
		marshalledSource = MapEditor.VersionConversion.ConversionFunctions[n](marshalledSource)
	end
	print("Done")
	
	marshalledSource.version = MapEditor.version
	
	return marshalledSource
end

MapEditor.VersionConversion.ConversionFunctions = {
	[2] = function(marshalledSource)
		-- Nothing to do here. Only some object properties were added, which get fixed automatically
		-- on the client.
		return marshalledSource
	end
}
