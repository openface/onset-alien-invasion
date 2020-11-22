-- global 
DB = nil

AddEvent("OnPackageStart", function()

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
end)

AddEvent("OnPackageStop", function()
	mariadb_close(DB)
end)

AddEvent("OnQueryError", function(errorid, error_str, query_str, handle_id)
    log.error("DATABASE ERROR: " .. error_str)
end)
