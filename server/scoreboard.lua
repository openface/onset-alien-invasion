-- indexed by player id
local ScoreboardData = {}

function UpdateScoreboardData(player)
  local _send = {}
  for _,v in ipairs(GetAllPlayers()) do
    -- determine playtime
    local joined = 0
    if ScoreboardData[v]['joined'] == nil then 
      joined = GetTimeSeconds() 
    else 
      joined = GetTimeSeconds() - ScoreboardData[v]['joined']
    end

    -- key by index to avoid sparse array issue with json_encode
    table.insert(_send, {
      ['name'] = GetPlayerName(v),
      ['player_kills'] = ScoreboardData[v]['player_kills'],
      ['alien_kills'] = ScoreboardData[v]['alien_kills'],
      ['boss_kills'] = ScoreboardData[v]['boss_kills'],
      ['parts_collected'] = ScoreboardData[v]['parts_collected'],
      ['deaths'] = ScoreboardData[v]['deaths'],
      ['joined'] = joined,
      ['ping'] = GetPlayerPing(v)
    })
  end
  print(json_encode(_send))
  CallRemoteEvent(player, 'OnGetScoreboardData', json_encode(_send))
end
AddRemoteEvent('UpdateScoreboardData', UpdateScoreboardData)

AddEvent('OnPlayerJoin', function(player)
  if ScoreboardData[player] == nil then
    local _new = {
      ['player_kills'] = 0,
      ['alien_kills'] = 0,
      ['boss_kills'] = 0,
      ['parts_collected'] = 0,
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
