local Config = require("packages/" .. GetPackageName() .. "/config")

-- global Log
log = require("packages/" .. GetPackageName() .. "/server/vendor/log")

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

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function IsAdmin(player)
    steam_id = GetPlayerSteamId(player)
    for _,id in ipairs(Config.admin_steam_ids) do
        if id == steam_id then
            return true
        end
    end
    return false
end