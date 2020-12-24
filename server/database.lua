-- global 
DB = nil

if not Config.database then
    log.error("Database config file not found.")
    ServerExit()
    return
end

mariadb_log(Config.database['log_level'])

local port = 3306
if Config.database['port'] ~= nil then
    port = tonumber(Config.database['port'])
end
DB = mariadb_connect(Config.database['host'] .. ':' .. port, Config.database['user'], Config.database['password'],
            Config.database['name'])
if DB == false then
    print("MariaDB: Connection failed to " .. Config.database['host'] .. ", see mariadb_log file")
    ServerExit()
    return
end

log.info("MariaDB: Connected to " .. Config.database['host'])

local charset = 'utf8'
if Config.database['charset'] ~= nil then
    charset = Config.database['charset']
end
mariadb_set_charset(DB, charset)

--[[ # OnServerExit ???
mariadb_close(DB)
 ]]
 
AddEvent("OnQueryError", function(errorid, error_str, query_str, handle_id)
    log.error("DATABASE ERROR: " .. error_str)
end)

--
-- Schema tables / Database API
--
local Tables = {}

function InitTable(name, fields, force_recreate)
    Tables[name] = Table.new(DB, name, fields)

    -- create schema, force recreate if specified
    local force_recreate = force_recreate or false
    Tables[name].create_schema(force_recreate)
end

function InsertRow(name, params, callback)
    return Tables[name].insert(params, callback)
end

function UpdateRows(name, params, where)
    return Tables[name].update(params, where)
end

function SelectRows(name, fields, where, callback)
    return Tables[name].select(fields, where, callback)
end

function SelectFirst(name, where)
    return Tables[name].first(where)
end

--
-- Schema table functions
--

function FormatDateTime(time)
    return os.date("%Y-%m-%d %H:%M:%S", time)
end
AddFunctionExport("FormatDateTime", FormatDateTime)

function FormatDataType(type)
    if type == "number" then
        return "INT"
    elseif type == "char" then
        return "VARCHAR"
    elseif type == "bool" then
        return "TINYINT"
    elseif type == "text" then
        return "TEXT"
    elseif type == "json" then
        return "LONGTEXT"
    elseif type == "datetime" then
        return "DATETIME"
    else
        log.error("Unreconized data type: "..type)
        return type
    end
end

-- Handles NULL strings and quotes for SQL statements
-- Must return a string
function FormatValue(value, field)
    if field.type == "char" or field.type == "text" or field.type == "datetime" then
        if value == nil and field.null ~= false then
            return "NULL"
        else
            return "'" .. tostring(mariadb_escape_string(DB, value)) .. "'"
        end
    elseif field.type == "json" then
        return "'" .. json_encode(value) .. "'"
    elseif field.type == "bool" then
        if value then
            return "1"
        else
            return "0"
        end
    else
        -- integers
        if value == nil then
            return "NULL"
        else 
            return tostring(value)
        end
    end
end

-- TODO
function ValidateDataType(value, field)
    return true
end
