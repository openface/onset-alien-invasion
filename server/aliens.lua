local AlienHealth = 999
local AlienRespawnTime = 20 * 1000
local AlienAttackRange = 5000
local AlienAttackDamage = 50
local SafeLocation = { x = -102037, y = 194299, z = 1400 }
local SafeRange = 8000

-- TODO remove
AddCommand("alien", function(player)
    SpawnAlienNearPlayer(player)
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
    -- destroy any existing aliens
    for _,npc in pairs(GetAllNPC()) do
        if (GetNPCPropertyValue(npc, 'type') == 'alien') then
            -- only destroy aliens not currently attacking
            if (GetNPCPropertyValue(npc, 'target') == nil) then
                print "Despawning alien"
                DestroyNPC(npc)
            end
        end
    end

    -- create alien npcs
    for _,ply in pairs(GetAllPlayers()) do
        -- chance to spawn
        if math.random(1,3) == 1 then
            SpawnAlienNearPlayer(ply)
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

    print("Spawning alien near player "..GetPlayerName(player))
    local x,y = randomPointInCircle(x, y, AlienAttackRange + 1000) -- 1000 buffer
    --CreateObject(303, x, y, z+100, 0, 0, 0, 10, 10, 200) -- TODO remove me
    local npc = CreateNPC(x, y, z+100, 90)
    SetNPCHealth(npc, AlienHealth)
    SetNPCRespawnTime(npc, AlienRespawnTime)
    SetNPCPropertyValue(npc, 'clothing', math.random(23, 24))
    SetNPCPropertyValue(npc, 'type', 'alien')
    SetNPCPropertyValue(npc, 'location', { x, y, z })
end

function OnNPCSpawn(npc)
    if GetNPCPropertyValue(npc, 'type') == 'alien' then
        SetNPCHealth(npc, AlienHealth)

        local x,y,z = GetNPCLocation(npc)
        SetNPCPropertyValue(npc, 'location', { x, y, z })
    end
end
AddEvent("OnNPCSpawn", OnNPCSpawn)

-- damage aliens
AddEvent("OnPlayerWeaponShot", function(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
    if (hittype == HIT_NPC and GetNPCPropertyValue(hitid, "type") == "alien") then
        SetAlienTarget(hitid, player)
    end
end)

AddEvent("OnNPCDeath", function(npc, killer)
    if killer ~= 0 then
        CallRemoteEvent(killer, 'AlienNoLongerAttacking')
        AddPlayerChatAll(GetPlayerName(killer) .. ' has killed an alien!')
        print(GetPlayerName(killer) .. ' has killed an alien')
        BumpPlayerStat(killer, 'alien_kills')
    end
    SetNPCPropertyValue(npc, 'target', nil, true)
end)

function SetAlienTarget(npc, player)
    print("Alien targets player: "..GetPlayerName(player))
    SetNPCPropertyValue(npc, 'target', player, true)

    local veh = GetPlayerVehicle(player)
    if veh == 0 then
        -- alien has a new target
        SetNPCFollowPlayer(npc, player, math.random(325,360)) -- random speed
    else
        -- alien has a new target vehicle
        SetNPCFollowVehicle(npc, veh, 400)
        if (nearest_dist < 2000) then
            -- force player out of vehicle and damage it
            RemovePlayerFromVehicle(player)
            SetVehicleDamage(veh, math.random(1,8), 1.0)
            -- remove it from game
            Delay(60000, function()
                DestroyVehicle(veh)
            end)
        end
    end
    CallRemoteEvent(player, 'AlienAttacking', npc)
end

-- alien tick
function ResetAlien(npc)
    health = GetNPCHealth(npc)
    if (health == false or health <= 0) then
        return
    end

    local player, nearest_dist = GetNearestPlayer(npc)
    if (player~=0 and not IsPlayerDead(player)) then

        local x,y,z = GetPlayerLocation(player)
        local distance_to_safety = GetDistance3D(x, y, z, SafeLocation.x, SafeLocation.y, SafeLocation.z)
        if (nearest_dist < AlienAttackRange and distance_to_safety > SafeRange) then
            SetAlienTarget(npc, player)
        elseif (GetNPCPropertyValue(npc, 'target') == player) then
            -- target is out of range, alien is sad
            local x, y, z = GetNPCLocation(npc)
            SetNPCTargetLocation(npc, x, y, z)

            SetNPCPropertyValue(npc, 'target', nil, true)
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
    if GetNPCPropertyValue(npc, 'type') ~= 'alien' then
        return
    end

    local target = GetNPCPropertyValue(npc, 'target')
    if target ~= nil then
        if (not IsPlayerDead(target)) then
            -- attack player
            SetNPCAnimation(npc, "KUNGFU", false)
            ApplyPlayerDamage(target)
            Delay(1000, function()
                SetNPCFollowPlayer(npc, target, 350)
            end)
        else
            -- player already dead, dance and go home
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
        end
    end
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

    SetNPCAnimation(npc, "STOP", true)
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
		local x2, y2, z2 = GetPlayerLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)
		if dist < nearest_dist then
			nearest_dist = dist
			found = v
		end
	end
	return found, nearest_dist
end