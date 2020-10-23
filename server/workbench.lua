local WorkbenchTest3D
local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }

AddEvent("OnPackageStart", function()
    -- workbench
    WorkbenchText3D = CreateText3D("Press [E] to Interact", 10, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z + 130, 0,0,0)
end)

AddEvent("OnPackageStop", function()
    DestroyText3D(WorkbenchText3D)
end)

AddRemoteEvent("GetWorkbenchData", function(player)
    local item_data = {}
    for key,item in pairs(GetItemConfigs()) do
        if item['recipe'] ~= nil then
            table.insert(item_data, {
                item = key,
                name = item['name'],
                modelid = item['modelid'],
                recipe = item['recipe']
            })
        end
    end

    local _send = {
        ["item_data"] = item_data,
        ["player_resources"] = GetPlayerResources(player)
    }
    --print(dump(json_encode(_send)))
    CallRemoteEvent(player, "OnGetWorkbenchData", json_encode(_send))
end)

AddRemoteEvent("BuildItem", function(player, item)
    local item_cfg = GetItemConfig(item)
    if item_cfg == nil then
        return
    end

    -- start the build
    print("Player "..GetPlayerName(player).." builds item "..item_cfg['name'])

    -- remove scrap from inventory
    for resource,amount in pairs(item_cfg['recipe']) do
        RemoveFromInventory(player, resource, amount)
    end

    CallRemoteEvent(player, "StartBuilding", item, json_encode(GetPlayerResources(player)))

    SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547) 
    SetPlayerHeading(player, -92.786437988281)   
    SetPlayerAnimation(player, "BARCLEAN01")
    Delay(15000, function()
        SetPlayerAnimation(player, "STOP")
        AddPlayerChat(player, item_cfg['name'].." has been added to your inventory.")
        AddToInventory(player, item)
    end)
end)

function GetPlayerResources(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    local resources = {}
    for _,item in pairs(inventory) do
        if item['type'] == 'resource' then
            resources[item['item']] = item['quantity']
        end
    end
    print(dump(resources))
    return resources
end