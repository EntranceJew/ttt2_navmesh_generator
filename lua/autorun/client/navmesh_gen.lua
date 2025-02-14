local function NavmeshTest()
	net.Start("blechkanneNavmeshTestRequest")
	net.SendToServer()
end

local function NavmeshTestMap()
	net.Start("blechkanneNavmeshTestMapRequest")
	net.SendToServer()
end

local function StartGenerating()
	net.Start("blechkanneNavmeshGenRequest")
	net.SendToServer()
end

local function MapChangeRequest(mapName)
	net.Start("blechkanneNavmeshMapChangeRequest")
	net.WriteString(mapName)
	net.SendToServer()
end

concommand.Add("navmesh_generate_custom_local", function()
	StartGenerating()
end)

concommand.Add("navmesh_test_local", function()
	NavmeshTest()
end)

concommand.Add("navmesh_test_map_local", function()
	NavmeshTestMap()
end)


local function mapThumbnail(name)
	if file.Exists("maps/thumb/" .. name .. ".png", "GAME") then
		return "maps/thumb/" .. name .. ".png"
	elseif file.Exists("maps/" .. name .. ".png", "GAME") then
		return "maps/" .. name .. ".png"
	else
		return "maps/thumb/noicon.png"
	end
end

-- Networking
net.Receive("blechkanneNavmeshTestReturned", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local data = net.ReadTable()
	local frame = vgui.Create( "DFrameTTT2" )
	frame:SetSize( 900, 800 )
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Navmesh Generator")
	frame:SetBackgroundBlur(true)
	frame:SetPaintShadow(true)
	frame:SetSizable(true)

	local scrollPanel = vgui.Create( "DScrollPanel", frame )
	scrollPanel:Dock( FILL )
	local listLayout = vgui.Create("DListLayout", scrollPanel)
	listLayout:Dock( FILL )

	local colorGreen = Color(0,255,0)
	local colorRed = Color(255,0,0)

	for key, role in pairs(data) do
		local containerPanel = vgui.Create("DPanelTTT2")
		-- containerPanel:SetPaintBackground(false)
		containerPanel:SetSize(900, 64)

		local map_name = tostring(data[key][1])

		local thumb_path = mapThumbnail(map_name)
		local thumb = vgui.Create("DImage")
		thumb:SetSize(64, 64)
		thumb:Dock( LEFT )
		thumb:DockMargin( 4, 4, 4, 4 )
		thumb:SetImage( thumb_path )
		thumb:SetTooltip( thumb_path )
		containerPanel:Add(thumb)

		local labelMapName = Label(map_name)
		labelMapName:SetSize(256, 64)
		labelMapName:Dock( LEFT )
		labelMapName:DockMargin( 4, 4, 4, 4 )
		labelMapName:SetFont("Trebuchet24")
		containerPanel:Add(labelMapName)

		--[[
		local textThumb = tostring(data[key][3])
		local labelThumb
		if (textThumb == "true") then
			labelThumb = Label("thumb: ✔")
			labelThumb:SetColor(colorGreen)
		else
			labelThumb = Label("thumb: ❌")
			labelThumb:SetColor(colorRed)
		end
		labelThumb:SetSize(128, 64)
		labelThumb:Dock( LEFT )
		labelThumb:DockMargin( 4, 4, 4, 4 )
		labelThumb:SetFont("Trebuchet24")
		containerPanel:Add(labelThumb)
		]]

		local buttonSwitchMap = vgui.Create( "DButton" )
		buttonSwitchMap:SetText(" Switch\n   To")
		buttonSwitchMap:SetSize(64, 64)
		buttonSwitchMap:Dock( RIGHT )
		buttonSwitchMap:DockMargin( 4, 4, 4, 4 )
		buttonSwitchMap.DoClick = function()
			MapChangeRequest(map_name)
			frame:Close()
		end
		containerPanel:Add(buttonSwitchMap)

		local textNavmesh = tostring(data[key][2])
		local labelNavmesh
		if (textNavmesh == "true") then
			labelNavmesh = Label("nav: ✔")
			labelNavmesh:SetColor(colorGreen)
		else
			labelNavmesh = Label("nav: ❌")
			labelNavmesh:SetColor(colorRed)
		end
		labelNavmesh:SetSize(128, 64)
		labelNavmesh:Dock( RIGHT )
		labelNavmesh:DockMargin( 4, 4, 4, 4 )
		labelNavmesh:SetFont("Trebuchet24")
		containerPanel:Add(labelNavmesh)

		listLayout:Add(containerPanel)
	end
end)

net.Receive("blechkanneNavmeshTestMapReturned", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local data = net.ReadBool()
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 200, 100 )
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Navmesh Generator")
	frame:SetBackgroundBlur(true)
	frame:SetPaintShadow(true)

	local scrollPanel = vgui.Create( "DScrollPanel", frame )
	scrollPanel:Dock(FILL)

	local label = vgui.Create( "DLabel", scrollPanel )
	label:Dock(FILL)
	if (data) then
		label:SetText("Yes")
	else
		label:SetText("No")
	end
	label:SetFont("Trebuchet24")
end)

net.Receive("blechkanneNavmeshGenReturned", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local data = net.ReadString()
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 400, 100 )
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Navmesh Generator")
	frame:SetBackgroundBlur(true)
	frame:SetPaintShadow(true)
	frame:SetSizable(true)

	local scrollPanel = vgui.Create( "DScrollPanel", frame )
	scrollPanel:Dock( FILL )

	local label = vgui.Create( "DLabel", scrollPanel )
	label:SetSize(100, 20)
	label:Dock( TOP )
	label:DockMargin( 10, 5, 0, 5 )
	label:SetText(data)
	label:SetFont("Trebuchet24")
end)