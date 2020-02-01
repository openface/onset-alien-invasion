local AlienHealth = 999
local AlienRespawnTime = 20 * 1000
local AlienAttackRange = 5000
local AlienSpawnInterval = 3 * 60 * 1000
local AlienAttackDamage = 50
local SpawnLocation = { x = -102037, y = 194299, z = 1400 }

-- TODO remove
AddCommand("alien", function(player)
    SpawnAlienNearPlayer(player)
end)

function OnPackageStart()
    -- re-spawn on a timer
    CreateTimer(function()
        SpawnAliens()
    end, AlienSpawnInterval)

    -- process timer for all aliens
    CreateTimer(function()
        for _,npc in pairs(GetAllNPC()) do
            if (GetNPCPropertyValue(npc, 'type') == 'alien') then
                ResetAlien(npc)
            end
        end
    end, 10000)
end
AddEvent("OnPackageStart", OnPackageStart)

function SpawnAliens()
    -- destroy any existing aliens
    for _,npc in pairs(GetAllNPC()) do
        if (GetNPCPropertyValue(npc, 'type') == 'alien') then
            -- only destroy aliens not currently attacking
            if (GetNPCPropertyValue(npc, 'target') == nil) then
                DestroyNPC(npc)
            end
        end
    end

    -- create alien npcs
    for _,ply in pairs(GetAllPlayers()) do
        SpawnAlienNearPlayer(ply)
    end
end

function SpawnAlienNearPlayer(player)
    local x,y,z = GetPlayerLocation(player)
    local distance = GetDistance3D(x, y, z, SpawnLocation.x, SpawnLocation.y, SpawnLocation.z)
    if distance < 3000 then
        print("Player "..GetPlayerName(player).." in safe zone")
        return
    end

    print("Spawning alien near player "..GetPlayerName(player))
    local x,y = randomPointInCircle(x, y, 10000)
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
AddEvent("OnNPCDamage", function(npc, damagetype, amount)
    local health = GetNPCHealth(npc)
    if (health > 0) then
        -- keep attacking if still alive
        Delay(500, function(npc)
            ResetAlien(npc)
        end, npc)
    end
end)

AddEvent("OnNPCDeath", function(npc, killer)
    if killer ~= 0 then
        CallRemoteEvent(killer, 'AlienNoLongerAttacking')
        AddPlayerChatAll(GetPlayerName(killer) .. ' has killed an alien!')
        print(GetPlayerName(killer) .. ' has killed an alien')
    end
    SetNPCPropertyValue(npc, 'target', nil, true)
end)

-- alien tick
function ResetAlien(npc)
    health = GetNPCHealth(npc)
    if (health == false or health <= 0) then
        return
    end

    local player, nearest_dist = GetNearestPlayer(npc)
    if (player~=0 and not IsPlayerDead(player)) then

        local x,y,z = GetPlayerLocation(player)
        local distance_to_spawn = GetDistance3D(x, y, z, SpawnLocation.x, SpawnLocation.y, SpawnLocation.z)
        if (nearest_dist < AlienAttackRange and distance_to_spawn > 3000) then
            print("Alien targets player: "..GetPlayerName(player))
            SetNPCPropertyValue(npc, 'target', player, true)

            local veh = GetPlayerVehicle(player)
            if veh == 0 then
                -- alien has a new target
                SetNPCFollowPlayer(npc, player, 350)
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
        elseif (GetNPCPropertyValue(npc, 'target') == player) then
            -- target is out of range, alien is sad
            local x, y, z = GetNPCLocation(npc)
            SetNPCTargetLocation(npc, x, y, z)
            SetNPCPropertyValue(npc, 'target', nil, true)
            CallRemoteEvent(player, 'AlienNoLongerAttacking', npc)
            -- wait a bit then walk back home, little alien
            Delay(15000, function()
                local location = GetNPCPropertyValue(npc, 'location')
                SetNPCTargetLocation(npc, location[1], location[2], location[3], 100)
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
    SetNPCAnimation(npc, "STOP", true)
    SetNPCPropertyValue(npc, 'target', nil, true)

    local location = GetNPCPropertyValue(npc, 'location')
    SetNPCTargetLocation(npc, location[1], location[2], location[3], 800)
end

-- get nearest player to npc
function GetNearestPlayer(npc)
	local plys = GetAllPlayers()
	local found = 0
	local nearest_dist = AlienAttackRange + 5000
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