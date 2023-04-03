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

-- Networking
net.Receive("blechkanneNavmeshTestReturned", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local data = net.ReadTable()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( 600, 800 )
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
        local containerPanel = vgui.Create("DPanel")
        containerPanel:SetPaintBackground(false)
        containerPanel:SetSize(500, 50)
        local textLeft = tostring(data[key][1])
        local labelLeft = Label(textLeft)
        labelLeft:SetSize(500, 50)
        labelLeft:Dock( LEFT )
        labelLeft:DockMargin( 5, 5, 5, 5 )
        labelLeft:SetFont("Trebuchet24")
        containerPanel:Add(labelLeft)

        local buttonRight = vgui.Create( "DButton")
        buttonRight:SetText("Change Map To")
        buttonRight:SetSize(100, 50)
        buttonRight:Dock( RIGHT )
        buttonRight:DockMargin( 5, 5, 5, 5 )
        buttonRight.DoClick = function()
            MapChangeRequest(textLeft)
            frame:Close()
        end

        containerPanel:Add(buttonRight)

        local textRight = tostring(data[key][2])
        local labelRight = Label(textRight)
        if (textRight == "true") then
            labelRight:SetColor(colorGreen)
        else
            labelRight:SetColor(colorRed)
        end
        labelRight:SetSize(100, 50)
        labelRight:Dock( RIGHT )
        labelRight:DockMargin( 5, 5, 5, 5 )
        labelRight:SetFont("Trebuchet24")
        containerPanel:Add(labelRight)



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