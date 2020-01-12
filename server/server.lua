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
    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 90.0)
    SetPlayerRespawnTime(player, PlayerRespawnSecs * 1000)
	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' has joined the server</>')
	AddPlayerChatAll('<span color="#eeeeeeaa">There are '..GetPlayerCount()..' players on the server</>')
    Delay(5000, function()
        CallRemoteEvent(player, "ShowBanner", "WELCOME TO THE<br/>INVASION", 5000)
    end)
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

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
    local pickup = CreatePickup(2, -106279.4140625, 193854.59375, 1399.1424560547)
    SetPickupPropertyValue(pickup, 'type', 'computer')
    
end
AddEvent("OnPackageStart", OnPackageStart)

-- Access computer
AddEvent("OnPlayerPickupHit", function(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') == 'computer') then
        CallRemoteEvent(player, 'AccessComputer')
    end
end)

-- Chat
function OnPlayerChat(player, message)
    local fullchatmessage = GetPlayerName(player)..' ('..player..'): '..message
    AddPlayerChatAll(fullchatmessage)
end
AddEvent("OnPlayerChat", OnPlayerChat)

AddRemoteEvent("PlayerInWater", function(player)
    AddPlayerChat(player, "You feel the poison sear through your veins.")
    SetPlayerHealth(player, GetPlayerHealth(player) - 10)
end)

-- Time
local time = 8
function SyncTime()
    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "ClientSetTime", time)
    end
end
AddEvent("OnPlayerJoin", SyncTime)

CreateTimer(function()
    time = time + 0.05
    if time > 24 then
        time = 0
    end
    print("Time is now "..time)
    SyncTime()
end, 60 * 1000)
