local PlayerRespawnSecs = 20 -- 20 secs

InitTable("accounts", {
    steamid = {
        type = 'char',
        length = 17,
        unique = true
    },
    is_admin = {
        type = 'bool',
        default = false
    },
    clothing = {
        type = 'number',
        length = 11
    },
    location = {
        type = 'json'
    },
    equipped = {
        type = 'json'
    },
    inventory = {
        type = 'json'
    }
}, false) -- true to recreate table

PlayerData = {}

AddEvent("OnPackageStart", function()
    -- for restarting package on a live server with players
    for _, player in pairs(GetAllPlayers()) do
        InitializePlayer(player)
    end
end)

AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
        ClearEquippedObjects(player)
    end
end)

-- player disconnected
AddEvent("OnPlayerQuit", function(player)
    log.trace("OnPlayerQuit")

    if PlayerData[player] == nil then
        return
    end

    SavePlayer(player)
    ClearEquippedObjects(player)

    PlayerData[player] = nil
end)

-- joins the server, happens just before initial spawn
AddEvent("OnPlayerJoin", function(player)
    log.trace("OnPlayerJoin")

    -- initialize PlayerData
    PlayerData[player] = {
        inventory = {},
        equipped = {}
    }

    -- randomized spawn location
    x, y = randomPointInCircle(SafeZoneLocation.x, SafeZoneLocation.y, 6000)
    SetPlayerSpawnLocation(player, x, y, SafeZoneLocation.z, 180)
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
    log.trace("OnPlayerSpawn")

    -- cleansing
    SetPlayerArmor(player, 0)

    -- reset PlayerData
    if PlayerData[player] then
        PlayerData[player] = {
            inventory = {},
            equipped = {}
        }
    end
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
    UpdateRows("accounts", {
        inventory = {},
        equipped = {}
    }, {
        steamid = GetPlayerSteamId(player)
    })

    -- stats
    BumpPlayerStat(player, 'deaths')
    AddPlayerChat(player, "YOU ARE DEAD!  You must wait " .. PlayerRespawnSecs .. " seconds to respawn...")

    -- set a new random spawn location
    x, y = randomPointInCircle(SafeZoneLocation.x, SafeZoneLocation.y, 6000)
    SetPlayerSpawnLocation(player, x, y, SafeZoneLocation.z, 180)
end)

-- Happens after spawn!
AddEvent("OnPlayerSteamAuth", function(player)
    log.trace("OnPlayerSteamAuth")

    local steamid = GetPlayerSteamId(player)
    log.info("Player " .. GetPlayerName(player) .. " (ID " .. player .. ") authenticated with steam ID " .. steamid)

    local account = SelectFirst("accounts", {
        steamid = steamid
    })
    if not account then
        log.info("New account starting...")

        -- new character gets character selection screen
        SetPlayerDimension(player, math.random(1, 999))
        CallRemoteEvent(player, "ShowCharacterSelection")
    else
        log.info("Loading existing character for player " .. GetPlayerName(player))

        -- initialize player from database
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
    local x, y = randomPointInCircle(SafeZoneLocation.x, SafeZoneLocation.y, 6000)
    local z = SafeZoneLocation.z
    SetPlayerSpawnLocation(player, x, y, z, 180)

    InsertRow("accounts", {
        steamid = GetPlayerSteamId(player),
        clothing = preset,
        location = json_encode({
            x = x,
            y = y,
            z = z
        })
    }, function()
        -- join the others as a new character
        SetPlayerDimension(player, 0)

        -- initialize PlayerData
        InitializePlayer(player)

        -- spawn a new character up in the sky
        SetPlayerLocation(player, x, y, SafeZoneLocation.z + 30000)
        AttachPlayerParachute(player, true)

        local chopper = CreateObject(1847, x, y, SafeZoneLocation.z + 31000)
        Delay(1000 * 25, function(chopper)
            DestroyObject(chopper)
        end, chopper)
    end)
end)

-- initialize player from database values
function InitializePlayer(player)
    log.trace("InitializePlayer")

    if PlayerData[player] == nil then
        PlayerData[player] = {}
    end

    -- existing player logging on
    local account = SelectFirst("accounts", {
        steamid = GetPlayerSteamId(player)
    })
    if not account then
        log.error("Error initializing player from database!")
        KickPlayer(player, "Error initializing player!")
        return
    end

    log.debug("Initializing player from database")

    -- setup properties
    SetPlayerPropertyValue(player, 'clothing', account['clothing'], true)

    -- setup inventory
    PlayerData[player].inventory = json_decode(account['inventory'])
    for i, item in ipairs(PlayerData[player].inventory) do
        SetItemInstance(item.uuid, item.item)
    end

    -- equip items
    local equipped = json_decode(account['equipped'])
    for uuid, object in pairs(equipped) do
        EquipItem(player, uuid)
    end

    SyncWeaponSlotsFromInventory(player)
    SyncInventory(player)
end

-- Chat
AddEvent("OnPlayerChat", function(player, message)
    AddPlayerChatAll('<span color="#eeeeeeaa"><' .. GetPlayerName(player) .. '></> ' .. message)
    log.debug("<" .. GetPlayerName(player) .. "> " .. message)
end)

AddRemoteEvent("DropParachute", function(player)
    AttachPlayerParachute(player, false)
end)

function SavePlayer(player)
    if PlayerData[player] == nil then
        return
    end
    log.info("Saving player: " .. GetPlayerName(player))
    local x, y, z = GetPlayerLocation(player)

    UpdateRows("accounts", {
        location = {
            x = x,
            y = y,
            z = z
        },
        inventory = PlayerData[player].inventory,
        equipped = PlayerData[player].equipped
    }, {
        steamid = GetPlayerSteamId(player)
    })
end

function IsAdmin(steamid)
    account = SelectFirst("accounts", {
        steamid = steamid
    })
    if account and account["is_admin"] == "1" then
        return true
    else
        return false
    end
end

AddCommand("die", function(player)
    SetPlayerHealth(player, 0)
    AddPlayerChat(player, "You have been forcefully killed.")
end)

