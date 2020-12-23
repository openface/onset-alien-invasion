local PlayerRespawnSecs = 20 -- 20 secs
SpawnLocation = {
    x = -106884.28125,
    y = 197996.78125,
    z = 1298.3040771484
}
local SavePlayerTimer
local PlayerSaveTime = 1000 * 60 -- 60 secs

PlayerData = {}

AddEvent("OnPackageStart", function()
    for _, player in pairs(GetAllPlayers()) do
        LoadPlayer(player)
    end
end)

AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
        ClearEquippedObjects(player)
    end
end)

-- player disconnected
AddEvent("OnPlayerQuit", function(player)
    log.debug("OnPlayerQuit")
    if PlayerData[player] == nil then return end
    
    SavePlayer(player)
    ClearEquippedObjects(player)

    PlayerData[player] = nil
end)

-- joins the server, happens just before initial spawn
AddEvent("OnPlayerJoin", function(player)
    log.debug("OnPlayerJoin")

    -- initialize PlayerData
    PlayerData[player] = {
        inventory = nil,
        weapons = nil,
        equipped = nil
    }

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
    
    PlayerData[player].inventory = {}
    PlayerData[player].weapons = {}
    PlayerData[player].equipped = {}
    SyncInventory(player)
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
    ClearEquippedObjects(player)

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

-- Happens after spawn!
AddEvent("OnPlayerSteamAuth", function(player)
    log.debug("OnPlayerSteamAuth")

    local steamid = GetPlayerSteamId(player)
    log.info("Player " .. GetPlayerName(player) .. " (ID " .. player .. ") authenticated with steam ID " .. steamid)

    if not Account.exists(steamid) then
        -- new character gets character selection screen
        SetPlayerDimension(player, math.random(1, 999))
        CallRemoteEvent(player, "ShowCharacterSelection")
    else
        log.info("Loading existing character for player " .. GetPlayerName(player))

        -- existing player logging on
        local account = Account.get(GetPlayerSteamId(player))
        if not account then 
            log.error "Account not found!"
            return
        end

        -- setup inventory
        InitializePlayer(player)

        -- player is already spawned, relocate them
        local loc = json_decode(account['location'])
        SetPlayerLocation(player, loc['x'], loc['y'], loc['z'])
    end
end)

-- new character selected
AddRemoteEvent("SelectCharacter", function(player, preset)
    log.info("Creating new account for player " .. GetPlayerName(player))

    -- new player spawn location
    local x, y = randomPointInCircle(SpawnLocation.x, SpawnLocation.y, 6000)
    local z = SpawnLocation.z
    SetPlayerSpawnLocation(player, x, y, z, 180)

    Account.create({
        steamid = GetPlayerSteamId(player),
        clothing = preset,
        location = { x = x, y = y, z = z }
    })

    -- join the others as a new character
    SetPlayerDimension(player, 0)

    -- initialize PlayerData
    InitializePlayer(player)

    -- spawn a new character up in the sky
    SetPlayerLocation(player, x, y, SpawnLocation.z + 30000)
    AttachPlayerParachute(player, true)

    local chopper = CreateObject(1847, x, y, SpawnLocation.z + 31000)
    Delay(1000 * 25, function(chopper)
        DestroyObject(chopper)
    end, chopper)
end)

-- initialize player from database values
function InitializePlayer(player)
    if PlayerData[player] == nil then
        PlayerData[player] = {}
    end

    -- existing player logging on
    local account = Account.get(GetPlayerSteamId(player))
    if not account then
        log.error("Error initializing player from database!")
        KickPlayer(player, "Error initializing player!")
        return
    end

    log.debug("Initializing player from database")

    -- setup inventory
    PlayerData[player].inventory = json_decode(account['inventory'])
    PlayerData[player].weapons = json_decode(account['weapons'])
    PlayerData[player].equipped = json_decode(account['equipped'])

    -- setup properties
    SetPlayerPropertyValue(player, 'clothing', account['clothing'], true)

    Delay(2500, function(player)
        SyncInventory(player)
        SyncEquipped(player)
        SyncWeapons(player)
    end, player)
end

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
end, PlayerSaveTime)

function SavePlayer(player)
    if PlayerData[player] == nil then return end

    local x, y, z = GetPlayerLocation(player)
    Account.update(GetPlayerSteamId(player), {
        location = {
            x = x,
            y = y,
            z = z
        },
        inventory = PlayerData[player].inventory,
        weapons = PlayerData[player].weapons,
        equipped = PlayerData[player].equipped
    })
end