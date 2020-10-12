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
    for key,item in pairs(GetObjects()) do
        if item['recipe'] ~= nil then
            item_data[key] = {
                name = item['name'],
                modelid = item['modelid'],
                recipe = item['recipe']
            }
        end
    end

    local _send = {
        ["item_data"] = item_data,
        ["player_resources"] = GetPlayerResources(player)
    }
    print(dump(json_encode(_send)))
    CallRemoteEvent(player, "OnGetWorkbenchData", json_encode(_send))
end)

AddRemoteEvent("BuildItem", function(player, item_key)
    local item = GetObject(item_key)

    if item == nil then
        return
    end

    -- start the build
    print("Player "..GetPlayerName(player).." builds item "..item['name'])

    -- remove scrap from inventory
    for resource,amount in pairs(item['recipe']) do
        CallEvent("RemoveFromInventory", player, resource, amount)
    end

    CallRemoteEvent(player, "StartBuilding", item_key, json_encode(GetPlayerResources(player)))

    SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547) 
    SetPlayerHeading(player, -92.786437988281)   
    SetPlayerAnimation(player, "BARCLEAN01")
    Delay(15000, function()
        SetPlayerAnimation(player, "STOP")
        AddPlayerChat(player, item['name'].." has been added to your inventory.")
        AddToInventory(player, item_key)
    end)
end)

function GetPlayerResources(player)
    local inventory = GetPlayerPropertyValue(player, "inventory")
    local resources = {}
    for k,item in pairs(inventory) do
        if item['type'] == 'resource' then
            resources[k] = item['quantity']
        end
    end
    print(dump(resources))
    return resources
end