local LootLocations = {} -- lootpickups.json
local LootDropInterval = 3 * 60 * 1000 -- drop loot every 3 min (if players are nearby)

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

    local file = io.open("packages/"..GetPackageName().."/server/data/lootpickups.json", 'w')
    local contents = json_encode(LootLocations)
    file:write(contents)
    io.close(file)
end)


function SetupLootPickups()
    local file = io.open("packages/"..GetPackageName().."/server/data/lootpickups.json", 'r')
    local contents = file:read("*a")
    LootLocations = json_decode(contents);
    io.close(file)

    -- spawn random loot area
	local loot_timer = CreateTimer(function()
        SpawnLootArea(LootLocations[ math.random(#LootLocations) ])
    end, LootDropInterval)
end


function SpawnLootArea(pos)
    -- destroy any existing loot pickups
    local pickups = GetAllPickups()
    for _,p in pairs(pickups) do
        if (GetPickupPropertyValue(p, 'type') == 'loot') then
            --print "despawned loot pickup"
            DestroyPickup(p)
        end
    end

    players = GetPlayersInRange3D(pos[1], pos[2], pos[3], 50000)
    if next(players) == nil then
        return
    end

    print 'Spawning loot pickups...'

    -- notify nearby players
    for _,ply in pairs(players) do
        CallRemoteEvent(ply, 'LootSpawnNearby', pos)
    end

    local pickup = CreatePickup(588, pos[1], pos[2], pos[3])
    SetPickupPropertyValue(pickup, 'type', 'loot')
    --print "spawned loot pickup"
end

-- pickup loot
function OnPlayerPickupHit(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') == 'loot') then
        CallRemoteEvent(player, 'LootPickup')                

        -- random weapon
        local slot = GetNextEmptySlot(player)
        SetPlayerWeapon(player, math.random(4,22), 450, true, slot, true)
        SetPlayerHealth(player, 100)
        SetPlayerArmor(player, 100)

        DestroyPickup(pickup)
    end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)

function GetNextEmptySlot(player)
    -- slot 1 is reserved for fists
    for slot=2,3 do
        local w,a,m = GetPlayerWeapon(player, slot)
        if (w == 1) then
            return slot
        end          
    end
    return 2
end