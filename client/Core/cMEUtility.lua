MapEditor.Utility = {}

MapEditor.Utility.DrawBounds = function(position , bounds , color)
	local b1 = bounds[1]
	local b2 = bounds[2]
	local lines = {
		-- Top square
		{Vector3(b1.x , b2.y , b1.z) , Vector3(b2.x , b2.y , b1.z)} ,
		{Vector3(b1.x , b2.y , b2.z) , Vector3(b2.x , b2.y , b2.z)} ,
		{Vector3(b1.x , b2.y , b1.z) , Vector3(b1.x , b2.y , b2.z)} ,
		{Vector3(b2.x , b2.y , b1.z) , Vector3(b2.x , b2.y , b2.z)} ,
		-- Bottom square
		{Vector3(b1.x , b1.y , b1.z) , Vector3(b2.x , b1.y , b1.z)} ,
		{Vector3(b1.x , b1.y , b2.z) , Vector3(b2.x , b1.y , b2.z)} ,
		{Vector3(b1.x , b1.y , b1.z) , Vector3(b1.x , b1.y , b2.z)} ,
		{Vector3(b2.x , b1.y , b1.z) , Vector3(b2.x , b1.y , b2.z)} ,
		-- Sides
		{Vector3(b1.x , b1.y , b1.z) , Vector3(b1.x , b2.y , b1.z)} ,
		{Vector3(b2.x , b1.y , b1.z) , Vector3(b2.x , b2.y , b1.z)} ,
		{Vector3(b1.x , b1.y , b2.z) , Vector3(b1.x , b2.y , b2.z)} ,
		{Vector3(b2.x , b1.y , b2.z) , Vector3(b2.x , b2.y , b2.z)} ,
	}
	
	local transform = Transform3()
	transform:Translate(position)
	Render:SetTransform(transform)
	
	for index , line in ipairs(lines) do
		Render:DrawLine(line[1] , line[2] , color or Color.White)
	end
	
	Render:ResetTransform()
end
