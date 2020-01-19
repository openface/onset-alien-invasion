ScoreboardData = {}

function Scoreboard_RequestUpdate(player)
  local _send = {}
  for _, v in ipairs(GetAllPlayers()) do
    local kills = ScoreboardData[v]['kills']
    if kills == nil then kills = 0 end

    local deaths = ScoreboardData[v]['deaths']
    if deaths == nil then deaths = 0 end

    local joined = 0
    if ScoreboardData[v]['joined'] == nil then 
      joined = GetTimeSeconds() 
    else 
      joined = GetTimeSeconds() - ScoreboardData[v]['joined']
    end

    _send[v] = {
      ['name'] = GetPlayerName(v),
      ['kills'] = kills,
      ['deaths'] = deaths,
      ['joined'] = joined,
      ['ping'] = GetPlayerPing(v)
    }
  end

  CallRemoteEvent(player, 'OnServerScoreboardUpdate', json_encode(_send))
end
AddRemoteEvent('RequestScoreboardUpdate', Scoreboard_RequestUpdate)

function Scoreboard_UpdateAllClients()
  for _, v in pairs(GetAllPlayers()) do
    if v ~= nil then
      Scoreboard_RequestUpdate(v)
    end
  end
end

AddEvent('OnPlayerJoin', function(player)
  if ScoreboardData[player] == nil then
    local _new = {
      ['kills'] = 0,
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
      Scoreboard_UpdateAllClients()
    end
  end
end)

AddEvent('OnPlayerDeath', function(player, killer)
  -- Player
  if ScoreboardData[player] ~= nil then
    ScoreboardData[player]['deaths'] = ScoreboardData[player]['deaths'] + 1
  end

  -- Killer
  if (ScoreboardData[killer] ~= nil and killer ~= player) then
    ScoreboardData[killer]['kills'] = ScoreboardData[killer]['kills'] + 1
  end

  Scoreboard_UpdateAllClients()
end)