local BossInitialHealth = 3000
local BossDamageAmount = 5 -- hurts players this much every interval
local BossDamageRange = 10000
local WeaponData
local BossHealth = BossInitialHealth
local Boss
local BossTargetedLocation
local BossHurtTimer
local BossBombTimer
local BossKillers = {}

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

function SpawnBoss()
    if Boss ~= nil then
        -- boss is already spawned
        log.warn "Mothership already spawned"
        return
    end

    -- randomly pick a target
    local players = GetAllPlayers()
    local target = players[ math.random(#players) ]
    
    -- determine boss targeted location
    local x,y,z = GetPlayerLocation(target)
    BossTargetedLocation = { x = x, y = y, z = z }

    -- spawn boss randomly near the target
    log.info("Spawning boss on target "..GetPlayerName(target))
    local r_x,r_y = randomPointInCircle(BossTargetedLocation.x, BossTargetedLocation.y, BossDamageRange)

    Boss = CreateObject(91212, r_x, r_y, BossTargetedLocation.z+20000, 0, 0, 0, 20, 20, 20)
    SetObjectPropertyValue(Boss, "type", "boss")

    -- move down to earth over targeted player, slowly
    SetObjectMoveTo(Boss, BossTargetedLocation.x, BossTargetedLocation.y, BossTargetedLocation.z+7000, 1500)

    -- reset boss health
    BossHealth = BossInitialHealth

    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "SpawnBoss")
    end

    -- give it time for boss to land before attacking
    Delay(6000, StartBossFight)
end
AddEvent("SpawnBoss", SpawnBoss)

function StartBossFight()
    if Boss == nil or BossTargetedLocation == nil then
        -- boss is already spawned
        log.warn "Mothership not spawned"
        return
    end

    -- hurt all players near the initial targeted player every 5 seconds
    BossHurtTimer = CreateTimer(function()
        if Boss ~= nil then
            -- find targets within 3d range of initial target
            local targets = GetPlayersInRange3D(BossTargetedLocation.x, BossTargetedLocation.y, BossTargetedLocation.z, BossDamageRange)

            if next(targets) == nil then
                -- no targets found, mothership leaves
                log.warn "Mothership has no targets"
                DespawnBoss()
                return
            end

            log.debug("Boss targets: "..dump(targets))

            for _,ply in pairs(targets) do
                -- player may have disconnected
                if IsValidPlayer(ply) and not IsPlayerDead(ply) and GetPlayerDimension(ply) == 0 then
                    -- hurt player
                    CallRemoteEvent(ply, "BossHurtPlayer")
                    SetPlayerHealth(ply, GetPlayerHealth(ply) - BossDamageAmount)
                end
            end
        end
    end, 5 * 1000)

    -- random explosions on the ground
    BossBombTimer = CreateTimer(function()
        if BossTargetedLocation ~= nil then
            local ex,ey = randomPointInCircle(BossTargetedLocation.x, BossTargetedLocation.y, BossDamageRange)
            CreateExplosion(10, ex, ey, BossTargetedLocation.z, true, 15000, 1000000)
        end
    end, 2500)
end
AddEvent("StartBossFight", StartBossFight)

function DespawnBoss()
    if Boss == nil then
        return
    end

    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "DespawnBoss", Boss)
    end

    DestroyTimer(BossHurtTimer)
    DestroyTimer(BossBombTimer)
    DestroyObject(Boss)
    Boss = nil
    BossTargetedLocation = nil
    BossHealth = BossInitialHealth
    BossTargets = {}
    BossKillers = {}

    log.info "Mothership despawned"
end
    
AddEvent("OnPlayerWeaponShot", function(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
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
            log.debug("Adding boss killer "..player)
            BossKillers[player] = player
        end

        -- update boss health bar for everyone
        local players = GetAllPlayers()

        -- this is network intensive, so we only send health status
        -- when percentage is divisible by 5
        local percentage_health = math.floor(BossHealth / BossInitialHealth * 100.0)
        if first_hit or math.fmod(percentage_health, 5) == 0.0 then
            log.debug("Mothership health: "..percentage_health.."%")
            for _,ply in pairs(players) do
                CallRemoteEvent(ply, "SetBossHealth", percentage_health)
            end
        end

        -- explosions in the sky
        if (math.random(1,3) == 1) then
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

            AddPlayerChatAll("Mothership has been destroyed!")
            for _,ply in pairs(players) do
                CallRemoteEvent(ply, "ShowBanner", "MOTHERSHIP HAS BEEN DESTROYED!")
            end
            log.info "Mothership has been destroyed"

            --
            -- start new round
            --
            Delay(10000, function()
                for _,ply in pairs(players) do
                    CallRemoteEvent(ply, "ShowBanner", "NEW GAME BEGINS NOW!")
                end

                -- respawn all computer parts
                SpawnParts()

                -- respawn all vehicles
                SpawnVehicles()
                
                -- reset satellite status for everyone
                UpdateAllPlayersSatelliteStatus(0)
            end)
        end
    end
end)
