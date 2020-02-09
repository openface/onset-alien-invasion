local LootLocations = {} -- lootpickups.json
local LootDropInterval = 4 * 60 * 1000 -- drop loot every 4 min (if players are nearby)

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

function OnPackageStart()
    LootLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/lootpickups.json")

    -- spawn random loot area
	local loot_timer = CreateTimer(function()
        SpawnLootArea(LootLocations[ math.random(#LootLocations) ])
    end, LootDropInterval)
end
AddEvent("OnPackageStart", OnPackageStart)

function SpawnLootArea(pos)
    local players = GetAllPlayers()
    if next(players) == nil then
        return
    end

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
    for _,p in pairs(players) do
        CallRemoteEvent(p, 'LootSpawned', pos, pickup)
    end
end

-- pickup loot
function OnPlayerPickupHit(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') != 'loot') then
        return
    end

    CallRemoteEvent(player, 'LootPickedup', pickup)

    -- random weapon
    SetPlayerWeapon(player, math.random(6,20), 450, true, 1, true)
    SetPlayerHealth(player, 100)

    -- full armor
    SetPlayerArmor(player, 100)
    EquipVest(player)       

    DestroyPickup(pickup)

    BumpPlayerStat(player, "loot_collected")
    AddPlayerChatAll(GetPlayerName(player)..' has picked up a lootbox!')
    
    -- remove waypoint for others
    for _,p in pairs(GetAllPlayers()) do
        CallRemoteEvent(p, "HideLootWaypoint")
    end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)

function EquipVest(player)
    local x,y,z = GetPlayerLocation(player)
    local vest = CreateObject(843, x, y, z)
    SetObjectAttached(vest, ATTACH_PLAYER, player, -17, 0, 0, 270, 0, 0, "spine_02")
    SetPlayerPropertyValue(player, "equippedVest", vest)
end