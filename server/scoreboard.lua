-- indexed by player, but the scoreboard indexed by index
local ScoreboardData = {}

function RequestScoreboardUpdate(player)
  local _send = {}
  for index,v in ipairs(GetAllPlayers()) do
    -- determine playtime
    local joined = 0
    if ScoreboardData[v]['joined'] == nil then 
      joined = GetTimeSeconds() 
    else 
      joined = GetTimeSeconds() - ScoreboardData[v]['joined']
    end

    -- key by index to avoid sparse array issue with json_encode
    _send[index] = {
      ['name'] = GetPlayerName(v),
      ['kills'] = ScoreboardData[v]['kills'],
      ['alien_kills'] = ScoreboardData[v]['alien_kills'],
      ['parts_found'] = ScoreboardData[v]['parts_found'],
      ['parts_returned'] = ScoreboardData[v]['parts_returned'],
      ['deaths'] = ScoreboardData[v]['deaths'],
      ['joined'] = joined,
      ['ping'] = GetPlayerPing(v)
    }
  end
  print(json_encode(_send))
  CallRemoteEvent(player, 'OnServerScoreboardUpdate', json_encode(_send))
end
AddRemoteEvent('RequestScoreboardUpdate', RequestScoreboardUpdate)

AddEvent('OnPlayerJoin', function(player)
  if ScoreboardData[player] == nil then
    local _new = {
      ['kills'] = 0,
      ['alien_kills'] = 0,
      ['parts_found'] = 0,
      ['parts_returned'] = 0,
      ['deaths'] = 0,
      ['joined'] = GetTimeSeconds()
    }

    ScoreboardData[player] = _new
  end
end)

AddEvent('OnPlayerQuit', function(player)
  if ScoreboardData[player] ~= nil then
    local _index = 0
    for _i, v in pairs(ScoreboardData) do
      if v == player then
        _index = _i
      end
    end

    if _index ~= 0 then
      table.remove(ScoreboardData, _index)
    end
  end
end)

-- increment stats from elsewhere
function BumpPlayerStat(player, stat)
  if ScoreboardData[player] ~= nil then
    ScoreboardData[player][stat] = ScoreboardData[player][stat] + 1
  end
end
AddFunctionExport("BumpPlayerStat", BumpPlayerStat)

-- debug helper
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