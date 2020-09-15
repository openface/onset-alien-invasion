local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }
local WorkbenchData = {
    { ['key'] = 'armor', ['name'] = 'Kevlar Vest', ['modelid'] = 843, ['scrap_needed'] = 15 },
    { ['key'] = 'flashlight', ['name'] = 'Flashlight', ['modelid'] = 1271, ['scrap_needed'] = 10 },
    { ['key'] = 'medkit', ['name'] = 'Medical Kit', ['modelid'] = 796, ['scrap_needed'] = 5 },
}

AddEvent("OnPackageStart", function()
    -- workbench
    CreateText3D("Press [E] to Interact", 10, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z + 130, 0,0,0)
end)

AddRemoteEvent("GetWorkbenchData", function(player)
    CallRemoteEvent(player, "OnGetWorkbenchData", json_encode(WorkbenchData))
end)

AddRemoteEvent("BuildPart", function(player, name)
    SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547) 
    SetPlayerHeading(player, -92.786437988281)   
    SetPlayerAnimation(player, "BARCLEAN01")
    Delay(15000, function()
        SetPlayerAnimation(player, "STOP")
        AddPlayerChat(player, "You have built something!")
    end)
end)

