local PlayerRespawnSecs = 20 -- 20 secs
SpawnLocation = {
    x = -106884.28125,
    y = 197996.78125,
    z = 1298.3040771484
}
local SavePlayerTimer

AddCommand("pos", function(player)
    if not Account.IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    local heading = GetPlayerHeading(player)
    string = "Location: " .. x .. " " .. y .. " " .. z .. " Heading: " .. heading
    AddPlayerChat(player, string)
    log.debug(string)
end)

AddCommand("players", function(player)
    for _, v in pairs(GetAllPlayers()) do
        AddPlayerChat(player, '[' .. v .. '] ' .. GetPlayerName(v))
    end
end)

AddCommand("anim", function(player, anim)
    log.debug("Animation:", anim)
    SetPlayerAnimation(player, "STOP")
    if anim ~= nil then
        SetPlayerAnimation(player, string.upper(anim))
    end
end)

AddEvent("OnPackageStart", function()
end)

AddEvent("OnPackageStop", function()
end)

-- console input from client
AddRemoteEvent("ConsoleInput", function(player, input)
    if not Account.IsAdmin(GetPlayerSteamId(player)) then
        return
    end

    if input == "stats" then
        print("Objects: " .. tostring(GetObjectCount()))
    end

    log.debug("console: " .. input)
end)

AddEvent("OnConsoleInput", function(input)
    if input == "" then
        return
    end
    if input == "quit" or input == "exit" then
        ServerExit("Exiting via console command")
    end
    -- run lua
    load(input)()
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
    AddPlayerChat(player, '<span color="#ffffffff">Go to the computer in the garage for game information..  Good luck!</>')
end)

-- Player spawn
-- happens initially before auth!
AddEvent("OnPlayerSpawn", function(player)
    log.debug("OnPlayerSpawn")

    -- cleansing
    SetPlayerArmor(player, 0)
    ClearInventory(player)
    SetPlayerPropertyValue(player, "equipped", {})
end)

AddRemoteEvent("SelectCharacter", function(player, preset)
    SetPlayerPropertyValue(player, 'clothing', preset, true)

    -- join the others as a new character
    SetPlayerDimension(player, 0)
    SetPlayerPropertyValue(player, "inventory", {})
    SetPlayerPropertyValue(player, "equipped", {})

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

    -- clear last location on death
    Account.update(GetPlayerSteamId(player), { location = nil })

    -- stats
    BumpPlayerStat(player, 'deaths')
    AddPlayerChat(player, "YOU ARE DEAD!  You must wait " .. PlayerRespawnSecs .. " seconds to respawn...")
end)

-- Log auth
AddEvent("OnPlayerSteamAuth", function(player)
    log.debug("OnPlayerSteamAuth")

    local steamid =  GetPlayerSteamId(player)
    log.info("Player " .. GetPlayerName(player) .. " (ID " .. player .. ") authenticated with steam ID " ..
                 steamid)

    if not Account.exists(steamid) then
        log.info("Creating new account for player "..GetPlayerName(player))
        Account.create({ steamid = steamid })
        
        -- new character
        SetPlayerDimension(player, math.random(1, 999))
        CallRemoteEvent(player, "ShowCharacterSelection")
    else
        log.info("Existing account player "..GetPlayerName(player) .. " logging on.")

        -- existing player logging on
        local account = Account.get(GetPlayerSteamId(player))

        -- setup inventory
        SetPlayerPropertyValue(player, "inventory", json_decode(account['inventory']))
        Delay(2000, function(player)
            SyncInventory(player)
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
    for p in pairs(GetAllPlayers()) do
        if IsValidPlayer(p) and GetPlayerDimension(p) == 0 and not IsPlayerDead(p)
         then
            local x,y,z = GetPlayerLocation(p)
            Account.update(GetPlayerSteamId(p), {
                location = { x = x, y = y, z = z },
                inventory = GetPlayerPropertyValue(p, 'inventory')
            })
        end
    end
end, 1000 * 10)