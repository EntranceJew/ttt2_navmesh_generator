CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.title = "navmesh_gen_info"

function CLGAMEMODESUBMENU:Populate(parent)
	local form = vgui.CreateTTT2Form(parent, "navmesh_gen_header")

	form:MakeHelp({
		label = "navmesh_gen_help_menu"
	})


    local testMeshButton = vgui.Create( "DButton", form )
    testMeshButton:SetText(LANG.GetTranslation("navmesh_gen_test_for_mesh"))
    testMeshButton:Dock( TOP )
    testMeshButton:SetSize( 250, 30 )
    testMeshButton:DockMargin( 10, 5, 10, 5 )
    testMeshButton.DoClick = function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        ply:ConCommand("navmesh_test_map_local")
    end

    local testMeshesButton = vgui.Create( "DButton", form )
    testMeshesButton:SetText(LANG.GetTranslation("navmesh_gen_test_for_map_meshes"))
    testMeshesButton:Dock( TOP )
    testMeshesButton:SetSize( 250, 30 )
    testMeshesButton:DockMargin( 10, 5, 10, 5 )
    testMeshesButton.DoClick = function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        ply:ConCommand("navmesh_test_local")
    end

    local generateMeshButton = vgui.Create( "DButton", form )
    generateMeshButton:SetText(LANG.GetTranslation("navmesh_gen_generate_mesh"))
    generateMeshButton:Dock( TOP )
    generateMeshButton:SetSize( 250, 30 )
    generateMeshButton:DockMargin( 10, 5, 10, 5 )
    generateMeshButton.DoClick = function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        ply:ConCommand("navmesh_generate_custom_local")
    end
end
