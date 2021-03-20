local Workbenches = {}

AddEvent("OnPackageStart", function()
    log.info("Loading workbenches...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/workbench/workbenches.json")
    for _, config in pairs(_table) do
        CreateWorkbench(config)
    end
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all workbenches..."
    for _, object in pairs(Workbenches) do
        Workbenches[object] = nil
        DestroyObject(object)
    end
end)

function CreateWorkbench(config)
    log.debug("Creating workbench: " .. config.name)
    local object = CreateObject(config.modelID, config.x, config.y, config.z, config.rx, config.ry, config.rz,
                       config.sx, config.sy, config.sz)
    SetObjectPropertyValue(object, "prop", {
        use_label = "Interact",
        event = "StartWorkbench",
        options = {
            workbench = {
                id = config.id,
                name = config.name
            }
        }
    })
    Workbenches[object] = true
end

AddEvent("StartWorkbench", function(player, ActiveProp)
    log.debug("Workbench: " .. ActiveProp.options.workbench.id)
    if not ActiveProp.options.workbench then
        log.error("Cannot start non-workbench object")
        return
    end

    local item_data = {}
    for key, item in pairs(ItemConfig) do
        if item.recipe then
            table.insert(item_data, {
                item = key,
                name = item.name,
                modelid = item.modelid,
                image = item.image,
                recipe = item.recipe
            })
        end
    end

    local _send = {
        ["workbench_name"] = ActiveProp.options.workbench.name,
        ["item_data"] = item_data,
        ["player_resources"] = GetPlayerResources(player)
    }
    log.debug(dump(json_encode(_send)))
    CallRemoteEvent(player, "LoadWorkbenchData", json_encode(_send))
end)

AddRemoteEvent("BuildItem", function(player, item)
    if ItemConfig[item] == nil then
        return
    end

    -- start the build
    log.debug("Player " .. GetPlayerName(player) .. " builds item " .. ItemConfig[item].name)

    if not CanBuildItem(player, item) then
        log.debug(GetPlayerName(player) .. " does enough resources to build " .. item)
        AddPlayerChat(player, "You do not have the resources to build this!")
        CallRemoteEvent(player, "BuildDenied")
        return
    end

    -- remove scrap from inventory
    for resource_item, amount in pairs(ItemConfig[item].recipe) do
        local inventory_item = GetItemFromInventoryByName(player, resource_item)
        RemoveFromInventory(player, inventory_item.uuid, amount)
    end

    -- todo: would be better if workbench made the sound, not player
    local x,y,z = GetPlayerLocation(player)
    PlaySoundSync("sounds/workbench.mp3", x, y, z)

    SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547)
    SetPlayerHeading(player, -92.786437988281)
    SetPlayerAnimation(player, "BARCLEAN01")
    Delay(15000, function()
        SetPlayerAnimation(player, "STOP")

        local _send = {
            ["player_resources"] = GetPlayerResources(player)
        }
        CallRemoteEvent(player, "CompleteBuild", json_encode(_send))

        CallRemoteEvent(player, "ShowMessage", ItemConfig[item].name .. " has been added to your inventory")

        AddToInventoryByName(player, item)
    end)
end)

function GetPlayerResources(player)
    local inventory = PlayerData[player].inventory
    local resources = {}
    for _, item in pairs(inventory) do
        if ItemConfig[item.item].type == 'resource' then
            resources[item.item] = GetInventoryCountByName(player, item.item)
        end
    end
    return resources
end

-- whether or not player has required resources to build item
function CanBuildItem(player, item)
    if not ItemConfig[item] then
        return false
    end
    if not ItemConfig[item].recipe then
        return false
    end
    local resources = GetPlayerResources(player)

    local canBuild = true
    for required_item, required_amount in pairs(ItemConfig[item].recipe) do
        if not resources[required_item] or resources[required_item] < required_amount then
            canBuild = false
            break
        end
    end
    return canBuild
end
