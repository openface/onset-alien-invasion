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

function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
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