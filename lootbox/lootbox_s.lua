local LootLocations = {} -- lootpickups.json
local LootDropInterval = 5 * 60 * 1000 -- drop loot every 5 min (if players are nearby)
local LootWeapons = { 'ak47', 'ak47g', 'auto_shotgun', 'shotgun', 'm16a4', 'ump', 'uzi' }
local LootTimer

AddCommand("loot", function(player)
    if not IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    local pos = { [1] = x, [2] = y, [3] = z }
    SpawnLootArea(pos)
end)

AddCommand("lpos", function(player)
    if not IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(player, string)
    log.debug(string)
    table.insert(LootLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/lootbox/lootboxes.json", LootLocations)
end)

AddEvent("OnPackageStart", function()
    LootLocations = File_LoadJSONTable("packages/"..GetPackageName().."/lootbox/lootboxes.json")

    -- spawn random loot area
	  LootTimer = CreateTimer(function()
        SpawnLootArea(LootLocations[ math.random(#LootLocations) ])
    end, LootDropInterval)
end)

AddEvent("OnPackageStop", function()
    DestroyLootPickups()
    DestroyTimer(LootTimer)
end)

function SpawnLootArea(pos)
    local players = GetAllPlayers()
    if next(players) == nil then
        return
    end

    log.debug 'Spawning loot pickup...'

    -- destroy any existing loot pickups
    DestroyLootPickups()

    -- parachute is the lootdrop object
    local lootdrop = CreateObject(819, pos[1], pos[2], pos[3]+20000)
    SetObjectPropertyValue(lootdrop, 'type', 'lootdrop')

    -- attach a crate
    local box = CreateObject(588, pos[1], pos[2], pos[3]+30000)
    SetObjectAttached(box, ATTACH_OBJECT, lootdrop, 0, 0, 10)

    -- move parachute to location
    SetObjectMoveTo(lootdrop, pos[1], pos[2], pos[3] - 50, 750)

    -- notify players loot is dropping
    for _,p in pairs(players) do
        CallRemoteEvent(p, "LootDropping", pos[1], pos[2], pos[3])        
    end
end

function DestroyLootPickups()
    local pickups = GetAllPickups()
    for _,p in pairs(pickups) do
        if (GetPickupPropertyValue(p, 'type') == 'loot') then
            DestroyPickup(p)
        end
    end
end

-- spawn pickup once lootbox lands
AddEvent("OnObjectStopMoving", function(object)
    if GetObjectPropertyValue(object, 'type') ~= 'lootdrop' then 
        return 
    end

    -- get attached create
    local attach_type, box = GetObjectAttachmentInfo(object)

    local x,y,z = GetObjectLocation(object)

    DestroyObject(object)
    DestroyObject(box)

    -- create pickup
    local pickup = CreatePickup(588, x, y, z)
    SetPickupPropertyValue(pickup, 'type', 'loot')

    -- notify players
    for _,p in pairs(GetAllPlayers()) do
        CallRemoteEvent(p, 'LootSpawned', pickup, x, y, z)
    end
end)

-- pickup loot
AddEvent("OnPlayerPickupHit", function(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') ~= 'loot') then
        return
    end

    -- add loot items to inventory
    AddLootItem(player, 'vest')
    AddLootItem(player, 'bandage')
    AddLootItem(player, LootWeapons[math.random(#LootWeapons)])

    DestroyPickup(pickup)

    BumpPlayerStat(player, "loot_collected")
    AddPlayerChatAll(GetPlayerName(player)..' has picked up a lootbox!')
    log.debug(GetPlayerName(player)..' has picked up a lootbox')

    CallRemoteEvent(player, "LootPickedup")

    -- remove waypoint for others
    for _,p in pairs(GetAllPlayers()) do
        CallRemoteEvent(p, "HideLootWaypoint")
    end
end)

function AddLootItem(player, item)
    if ItemConfig[item] then
        local uuid = RegisterNewItem(item)
        AddToInventory(player, uuid)
        CallRemoteEvent(player, "ShowMessage", "You picked up a "..ItemConfig[item].name)
    end
end

