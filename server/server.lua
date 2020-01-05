local SpawnLocation = { x = -102037, y = 194299, z = 1400 }

local AlienNPCs = {}
local AlienHealth = 999
local AlienLocations = {} -- aliens.json
local AlienAttackRange = 5000

local LootPickups = {}
local LootLocations = {} -- lootpickups.json
local LootDropInterval = 5 * 60 * 1000

-- welcome message
function OnPlayerJoin(player)
    local x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 3000)
    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 90.0)
    SetPlayerRespawnTime(player, 15 * 1000)
	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' ('..player..') joined the server</>')
	AddPlayerChatAll('<span color="#eeeeeeaa">There are '..GetPlayerCount()..' players on the server</>')
    AddPlayerChat(player, "Welcome to the invasion!")
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

-- death message
function OnPlayerDeath(player, killer)
    AddPlayerChatAll(GetPlayerName(player)..' has been taken')
    AddPlayerChat(player, "DEAD!  You must wait 15 seconds to respawn...")
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

-- add alien pos
AddCommand("apos", function(playerid)
    local x, y, z = GetPlayerLocation(playerid)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(playerid, string)
    print(string)
    table.insert(AlienLocations, { x, y, z })

    local file = io.open("packages/"..GetPackageName().."/server/data/aliens.json", 'w')
    local contents = json_encode(AlienLocations)
    file:write(contents)
    io.close(file)
end)

AddCommand("loot", function(player)
    local x, y, z = GetPlayerLocation(player)
    local pos = { [1] = x, [2] = y, [3] = z }
    SpawnLootArea(pos)
end)

-- add loot pos
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

AddCommand("loc", function(playerid, x, y, z)
    if (x == nil) then
        local x, y, z = GetPlayerLocation(playerid)
        string = "Location: "..x.." "..y.." "..z
        AddPlayerChat(playerid, string)
        print(string)
        return
    end
    SetPlayerLocation(playerid, x, y, z + 150)
end)

-- Setup world
function OnPackageStart()
    SetupAliens()
    SetupLootPickups()

    -- one timer to rule them all
    CreateTimer(function()
        for _,npc in pairs(AlienNPCs) do
            ResetAlien(npc)
        end
    end, 10000, npc)
end
AddEvent("OnPackageStart", OnPackageStart)


function SetupAliens()
    print "Reading alien NPC positions..."
    local file = io.open("packages/"..GetPackageName().."/server/data/aliens.json", 'r')
    local contents = file:read("*a")
    AlienLocations = json_decode(contents);
    io.close(file)

    -- create alien npcs
    for _,pos in pairs(AlienLocations) do
        CreateObject(303, pos[1], pos[2], pos[3], 0, 0, 0, 10, 10, 200)

        npc = CreateNPC(pos[1], pos[2], pos[3], 90)
        SetNPCHealth(npc, AlienHealth)
        SetNPCPropertyValue(npc, 'clothing', math.random(23, 24))
        SetNPCPropertyValue(npc, 'location', pos)
        table.insert(AlienNPCs, npc)
    end
end

function SetupLootPickups()
    print "Reading loot pickups..."
    local file = io.open("packages/"..GetPackageName().."/server/data/lootpickups.json", 'r')
    local contents = file:read("*a")
    LootLocations = json_decode(contents);
    io.close(file)

    -- spawn random loot area
	loot_timer = CreateTimer(function()
        SpawnLootArea(LootLocations[ math.random(#LootLocations) ])
    end, LootDropInterval)
end

function SpawnLootArea(pos)
    -- destroy any existing loot pickups
    local pickups = GetAllPickups()
    for _,p in pairs(pickups) do
        if (GetPickupPropertyValue(p, 'type') == 'loot') then
            DestroyPickup(p)
            LootPickups[p] = nil
        end
    end

    players = GetPlayersInRange3D(pos[1], pos[2], pos[3], 50000)
    if next(players) == nil then
        return
    end

    print 'Spawning loot...'

    -- notify nearby players
    for _,ply in pairs(players) do
        CallRemoteEvent(ply, 'LootSpawnNearby', pos)
    end

    local pickup = CreatePickup(588, pos[1], pos[2], pos[3])
    SetPickupPropertyValue(pickup, 'type', 'loot')
    table.insert(LootPickups, pickup)
end

-- pickup loot
function OnPlayerPickupHit(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') == 'loot') then
        -- random weapon
        local slot = GetNextEmptySlot(player)
        SetPlayerWeapon(player, math.random(4,22), 450, true, slot, true)

        -- health
        CallRemoteEvent(player, 'HealthPickup')                
        SetPlayerHealth(player, 100)

        -- armor
        CallRemoteEvent(player, 'HealthPickup')
        SetPlayerArmor(player, 100)

        DestroyPickup(pickup)
        LootPickups[pickup] = nil
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

function OnNPCSpawn(npc)
    SetNPCHealth(npc, AlienHealth)
end
AddEvent("OnNPCSpawn", OnNPCSpawn)


-- damage aliens
function OnNPCDamage(npc, damagetype, amount)
    -- stop alien temporarily when damaged
    local x, y, z = GetNPCLocation(npc)
    SetNPCTargetLocation(npc, x, y, z)
    local health = GetNPCHealth(npc)
    local percent_remaining = math.floor(health * 100 / AlienHealth)
    if (percent_remaining > 0) then
        local text = CreateText3D(percent_remaining..'%', 24, x, y, z + 140, 0, 0, 0)
        Delay(1000, function()
            DestroyText3D(text)
        end)
    end

    if (health <= 0) then
        -- alien is dead
        local location = GetNPCPropertyValue(npc, 'location')
        local target = GetNPCPropertyValue(npc, 'target')
        SetNPCTargetLocation(npc, location[1], location[2], location[3])
        SetNPCPropertyValue(npc, 'target', nil, true)
        CallRemoteEvent(target, 'AlienNoLongerAttacking', npc)
    else
        -- keep attacking if still alive
        Delay(500, function(npc)
            ResetAlien(npc)
        end, npc)
    end
end
AddEvent("OnNPCDamage", OnNPCDamage)

function ResetAlien(npc)
    health = GetNPCHealth(npc)
    if (health <= 0) then
        return
    end

    local target, nearest_dist = GetNearestPlayer(npc)
    if (target~=0 and not IsPlayerDead(target)) then
        if (nearest_dist < AlienAttackRange) then
            SetNPCPropertyValue(npc, 'target', target, true)
            SetNPCFollowPlayer(npc, target, 350)
            CallRemoteEvent(target, 'AlienAttacking', npc)
        elseif (GetNPCPropertyValue(npc, 'target') == target) then
            local x, y, z = GetNPCLocation(npc)
            SetNPCTargetLocation(npc, x, y, z)
            SetNPCPropertyValue(npc, 'target', nil, true)
            CallRemoteEvent(target, 'AlienNoLongerAttacking', npc)
        end
    end
end

function AttackNearestPlayer(npc)
    local target, nearest_dist = GetNearestPlayer(npc)
    if (target~=0 and nearest_dist==0.0) then
        if (not IsPlayerDead(target)) then
            SetNPCAnimation(npc, "THROW", false)
            SetPlayerHealth(target, 0)
            SetNPCPropertyValue(npc, 'target', nil, true)
            SetNPCAnimation(npc, "DANCE12", true)
            Delay(5000, function()
                local location = GetNPCPropertyValue(npc, 'location')
                SetNPCTargetLocation(npc, location[1], location[2], location[3])
            end)
        end
    end
end
AddEvent("OnNPCReachTarget", AttackNearestPlayer)

-- get nearest player to npc
function GetNearestPlayer(npc)
	local plys = GetAllPlayers()
	local found = 0
	local nearest_dist = 999999.9
	local x, y, z = GetNPCLocation(npc)

	for _,v in pairs(plys) do
		local x2, y2, z2 = GetPlayerLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)
		if dist < nearest_dist then
			nearest_dist = dist
			found = v
		end
	end
	return found, nearest_dist
end

function randomPointInCircle(x, y, radius)
	local randX, randY
	repeat
		randX, randY = math.random(-radius, radius), math.random(-radius, radius)
	until (((-randX) ^ 2) + ((-randY) ^ 2)) ^ 0.5 <= radius
	return x + randX, y + randY
end