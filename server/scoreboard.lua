local ScoreboardData = {}

function Scoreboard_RequestUpdate(player)
  local _send = {}
  for _, v in ipairs(GetAllPlayers()) do
    local kills = ScoreboardData[v]['kills'] or 0
    local alien_kills = ScoreboardData[v]['alien_kills'] or 0
    local deaths = ScoreboardData[v]['deaths'] or 0

    local joined = 0
    if ScoreboardData[v]['joined'] == nil then 
      joined = GetTimeSeconds() 
    else 
      joined = GetTimeSeconds() - ScoreboardData[v]['joined']
    end

    _send[v] = {
      ['name'] = GetPlayerName(v),
      ['kills'] = kills,
      ['alien_kills'] = alien_kills,
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
      ['alien_kills'] = 0,
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

  if ScoreboardData[player] ~= nil then
    ScoreboardData[player]['deaths'] = ScoreboardData[player]['deaths'] + 1
  end

  -- killed by player
  if (ScoreboardData[killer] ~= nil and killer ~= player) then
    ScoreboardData[killer]['kills'] = ScoreboardData[killer]['kills'] + 1
  end

  Scoreboard_UpdateAllClients()
end)

AddEvent("OnNPCDeath", function(npc, killer)
    if killer == 0 or killer == nil then return end
    if GetNPCPropertyValue(npc, 'type') ~= 'alien' then return end
    
    -- player kills alien
    if ScoreboardData[killer] ~= nil then
      ScoreboardData[killer]['alien_kills'] = ScoreboardData[killer]['alien_kills'] + 1
    end
end)