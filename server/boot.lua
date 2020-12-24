-- add game package to lua path
package.path = package.path .. ";" .. "./packages/" .. GetPackageName() .. "/?.lua"

-- global Config
Config = require("config")

-- global Log
log = require("server.util.log")
if Config.log_level ~= nil then
    log.level = Config.log_level
end

-- generate randomness
math.randomseed(os.time())


