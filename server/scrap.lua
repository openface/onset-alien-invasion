local ScrapCooldown = 60000 * 5 -- can only search a scrap point every 10 minutes
-- weighted resource loot
-- higher weight == more common
local Resources = {
    computer_part = 1,
    wood = 3,
    plastic = 4,
    metal = 5
}
local CurrentlySearching = {}

AddCommand("scrap", function(player, amt)
    if not IsAdmin(player) then
        return
    end
    local amt = amt or 1
    for i = 1, amt do
        PickupScrap(player)
    end
end)

AddEvent("OnPackageStart", function()
end)

AddEvent("OnPackageStop", function()
end)

-- search for scrap
AddRemoteEvent("SearchForScrap", function(player)
    if CurrentlySearching[player] ~= nil then
        return
    end

    CallRemoteEvent(player, "SearchingScrap")
    CurrentlySearching[player] = true
    SetPlayerAnimation(player, "PICKUP_LOWER")

    Delay(4000, function()
        CurrentlySearching[player] = nil

        -- chance to find scrap
        if math.random(1, 3) == 1 then
            -- found something
            PickupScrap(player)
        else
            -- not found
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
        AddPlayerChat(player, "Some "..item.." has been added to your inventory.")
        AddToInventory(player, item)
    end
end

