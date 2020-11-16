local AlienHealth = 300
local AlienAttackRange = 5000
local AlienAttackDamage = 50
local SafeLocation = {
    x = -102037,
    y = 194299,
    z = 1400
}
local SafeRange = 5000
local AlienRetargetCooldown = {} -- aliens re-target on every weapon hit w/ cooldown period
local AlienSpawnsEnabled = true

AddCommand("alien", function(player)
    if not Player.IsAdmin(player) then
        return
    end
    SpawnAlienNearPlayer(player)
end)

AddCommand("togaliens", function(player)
    if not Player.IsAdmin(player) then
        return
    end
    AlienSpawnsEnabled = not AlienSpawnsEnabled
    log.info("Alien spawning is now ", AlienSpawnsEnabled)
end)

AddEvent("OnPackageStart", function()
    -- re-spawn on a timer
    CreateTimer(function()
        SpawnAliens()
    end, 60000) -- alien spawn tick every minute

    -- process timer for all aliens
    CreateTimer(function()
        for _, npc in pairs(GetAllNPC()) do
            if (GetNPCPropertyValue(npc, 'type') == 'alien') then
                ResetAlien(npc)
            end
        end
    end, 10000) -- alien attack tick every 10 seconds
end)

AddEvent("OnPackageStop", function()
    AlienRetargetCooldown = {}
    for _, npc in pairs(GetAllNPC()) do
        if (GetNPCPropertyValue(npc, 'type') == 'alien') then
            DestroyNPC(npc)
        end
    end
end)

function SpawnAliens()
    if AlienSpawnsEnabled ~= true then
        log.info "Alien spawning disabled."
        return
    end

    -- calculate spawn density based on satellite status
    local satellite_percentage = GetSatelliteStatus()
    if satellite_percentage >= 80 then
        chance = 1
    elseif satellite_percentage >= 60 then
        chance = 2
    elseif satellite_percentage >= 40 then
        chance = 2
    elseif satellite_percentage >= 20 then
        chance = 3
    else
        chance = 3
    end

    -- create alien npcs
    for _, ply in pairs(GetAllPlayers()) do
        if IsPlayerAttackable(ply) then
            -- chance to spawn
            if math.random(1, chance) == 1 then
                SpawnAlienNearPlayer(ply)
            end

            -- spawn boss randomly
            if satellite_percentage >= 60 and math.random(1, 3) then
                CallEvent("SpawnBoss")
            end
        end
    end
end

function IsPlayerAttackable(player)
    if player == nil then return false end

    -- don't attack if player is in lobby (character selection)
    if GetPlayerDimension(player) ~= 0 then
        log.debug("Player " .. player .. " is in another dimension")
        return false
    end

    -- don't attack if player is in safe zone
    local x, y, z = GetPlayerLocation(player)
    local distance = GetDistance3D(x, y, z, SafeLocation.x, SafeLocation.y, SafeLocation.z)
    if distance < SafeRange then
        log.debug(GetPlayerName(player) .. " is in safe zone")
        return false
    end

    return true
end

function SpawnAlienNearPlayer(player)
    -- no spawning aliens if player is in safe distance
    if not IsPlayerAttackable(player) then
        return
    end

    local x, y, z = GetPlayerLocation(player)
    local x, y = randomPointInCircle(x, y, AlienAttackRange + 500) -- some buffer
    -- CreateObject(303, x, y, z+100, 0, 0, 0, 10, 10, 200) -- TODO remove me
    local npc = CreateNPC(x, y, z + 100, 90)

    SetNPCHealth(npc, AlienHealth)
    SetNPCRespawnTime(npc, 99999999) -- disable respawns
    SetNPCPropertyValue(npc, 'clothing', math.random(23, 24))
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
    Delay(120 * 1000, function()
        log.debug("NPC (ID " .. npc .. ") is dead.. despawning")
        AlienRetargetCooldown[npc] = nil
        DestroyNPC(npc)
    end)
end)

function SetAlienTarget(npc, player)
    local vehicle = GetPlayerVehicle(player)
    if vehicle == 0 then
        -- target is on foot
        log.debug("NPC (ID " .. npc .. ") targets player " .. GetPlayerName(player))
        SetNPCPropertyValue(npc, 'target', player, true)

        -- alien has a new target
        SetNPCFollowPlayer(npc, player, math.random(325, 360)) -- random speed
        CallRemoteEvent(player, 'AlienAttacking', npc)
    else
        -- target is in a vehicle
        log.debug("NPC (ID " .. npc .. ") targets player in vehicle: " .. GetPlayerName(player))
        SetNPCPropertyValue(npc, 'target', player, true)

        -- alien has a new target vehicle
        SetNPCFollowVehicle(npc, vehicle, 400)
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

    if player ~= 0 and IsPlayerAttackable(player) then
        -- we found a target
        SetAlienTarget(npc, player)
    elseif (GetNPCPropertyValue(npc, 'target') == player) then
        log.debug("NPC (ID " .. npc .. ") target "..GetPlayerName(player).." is no longer attackable")
        -- target is out of range, alien is sad
        local x, y, z = GetNPCLocation(npc)
        SetNPCTargetLocation(npc, x, y, z)
        SetNPCPropertyValue(npc, 'target', nil, true)
        CallRemoteEvent(player, 'AlienNoLongerAttacking', npc)

        -- wait a bit then walk back home, little alien
        Delay(15 * 1000, function()
            AlienReturn(npc)
        end)
    end
end

-- kills players when reached
AddEvent("OnNPCReachTarget", function(npc)
    -- log.debug("NPC (ID "..npc..") reached target")
    if GetNPCPropertyValue(npc, 'type') ~= 'alien' then
        return
    end

    local health = GetNPCHealth(npc)
    if (health == false or health <= 0) then
        return
    end

    local returning = GetNPCPropertyValue(npc, 'returning')
    if returning == true then
        -- alien is back in starting position
        log.debug("NPC (ID " .. npc .. ") back at starting position.. despawning")
        AlienRetargetCooldown[npc] = nil
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
        return
    end

    local x, y, z = GetNPCLocation(npc)
    local px, py, pz = GetPlayerLocation(target)
    local dist = GetDistance3D(x, y, z, px, py, pz)

    if dist < 200 then
        -- we're in close range, attack player
        log.debug("NPC (ID " .. npc .. ") hit player " .. GetPlayerName(target))

        -- return home if attacking an admin
        -- if Player.IsAdmin(target) then
        --    AlienReturn(npc)
        --    return
        -- end

        ApplyPlayerDamage(target)

        if GetPlayerHealth(target) <= 0 then
            Delay(8000, function()
                AlienReturn(npc)
            end)
            return
        end
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

    SetNPCPropertyValue(npc, 'returning', true)
    SetNPCPropertyValue(npc, 'target', nil, true)

    local location = GetNPCPropertyValue(npc, 'location')
    SetNPCTargetLocation(npc, location[1], location[2], location[3], 800)
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
