local BossSpawnInterval = 10 * 60 * 1000
local BossDespawnDelay = 35 * 1000 -- how long does boss stay around
local BossInitialHealth = 999
local BossDamageInterval = 5 * 1000 -- hurts players every 5 seconds
local BossDamageAmount = 5 -- hurts players this much every interval
local BossDamageRange = 10000

local BossHealth
local Boss
local BossRotationTimer

-- TODO remove
AddCommand("boss", function(player)
    SpawnBoss()
end)

function SetupBoss()
    -- process timer for the boss
    CreateTimer(function()
        SpawnBoss()        
    end, BossSpawnInterval)
end

function SpawnBoss()
    if Boss ~= nil then
        DespawnBoss()
        return
    end

    -- random pick a player target
    local players = GetAllPlayers()
    local target = players[ math.random(#players) ]
    local x,y,z = GetPlayerLocation(target)

    local x,y = randomPointInCircle(x, y, BossDamageRange)

    -- target all players in area
    local targeted_players = GetPlayersInRange3D(x, y, z, BossDamageRange)

    -- spawn boss around the target
    Boss = CreateObject(1164, x, y, z+10000, 0, 0, 0, 35, 35, 35)
    SetObjectPropertyValue(Boss, "type", "boss")
    if BossHealth == nil then
        BossHealth = BossInitialHealth
    end
    SetObjectPropertyValue(Boss, "health", BossHealth)

    print("Spawning boss with "..BossHealth.." health on target "..GetPlayerName(target))

    BossRotationTimer = CreateTimer(function()
        local x,y,z = GetObjectRotation(Boss)
        SetObjectRotation(Boss, x, y+1, z)
    end, 50)

    -- hurt all targeted players
    CreateCountTimer(function(targeted_players)
        for _,ply in pairs(targeted_players) do
            CallRemoteEvent(ply, "HurtPlayer")
            SetPlayerHealth(ply, GetPlayerHealth(ply) - BossDamageAmount)
        end
    end, BossDamageInterval, math.floor(BossDespawnDelay / BossDamageInterval), targeted_players)
    Delay(BossDespawnDelay, DespawnBoss)

    -- random explosions
    CreateCountTimer(function(x, y, z)
        local ex,ey = randomPointInCircle(x, y, math.floor(BossDamageRange / 2))
        CreateExplosion(10, ex, ey, z, true, 15000, 1000000)
    end, 6000, 5, x, y, z)
end

function DespawnBoss()
    if Boss == nil then
        return
    end

    DestroyTimer(BossRotationTimer)
    DestroyObject(Boss)
    Boss = nil

    Delay(5000, function()
        local players = GetAllPlayers()
        for _,ply in pairs(players) do
            CallRemoteEvent(ply, "DespawnBoss")
        end
    end)
end
    
function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
	if (hittype == HIT_OBJECT and GetObjectPropertyValue(hitid, "type") == "boss") then
        BossHealth = BossHealth - 10

        local players = GetAllPlayers()
        for _,ply in pairs(players) do
            CallRemoteEvent(ply, "UpdateBossHealth", BossHealth, BossInitialHealth)
	    end

        if (math.random(1,5) == 1) then
            CreateExplosion(6, hitx, hity, hitz, true)
        end

        if BossHealth <= 0 then
            local x,y,z = GetObjectLocation(hitid)
            CreateExplosion(9, x, y, z, true, 15000, 1000000)

            DespawnBoss()
            BossHealth = nil

            AddPlayerChatAll("Boss is destroyed!")
        end
    end
end
AddEvent("OnPlayerWeaponShot", OnPlayerWeaponShot)
