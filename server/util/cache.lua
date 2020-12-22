-- Cache design originally lifted from / inspired by AlexMog

Cache = {}
Cache.__index = Cache

local caches = {}

AddEvent("OnPackageStart", function()
    CreateTimer(function()
        for k, v in pairs(caches) do
            v:clearExpiredData()
        end
    end, 1000)
end)

function Cache:new(timeout)
    local cache = {}
    setmetatable(cache, Cache)
    cache._data = {}
    cache._timeout = timeout
    caches[cache] = cache
    return cache
end

function Cache:get(key)
    local item = self._data[key]
    if item then
        item.lastAccess = os.time()
    else
        return nil
    end
    return item.value
end

function Cache:put(key, value)
    if value == nil then
        print("Cache value cannot be nil.")
        return false
    end
    self._data[key] = {
        lastAccess = os.time(),
        value = value
    }
    return true
end

function Cache:remove(key)
    self._data[key] = nil
end

function Cache:clearExpiredData()
    local time = os.time()
    for k,v in pairs(self._data) do
        if v.lastAccess < time - self._timeout then
            log.trace("remove cache "..k)
            self:remove(k)
        end
    end
end
