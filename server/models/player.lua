Player = {}
Player.__index = Player

-- todo remove
Player.SpawnLocation = { x = -106884.28125, y = 197996.78125, z = 1298.3040771484 }

function Player.get(steamid, fn)
    local query = mariadb_prepare(DB, "SELECT * FROM players WHERE steamid = ?", tostring(steamid))
    mariadb_query(DB, query, function()
        return mariadb_get_assoc(1)
    end)
end

function Player.create(data)
    log.info(dump(data))
    local query = mariadb_prepare(DB, "INSERT INTO players (steamid) VALUES (?)", tostring(data["steamid"]))
    mariadb_async_query(DB, query)
end

function Player.IsAdmin(player)
    Player.get(GetPlayerSteamId(player), function(row)
        return row['is_admin']
    end)
end
