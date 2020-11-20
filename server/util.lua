-- add game package to lua path
package.path = package.path .. ";" .. "./packages/" .. GetPackageName() .. "/?.lua"

-- global Config
Config = require("config")

-- global Log
log = require("server.vendor.log")
if Config.log_level ~= nil then
    log.level = Config.log_level
end

-- generate randomness
math.randomseed(os.time())

function randomPointInCircle(x, y, radius)
    local randX, randY
    repeat
        randX, randY = math.random(-radius, radius), math.random(-radius, radius)
    until (((-randX) ^ 2) + ((-randY) ^ 2)) ^ 0.5 <= radius
    return x + randX, y + randY
end

-- random sample of table
function getRandomSample(tab, amount)
    local shuffled = {}
    for i,pos in ipairs(tab) do
        local p = math.random(1, #shuffled+1)
        table.insert(shuffled, p, pos)
    end
    return { table.unpack(shuffled, 1, amount) }
end

function getTableKeys(tab)
    local keyset = {}
    for k, v in pairs(tab) do
        keyset[#keyset + 1] = k
    end
    return keyset
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

