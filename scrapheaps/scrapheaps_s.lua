local Scrapheaps = {}
local SearchCooldownSeconds = 60 * 5 -- can only search a scrap point every 5 minutes
local SearchCooldown = {}

-- weighted resource loot
-- higher weight == more common
local Resources = {
    computer_part = 1,
    wood = 3,
    plastic = 4,
    metal = 5
}
local CurrentlySearching = {}

AddEvent("OnPackageStart", function()
    log.info("Loading scrapheaps...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/scrapheaps/scrapheaps.json")
    for _, config in pairs(_table) do
        CreateScrapheap(config)
    end
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all scrapheaps..."
    for _, object in pairs(Scrapheaps) do
        Scrapheaps[object] = nil
        DestroyObject(object)

        -- clean cooldown list
        SearchCooldown = {}
    end
end)

function CreateScrapheap(config)
    log.debug("Creating scrapheap")
    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], config['rx'],
                           config['ry'], config['rz'], config['sx'], config['sy'], config['sz'])
    SetObjectPropertyValue(object, "prop", { message = "Search", remote_event = "SearchForScrap"})
    Scrapheaps[object] = true
end

AddCommand("scrap", function(player, amt)
    if not Player.IsAdmin(player) then
        return
    end
    local amt = amt or 1
    for i = 1, amt do
        PickupScrap(player)
    end
end)

-- search for scrap
AddRemoteEvent("prop:SearchForScrap", function(player, object, options)
    if CurrentlySearching[player] ~= nil then
        return
    end
    if not SearchCooldown[player] then
        SearchCooldown[player] = {}
    end

    if SearchCooldown[player][object] then
        if os.time() < SearchCooldown[player][object] then
            CallRemoteEvent(player, "ShowError", "Already searched here!")
            return
        end
    end

    CallRemoteEvent(player, "SearchingScrap")
    CurrentlySearching[player] = true
    SetPlayerAnimation(player, "PICKUP_MIDDLE")

    Delay(4000, function()
        CurrentlySearching[player] = nil

        -- chance to find scrap
        if math.random(1, 2) == 1 then
            -- found something
            PickupScrap(player)
            -- track time of last search for this player for cooldown period
            SearchCooldown[player][object] = (os.time() + SearchCooldownSeconds)
        else
            -- not found
            SearchCooldown[player][object] = nil
            AddPlayerChat(player, "You were unable to find anything useful.")
            log.debug("Player " .. GetPlayerName(player) .. " searched but found nothing.")
        end
    end)
end)

-- add scrap to inventory
function PickupScrap(player)
    -- generate loot table
    _resources = {}
    for k, v in next, Resources do
        for i = 1, v do
            _resources[#_resources + 1] = k
        end
    end

    local item = _resources[math.random(#_resources)]
    local item_cfg = GetItemConfig(item)
    if item_cfg ~= nil then
        AddPlayerChat(player, "Some " .. item .. " has been added to your inventory.")
        AddToInventory(player, item)
    end
end

