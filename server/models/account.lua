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
    local account = CACHE:get(steamid)
    if not account then
        account = SelectFirst("accounts", { steamid = steamid })
        CACHE:put(steamid, account)
    end
    return account
end

function Account.create(data, callback)
    InsertRow("accounts", {
        steamid = data['steamid'],
        clothing = data['clothing'],
        location = json_encode(data['location'])
    }, callback)
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
    CACHE:remove(steamid)
    UpdateRows("accounts", {
        location = data['location'],
        inventory = data['inventory'],
        weapons = data['weapons'],
        equipped = data['equipped']
    }, { steamid = tostring(steamid) })
end

--[[ function Account.updateColumn(steamid, column, value)
    local query = mariadb_prepare(DB, "UPDATE accounts SET ? = '?' WHERE steamid = '?'", column, value,
                      tostring(steamid))
    log.trace("Updating account: " .. query)
    mariadb_async_query(DB, query)
end

 ]]