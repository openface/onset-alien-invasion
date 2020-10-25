-- indexed by player id
local ScoreboardData = {}

function UpdateScoreboardData(player)
  local _send = {}
  for _,ply in pairs(GetAllPlayers()) do

    -- determine playtime
    local joined = 0
    if ScoreboardData[ply]['joined'] == nil then 
      joined = GetTimeSeconds() 
    else 
      joined = GetTimeSeconds() - ScoreboardData[ply]['joined']
    end

    -- key by index to avoid sparse array issue with json_encode
    table.insert(_send, {
      ['name'] = GetPlayerName(ply),
      ['player_kills'] = ScoreboardData[ply]['player_kills'],
      ['alien_kills'] = ScoreboardData[ply]['alien_kills'],
      ['boss_kills'] = ScoreboardData[ply]['boss_kills'],
      ['parts_collected'] = ScoreboardData[ply]['parts_collected'],
      ['loot_collected'] = ScoreboardData[ply]['loot_collected'],
      ['deaths'] = ScoreboardData[ply]['deaths'],
      ['joined'] = joined,
      ['ping'] = GetPlayerPing(ply)
    })
  end
  --log.debug(json_encode(_send))
  CallRemoteEvent(player, 'OnGetScoreboardData', json_encode(_send))
end
AddRemoteEvent('UpdateScoreboardData', UpdateScoreboardData)

AddEvent('OnPlayerJoin', function(player)
  if ScoreboardData[player] == nil then
    ScoreboardData[player] = {
      ['player_kills'] = 0,
      ['alien_kills'] = 0,
      ['boss_kills'] = 0,
      ['parts_collected'] = 0,
      ['loot_collected'] = 0,
      ['deaths'] = 0,
      ['joined'] = GetTimeSeconds()
    }
  end
end)

AddEvent('OnPlayerQuit', function(player)
  if ScoreboardData[player] ~= nil then
    ScoreboardData[player] = nil
  end
end)

-- increment stats from elsewhere
function BumpPlayerStat(player, stat)
  if ScoreboardData[player] ~= nil then
    ScoreboardData[player][stat] = ScoreboardData[player][stat] + 1
  end
end
AddFunctionExport("BumpPlayerStat", BumpPlayerStat)
