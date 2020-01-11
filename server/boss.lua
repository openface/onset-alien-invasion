local BossSpawnInterval = 30 * 1000
local BossDespawnDelay = 20 * 1000
local BossObjectId = 1164
local BossInitialHealth = 999
local BossDamageInterval = 10 * 1000 -- hurts players every 10 seconds
local BossDamageAmount = 1 -- hurts players this much every interval

local BossHealth
local Boss

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

    Boss = CreateObject(BossObjectId, SpawnLocation.x, SpawnLocation.y, 12000, 0, 0, 0, 35, 35, 35)
    SetObjectPropertyValue(Boss, "type", "boss")

    if BossHealth == nil then
        BossHealth = BossInitialHealth
    end
    SetObjectPropertyValue(Boss, "health", BossHealth)

    print("spawning boss with "..BossHealth.." health")

    local timer = CreateTimer(HurtPlayers, BossDamageInterval)
    
    Delay(BossDespawnDelay, DespawnBoss, timer)  
end

function HurtPlayers()
    local players = GetAllPlayers()
    for _,ply in pairs(players) do
        CallRemoteEvent(ply, "HurtPlayer")
        SetPlayerHealth(ply, GetPlayerHealth(ply) - BossDamageAmount)
    end
end

function DespawnBoss(timer)
    if Boss == nil then
        return
    end
    print "despawning boss"
    DestroyObject(Boss)
    Boss = nil
    DestroyTimer(timer)

    local players = GetAllPlayers()
    for _,ply in pairs(players) do
        CallRemoteEvent(ply, "DespawnBoss")
    end
end
    
function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
	if (hittype == HIT_OBJECT and GetObjectPropertyValue(hitid, "type") == "boss") then
        AddPlayerChatAll(GetPlayerName(player) .. " is attacking the boss!")
        BossHealth = BossHealth - 10

        local players = GetAllPlayers()
        for _,ply in pairs(players) do
            CallRemoteEvent(ply, "UpdateBossHealth", BossHealth, BossInitialHealth)
	    end

        if (math.random(1,5) == 1) then
            CreateExplosion(9, hitx, hity, hitz, true, 15000, 1000000)
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
