local SpawnLocation = { x = -102037, y = 194299, z = 1400 }
local PlayerRespawnSecs = 20 -- 20 secs

AddCommand("pos", function(player)
    if not IsAdmin(player) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(player, string)
    print(string)
end)

AddCommand("players", function(player)
    for _, v in pairs(GetAllPlayers()) do
        AddPlayerChat(player, '['..v..'] '..GetPlayerName(v))
    end
end)

-- Setup world
AddEvent("OnPackageStart", function()
    -- pistol pickup near spawn
    local pickup = CreatePickup(1006, -103693.2421875, 192599.9375, 1250)
    SetPickupPropertyValue(pickup, 'type', 'pistol')   
end)

-- welcome message
AddEvent("OnPlayerJoin", function(player)
    -- place player in separate dimension while character is selected
    SetPlayerDimension(player, math.random(1, 999))
    -- temporary spawn point unless player selects a character
    SetPlayerSpawnLocation(player, 173454, 198906, 2496, 180)
    SetPlayerRespawnTime(player, PlayerRespawnSecs * 1000)
	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' has joined the server</>')
	AddPlayerChatAll('<span color="#eeeeeeaa">There are '..GetPlayerCount()..' players on the server</>')
    AddPlayerChatAll('<span color="#eeeeeeaa">Hit [T] to chat and [TAB] for scoreboard</>')
    AddPlayerChatAll('<span color="#ffffffff">Welcome to Alien Invasion by oweff!</>')
    AddPlayerChatAll('<span color="#ffffffff">Thanks for testing this gamemode.</>')
    CallRemoteEvent(player, "ShowCharacterSelection")
end)

AddRemoteEvent("SelectCharacter", function(player, preset)
    SetPlayerPropertyValue(player, 'clothing', preset, true)

    -- join the others
    SetPlayerDimension(player, 0)

    -- parachute down to the island
    local x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 8000)

    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 180)
    SetPlayerLocation(player, x, y, SpawnLocation.z + 30000)
    AttachPlayerParachute(player, true)
end)

-- killer is never a NPC so we have to guess
-- if player is killed by themselves, assume it's an alien?
AddEvent("OnPlayerDeath", function(player, killer)
    if player ~= killer then
        BumpPlayerStat(killer, 'player_kills')
        print(GetPlayerName(player)..' has been killed by '..GetPlayerName(killer)..'!')
        AddPlayerChatAll(GetPlayerName(player)..' has been killed by '..GetPlayerName(killer)..'!')
    else
        AddPlayerChatAll(GetPlayerName(player)..' has been taken!')
        print(GetPlayerName(player)..' has been taken')
    end

    DestroyEquipment(player)
    SetPlayerPropertyValue(player, 'equippedVest', nil, true)
    SetPlayerPropertyValue(player, 'carryingPart', nil, true)

    -- stats
    BumpPlayerStat(player, 'deaths')
    AddPlayerChat(player, "YOU ARE DEAD!  You must wait ".. PlayerRespawnSecs .." seconds to respawn...")
end)

-- destroy any equipped items
function DestroyEquipment(player)
    -- destroy vest if equipped
    local vest = GetPlayerPropertyValue(player, "equippedVest")
    if vest ~= nil then
        DestroyObject(vest)
    end

    -- destroy part if equipped
    local part = GetPlayerPropertyValue(player, "carryingPart")
    if part ~= nil then
        DestroyObject(part)
    end
end

AddEvent("OnPlayerQuit", function(player)
    DestroyEquipment(player)
end)

-- Pickup for pistol
AddEvent("OnPlayerPickupHit", function(player, pickup)
    if GetPickupPropertyValue(pickup, 'type') == 'pistol' then
    	SetPlayerWeapon(player, math.random(2,5), 100, true, 2)
	end
end)

-- Player spawn
AddEvent("OnPlayerSpawn", function(player)
    SetPlayerArmor(player, 0)
end)

-- Log auth
AddEvent("OnPlayerSteamAuth", function(player)
    print("Player "..GetPlayerName(player).." (ID "..player..") authenticated with steam ID "..GetPlayerSteamId(player))
end)

-- Chat
AddEvent("OnPlayerChat", function(player, message)
    AddPlayerChatAll('<span color="#eeeeeeaa"><'..GetPlayerName(player)..'></> '..message)
    print("<"..GetPlayerName(player).."> "..message)
end)

-- Water is a killer
AddRemoteEvent("HandlePlayerInWater", function(player)
    AddPlayerChat(player, "You feel the poison sear through your veins.")
    SetPlayerHealth(player, GetPlayerHealth(player) - 10)
end)

AddRemoteEvent("DropParachute", function(player)
    AttachPlayerParachute(player, false)
end)
