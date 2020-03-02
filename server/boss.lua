local BossInitialHealth = 999
local BossDamagePerHit = 5 -- amount of damage boss takes per player hit
local BossDamageAmount = 5 -- hurts players this much every interval
local BossDamageRange = 8000

local BossHealth = BossInitialHealth
local Boss
local BossRotationTimer
local BossHurtTimer
local BossBombTimer
local BossKillers = {}
local BossTargets = {}

AddCommand("boss", function(player)
    if not IsAdmin(player) then
        return
    end
    SpawnBoss()
end)

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
    BossTargets = GetPlayersInRange3D(x, y, z, BossDamageRange)

    -- spawn boss around the target
    Boss = CreateObject(1164, x, y, z+10000, 0, 0, 0, 35, 35, 35)
    SetObjectPropertyValue(Boss, "type", "boss")
    BossHealth = BossInitialHealth

    print("Spawning boss on target "..GetPlayerName(target))

    -- spin
    BossRotationTimer = CreateTimer(function()
        local x,y,z = GetObjectRotation(Boss)
        SetObjectRotation(Boss, x, y+1, z)
    end, 50)

    -- hurt all targeted players every 5 seconds
    BossHurtTimer = CreateTimer(function()
        if Boss ~= nil then
            if next(BossTargets) == nil then
                print "Mothership has no targets"
                DespawnBoss()
                return
            end

            for _,ply in pairs(BossTargets) do
                -- player may have disconnected
                if IsValidPlayer(ply) and not IsPlayerDead(ply) and GetPlayerDimension(ply) == 0 then
                    CallRemoteEvent(ply, "BossHurtPlayer")
                    SetPlayerHealth(ply, GetPlayerHealth(ply) - BossDamageAmount)
                else
                    print("Mothership no longer targeting player "..ply)
                    table.remove(BossTargets, ply)
                end
            end
        end
    end, 5 * 1000)

    -- random explosions on the ground
    BossBombTimer = CreateTimer(function(x, y, z)
        if Boss ~= nil then
            local ex,ey = randomPointInCircle(x, y, BossDamageRange)
            CreateExplosion(10, ex, ey, z, true, 15000, 1000000)
        end
    end, 2500, x, y, z)
end
AddEvent("SpawnBoss", SpawnBoss)

function DespawnBoss()
    if Boss == nil then
        return
    end

    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "DespawnBoss")
    end

    DestroyTimer(BossRotationTimer)
    DestroyTimer(BossHurtTimer)
    DestroyTimer(BossBombTimer)
    DestroyObject(Boss)
    Boss = nil
    BossHealth = BossInitialHealth
    BossTargets = {}
    BossKillers = {}

    print "Mothership despawned"
end
    
function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
    if (hittype == HIT_OBJECT and GetObjectPropertyValue(hitid, "type") == "boss") then

        if BossHealth == BossInitialHealth then
            first_hit = true
        else 
            first_hit = false
        end

        -- apply damage to boss
        BossHealth = BossHealth - BossDamagePerHit

        -- anyone who fires on boss gets credit for the kill
        if BossKillers[player] == nil then
            print("Adding boss killer "..player)
            BossKillers[player] = player
        end

        -- update boss health bar for everyone
        local players = GetAllPlayers()

        -- this is network intensive, so we only send health status
        -- when percentage is divisible by 5
        local percentage_health = math.floor(BossHealth / BossInitialHealth * 100.0)
        if first_hit or math.fmod(percentage_health, 5) == 0.0 then
            print("Mothership health: "..percentage_health.."%")
            for _,ply in pairs(players) do
                CallRemoteEvent(ply, "UpdateBossHealth", percentage_health)
            end
        end

        -- explosions in the sky
        if (math.random(1,5) == 1) then
            CreateExplosion(6, hitx, hity, hitz, true)
        end

        -- boss kill
        if BossHealth <= 0 then
            -- explosions in the sky
            local x,y,z = GetObjectLocation(hitid)
            CreateCountTimer(function()
                local ex,ey = randomPointInCircle(x, y, 5000)
                CreateExplosion(9, ex, ey, z, true, 10000.0, 1000)
            end, 300, 20)
            
            -- update scoreboard
            for _,ply in pairs(BossKillers) do
                BumpPlayerStat(ply, "boss_kills")
            end

            DespawnBoss()
            SpawnParts()

            AddPlayerChatAll("Mothership has been destroyed!")
            for _,ply in pairs(players) do
                CallRemoteEvent(ply, "ShowBanner", "MOTHERSHIP HAS BEEN DESTROYED!")
            end
            print "Mothership has been destroyed"
        end
    end
end
AddEvent("OnPlayerWeaponShot", OnPlayerWeaponShot)
