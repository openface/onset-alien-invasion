local SpawnLocation = { x = -102037, y = 194299, z = 1400 }
local PlayerRespawnSecs = 20 -- 20 secs

-- TODO remove
AddCommand("pos", function(playerid)
    local x, y, z = GetPlayerLocation(playerid)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(playerid, string)
    print(string)
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

function OnPlayerDeath(player, killer)
    AddPlayerChatAll(GetPlayerName(player)..' has been taken!')
    AddPlayerChat(player, "DEAD!  You must wait ".. PlayerRespawnSecs .." seconds to respawn...")
end
AddEvent("OnPlayerDeath", OnPlayerDeath)


-- Setup world
function OnPackageStart()
    SetupAliens()
    SetupBoss()
    SetupLootPickups()
    SetupVehicles()

    -- central computer
    CreateText3D("Press E to Interact", 15, -106279.4140625, 193854.59375, 1399.1424560547 + 130, 0,0,0)
end
AddEvent("OnPackageStart", OnPackageStart)

-- Chat
function OnPlayerChat(player, message)
    local fullchatmessage = GetPlayerName(player)..' ('..player..'): '..message
    AddPlayerChatAll(fullchatmessage)
end
AddEvent("OnPlayerChat", OnPlayerChat)

-- Water is a killer
AddRemoteEvent("PlayerInWater", function(player)
    AddPlayerChat(player, "You feel the poison sear through your veins.")
    SetPlayerHealth(player, GetPlayerHealth(player) - 10)
end)

