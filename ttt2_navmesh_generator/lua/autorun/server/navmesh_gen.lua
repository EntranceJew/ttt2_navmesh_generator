local allMaps = file.Find("maps/*.bsp", "GAME")

local function NavmeshTest()
    local data = {}
    for index, map in ipairs(allMaps) do
        local mapName = string.StripExtension(map)
        local navExists = file.Exists("maps/" .. mapName .. ".nav", "GAME")
        print(index, " ", map, " has a navmesh: ", navExists)
        data[index] = {mapName, navExists}
    end

    return data
end

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
    print(mapName, " has a navmesh: ", navExists)
    return navExists
end

local function StartGenerating(ply)
    if NavmeshTestMap() then
        print("Nav already Exists")
        return 
    end -- do not create nav if nav already exists
    
    if not IsValid(ply) then return end
    print("Generating Nav")
    ply:ConCommand("nav_generate_expanded")

    return true
end

local function checkCheats()
    local cheatsEnabled = cvars.Bool("sv_cheats")

    print("cheats are enabled: " .. tostring(cheatsEnabled))

    return cheatsEnabled
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

    ply:ConCommand("map " .. data)
end )