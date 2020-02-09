local SpawnLocation = { x = -102037, y = 194299, z = 1400 }
local PlayerRespawnSecs = 20 -- 20 secs

-- TODO remove
AddCommand("pos", function(playerid)
    local x, y, z = GetPlayerLocation(playerid)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(playerid, string)
    print(string)
end)

AddCommand("players", function(player)
    for _, v in pairs(GetAllPlayers()) do
        AddPlayerChat(player, '['..v..'] '..GetPlayerName(v))
    end
end)

-- welcome message
function OnPlayerJoin(player)
    local x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 3000)

    -- place player in separate dimension while character is selected
    SetPlayerDimension(player, math.random(1, 999))
    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 90.0)
    SetPlayerRespawnTime(player, PlayerRespawnSecs * 1000)
	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' has joined the server</>')
	AddPlayerChatAll('<span color="#eeeeeeaa">There are '..GetPlayerCount()..' players on the server</>')
    CallRemoteEvent(player, "ShowCharacterSelection")
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

AddRemoteEvent("SelectCharacter", function(player, preset)
    SetPlayerPropertyValue(player, 'clothing', preset, true)

    -- join the others
    SetPlayerDimension(player, 0)
end)

-- killer is never a NPC so we have to guess
-- if player is killed by themselves, assume it's an alien?
function OnPlayerDeath(player, killer)
    if player ~= killer then
        BumpPlayerStat(killer, 'player_kills')
        print(GetPlayerName(player)..' has been killed by '..GetPlayerName(killer)..'!')
        AddPlayerChatAll(GetPlayerName(player)..' has been killed by '..GetPlayerName(killer)..'!')
    else
        AddPlayerChatAll(GetPlayerName(player)..' has been taken!')
        print(GetPlayerName(player)..' has been taken')
    end

    -- destroy vest if equipped
    local vest = GetPlayerPropertyValue(player, "equippedVest")
    if vest ~= nil then
        DestroyObject(vest)
    end
    

    BumpPlayerStat(player, 'deaths')
    AddPlayerChat(player, "DEAD!  You must wait ".. PlayerRespawnSecs .." seconds to respawn...")
end
AddEvent("OnPlayerDeath", OnPlayerDeath)


-- Setup world
function OnPackageStart()
    -- pistol pickup near spawn
    local pickup = CreatePickup(1006, -103693.2421875, 192599.9375, 1250)
    SetPickupPropertyValue(pickup, 'type', 'pistol')   
end
AddEvent("OnPackageStart", OnPackageStart)

-- Pickup for pistol
function OnPlayerPickupHit(player, pickup)
    if GetPickupPropertyValue(pickup, 'type') == 'pistol' then
    	SetPlayerWeapon(player, math.random(2,5), 100, true, 2)
	end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)

-- Player spawn
function OnPlayerSpawn(player)
    SetPlayerArmor(player, 0)
end
AddEvent("OnPlayerSpawn", OnPlayerSpawn)

-- Chat
function OnPlayerChat(player, message)
    local fullchatmessage = GetPlayerName(player)..' ('..player..'): '..message
    AddPlayerChatAll(fullchatmessage)
end
AddEvent("OnPlayerChat", OnPlayerChat)

-- Water is a killer
AddRemoteEvent("HandlePlayerInWater", function(player)
    AddPlayerChat(player, "You feel the poison sear through your veins.")
    SetPlayerHealth(player, GetPlayerHealth(player) - 10)
end)

