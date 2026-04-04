RMenu.Add('overwatchmenu', 'main', RageUI.CreateMenu("", "overwatch Menu", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "adminmenu"))
RMenu.Add('overwatchmenu', 'players', RageUI.CreateSubMenu(RMenu:Get('overwatchmenu', 'main'), "All Players", ""))
RMenu.Add('overwatchmenu', 'searchoptions', RageUI.CreateSubMenu(RMenu:Get('overwatchmenu', 'main'), "Search Players", ""))
RMenu.Add('overwatchmenu', 'search_permid', RageUI.CreateSubMenu(RMenu:Get('overwatchmenu', 'searchoptions'), "Search by Perm ID", ""))
RMenu.Add('overwatchmenu', 'search_tempid', RageUI.CreateSubMenu(RMenu:Get('overwatchmenu', 'searchoptions'), "Search by Temp ID", ""))
RMenu.Add('overwatchmenu', 'search_name', RageUI.CreateSubMenu(RMenu:Get('overwatchmenu', 'searchoptions'), "Search by Name", ""))
RMenu.Add('overwatchmenu', 'player_actions', RageUI.CreateSubMenu(RMenu:Get('overwatchmenu', 'searchoptions'), "Player Actions", ""))
RegisterCommand('overwatch', function()
    
        
end)
