local SpawnLocation = { x = -102037, y = 194299, z = 1400 }
local PlayerRespawnTime = 20 * 1000 -- 20 secs

local AlienHealth = 999
local AlienLocations = {} -- aliens.json
local AlienAttackRange = 5000
local AlienSpawnInterval = 1 * 60 * 1000 -- spawn aliens every 30 mins

local LootLocations = {} -- lootpickups.json
local LootDropInterval = 5 * 60 * 1000 -- drop loot every 5 min (if players are nearby)

-- welcome message
function OnPlayerJoin(player)
    local x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 3000)
    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 90.0)
    SetPlayerRespawnTime(player, PlayerRespawnTime)
	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' has joined the server</>')
	AddPlayerChatAll('<span color="#eeeeeeaa">There are '..GetPlayerCount()..' players on the server</>')
    Delay(5000, function()
        CallRemoteEvent(player, "ShowBanner", "WELCOME TO THE<br/>INVASION", 5000)
    end)
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

function OnPlayerDeath(player, killer)
    AddPlayerChatAll(GetPlayerName(player)..' has been taken!')
    AddPlayerChat(player, "DEAD!  You must wait "..PlayerRespawnTime.." seconds to respawn...")
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

-- TODO remove
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

-- TODO remove
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
end
AddEvent("OnPackageStart", OnPackageStart)


function SetupAliens()
    local file = io.open("packages/"..GetPackageName().."/server/data/aliens.json", 'r')
    local contents = file:read("*a")
    AlienLocations = json_decode(contents);
    io.close(file)

    -- spawn all aliens
    SpawnAlienAreas()

    -- re-spawn on a timer
    CreateTimer(function()
        SpawnAlienAreas()
    end, AlienSpawnInterval)

    -- process timer for all aliens
    CreateTimer(function()
        for _,npc in pairs(GetAllNPC()) do
            if (GetNPCPropertyValue(npc, 'type') == 'alien') then
                ResetAlien(npc)
            end
        end
    end, 10000)
end

function SpawnAlienAreas()
    -- destroy any existing aliens
    for _,npc in pairs(GetAllNPC()) do
        if (GetNPCPropertyValue(npc, 'type') == 'alien') then
            -- only destroy aliens not currently attacking
            if (GetNPCPropertyValue(npc, 'target') == nil) then
                DestroyNPC(npc)
                print "despawned alien"
            end
        end
    end

    print "Spawning aliens..."

    -- create alien npcs
    for _,pos in pairs(AlienLocations) do
        local x,y = randomPointInCircle(pos[1], pos[2], 5000)
        CreateObject(303, x, y, pos[3]+100, 0, 0, 0, 10, 10, 200) -- TODO remove me

        local npc = CreateNPC(x, y, pos[3]+100, 90)
        SetNPCHealth(npc, AlienHealth)
        SetNPCPropertyValue(npc, 'type', 'alien')
        SetNPCPropertyValue(npc, 'clothing', math.random(23, 24))
        SetNPCPropertyValue(npc, 'location', pos)
        print "spawned alien"
    end
end

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
            print "despawned loot pickup"
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
    print "spawned loot pickup"
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

    --[[
    local percent_remaining = math.floor(health * 100 / AlienHealth)
    if (percent_remaining > 0) then
        local text = CreateText3D(percent_remaining..'%', 24, x, y, z + 140, 0, 0, 0)
        Delay(1000, function()
            DestroyText3D(text)
        end)
    end
    --]]

    if (health <= 0) then
        -- alien is dead
        local killer = GetNPCPropertyValue(npc, 'target')
        CallRemoteEvent(killer, 'AlienNoLongerAttacking')

        if (killer ~= nil) then
            AddPlayerChatAll(GetPlayerName(killer) .. ' has killed an alien!')
        end
        Delay(90000, function()
            DestroyNPC(npc)
        end)
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
    if (health == false or health <= 0) then
        return
    end

    local target, nearest_dist = GetNearestPlayer(npc)
    if (target~=0 and not IsPlayerDead(target)) then
        if (nearest_dist < AlienAttackRange) then
            SetNPCPropertyValue(npc, 'target', target, true)

            local veh = GetPlayerVehicle(target)
            if veh == 0 then
                SetNPCFollowPlayer(npc, target, 350)
            else
                SetNPCFollowVehicle(npc, veh, 400)
                if (nearest_dist < 2000) then
                    -- force player out of vehicle and disable it
                    RemovePlayerFromVehicle(target)
                    SetVehicleDamage(veh, math.random(1,8), 1.0)
                    -- remove it from game
                    Delay(60000, function()
                        DestroyVehicle(veh)
                    end)
                end
            end
            CallRemoteEvent(target, 'AlienAttacking', npc)
        elseif (GetNPCPropertyValue(npc, 'target') == target) then
            -- target is out of range, alien is sad
            local x, y, z = GetNPCLocation(npc)
            SetNPCTargetLocation(npc, x, y, z)
            SetNPCPropertyValue(npc, 'target', nil, true)
            CallRemoteEvent(target, 'AlienNoLongerAttacking', npc)
            -- wait a bit then walk back home, little alien
            Delay(15000, function()
                local location = GetNPCPropertyValue(npc, 'location')
                SetNPCTargetLocation(npc, location[1], location[2], location[3], 100)
            end)
        end
    end
end

function AttackNearestPlayer(npc)
    local target, nearest_dist = GetNearestPlayer(npc)
    if (target~=0 and nearest_dist==0.0) then
        if (not IsPlayerDead(target)) then
            -- insta-kill
            SetNPCAnimation(npc, "THROW", true)
            Delay(2000, function()
                SetPlayerHealth(target, 0)
                SetNPCPropertyValue(npc, 'target', nil, true)
                SetNPCAnimation(npc, "DANCE12", true)
            end)
            Delay(10000, function()
                local location = GetNPCPropertyValue(npc, 'location')
                SetNPCTargetLocation(npc, location[1], location[2], location[3], 800)
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

-- chat
function OnPlayerChat(player, message)
    local fullchatmessage = GetPlayerName(player)..' ('..player..'): '..message
    AddPlayerChatAll(fullchatmessage)
end
AddEvent("OnPlayerChat", OnPlayerChat)