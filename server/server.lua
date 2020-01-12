SpawnLocation = { x = -102037, y = 194299, z = 1400 }
local PlayerRespawnTime = 20 * 1000 -- 20 secs

-- welcome message
function OnPlayerJoin(player)
    local x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 3000)
    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 90.0)
    SetPlayerRespawnTime(player, PlayerRespawnTime)
	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' has joined the server</>')
	AddPlayerChatAll('<span color="#eeeeeeaa">There are '..GetPlayerCount()..' players on the server</>')
    Delay(5000, function()
        CallRemoteEvent(player, "ShowBanner", "WELCOME TO THE<br/>INVASION", 5000)
    end)
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

function OnPlayerDeath(player, killer)
    AddPlayerChatAll(GetPlayerName(player)..' has been taken!')
    AddPlayerChat(player, "DEAD!  You must wait ".. math.floor(PlayerRespawnTime / 60) .." seconds to respawn...")
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

-- TODO remove
AddCommand("exp", function(player, explosionid)
    local x,y,z = GetPlayerLocation(player)
    CreateExplosion(explosionid, x+2000, y, z, true, 15000, 1000000)
end)

-- Setup world
function OnPackageStart()
    SetupAliens()
    SetupBoss()
    SetupLootPickups()
end
AddEvent("OnPackageStart", OnPackageStart)

-- chat
function OnPlayerChat(player, message)
    local fullchatmessage = GetPlayerName(player)..' ('..player..'): '..message
    AddPlayerChatAll(fullchatmessage)
end
AddEvent("OnPlayerChat", OnPlayerChat)

AddRemoteEvent("PlayerInWater", function(player)
    AddPlayerChat(player, "You feel the poison sear through your veins.")
    SetPlayerHealth(player, GetPlayerHealth(player) - 10)
end)
