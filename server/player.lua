local PlayerRespawnSecs = 20 -- 20 secs
SpawnLocation = {
    x = -106884.28125,
    y = 197996.78125,
    z = 1298.3040771484
}
local SavePlayerTimer

AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
        ClearEquipped(player)
    end
end)

-- destroy vest on quit
AddEvent("OnPlayerQuit", function(player)
    SavePlayer(player)
    ClearEquipped(player)
end)

-- joins the server, happens just before initial spawn
AddEvent("OnPlayerJoin", function(player)
    log.debug("OnPlayerJoin")

    -- randomized spawn location
    x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 6000)
    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 180)
    SetPlayerRespawnTime(player, PlayerRespawnSecs * 1000)

    -- welcome messages
    AddPlayerChatAll('<span color="#eeeeeeaa">' .. GetPlayerName(player) .. ' has joined the server</>')
    AddPlayerChat(player, '<span color="#ffffffff">Welcome to Alien Invasion by oweff!</>')
    AddPlayerChat(player, '<span color="#eeeeeeaa">Hit [T] to chat, [TAB] for inventory, [P] for player list</>')
    AddPlayerChat(player, '<span color="#eeeeeeaa">Hit [E] when near interactive objects to interact with them</>')
    AddPlayerChat(player,
        '<span color="#ffffffff">Go to the computer in the garage for game information..  Good luck!</>')
end)

-- Player spawn
-- happens initially before auth!
AddEvent("OnPlayerSpawn", function(player)
    log.debug("OnPlayerSpawn")

    -- cleansing
    SetPlayerArmor(player, 0)

    ClearInventory(player)
    ClearEquipped(player)
end)

AddRemoteEvent("SelectCharacter", function(player, preset)
    SetPlayerPropertyValue(player, 'clothing', preset, true)

    -- join the others as a new character
    SetPlayerDimension(player, 0)

    ClearInventory(player)
    ClearEquipped(player)

    -- spawning in a new character
    local x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 6000)
    SetPlayerSpawnLocation(player, x, y, SpawnLocation.z, 180)
    SetPlayerLocation(player, x, y, SpawnLocation.z + 30000)

    AttachPlayerParachute(player, true)

    local chopper = CreateObject(1847, x, y, SpawnLocation.z + 31000)
    Delay(20000, function(chopper)
        DestroyObject(chopper)
    end, chopper)
end)

-- killer is never a NPC so we have to guess
-- if player is killed by themselves, assume it's an alien?
AddEvent("OnPlayerDeath", function(player, killer)
    if player ~= killer then
        BumpPlayerStat(killer, 'player_kills')
        log.info(GetPlayerName(player) .. ' has been killed by ' .. GetPlayerName(killer) .. '!')
        AddPlayerChatAll(GetPlayerName(player) .. ' has been killed by ' .. GetPlayerName(killer) .. '!')
    else
        AddPlayerChatAll(GetPlayerName(player) .. ' has been taken!')
        log.info(GetPlayerName(player) .. ' has been taken')
    end

    -- clear attached objects from world
    ClearEquipped(player)

    -- clear player data on death
    Account.update(GetPlayerSteamId(player), {
        location = nil,
        inventory = nil,
        equipped = nil,
        weapons = nil
    })

    -- stats
    BumpPlayerStat(player, 'deaths')
    AddPlayerChat(player, "YOU ARE DEAD!  You must wait " .. PlayerRespawnSecs .. " seconds to respawn...")
end)

-- Log auth
AddEvent("OnPlayerSteamAuth", function(player)
    log.debug("OnPlayerSteamAuth")

    local steamid = GetPlayerSteamId(player)
    log.info("Player " .. GetPlayerName(player) .. " (ID " .. player .. ") authenticated with steam ID " .. steamid)

    if not Account.exists(steamid) then
        log.info("Creating new account for player " .. GetPlayerName(player))
        Account.create({
            steamid = steamid
        })

        -- new character
        SetPlayerDimension(player, math.random(1, 999))
        CallRemoteEvent(player, "ShowCharacterSelection")
    else
        log.info("Existing account player " .. GetPlayerName(player) .. " logging on.")

        -- existing player logging on
        local account = Account.get(GetPlayerSteamId(player))

        -- setup inventory
        SetPlayerPropertyValue(player, "inventory", json_decode(account['inventory']))
        SetPlayerPropertyValue(player, "weapons", json_decode(account['weapons']))
        SetPlayerPropertyValue(player, "equipped", json_decode(account['equipped']))

        Delay(2000, function(player)
            SyncInventory(player)
            SyncEquipped(player)
            SyncWeapons(player)
        end, player)

        -- player is already spawned, relocate them
        local loc = json_decode(account['location'])
        SetPlayerLocation(player, loc['x'], loc['y'], loc['z'])
    end
end)

-- Chat
AddEvent("OnPlayerChat", function(player, message)
    AddPlayerChatAll('<span color="#eeeeeeaa"><' .. GetPlayerName(player) .. '></> ' .. message)
    log.debug("<" .. GetPlayerName(player) .. "> " .. message)
end)

AddRemoteEvent("DropParachute", function(player)
    AttachPlayerParachute(player, false)
end)

local SavePlayerTimer = CreateTimer(function(vehicle)
    for player in pairs(GetAllPlayers()) do
        if IsValidPlayer(player) and GetPlayerDimension(player) == 0 and not IsPlayerDead(player) then
            SavePlayer(player)
        end
    end
end, 1000 * 10)

function SavePlayer(player)
    local x, y, z = GetPlayerLocation(player)
    Account.update(GetPlayerSteamId(player), {
        location = {
            x = x,
            y = y,
            z = z
        },
        inventory = GetPlayerPropertyValue(player, 'inventory'),
        weapons = GetPlayerPropertyValue(player, 'weapons'),
        equipped = GetPlayerPropertyValue(player, 'equipped')
    })
end