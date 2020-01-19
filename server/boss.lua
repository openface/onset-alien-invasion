local BossSpawnInterval = 10 * 60 * 1000
local BossDespawnDelay = 35 * 1000 -- how long does boss stay around
local BossInitialHealth = 999
local BossDamageInterval = 5 * 1000 -- hurts players every 5 seconds
local BossDamageAmount = 5 -- hurts players this much every interval
local BossDamageRange = 8000

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

    local players = GetAllPlayers()
    if #players == 0 then
        return
    end

    -- random pick a player target
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

    BossRotationTimer = CreateTimer(function(Boss)
        local x,y,z = GetObjectRotation(Boss)
        SetObjectRotation(Boss, x, y+1, z)
    end, 50, Boss)

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
        local ex,ey = randomPointInCircle(x, y, BossDamageRange)
        --CreateObject(303, ex, ey, z, 0, 0, 0, 10, 10, 200) -- TODO remove me
        CreateExplosion(10, ex, ey, z, true, 15000, 1000000)
    end, 2500, 14, x, y, z)
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

    AddPlayerChatAll("The mothership has left.")
    
end
    
function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
	if (hittype == HIT_OBJECT and GetObjectPropertyValue(hitid, "type") == "boss") then
        BossHealth = BossHealth - 10

        local players = GetAllPlayers()
        for _,ply in pairs(players) do
            CallRemoteEvent(ply, "UpdateBossHealth", BossHealth, BossInitialHealth)
	    end

        -- explosions in the sky
        if (math.random(1,5) == 1) then
            CreateExplosion(6, hitx, hity, hitz, true)
        end

        if BossHealth <= 0 then
            local x,y,z = GetObjectLocation(hitid)

            -- explosions in the sky
            CreateCountTimer(function()
                local ex,ey = randomPointInCircle(x, y, 5000)
                CreateExplosion(9, ex, ey, z, true)
            end, 300, 20)
            
            DespawnBoss()
            BossHealth = nil

            AddPlayerChatAll("Mothership is destroyed!")

            for _,ply in pairs(players) do
                CallRemoteEvent(ply, "ShowBanner", "MOTHERSHIP IS DOWN!", 5000)
            end
        end
    end
end
AddEvent("OnPlayerWeaponShot", OnPlayerWeaponShot)
