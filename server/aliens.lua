local AlienHealth = 999
local AlienRespawnTime = 20 * 1000
local AlienLocations = {} -- aliens.json
local AlienAttackRange = 5000
local AlienSpawnInterval = 30 * 60 * 1000 -- spawn aliens every 30 mins

-- TODO remove
AddCommand("apos", function(playerid)
    local x, y, z = GetPlayerLocation(playerid)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(playerid, string)
    print(string)
    table.insert(AlienLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/aliens.json", AlienLocations)
end)

function SetupAliens()
    AlienLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/aliens.json")

    -- spawn all aliens
    SpawnAlienAreas()

    -- re-spawn on a timer
    CreateTimer(function()
        SpawnAlienAreas()
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


function SpawnAlienAreas()
    -- destroy any existing aliens
    for _,npc in pairs(GetAllNPC()) do
        if (GetNPCPropertyValue(npc, 'type') == 'alien') then
            -- only destroy aliens not currently attacking
            if (GetNPCPropertyValue(npc, 'target') == nil) then
                DestroyNPC(npc)
            end
        end
    end

    print "Spawning aliens..."

    -- create alien npcs
    for _,pos in pairs(AlienLocations) do
        local x,y = randomPointInCircle(pos[1], pos[2], 10000)
        CreateObject(303, x, y, pos[3]+100, 0, 0, 0, 10, 10, 200) -- TODO remove me

        local npc = CreateNPC(x, y, pos[3]+100, 90)
        SetNPCHealth(npc, AlienHealth)
        SetNPCRespawnTime(npc, AlienRespawnTime)
        SetNPCPropertyValue(npc, 'clothing', math.random(23, 24))
        SetNPCPropertyValue(npc, 'type', 'alien')
        SetNPCPropertyValue(npc, 'location', pos)
    end
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
function OnNPCDamage(npc, damagetype, amount)
    -- stop alien temporarily when damaged
    local x, y, z = GetNPCLocation(npc)
    SetNPCTargetLocation(npc, x, y, z)

    local health = GetNPCHealth(npc)
    if (health <= 0) then
        -- alien is dead
        local killer = GetNPCPropertyValue(npc, 'target')
        CallRemoteEvent(killer, 'AlienNoLongerAttacking')

        if (killer ~= nil) then
            AddPlayerChatAll(GetPlayerName(killer) .. ' has killed an alien!')
        end
    else
        -- keep attacking if still alive
        Delay(500, function(npc)
            ResetAlien(npc)
        end, npc)
    end
end
AddEvent("OnNPCDamage", OnNPCDamage)

function ResetAlien(npc)
    health = GetNPCHealth(npc)
    if (health == false or health <= 0) then
        return
    end

    local target, nearest_dist = GetNearestPlayer(npc)
    if (target~=0 and not IsPlayerDead(target)) then
        if (nearest_dist < AlienAttackRange) then
            SetNPCPropertyValue(npc, 'target', target, true)

            local veh = GetPlayerVehicle(target)
            if veh == 0 then
                SetNPCFollowPlayer(npc, target, 350)
            else
                SetNPCFollowVehicle(npc, veh, 400)
                if (nearest_dist < 2000) then
                    -- force player out of vehicle and disable it
                    RemovePlayerFromVehicle(target)
                    SetVehicleDamage(veh, math.random(1,8), 1.0)
                    -- remove it from game
                    Delay(60000, function()
                        DestroyVehicle(veh)
                    end)
                end
            end
            CallRemoteEvent(target, 'AlienAttacking', npc)
        elseif (GetNPCPropertyValue(npc, 'target') == target) then
            -- target is out of range, alien is sad
            local x, y, z = GetNPCLocation(npc)
            SetNPCTargetLocation(npc, x, y, z)
            SetNPCPropertyValue(npc, 'target', nil, true)
            CallRemoteEvent(target, 'AlienNoLongerAttacking', npc)
            -- wait a bit then walk back home, little alien
            Delay(15000, function()
                local location = GetNPCPropertyValue(npc, 'location')
                SetNPCTargetLocation(npc, location[1], location[2], location[3], 100)
            end)
        end
    end
end

function AttackNearestPlayer(npc)
    local target, nearest_dist = GetNearestPlayer(npc)
    if (target~=0 and nearest_dist==0.0) then
        if (not IsPlayerDead(target)) then
            -- insta-kill
            SetNPCAnimation(npc, "THROW", true)
            Delay(2000, function()
                SetPlayerHealth(target, 0)
                SetNPCPropertyValue(npc, 'target', nil, true)
                SetNPCAnimation(npc, "DANCE12", true)
            end)
            Delay(10000, function()
                local location = GetNPCPropertyValue(npc, 'location')
                SetNPCTargetLocation(npc, location[1], location[2], location[3], 800)
            end)
        end
    end
end
AddEvent("OnNPCReachTarget", AttackNearestPlayer)

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