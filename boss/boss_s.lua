local BossInitialHealth = 3000
local BossDamageRange = 10000
local WeaponData
local BossHealth = BossInitialHealth
local Boss
local BossTargetedLocation
local BossBombTimer
local BossKillers = {}
local MAX_BOSS_DURATION = 1000 * 90 -- 90 seconds
local FakeBossModelID = 91212

AddEvent("OnPackageStart", function()
    WeaponData = File_LoadJSONTable("weapons.json")["weapons"]
end)

AddEvent("OnPackageStop", function()
    DespawnBoss()
end)

AddCommand("boss", function(player)
    if not IsAdmin(player) then
        return
    end
    CallEvent("SpawnBoss")
end)

AddCommand("noboss", function(player)
    if not IsAdmin(player) then
        return
    end
    DespawnBoss()
end)

function IsBossPresent()
    return Boss ~= nil
end

function SpawnBoss()
    if Boss ~= nil then
        -- boss is already spawned
        log.warn "Mothership already spawned"
        return
    end

    -- randomly pick a target
    local players = GetAllPlayers()
    local target = players[math.random(#players)]

    -- determine boss targeted location
    local x, y, z = GetPlayerLocation(target)
    BossTargetedLocation = {
        x = x,
        y = y,
        z = z
    }

    -- spawn boss randomly near the target
    log.info("Spawning boss on target " .. GetPlayerName(target))
    local from_x, from_y = randomPointInCircle(BossTargetedLocation.x, BossTargetedLocation.y, BossDamageRange + 10000)

    Boss = CreateObject(FakeBossModelID, from_x, from_y, BossTargetedLocation.z + 20000)
    SetObjectPropertyValue(Boss, "type", "boss")

    -- move down to earth towards targeted player, slowly
    local to_x, to_y = randomPointInCircle(BossTargetedLocation.x, BossTargetedLocation.y, BossDamageRange - 5000)

    SetObjectMoveTo(Boss, to_x, to_y, BossTargetedLocation.z + 7000, 2500)

    -- reset boss health
    BossHealth = BossInitialHealth  

    -- give it time for boss to land before attacking
    Delay(6000, StartBossFight)

    Delay(10000, function()
        for i = 1,7 do 
            SpawnAlienNearPlayer(target)
        end
    end)
end
AddEvent("SpawnBoss", SpawnBoss)

function StartBossFight()
    if Boss == nil or BossTargetedLocation == nil then
        -- boss is already spawned
        log.warn "Mothership not spawned"
        return
    end

    -- random explosions on the ground
    BossBombTimer = CreateTimer(function()
        if BossTargetedLocation ~= nil then
            local ex, ey = randomPointInCircle(BossTargetedLocation.x, BossTargetedLocation.y, BossDamageRange)
            CreateExplosion(10, ex, ey, BossTargetedLocation.z, true, 15000, 1000000)
        end
    end, 2500)

    Delay(MAX_BOSS_DURATION, DespawnBoss)
end
AddEvent("StartBossFight", StartBossFight)

function DespawnBoss()
    if Boss == nil then
        return
    end

    for _, ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "DespawnBoss", Boss)
    end

    DestroyTimer(BossBombTimer)
    DestroyObject(Boss)
    Boss = nil
    BossTargetedLocation = nil
    BossHealth = BossInitialHealth
    BossKillers = {}

    log.info "Mothership despawned"
end

AddEvent("OnPlayerWeaponShot",
    function(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
        if (hittype == HIT_OBJECT and GetObjectPropertyValue(hitid, "type") == "boss") then

            if BossHealth == BossInitialHealth then
                first_hit = true
            else
                first_hit = false
            end

            -- apply weapon damage to boss
            BossHealth = BossHealth - WeaponData[weapon]["Damage"]

            -- anyone who fires on boss gets credit for the kill
            if BossKillers[player] == nil then
                log.debug("Adding boss killer " .. player)
                BossKillers[player] = player
            end

            -- update boss health bar for everyone
            local players = GetAllPlayers()

            -- this is network intensive, so we only send health status
            -- when percentage is divisible by 5
            local percentage_health = math.floor(BossHealth / BossInitialHealth * 100.0)
            if first_hit or math.fmod(percentage_health, 5) == 0.0 then
                log.debug("Mothership health: " .. percentage_health .. "%")
                for _, ply in pairs(players) do
                    CallRemoteEvent(ply, "SetBossHealth", percentage_health)
                end
            end

            -- explosions in the sky
            if (math.random(1, 3) == 1) then
                CreateExplosion(6, hitx, hity, hitz, true)
            end

            -- boss kill
            if BossHealth <= 0 then
                -- explosions in the sky
                local x, y, z = GetObjectLocation(hitid)
                CreateCountTimer(function()
                    local ex, ey = randomPointInCircle(x, y, 5000)
                    CreateExplosion(9, ex, ey, z, true, 10000.0, 1000)
                end, 300, 20)

                -- update scoreboard
                for _, ply in pairs(BossKillers) do
                    BumpPlayerStat(ply, "boss_kills")
                end

                DespawnBoss()

                for _, ply in pairs(players) do
                    CallRemoteEvent(ply, "ShowBanner", "MOTHERSHIP HAS BEEN DEFEATED!")
                end
                log.info "Mothership has been defeated"
            end
        end
    end)
