Utility = {}

-- these are tabs, such as 4 spaces
Utility.tabPhrase = "    "

-- simulates a tab thing for type info
Utility.typeStringTabLength = 8

-- prints a table, in full
-- should be called using PrintTable(tableToCall)
-- depth and tableList are used internally
	-- depth helps with tabs.
	-- tableList is a list that contains all of the tables that
	-- have already been printed, so that it doesn't
	-- form an infinite loop of printing tables.
Utility.PrintTable = function(t , depth , tableList)
	-- Error checking against arguments.
	if t == nil then
		print("nil")
		return
	end
	
	if type(t) ~= "table" then
		print("Not a table")
		return
	end
	
	-- helps with adding tabs
	if not depth then depth = 0 end
	local tab = ""
	for i=1 , depth do
		tab = tab..Utility.tabPhrase
	end
	
	-- if tableList is nil, make it
	if not tableList then tableList = {} end
	
	-- add t to tableList
	tableList[t] = true
	
	for key , value in pairs(t) do
		local keyString = tostring(key)
		
		-- If this check isn't in place it will error.
		if type(key) == "table" then
			local keysString = ""
			for k,v in pairs(key) do
				keysString = keysString..tostring(k).." , "
			end
			keysString = keysString:sub(1 , keysString:len() - 3)
			key = "TABLE: {"..keysString.."}"
		end
		
		local type = type(value)
		local typeString = " ("..
			type..
			") "
		if type == "table" then
			print(tab..keyString..typeString)
			if tableList[value] then
				print(tab.."(already printed)")
			else
				Utility.PrintTable(value , depth + 1 , tableList)
			end
		elseif type == "boolean" then
			if value then
				print(tab..keyString..typeString.." = true")
			else
				print(tab..keyString..typeString.." = false")
			end
		else
			-- other types
			if type == "number" or type == "string" then
				print(tab..keyString..typeString.." = "..value)
			else
				print(tab..keyString..typeString.." ("..tostring(value.__type)..") = "..tostring(value))
			end
		end
	end
end

Utility.PrettifyVariableName = function(name)
	local words = {}
	for word in string.gmatch(name , "[%u%l][%l%d]+") do
		word = word:sub(1 , 1):upper()..word:sub(2)
		table.insert(words , word)
	end
	
	return table.concat(words , " ")
end
