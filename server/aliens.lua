local AlienHealth = 999
local AlienAttackRange = 5000
local AlienAttackDamage = 50
local SafeLocation = { x = -102037, y = 194299, z = 1400 }
local SafeRange = 7000
local AlienRetargetCooldown = {} -- aliens re-target on every weapon hit w/ cooldown period
local AlienSpawnsEnabled = true

AddCommand("alien", function(player)
    if not IsAdmin(player) then
        return
    end
    SpawnAlienNearPlayer(player)
end)

AddCommand("togaliens", function(player)
    if not IsAdmin(player) then
        return
    end
    AlienSpawnsEnabled = not AlienSpawnsEnabled
    print("Alien spawning is now ",AlienSpawnsEnabled)
end)

function OnPackageStart()
    -- re-spawn on a timer
    CreateTimer(function()
        SpawnAliens()
    end, 60000) -- alien spawn tick every 1 minute

    -- process timer for all aliens
    CreateTimer(function()
        for _,npc in pairs(GetAllNPC()) do
            if (GetNPCPropertyValue(npc, 'type') == 'alien') then
                ResetAlien(npc)
            end
        end
    end, 10000) -- alien attack tick every 10 seconds
end
AddEvent("OnPackageStart", OnPackageStart)

function SpawnAliens()
    if AlienSpawnsEnabled ~= true then
        print "Alien spawning disabled."
        return
    end

    -- create alien npcs
    for _,ply in pairs(GetAllPlayers()) do
        local dim = GetPlayerDimension(ply)
        if dim == 0 then
            -- chance to spawn
            if math.random(1,3) == 1 then
                SpawnAlienNearPlayer(ply)
            end
        end
    end
end

function SpawnAlienNearPlayer(player)
    -- no spawning aliens if player is in safe distance
    local x,y,z = GetPlayerLocation(player)
    local distance = GetDistance3D(x, y, z, SafeLocation.x, SafeLocation.y, SafeLocation.z)
    if distance < SafeRange then
        print("Player "..GetPlayerName(player).." in safe zone")
        return
    end

    local x,y = randomPointInCircle(x, y, AlienAttackRange + 1000) -- 1000 buffer
    --CreateObject(303, x, y, z+100, 0, 0, 0, 10, 10, 200) -- TODO remove me
    local npc = CreateNPC(x, y, z+100, 90)
    SetNPCHealth(npc, AlienHealth)
    SetNPCRespawnTime(npc, 99999999) -- disable respawns
    SetNPCPropertyValue(npc, 'clothing', math.random(23, 24))
    SetNPCPropertyValue(npc, 'type', 'alien')
    SetNPCPropertyValue(npc, 'location', { x, y, z })

    print("Spawned alien "..npc.." near player "..GetPlayerName(player))
end

function OnNPCSpawn(npc)
    if GetNPCPropertyValue(npc, 'type') == 'alien' then
        print("OnNPCSpawn alien "..npc)
        SetNPCHealth(npc, AlienHealth)

        local x,y,z = GetNPCLocation(npc)
        SetNPCPropertyValue(npc, 'location', { x, y, z })
    end
end
AddEvent("OnNPCSpawn", OnNPCSpawn)

-- damage aliens
AddEvent("OnPlayerWeaponShot", function(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
    if (hittype == HIT_NPC and GetNPCPropertyValue(hitid, "type") == "alien") then
        -- hack to get around a bug where OnNPCDeath 
        -- doesn't always report the killer
        SetNPCPropertyValue(hitid, "shotby", player)

        -- headshot bonus
        local x,y,z = GetNPCLocation(hitid)
        local zfloor = z - 90
        local health = GetNPCHealth(hitid)
        if hitz > zfloor + 150 then
            SetNPCHealth(hitid, health - 35)
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
    print("OnNPCDeath npc: "..npc.." killer: "..killer)
    print("adjusted_killer: "..adjusted_killer)
    if adjusted_killer ~= 0 then
        CallRemoteEvent(adjusted_killer, 'AlienNoLongerAttacking')
        AddPlayerChatAll(GetPlayerName(adjusted_killer) .. ' has killed an alien!')
        print(GetPlayerName(adjusted_killer) .. ' has killed an alien')
        BumpPlayerStat(adjusted_killer, 'alien_kills')
    end
    SetNPCRagdoll(npc, true)
    Delay(120 * 1000, function()
        print("Despawn dead npc "..npc)
        DestroyNPC(npc)
    end)
end)

function SetAlienTarget(npc, player)
    local vehicle = GetPlayerVehicle(player)
    if vehicle == 0 then
        -- target is on foot
        print("NPC targets player: "..GetPlayerName(player))
        SetNPCPropertyValue(npc, 'target', player, true)

        -- alien has a new target
        SetNPCFollowPlayer(npc, player, math.random(325,360)) -- random speed
        CallRemoteEvent(player, 'AlienAttacking', npc)
    else
        -- target is in a vehicle
        print("NPC targets player in vehicle: "..GetPlayerName(player))
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
            SetVehicleDamage(vehicle, math.random(1,8), 1.0)
            -- remove it from game
            -- Delay(60000, function()
            --  DestroyVehicle(veh)
            -- end)
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
    if (player ~= 0 and not IsPlayerDead(player)) then

        local x,y,z = GetPlayerLocation(player)
        local distance_to_safety = GetDistance3D(x, y, z, SafeLocation.x, SafeLocation.y, SafeLocation.z)
        if (nearest_dist < AlienAttackRange and distance_to_safety > SafeRange) then
            -- we found a target
            SetAlienTarget(npc, player)
        elseif (GetNPCPropertyValue(npc, 'target') == player) then
            print "NPC target out of range"
            -- target is out of range, alien is sad
            local x, y, z = GetNPCLocation(npc)
            SetNPCTargetLocation(npc, x, y, z)
            SetNPCPropertyValue(npc, 'target', nil, true)
            SetNPCAnimation(npc, "THROATSLIT", false)
            CallRemoteEvent(player, 'AlienNoLongerAttacking', npc)

            -- wait a bit then walk back home, little alien
            Delay(15000, function()
                AlienReturn(npc)
            end)
        end
    end
end

-- kills players when reached
function OnNPCReachTarget(npc)
    print "NPC reached target"
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
        print "Despawning alien"
        DestroyNPC(npc)
        return
    end

    local target = GetNPCPropertyValue(npc, 'target')
    if target == nil then
        print "no target"
        -- alien reached a target but there is no target property?
        return
    end

    if IsPlayerDead(target) then
        -- target was dead when we got here
        return
    end

    local x, y, z = GetNPCLocation(npc)
    local px, py, pz = GetPlayerLocation(target)
    local dist = GetDistance3D(x, y, z, px, py, pz)

    if dist < 200 then
        -- we're in close range, attack player
        print "NPC hit player"
        SetNPCAnimation(npc, "KUNGFU", false)
        ApplyPlayerDamage(target)

        if GetPlayerHealth(target) <= 0 then
            -- critical hit, dance and go home
            Delay(2000, function()
                local dances = { 
                    "DANCE01", "DANCE02", "DANCE03", "DANCE04", "DANCE05", "DANCE06", "DANCE07", "DANCE08",
                    "DANCE09", "DANCE10", "DANCE11", "DANCE12", "DANCE13", "DANCE14", "DANCE15", "DANCE16",
                    "DANCE17", "DANCE18", "DANCE19", "DANCE20"
                }
                SetNPCAnimation(npc, dances[ math.random(#dances) ], true)
            end)
            Delay(8000, function()
                AlienReturn(npc)
            end)
            return
        end
    end

    SetAlienTarget(npc, target)
end
AddEvent("OnNPCReachTarget", OnNPCReachTarget)

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

    for _,v in pairs(plys) do
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