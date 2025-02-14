CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.title = "navmesh_gen_info"

function CLGAMEMODESUBMENU:Populate(parent)
	local form = vgui.CreateTTT2Form(parent, "navmesh_gen_header")

	net.Receive("blechkanneNavmeshMenuDataReturned", function(len, ply)
		local map_name = net.ReadString()
		local map_path = net.ReadString()
		local map_size = net.ReadUInt(32)
		local map_has_navmesh = net.ReadBool()

		local wad = {
			map_name = map_name,
			map_path = map_path,
			map_size = map_size,
			map_has_navmesh = map_has_navmesh and "true" or "false",
		}

		local current_map = vgui.CreateTTT2Form(parent, "navmesh_gen_current_map")
		current_map:MakeHelp({
			label = "navmesh_gen_help_current_map",
			params = wad
		})

		current_map:MoveToBefore(parent:Find("navmesh_gen_header"))
	end)

	net.Start("blechkanneNavmeshMenuDataRequest")
	net.SendToServer()

	form:MakeHelp({
		label = "navmesh_gen_help_menu"
	})

	local testMeshesButton = vgui.Create( "DButtonTTT2", form )
	testMeshesButton:SetText(LANG.GetTranslation("navmesh_gen_test_for_map_meshes"))
	testMeshesButton:Dock( TOP )
	testMeshesButton:SetSize( 250, 30 )
	testMeshesButton:DockMargin( 10, 5, 10, 5 )
	testMeshesButton.DoClick = function()
		local ply = LocalPlayer()
		if !IsValid(ply) then return end
		ply:ConCommand("navmesh_test_local")
	end

	local generateMeshButton = vgui.Create( "DButtonTTT2", form )
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
