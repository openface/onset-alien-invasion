Account = {}
Account.__index = Account

local CACHE = Cache:new(3600)

AddEvent("OnPackageStart", function()
    InitTable("accounts", {
        steamid = { type = 'char', length = 17, unique = true },
        is_admin = { type = 'bool', default = false },
        clothing = { type = 'number', length = 11 },
        location = { type = 'json' },
        weapons = { type = 'json' },
        equipped = { type = 'json' },
        inventory = { type = 'json' }
    }, true) 
end)

function Account.get(steamid)
    local account = CACHE:get(tostring(steamid))
    if not account then
        account = SelectFirst("accounts", { steamid = steamid })
        CACHE:put(tostring(steamid), account)
    end
    return account
end

function Account.create(data)
    InsertRow("accounts", {
        steamid = data['steamid'],
        clothing = data['clothing'],
        location = json_encode(data['location']),
    })
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
    local row = Account.get(steamid)
    if row and row["is_admin"] == "1" then
        return true
    else
        return false
    end
end

function Account.update(steamid, data)
    CACHE:remove(tostring(steamid))
    local query = mariadb_prepare(DB,
                      "UPDATE accounts SET location = '?', inventory = '?', weapons = '?', equipped = '?' WHERE steamid = '?'",
                      json_encode(data['location']), json_encode(data['inventory']), json_encode(data['weapons']),
                      json_encode(data['equipped']), tostring(steamid))
    log.trace("Updating account: " .. query)
    mariadb_async_query(DB, query)
end

function Account.updateColumn(steamid, column, value)
    local query = mariadb_prepare(DB, "UPDATE accounts SET ? = '?' WHERE steamid = '?'", column, value,
                      tostring(steamid))
    log.trace("Updating account: " .. query)
    mariadb_async_query(DB, query)
end

