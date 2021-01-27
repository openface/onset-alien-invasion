local VNPCS = ImportPackage("vnpcs")

local AlienHealth = 300
local AlienAttackRange = 5000
local AlienAttackDamage = 50
local SafeRange = 6000
local AlienRetargetCooldown = {} -- aliens re-target on every weapon hit w/ cooldown period
local AlienSpawnsEnabled = true
local AlienSpawnTimer
local AlienAttackTimer

AddCommand("alien", function(player)
    if not IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    SpawnAlienNearPlayer(player)
end)

AddCommand("togaliens", function(player)
    if not IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    AlienSpawnsEnabled = not AlienSpawnsEnabled
    log.info("Alien spawning is now ", AlienSpawnsEnabled)
end)

AddEvent("OnPackageStart", function()
    -- re-spawn on a timer
    AlienSpawnTimer = CreateTimer(function()
        SpawnAliens()
    end, 60000) -- alien spawn tick every minute

    -- process timer for all aliens
    AlienAttackTimer = CreateTimer(function()
        for _, npc in pairs(GetAllNPC()) do
            if (GetNPCPropertyValue(npc, 'type') == 'alien') then
                ResetAlien(npc)
            end
        end
    end, 10000) -- alien attack tick every 10 seconds
end)

AddEvent("OnPackageStop", function()
    ClearAliens()

    DestroyTimer(AlienSpawnTimer)
    DestroyTimer(AlienAttackTimer)
end)

function SpawnAliens()
    if AlienSpawnsEnabled ~= true then
        log.info "Alien spawning disabled."
        return
    end

    -- create alien npcs
    for _, ply in pairs(GetAllPlayers()) do
        if IsPlayerAttackable(ply) then
            -- chance to spawn
            if math.random(1, 2) == 1 then
                SpawnAlienNearPlayer(ply)
            end
        end
    end
end

function ClearAliens()
    for _, npc in pairs(GetAllNPC()) do
        if (GetNPCPropertyValue(npc, 'type') == 'alien') then
            DestroyNPC(npc)
        end
    end
end

function IsPlayerAttackable(player)
    if player == nil or player == 0 then return false end

    -- don't attack if player is in lobby (character selection)
    if GetPlayerDimension(player) ~= 0 then
        log.debug("Player " .. player .. " is in another dimension")
        return false
    end

    if IsPlayerDead(player) or not IsValidPlayer(player) then
        return false
    end

    if IsBossPresent() then return true end

    --if IsAdmin(GetPlayerSteamId(player)) then return false end

    -- don't attack if player is in safe zone
    local x, y, z = GetPlayerLocation(player)
    local distance = GetDistance3D(x, y, z, SpawnLocation.x, SpawnLocation.y, SpawnLocation.z)
    if distance < SafeRange then
        log.debug(GetPlayerName(player) .. " is in safe zone")
        return false
    end

    return true
end

function SpawnAlienNearPlayer(player)
    local x, y, z = GetPlayerLocation(player)
    local x, y = randomPointInCircle(x, y, AlienAttackRange + 500) -- some buffer
    -- CreateObject(303, x, y, z+100, 0, 0, 0, 10, 10, 200) -- TODO remove me
    local npc = CreateNPC(x, y, z + 100, 90)

    SetNPCHealth(npc, AlienHealth)
    SetNPCRespawnTime(npc, 99999999) -- disable respawns
    SetNPCPropertyValue(npc, 'type', 'alien')
    SetNPCPropertyValue(npc, 'location', {x, y, z})

    log.info("NPC (ID " .. npc .. ") spawned near player " .. GetPlayerName(player))
end

AddEvent("OnNPCSpawn", function(npc)
    if GetNPCPropertyValue(npc, 'type') == 'alien' then
        -- log.debug("OnNPCSpawn alien " .. npc)
        SetNPCHealth(npc, AlienHealth)

        local x, y, z = GetNPCLocation(npc)
        SetNPCPropertyValue(npc, 'location', {x, y, z})
    end
end)

-- damage aliens
AddEvent("OnPlayerWeaponShot",
    function(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
        if (hittype == HIT_NPC and GetNPCPropertyValue(hitid, "type") == "alien") then
            -- hack to get around a bug where OnNPCDeath 
            -- doesn't always report the killer
            SetNPCPropertyValue(hitid, "shotby", player)

            -- headshot bonus
            local x, y, z = GetNPCLocation(hitid)
            local zfloor = z - 90
            local health = GetNPCHealth(hitid)
            if hitz > zfloor + 150 then
                SetNPCHealth(hitid, health - 35)
            end

            -- chance that the alien runs away
            if math.random(1, 5) == 1 then
                AlienReturn(hitid)
                log.debug("Alien retreated " .. hitid)
                return
            end

            -- retarget w/ cooldown
            if (os.time() - (AlienRetargetCooldown[hitid] or 0) > 10) then
                SetAlienTarget(hitid, player)
                AlienRetargetCooldown[hitid] = os.time()
            end
        end
    end)

AddEvent("OnNPCDeath", function(npc, killer)
    local shotby = GetNPCPropertyValue(npc, "shotby")
    -- hack to get around a bug where OnNPCDeath 
    -- doesn't always report the killer
    if killer == 0 and shotby ~= nil then
        adjusted_killer = shotby
    else
        adjusted_killer = killer
    end
    if adjusted_killer ~= 0 then
        CallRemoteEvent(adjusted_killer, 'AlienNoLongerAttacking')
        AddPlayerChatAll(GetPlayerName(adjusted_killer) .. ' has killed an alien!')
        log.info("NPC (ID " .. npc .. ") killed by player " .. GetPlayerName(adjusted_killer))
        BumpPlayerStat(adjusted_killer, 'alien_kills')
    end
    SetNPCRagdoll(npc, true)
    VNPCS.StopVNPC(npc)
    Delay(120 * 1000, function()
        log.debug("NPC (ID " .. npc .. ") is dead.. despawning")
        DestroyNPC(npc)
    end)
end)

function SetAlienTarget(npc, player)
    if not IsPlayerAttackable(player) then
        return
    end

    SetNPCPropertyValue(npc, 'returning', nil)

    local vehicle = GetPlayerVehicle(player)
    if vehicle == 0 then
        -- target is on foot
        log.debug("NPC (ID " .. npc .. ") targets player " .. GetPlayerName(player))
        SetNPCPropertyValue(npc, 'target', player, true)

        -- alien has a new target
        --SetNPCFollowPlayer(npc, player, math.random(325, 360)) -- random speed
        VNPCS.SetVNPCFollowPlayer(npc, player, 50)

        CallRemoteEvent(player, 'AlienAttacking', npc)
    else
        -- target is in a vehicle
        log.debug("NPC (ID " .. npc .. ") targets player in vehicle: " .. GetPlayerName(player))
        SetNPCPropertyValue(npc, 'target', player, true)

        -- alien has a new target vehicle
        --SetNPCFollowVehicle(npc, vehicle, 400)
        VNPCS.SetVNPCFollowVehicle(npc, vehicle, 50)

        local x, y, z = GetNPCLocation(npc)
        local vx, vy, vz = GetVehicleLocation(vehicle)
        local dist = GetDistance3D(x, y, z, vx, vy, vz)
        if (dist < 1000) then
            -- force player out of vehicle and damage it
            RemovePlayerFromVehicle(player)
            CreateExplosion(1, vx, vy, vz, true, 1500, 100000)
            SetVehicleDamage(vehicle, math.random(1, 8), 1.0)
        end
        CallRemoteEvent(player, 'AlienAttacking', npc)
    end
end

-- alien tick
function ResetAlien(npc)
    local health = GetNPCHealth(npc)
    if (health == false or health <= 0) then
        return
    end

    local player, nearest_dist = GetNearestPlayer(npc)

    if IsPlayerAttackable(player) and nearest_dist < AlienAttackRange then
        -- we found a nearby target
        SetAlienTarget(npc, player)
    elseif (GetNPCPropertyValue(npc, 'target') == player) then
        log.debug("NPC (ID " .. npc .. ") target "..GetPlayerName(player).." is no longer attackable")
        -- target is out of range, stop following
        SetNPCPropertyValue(npc, 'target', nil, true)
        VNPCS.StopVNPC(npc)
        CallRemoteEvent(player, 'AlienNoLongerAttacking')

        -- wait a bit then walk back home, little alien
        Delay(15 * 1000, function()
            AlienReturn(npc)
        end)
    end
end

AddEvent("OnNPCDestroyed", function(npc)
    if GetNPCPropertyValue(npc, 'type') ~= 'alien' then
        return
    end

    log.info("Despawned alien "..npc)
    AlienRetargetCooldown[npc] = nil
end)

AddEvent("OnVNPCReachTargetFailed", function(npc)
    log.error("OnVNPCReachTargetFailed")
    if GetNPCPropertyValue(npc, 'type') ~= 'alien' then
        return
    end

    VNPCS.StopVNPC(npc)
    SetNPCAnimation(npc, "DONTKNOW", false)

    local target = GetNPCPropertyValue(npc, 'target')
    
    if target == nil then
        log.error("Alien is confused.  Despawning.")
        DestroyNPC(npc)
        return
    end

    if IsPlayerDead(target) or GetPlayerHealth(target) <= 0 then
        Delay(8000, function()
            AlienReturn(npc)
        end)
    else
       -- alien is stuck, summon an alien friend and go away
       log.debug("Stuck alien.. spawning a friend")
       SpawnAlienNearPlayer(target)
       AlienReturn(npc)
    end
end)

-- kills players when reached
AddEvent("OnVNPCReachTarget", function(npc)
    if GetNPCPropertyValue(npc, 'type') ~= 'alien' then
        return
    end
    log.debug("NPC (ID "..npc..") reached target")

    local health = GetNPCHealth(npc)
    if (health == false or health <= 0) then
        return
    end

    local returning = GetNPCPropertyValue(npc, 'returning')
    if returning == true then
        -- alien is back in starting position
        log.debug("NPC (ID " .. npc .. ") back at starting position.. despawning")
        DestroyNPC(npc)
        return
    end

    local target = GetNPCPropertyValue(npc, 'target')
    if target == nil then
        log.debug("NPC (ID " .. npc .. ") no longer has a target")
        -- alien reached a target but there is no target property?
        return
    end

    if IsPlayerDead(target) or not IsValidPlayer(target) then
        -- target was dead or gone when we got here
        log.debug("NPC (ID " .. npc ..") reached dead target")
        return
    end

    local x, y, z = GetNPCLocation(npc)
    local px, py, pz = GetPlayerLocation(target)
    local dist = GetDistance3D(x, y, z, px, py, pz)

    if dist < 200 then
        -- we're in close range, attack player
        -- TODO: this attack through walls, needs a line of sight check
        log.debug("NPC (ID " .. npc .. ") hit player " .. GetPlayerName(target))

        SetNPCAnimation(npc, "SHOUT01", false)

        ApplyPlayerDamage(target)
    elseif dist < 500 then
        -- occurs when player is behind an unreachable boundary
        log.debug("Player out of boundary")
        SetNPCAnimation(npc, "SHOUT01", false)
        return
    end

    SetAlienTarget(npc, target)
end)

function ApplyPlayerDamage(player)
    local armor = GetPlayerArmor(player)
    local health = GetPlayerHealth(player)

    if armor ~= false and armor > 0 then
        -- absorb damage
        SetPlayerArmor(player, armor - AlienAttackDamage)
        SetPlayerHealth(player, health - 10)
    else
        -- no armor, take full damage
        SetPlayerHealth(player, health - AlienAttackDamage)
    end

    CallRemoteEvent(player, "OnAlienHit")
end

-- return alien back to starting position
function AlienReturn(npc)
    if not IsValidNPC(npc) then
        return
    end

    log.debug("Alien is returning...")
    SetNPCPropertyValue(npc, 'returning', true)
    SetNPCPropertyValue(npc, 'target', nil, true)

    local location = GetNPCPropertyValue(npc, 'location')

    --SetNPCTargetLocation(npc, location[1], location[2], location[3], 800)
    VNPCS.SetVNPCTargetLocation(npc, location[1], location[2], location[3], 300)
end

-- get nearest player to npc
function GetNearestPlayer(npc)
    local plys = GetAllPlayers()
    local found = 0
    local nearest_dist = 999999.9
    local x, y, z = GetNPCLocation(npc)

    for _, v in pairs(plys) do
        local dim = GetPlayerDimension(v)
        if dim == 0 then
            local x2, y2, z2 = GetPlayerLocation(v)
            local dist = GetDistance3D(x, y, z, x2, y2, z2)
            if dist < nearest_dist then
                nearest_dist = dist
                found = v
            end
        end
    end
    return found, nearest_dist
end
