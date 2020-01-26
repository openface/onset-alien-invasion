local LootLocations = {} -- lootpickups.json
local LootDropInterval = 2 * 60 * 1000 -- drop loot every 2 min (if players are nearby)

-- TODO remove
AddCommand("loot", function(player)
    local x, y, z = GetPlayerLocation(player)
    local pos = { [1] = x, [2] = y, [3] = z }
    SpawnLootArea(pos)
end)

-- TODO remove
AddCommand("lpos", function(playerid)
    local x, y, z = GetPlayerLocation(playerid)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(playerid, string)
    print(string)
    table.insert(LootLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/lootpickups.json", LootLocations)
end)

function SetupLootPickups()
    LootLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/lootpickups.json")

    -- spawn random loot area
	local loot_timer = CreateTimer(function()
        SpawnLootArea(LootLocations[ math.random(#LootLocations) ])
    end, LootDropInterval)
end

function SpawnLootArea(pos)
    print 'Spawning loot pickup...'

    -- destroy any existing loot pickups
    local pickups = GetAllPickups()
    for _,p in pairs(pickups) do
        if (GetPickupPropertyValue(p, 'type') == 'loot') then
            DestroyPickup(p)
        end
    end

    local pickup = CreatePickup(588, pos[1], pos[2], pos[3])
    SetPickupPropertyValue(pickup, 'type', 'loot')

    -- notify players
    local players = GetAllPlayers()
    for _,p in pairs(players) do
        CallRemoteEvent(p, 'LootSpawned', pos, pickup)
    end
end

-- pickup loot
function OnPlayerPickupHit(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') == 'loot') then
        CallRemoteEvent(player, 'LootPickedup', pickup)

        -- random weapon
        SetPlayerWeapon(player, math.random(6,20), 450, true, 1, true)
        SetPlayerHealth(player, 100)
        SetPlayerArmor(player, 100)

        DestroyPickup(pickup)

        AddPlayerChatAll(GetPlayerName(player)..' has picked up a lootbox!')        
    end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)
