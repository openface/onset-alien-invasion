Player = {}
Player.__index = Player

-- todo remove
Player.SpawnLocation = { x = -106884.28125, y = 197996.78125, z = 1298.3040771484 }

function Player.get(steamid, fn)
    log.debug("getting player "..steamid)
    local query = mariadb_prepare(DB, "SELECT * FROM players WHERE steamid = '?' LIMIT 1", tostring(steamid))
    mariadb_await_query(DB, query, fn)
end

function Player.create(data)
    log.info("creating player "..dump(data))
    local query = mariadb_prepare(DB, "INSERT INTO players (steamid) VALUES ('?')", tostring(data["steamid"]))
    mariadb_async_query(DB, query)
end

function Player.exists(steamid)
    Player.get(steamid, function()
        if (mariadb_get_row_count() == 0) then
            return false
        else
            return true
        end
    end)
end

function Player.IsAdmin(player)
    Player.get(GetPlayerSteamId(player), function()
        local row = mariadb_get_assoc(1)
        if row['is_admin'] == 1 then
            return true
        else
            return false
        end
    end)
end
