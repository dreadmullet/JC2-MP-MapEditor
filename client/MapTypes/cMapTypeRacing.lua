MapTypes.Racing = {
	objects = {
		"RaceCheckpoint" ,
		"RaceSpawn" ,
		"RaceVehicleInfo" ,
	} ,
	properties = {
		{
			name = "title" ,
			type = "string" ,
			default = "Untitled Course" ,
		} ,
		-- TODO: This should be a ComboBox where you can choose Linear and Circuit (as integers?)
		{
			name = "type" ,
			type = "string" ,
			default = "Linear" ,
		} ,
		{
			name = "laps" ,
			type = "number" ,
			default = 1 ,
		} ,
		-- TODO: Need tooltips; "-1 is random weather, 2 is max"
		{
			name = "weatherSeverity" ,
			type = "number" ,
			default = -1 ,
		} ,
		{
			name = "parachuteEnabled" ,
			type = "boolean" ,
			default = true ,
		} ,
		{
			name = "grappleEnabled" ,
			type = "boolean" ,
			default = true ,
		} ,
		-- Needs a groupbox as well
		{
			name = "forceCollision" ,
			type = "number" ,
			default = 0 ,
		} ,
		{
			name = "authors" ,
			type = "table" ,
			subtype = "string"
		} ,
	} ,
}
