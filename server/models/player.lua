Player = {}
Player.__index = Player

-- todo remove
Player.SpawnLocation = {
    x = -106884.28125,
    y = 197996.78125,
    z = 1298.3040771484
}

function Player.get(steamid)
    log.debug("getting player " .. steamid)
    local query = mariadb_prepare(DB, "SELECT * FROM players WHERE steamid = '?' LIMIT 1", tostring(steamid))
    return mariadb_await_query(DB, query)
end

function Player.create(data)
    log.info("creating player " .. dump(data))
    local query = mariadb_prepare(DB, "INSERT INTO players (steamid) VALUES ('?')", tostring(data["steamid"]))
    mariadb_async_query(DB, query)
end

function Player.exists(steamid)
    local result = Player.get(steamid)
    if (mariadb_get_row_count() == 0) then
        return false
    else
        return true
    end
end

function Player.IsAdmin(player)
    local result = Player.get(GetPlayerSteamId(player))
    local row = mariadb_get_assoc(1)
    return row["is_admin"]
end
