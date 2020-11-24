Account = {}
Account.__index = Account

local CACHE = Cache:new(3600)

function Account.get(steamid)
    local account = CACHE:get(tostring(steamid))
    if not account then
        log.debug("getting player " .. steamid)
        local query = mariadb_prepare(DB, "SELECT * FROM accounts WHERE steamid = '?' LIMIT 1", tostring(steamid))
        mariadb_await_query(DB, query)
        local account = mariadb_get_assoc(1)
        CACHE:put(tostring(steamid), account)
    end
    return account
end

function Account.create(data)
    log.info("creating player " .. dump(data))
    local query = mariadb_prepare(DB, "INSERT INTO accounts (steamid) VALUES ('?')", tostring(data["steamid"]))
    mariadb_async_query(DB, query)
end

function Account.exists(steamid)
    local result = Account.get(steamid)
    if (mariadb_get_row_count() == 0) then
        return false
    else
        return true
    end
end

function Account.IsAdmin(steamid)
    local result = Account.get(steamid)
    local row = mariadb_get_assoc(1)
    if row["is_admin"] == "1" then
        return true
    else
        return false
    end
end
