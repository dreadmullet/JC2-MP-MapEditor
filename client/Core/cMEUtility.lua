MapEditor.Utility = {}

MapEditor.Utility.DrawBounds = function(args)
	local b1 = args.bounds[1]
	local b2 = args.bounds[2]
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
	transform:Translate(args.position)
	transform:Rotate(args.angle)
	Render:SetTransform(transform)
	
	for index , line in ipairs(lines) do
		Render:DrawLine(line[1] , line[2] , args.color or Color.White)
	end
	
	Render:ResetTransform()
end

MapEditor.Utility.DrawArea = function(position , size , thickness , color)
	local tVec = Vector2(thickness , thickness) * 0.5
	local Draw = function(a , b)
		if size.x < 0 and size.y < 0 then
			Render:FillArea(a + tVec , b - tVec - (a + tVec) , color)
		else
			Render:FillArea(a - tVec , b + tVec - (a - tVec) , color)
		end
	end
	
	local topLeft = position
	local topRight = position + Vector2(size.x , 0)
	local bottomLeft = position + Vector2(0 , size.y)
	local bottomRight = position + size
	Draw(topLeft , topRight , color)
	Draw(topLeft , bottomLeft , color)
	Draw(topRight , bottomRight , color)
	Draw(bottomLeft , bottomRight , color)
end
