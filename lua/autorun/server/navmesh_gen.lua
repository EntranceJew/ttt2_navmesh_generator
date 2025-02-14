local allMaps = file.Find("maps/*.bsp", "GAME")

local function NavmeshTestMap(mapName)
	if (mapName == nil) then
		mapName = game.GetMap()
	end
	local map = file.Exists("maps/" .. mapName .. ".bsp", "GAME")
	if not map then
		print(mapName, " does not exist")
		return false
	end
	local navExists = file.Exists("maps/" .. mapName .. ".nav", "GAME")
	-- print(mapName, " has a navmesh: ", navExists)
	return navExists
end

local function NavmeshTest()
	local data = {}
	for index, map in ipairs(allMaps) do
		local mapName = string.StripExtension(map)
		local navExists = NavmeshTestMap(mapName)
		local thumbExists = file.Exists("maps/thumb/" .. mapName .. ".png", "GAME")
		-- print(index, " ", map, " has a navmesh: ", navExists)
		data[index] = {mapName, navExists, thumbExists}
	end

	return data
end

local function StartGenerating(ply)
	-- if NavmeshTestMap() then
	--     print("Nav already Exists")
	--     return
	-- end -- do not create nav if nav already exists

	if not IsValid(ply) then return end
	print("Generating Nav")
	ply:ConCommand("nav_generate_cheap_expanded")

	return true
end

local bigNegativeZ = Vector( 0, 0, -3000 )
local function snappedToFloor( pos )
	local traceDat = {
		mask = MASK_SOLID,
		start = pos,
		endpos = pos + bigNegativeZ
	}

	local trace = util.TraceLine( traceDat )
	if not trace.Hit then return nil, nil end

	local snapped = trace.HitPos
	if not util.IsInWorld( snapped ) then return nil, nil end

	return true, snapped, trace
end

hook.Add("navoptimizer_comprehensiveseedpositions_postbuilt", "NavMeshGen_postbuilt", function(donePositions)
	local spawnPoints = plyspawn.GetPlayerSpawnPoints()
	for _, spawn in ipairs(spawnPoints) do
		local didSnap, pos = snappedToFloor(spawn.pos)
		if didSnap then
			donePositions[#donePositions + 1] = pos
		end
	end
end)

local function checkCheats()
	local cheatsEnabled = cvars.Bool("sv_cheats")

	print("cheats are enabled: " .. tostring(cheatsEnabled))

	return cheatsEnabled
end

local function ComputeSize()
	local areas = navmesh.GetAllNavAreas()
	local sum = 0
	for _, area in ipairs(areas) do
		sum = sum + (area:GetSizeX() * area:GetSizeY())
	end
	return math.Round( math.sqrt( sum ) )
end


-- Con Commands
concommand.Add("navmesh_generate_custom", function(ply, cmd, args)
	StartGenerating(ply)
end)

concommand.Add("navmesh_test", function(ply, cmd, args)
	NavmeshTest()
end)

concommand.Add("navmesh_test_map", function(ply, cmd, args)
	NavmeshTestMap(args[0])
end, function(cmd, args)
	local mapsStripped = {}
	for index, map in ipairs(allMaps) do
		local mapName = string.StripExtension(map)
		mapsStripped[index] = cmd .. " " .. mapName
	end
	return mapsStripped
end)

-- Networking
util.AddNetworkString("blechkanneNavmeshTestRequest")
util.AddNetworkString("blechkanneNavmeshTestReturned")
util.AddNetworkString("blechkanneNavmeshTestMapRequest")
util.AddNetworkString("blechkanneNavmeshTestMapReturned")
util.AddNetworkString("blechkanneNavmeshGenRequest")
util.AddNetworkString("blechkanneNavmeshGenReturned")
util.AddNetworkString("blechkanneNavmeshMapChangeRequest")
util.AddNetworkString("blechkanneNavmeshMenuDataRequest")
util.AddNetworkString("blechkanneNavmeshMenuDataReturned")

local function mapThumbnail(name)
	if file.Exists("maps/thumb/" .. name .. ".png", "GAME") then
		return "maps/thumb/" .. name .. ".png"
	elseif file.Exists("maps/" .. name .. ".png", "GAME") then
		return "maps/" .. name .. ".png"
	else
		return "maps/thumb/noicon.png"
	end
end

net.Receive("blechkanneNavmeshMenuDataRequest", function(len, ply)
	net.Start("blechkanneNavmeshMenuDataReturned")
		net.WriteString(game.GetMap())
		net.WriteString(mapThumbnail(game.GetMap()))
		net.WriteUInt(ComputeSize(), 32)
		-- net.WriteUInt(map_data.config.MinPlayers, 8)
		-- net.WriteUInt(map_data.config.MaxPlayers, 8)
	net.Send( ply )
end)

net.Receive("blechkanneNavmeshTestRequest", function(len, ply)
	if not ply:IsAdmin() then
		print("Unauthorized Request from " .. ply:GetName())
		return
	end

	local data = NavmeshTest()
	if (data == nil) then
		data = {}
	end
	net.Start("blechkanneNavmeshTestReturned")
	net.WriteTable(data)
	net.Send(ply)

end )

net.Receive("blechkanneNavmeshTestMapRequest", function(len, ply)
	if not ply:IsAdmin() then
		print("Unauthorized Request from " .. ply:GetName())
		return
	end

	local data = NavmeshTestMap()
	if (data == nil) then
		data = false
	end
	net.Start("blechkanneNavmeshTestMapReturned")
	net.WriteBool(data)
	net.Send(ply)
end )

net.Receive("blechkanneNavmeshGenRequest", function(len, ply)
	if not ply:IsAdmin() then
		print("Unauthorized Request from " .. ply:GetName())
		return
	end

	if not checkCheats() then
		print("Cheats are disabled")
		net.Start("blechkanneNavmeshGenReturned")
		net.WriteString("Cheats are disabled")
		net.Send(ply)
		return
	end

	if StartGenerating(ply) then
		net.Start("blechkanneNavmeshGenReturned")
		net.WriteString("Generating Mesh")
	else
		net.Start("blechkanneNavmeshGenReturned")
		net.WriteString("Mesh already exists")
	end

	net.Send(ply)
end )

net.Receive("blechkanneNavmeshMapChangeRequest", function(len, ply)
	if not ply:IsAdmin() then
		print("Unauthorized Request from " .. ply:GetName())
		return
	end

	local data = net.ReadString()

	-- ply:ConCommand("rcon changelevel " .. data)
	RunConsoleCommand("changelevel", data)
end )